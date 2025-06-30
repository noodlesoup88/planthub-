import 'package:flutter/material.dart';
import 'package:planthub/screens/homepage.dart';
import 'package:planthub/screens/explore.dart';
import 'package:planthub/screens/bookmark.dart';
import 'package:planthub/screens/settings.dart';
import 'dart:async';
import '../services/cart_service.dart';
import '../services/auth_service.dart';
import '../services/sales_service.dart';
import '../models/plant_model.dart';
import '../models/user_model.dart';
import '../screens/plant_detail.dart';

class Cart extends StatefulWidget {
  const Cart({super.key});

  @override
  State<Cart> createState() => _CartState();
}

class _CartState extends State<Cart> {
  final CartService _cartService = CartService();
  final AuthService _authService = AuthService();
  final SalesService _salesService = SalesService();
  
  UserModel? currentUser;
  bool isLoading = true;
  List<Map<String, dynamic>> _cartItems = [];
  StreamSubscription? _cartSubscription;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (mounted) {
      if (currentUser != null) {
        _startListeningToCart();
      }
    }
  }

  @override
  void dispose() {
    _cartSubscription?.cancel();
    super.dispose();
  }

  void _startListeningToCart() {
    _cartSubscription?.cancel(); // Cancel any existing subscription
    _cartSubscription = _cartService.getCartItems(currentUser!.uid).listen(
      (cartItems) {
        if (mounted) {
          setState(() {
            _cartItems = cartItems;
          });
        }
      },
      onError: (error) {
        print('Error listening to cart: $error');
        if (mounted) {
          setState(() {
            _error = error.toString();
          });
        }
      },
    );
  }

  Future<void> _loadCurrentUser() async {
    try {
      currentUser = await _authService.getCurrentUser();
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      print('Error loading user: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _removeFromCart(String cartId) async {
    try {
      // Show confirmation dialog
      final shouldRemove = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Remove from Cart'),
          content: const Text('Are you sure you want to remove this item?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Remove'),
            ),
          ],
        ),
      );

      if (shouldRemove == true) {
        await _cartService.removeFromCart(cartId);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Item removed from cart!')),
        );
      }
    } catch (e) {
      print('Error removing from cart: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error removing item from cart')),
      );
    }
  }

  Future<void> _clearCart() async {
    try {
      // Show confirmation dialog
      final shouldClear = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Clear Cart'),
          content: const Text('Are you sure you want to clear your entire cart?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Clear'),
            ),
          ],
        ),
      );

      if (shouldClear == true) {
        await _cartService.clearCart(currentUser!.uid);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cart cleared!')),
        );
      }
    } catch (e) {
      print('Error clearing cart: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error clearing cart')),
      );
    }
  }

  Future<void> _purchaseItems() async {
    if (_cartItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Your cart is empty!')),
      );
      return;
    }

    try {
      // Calculate total price
      double totalPrice = _cartItems.fold(0.0, (sum, item) => sum + item['price']);

      // Show confirmation dialog
      final shouldPurchase = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Confirm Purchase'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('You are about to purchase:'),
              const SizedBox(height: 8),
              ..._cartItems.map((item) => Text('${item['plantName']} - KES ${item['price']}')).toList(),
              const SizedBox(height: 16),
              Text(
                'Total: KES ${totalPrice.toStringAsFixed(2)}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Purchase'),
            ),
          ],
        ),
      );

      if (shouldPurchase == true) {
        // Record the sale
        final firstItem = _cartItems.first;
        final plant = PlantModel(
          id: firstItem['plantId'],
          name: firstItem['plantName'],
          imageUrl: firstItem['plantImage'],
          category: '',
          price: firstItem['price'].toDouble(),
          location: '',
          farmerId: firstItem['farmerId'],
          farmerName: firstItem['farmerName'],
          createdAt: DateTime.now(),
        );
        
        await _salesService.recordSale(
          plant: plant,
          buyer: currentUser!,
        );

        // Clear the cart
        await _cartService.clearCart(currentUser!.uid);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Purchase successful!')),
        );
      }
    } catch (e) {
      print('Error during purchase: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error during purchase')),
      );
    }
  }

  double _calculateTotal() {
    return _cartItems.fold(0.0, (sum, item) => sum + (item['price'] as num).toDouble());
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
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_forever),
            onPressed: _cartItems.isNotEmpty ? _clearCart : null,
            tooltip: 'Clear Cart',
          ),
        ],
      ),
      backgroundColor: Colors.green[100],
      body: Column(
        children: [
          if (_error != null)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Error loading cart. Please try again later.',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            )
          else
            Expanded(
              child: _cartItems.isEmpty
                  ? const Center(
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
                            'Add some plants to your cart!',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _cartItems.length,
                      itemBuilder: (context, index) {
                        final cartItem = _cartItems[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                cartItem['plantImage'],
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
                            title: Text(cartItem['plantName']),
                            subtitle: Text('By ${cartItem['farmerName']}'),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'KES ${cartItem['price'].toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () => _removeFromCart(cartItem['id']),
                                ),
                              ],
                            ),
                            onTap: () {
                              final plant = PlantModel(
                                id: cartItem['plantId'],
                                name: cartItem['plantName'],
                                imageUrl: cartItem['plantImage'],
                                category: '',
                                price: cartItem['price'].toDouble(),
                                location: '',
                                farmerId: cartItem['farmerId'],
                                farmerName: cartItem['farmerName'],
                                createdAt: DateTime.now(),
                              );
                              
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PlantDetail(plant: plant),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
            ),
          if (_cartItems.isNotEmpty && _error == null)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'KES ${_calculateTotal().toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _purchaseItems,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[300],
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text(
                        'Proceed to Checkout',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ],
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
