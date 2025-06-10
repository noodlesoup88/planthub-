import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/plant_service.dart';
import '../services/auth_service.dart';
import '../models/plant_model.dart';
import '../models/user_model.dart';

class Store extends StatefulWidget {
  const Store({super.key});

  @override
  State<Store> createState() => _StoreState();
}

class _StoreState extends State<Store> {
  final PlantService _plantService = PlantService();
  final AuthService _authService = AuthService();
  
  List<PlantModel> _myPlants = [];
  UserModel? _currentUser;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
    _loadMyPlants();
  }

  Future<void> _loadCurrentUser() async {
    _currentUser = await _authService.getCurrentUser();
    setState(() {});
  }

  void _loadMyPlants() {
    // Load plants uploaded by current farmer
    _plantService.getAllPlants().listen((plants) {
      if (_currentUser != null) {
        setState(() {
          _myPlants = plants.where((plant) => plant.farmerId == _currentUser!.uid).toList();
        });
      }
    });
  }

  void _showAddPlantDialog() {
    showDialog(
      context: context,
      builder: (context) => AddPlantDialog(
        onPlantAdded: () {
          // Refresh the list when a new plant is added
          _loadMyPlants();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[50],
      appBar: AppBar(
        title: const Text('My Store'),
        backgroundColor: Colors.green[300],
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.green[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Welcome to your store!',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'You have ${_myPlants.length} plants listed',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            const Text(
              'My Plants',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Plants list
            Expanded(
              child: _myPlants.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.local_florist,
                            size: 80,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'No plants yet',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Tap the + button to add your first plant',
                            style: TextStyle(
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: _myPlants.length,
                      itemBuilder: (context, index) {
                        final plant = _myPlants[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                plant.imageUrl,
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    width: 60,
                                    height: 60,
                                    color: Colors.grey[300],
                                    child: const Icon(Icons.local_florist),
                                  );
                                },
                              ),
                            ),
                            title: Text(plant.name),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Category: ${plant.category}'),
                                Text('Location: ${plant.location}'),
                              ],
                            ),
                            trailing: Text(
                              '\$${plant.price.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.green,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddPlantDialog,
        backgroundColor: Colors.green,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

class AddPlantDialog extends StatefulWidget {
  final VoidCallback onPlantAdded;
  
  const AddPlantDialog({super.key, required this.onPlantAdded});

  @override
  State<AddPlantDialog> createState() => _AddPlantDialogState();
}

class _AddPlantDialogState extends State<AddPlantDialog> {
  final PageController _pageController = PageController();
  final PlantService _plantService = PlantService();
  final AuthService _authService = AuthService();
  
  int _currentStep = 0;
  bool _isLoading = false;
  
  // Form data
  String _plantName = '';
  File? _selectedImage;
  String _selectedCategory = 'Flowers';
  double _price = 0.0;
  String _location = '';
  
  final List<String> _categories = ['Flowers', 'Trees', 'Indoor Plants', 'Vegetables'];
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  Future<void> _submitPlant() async {
    if (_plantName.isEmpty || _selectedImage == null || _location.isEmpty || _price <= 0) {
      _showMessage('Please fill all fields');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Get current user
      UserModel? currentUser = await _authService.getCurrentUser();
      if (currentUser == null) {
        _showMessage('User not found');
        return;
      }

      // Upload image
      String? imageUrl = await _plantService.uploadPlantImage(_selectedImage!, _plantName);
      if (imageUrl == null) {
        _showMessage('Failed to upload image');
        return;
      }

      // Create plant model
      PlantModel plant = PlantModel(
        id: '',
        name: _plantName,
        imageUrl: imageUrl,
        category: _selectedCategory,
        price: _price,
        location: _location,
        farmerId: currentUser.uid,
        farmerName: '${currentUser.firstName} ${currentUser.lastName}',
        createdAt: DateTime.now(),
      );

      // Add to Firestore
      bool success = await _plantService.addPlant(plant);
      
      if (success) {
        widget.onPlantAdded();
        Navigator.pop(context);
        _showMessage('Plant added successfully!');
      } else {
        _showMessage('Failed to add plant');
      }
    } catch (e) {
      _showMessage('Error: ${e.toString()}');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _nextStep() {
    if (_currentStep < 4) {
      setState(() {
        _currentStep++;
      });
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: double.infinity,
        height: MediaQuery.of(context).size.height * 0.7,
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Add New Plant',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            
            // Progress indicator
            Container(
              margin: const EdgeInsets.symmetric(vertical: 20),
              child: Row(
                children: List.generate(5, (index) {
                  return Expanded(
                    child: Container(
                      height: 4,
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      decoration: BoxDecoration(
                        color: index <= _currentStep ? Colors.green : Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  );
                }),
              ),
            ),
            
            // Steps
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildNameStep(),
                  _buildImageStep(),
                  _buildCategoryStep(),
                  _buildPriceStep(),
                  _buildLocationStep(),
                ],
              ),
            ),
            
            // Navigation buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (_currentStep > 0)
                  TextButton(
                    onPressed: _previousStep,
                    child: const Text('Back'),
                  )
                else
                  const SizedBox(),
                
                ElevatedButton(
                  onPressed: _isLoading ? null : (_currentStep == 4 ? _submitPlant : _nextStep),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(_currentStep == 4 ? 'Upload Plant' : 'Next'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNameStep() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.local_florist, size: 80, color: Colors.green),
        const SizedBox(height: 20),
        const Text(
          'What\'s the name of your plant?',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        TextField(
          onChanged: (value) => _plantName = value,
          decoration: const InputDecoration(
            labelText: 'Plant Name',
            border: OutlineInputBorder(),
            hintText: 'e.g., Rose Bush',
          ),
        ),
      ],
    );
  }

  Widget _buildImageStep() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Add a photo of your plant',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        GestureDetector(
          onTap: _pickImage,
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(12),
            ),
            child: _selectedImage != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      _selectedImage!,
                      fit: BoxFit.cover,
                    ),
                  )
                : const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.camera_alt, size: 50, color: Colors.grey),
                      SizedBox(height: 10),
                      Text('Tap to select image'),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryStep() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Select a category',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        ..._categories.map((category) {
          return RadioListTile<String>(
            title: Text(category),
            value: category,
            groupValue: _selectedCategory,
            onChanged: (value) {
              setState(() {
                _selectedCategory = value!;
              });
            },
          );
        }).toList(),
      ],
    );
  }

  Widget _buildPriceStep() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.attach_money, size: 80, color: Colors.green),
        const SizedBox(height: 20),
        const Text(
          'Set your price',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        TextField(
          keyboardType: TextInputType.number,
          onChanged: (value) => _price = double.tryParse(value) ?? 0.0,
          decoration: const InputDecoration(
            labelText: 'Price (\$)',
            border: OutlineInputBorder(),
            hintText: '25.00',
            prefixText: '\$ ',
          ),
        ),
      ],
    );
  }

  Widget _buildLocationStep() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.location_on, size: 80, color: Colors.green),
        const SizedBox(height: 20),
        const Text(
          'Where can customers find you?',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        TextField(
          onChanged: (value) => _location = value,
          decoration: const InputDecoration(
            labelText: 'Location',
            border: OutlineInputBorder(),
            hintText: 'e.g., Downtown Garden Center',
          ),
        ),
      ],
    );
  }
}
