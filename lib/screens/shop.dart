import 'package:flutter/material.dart';
import '../services/plant_service.dart';
import '../models/plant_model.dart';

class Shop extends StatefulWidget {
  const Shop({super.key});

  @override
  State<Shop> createState() => _ShopState();
}

class _ShopState extends State<Shop> {
  final PlantService _plantService = PlantService();
  List<PlantModel> _plants = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPlants();
  }

  Future<void> _loadPlants() async {
    try {
      setState(() => _isLoading = true);
      _plants = await _plantService.getAllPlants().first;
      setState(() => _isLoading = false);
    } catch (e) {
      print('Error loading plants: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shop Plants'),
        backgroundColor: Colors.green,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _plants.isEmpty
              ? const Center(child: Text('No plants available'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _plants.length,
                  itemBuilder: (context, index) {
                    final plant = _plants[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            // Plant image
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(8),
                                image: plant.imageUrl.isNotEmpty
                                    ? DecorationImage(
                                        image: NetworkImage(plant.imageUrl),
                                        fit: BoxFit.cover,
                                      )
                                    : null,
                              ),
                              child: plant.imageUrl.isEmpty
                                  ? const Icon(
                                      Icons.local_florist,
                                      size: 40,
                                      color: Colors.green,
                                    )
                                  : null,
                            ),
                            const SizedBox(width: 16),
                            // Plant details
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    plant.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Text(
                                    '${plant.price.toStringAsFixed(2)} KES',
                                    style: const TextStyle(
                                      color: Colors.green,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    plant.category,
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}                                'Category: ${plant.category}',
                                style: TextStyle(color: Colors.grey.shade600),
                              ),
                              Text(
                                'Price: \$${plant.price.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Edit and delete buttons
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => _editPlant(index),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deletePlant(index),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        onPressed: _showAddPlantDialog,
        child: const Icon(Icons.add),
      ),
    );
  }

  // Show dialog to add a new plant
  void _showAddPlantDialog() {
    final nameController = TextEditingController();
    final categoryController = TextEditingController();
    final priceController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Plant'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Image picker would go here in a real app
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.add_photo_alternate,
                  size: 40,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              const Text('Tap to add image'),
              const SizedBox(height: 16),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Plant Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: categoryController,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: priceController,
                decoration: const InputDecoration(
                  labelText: 'Price (\$)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
            ),
            onPressed: () {
              // Validate and add plant
              if (nameController.text.isNotEmpty &&
                  categoryController.text.isNotEmpty &&
                  priceController.text.isNotEmpty) {
                setState(() {
                  plants.add(Plant(
                    name: nameController.text,
                    category: categoryController.text,
                    price: double.tryParse(priceController.text) ?? 0.0,
                    imageUrl: 'https://placeholder.svg?height=100&width=100',
                  ));
                });
                Navigator.pop(context);
              }
            },
            child: const Text('Add Plant'),
          ),
        ],
      ),
    );
  }

  // Edit existing plant
  void _editPlant(int index) {
    final plant = plants[index];
    final nameController = TextEditingController(text: plant.name);
    final categoryController = TextEditingController(text: plant.category);
    final priceController = TextEditingController(text: plant.price.toString());
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Plant'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Image picker would go here in a real app
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.add_photo_alternate,
                  size: 40,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              const Text('Tap to change image'),
              const SizedBox(height: 16),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Plant Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: categoryController,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: priceController,
                decoration: const InputDecoration(
                  labelText: 'Price (\$)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
            ),
            onPressed: () {
              // Validate and update plant
              if (nameController.text.isNotEmpty &&
                  categoryController.text.isNotEmpty &&
                  priceController.text.isNotEmpty) {
                setState(() {
                  plants[index] = Plant(
                    name: nameController.text,
                    category: categoryController.text,
                    price: double.tryParse(priceController.text) ?? 0.0,
                    imageUrl: plant.imageUrl,
                  );
                });
                Navigator.pop(context);
              }
            },
            child: const Text('Update Plant'),
          ),
        ],
      ),
    );
  }

  // Delete plant
  void _deletePlant(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Plant'),
        content: const Text('Are you sure you want to delete this plant?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            onPressed: () {
              setState(() {
                plants.removeAt(index);
              });
              Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
