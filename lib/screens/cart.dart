import 'package:flutter/material.dart';
import 'package:planthub/screens/homepage.dart';
import 'package:planthub/screens/explore.dart';
import 'package:planthub/screens/bookmark.dart';
import 'package:planthub/screens/settings.dart';
import '../services/cart_service.dart';
import '../services/sales_service.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';
import '../models/plant_model.dart';

class Cart extends StatefulWidget {
  const Cart({super.key});

  @override
  State<Cart> createState() => _CartState();
}

class _CartState extends State<Cart> {
  final CartService _cartService = CartService();
  final SalesService _salesService = SalesService();
  final AuthService _authService = AuthService();
  
  UserModel? currentUser;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    try {
      currentUser = await _authService.getCurrentUser();
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _purchaseAll(List<Map<String, dynamic>> cartItems) async {
    if (currentUser == null) return;

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // Process each item
      for (var item in cartItems) {
        // Create plant model from cart item
        final plant = PlantModel(
          id: item['plantId'],
          name: item['plantName'],
          imageUrl: item['plantImage'],
          category: '', // Not stored in cart, but not needed for sale
          price: item['price'].toDouble(),
          location: '',
          farmerId: item['farmerId'],
          farmerName: item['farmerName'],
          createdAt: DateTime.now(),
        );

        // Record sale
        await _salesService.recordSale(plant: plant, buyer: currentUser!);
      }

      // Clear cart after successful purchase
      await _cartService.clearCart(currentUser!.uid);

      // Close loading dialog
      Navigator.pop(context);

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Purchase successful! Thank you for your order.'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      // Close loading dialog
      Navigator.pop(context);
      
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Purchase failed: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (currentUser == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Cart'),
          backgroundColor: Colors.green[300],
        ),
        body: const Center(
          child: Text('Please log in to view your cart'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cart'),
        backgroundColor: Colors.green[300],
      ),
      backgroundColor: Colors.green[100],
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _cartService.getCartItems(currentUser!.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Your cart is empty',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Add some plants to get started!',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          final cartItems = snapshot.data!;
          final totalPrice = cartItems.fold<double>(
            0,
            (sum, item) => sum + item['price'].toDouble(),
          );

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: cartItems.length,
                  itemBuilder: (context, index) {
                    final item = cartItems[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            item['plantImage'],
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
                        title: Text(item['plantName']),
                        subtitle: Text('By ${item['farmerName']}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '\$${item['price'].toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () async {
                                await _cartService.removeFromCart(item['id']);
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              
              // Purchase section
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total:',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '\$${totalPrice.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () => _purchaseAll(cartItems),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text(
                          'Purchase All',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.explore), label: 'Explore'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: 'Cart'),
          BottomNavigationBarItem(icon: Icon(Icons.bookmark), label: 'Bookmark'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
        ],
        currentIndex: 2,
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const Homepage()));
              break;
            case 1:
              Navigator.push(context, MaterialPageRoute(builder: (context) => const Explore()));
              break;
            case 2:
              Navigator.push(context, MaterialPageRoute(builder: (context) => const Cart()));
              break;
            case 3:
              Navigator.push(context, MaterialPageRoute(builder: (context) => const Bookmark()));
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
