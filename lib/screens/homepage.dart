import 'package:flutter/material.dart';
import 'package:planthub/screens/explore.dart';
import 'package:planthub/screens/cart.dart';
import 'package:planthub/screens/bookmark.dart';
import 'package:planthub/screens/settings.dart';
import 'package:planthub/services/auth_service.dart';
import 'package:planthub/models/user_model.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  final AuthService _authService = AuthService();
  
  UserModel? currentUser;
  
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // Method to load current user data
  Future<void> _loadUserData() async {
    try {
      UserModel? user = await _authService.getCurrentUser();
      setState(() {
        currentUser = user;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error loading user data: $e');
    }
  }

  // Navigate to Categories tab 
  void _navigateToCategories() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const Explore(initialTabIndex: 1), 
      ),
    );
  }

  // Discover tab
  void _navigateToDiscover() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const Explore(initialTabIndex: 0), 
      ),
    );
  }

  // plant care tips dialog
  void _showPlantCareTips() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            width: double.infinity,
            height: MediaQuery.of(context).size.height * 0.7,
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Plant Care Tips",
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
                const SizedBox(height: 10),
                const Text(
                  "Guide to Plant Care",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          "1. Watering Basics",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          "Most plants die from overwatering rather than underwatering. Always check the soil moisture before watering. Insert your finger about an inch into the soil - if it feels dry, it's time to water.",
                          style: TextStyle(fontSize: 16),
                        ),
                        SizedBox(height: 20),
                        Text(
                          "2. Light Requirements",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          "Different plants need different amounts of light. Most indoor plants prefer bright, indirect light. Direct sunlight can burn leaves, while too little light can cause leggy growth.",
                          style: TextStyle(fontSize: 16),
                        ),
                        SizedBox(height: 20),
                        Text(
                          "3. Soil & Fertilizer",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          "Use quality potting soil appropriate for your plant type. Most houseplants benefit from fertilizer during the growing season (spring and summer) but need less during winter months.",
                          style: TextStyle(fontSize: 16),
                        ),
                        SizedBox(height: 20),
                        Text(
                          "4. Repotting",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          "Repot plants when they become root-bound (roots circling the pot or growing out of drainage holes). Choose a pot 1-2 inches larger than the current one with good drainage.",
                          style: TextStyle(fontSize: 16),
                        ),
                        SizedBox(height: 20),
                        Text(
                          "5. Common Problems",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          "• Yellow leaves: Often indicates overwatering\n• Brown leaf tips: Usually from low humidity\n• Drooping: Could be under or overwatering\n• Pests: Check undersides of leaves regularly for insects",
                          style: TextStyle(fontSize: 16),
                        ),
                        SizedBox(height: 20),
                        Text(
                          "6. Seasonal Care",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          "Plants grow more in spring and summer. Increase watering and fertilizing during these months. In fall and winter, most plants enter dormancy and need less water and no fertilizer.",
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green[300],
        elevation: 0,
      ),
      backgroundColor: Colors.green[100],
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            decoration: BoxDecoration(
              color: Colors.green[300],
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Welcome back, ",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isLoading 
                    ? 'Loading...' 
                    : currentUser?.username ?? 'User',
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  
                  
                  GestureDetector(
                    onTap: _navigateToDiscover,
                    child: Container(
                      height: 150,
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        image: DecorationImage(
                          image: AssetImage('assets/images/learn.jpg'),
                          fit: BoxFit.cover,
                          colorFilter: ColorFilter.mode(
                            Colors.black.withOpacity(0.5),
                            BlendMode.darken,
                          ),
                        ),
                      ),
                      child: const Center(
                        child: Text(
                          'Check out new plants in the market',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                  
                  
                  GestureDetector(
                    onTap: _showPlantCareTips,
                    child: Container(
                      height: 150,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        image: DecorationImage(
                          image: AssetImage('assets/images/africanguy.jpg'),
                          fit: BoxFit.cover,
                          colorFilter: ColorFilter.mode(
                            Colors.black.withOpacity(0.5),
                            BlendMode.darken,
                          ),
                        ),
                      ),
                      child: const Center(
                        child: Text(
                          'Learn More About Plants',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Categories',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: _navigateToCategories, 
                                child: Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 4),
                                  padding: const EdgeInsets.symmetric(vertical: 20),
                                  decoration: BoxDecoration(
                                    color: Colors.green[50],
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.green[200]!),
                                  ),
                                  child: Column(
                                    children: [
                                      Image.asset(
                                        'assets/images/plant.png', 
                                        width: 40,
                                        height: 40,
                                        errorBuilder: (context, error, stackTrace) {
                                          return const Icon(
                                            Icons.home,
                                            size: 40,
                                            color: Colors.green,
                                          );
                                        },
                                      ),
                                      const SizedBox(height: 8),
                                      const Text(
                                        'Indoor',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.green,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            
                            // Outdoor 
                            Expanded(
                              child: GestureDetector(
                                onTap: _navigateToCategories, 
                                child: Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 4),
                                  padding: const EdgeInsets.symmetric(vertical: 20),
                                  decoration: BoxDecoration(
                                    color: Colors.blue[50],
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.blue[200]!),
                                  ),
                                  child: Column(
                                    children: [
                                      Image.asset(
                                        'assets/images/seedling.png', 
                                        width: 40,
                                        height: 40,
                                        errorBuilder: (context, error, stackTrace) {
                                          return const Icon(
                                            Icons.park,
                                            size: 40,
                                            color: Colors.blue,
                                          );
                                        },
                                      ),
                                      const SizedBox(height: 8),
                                      const Text(
                                        'Outdoor',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.blue,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            
                            // Seedlings 
                            Expanded(
                              child: GestureDetector(
                                onTap: _navigateToCategories, 
                                child: Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 4),
                                  padding: const EdgeInsets.symmetric(vertical: 20),
                                  decoration: BoxDecoration(
                                    color: Colors.orange[50],
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.orange[200]!),
                                  ),
                                  child: Column(
                                    children: [
                                      Image.asset(
                                        'assets/images/watering-plants.png', 
                                        width: 40,
                                        height: 40,
                                        errorBuilder: (context, error, stackTrace) {
                                          return const Icon(
                                            Icons.eco,
                                            size: 40,
                                            color: Colors.orange,
                                          );
                                        },
                                      ),
                                      const SizedBox(height: 8),
                                      const Text(
                                        'Seedlings',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.orange,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),  
                ],
              ),
            ),
          ),
        ],
      ),
      
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.explore), label: 'Explore'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: 'Cart'),
          BottomNavigationBarItem(icon: Icon(Icons.bookmark), label: 'Bookmark'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
        ],
        currentIndex: 0,
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const Homepage()));
              break;
            case 1:
              Navigator.push(context, MaterialPageRoute(builder: (context) => const Explore(initialTabIndex: 0)));
              break;
            case 2:
              Navigator.push(context, MaterialPageRoute(builder: (context) => Cart()));
              break;
            case 3:
              Navigator.push(context, MaterialPageRoute(builder: (context) => Bookmark()));
              break;
            case 4:
              Navigator.push(context, MaterialPageRoute(builder: (context) => Settings()));
              break;
          }
        },
        backgroundColor: Colors.white,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey[600],
      ),    
    );
  }
}
