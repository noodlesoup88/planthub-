import 'package:flutter/material.dart';
import '../models/plant_model.dart';
import '../models/user_model.dart';
import '../services/sales_service.dart';
import '../services/auth_service.dart';
import '../services/cart_service.dart';
import '../services/bookmark_service.dart';

class PlantDetail extends StatefulWidget {
  final PlantModel plant;
  
  const PlantDetail({super.key, required this.plant});

  @override
  State<PlantDetail> createState() => _PlantDetailState();
}

class _PlantDetailState extends State<PlantDetail> {
  final SalesService _salesService = SalesService();
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  Future<void> _purchasePlant() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Get current user
      UserModel? currentUser = await _authService.getCurrentUser();
      if (currentUser == null) {
        _showMessage('Please log in to purchase plants');
        return;
      }

      // Record the sale
      bool success = await _salesService.recordSale(
        plant: widget.plant,
        buyer: currentUser,
      );

      if (success) {
        _showMessage('Plant purchased successfully!');
        Navigator.pop(context);
      } else {
        _showMessage('Failed to complete purchase');
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.plant.name),
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Plant image
            SizedBox(
              width: double.infinity,
              height: 250,
              child: Image.network(
                widget.plant.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[300],
                    child: const Icon(
                      Icons.local_florist,
                      size: 100,
                      color: Colors.grey,
                    ),
                  );
                },
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Plant name and price
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        widget.plant.name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '\$${widget.plant.price.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Category
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.green[100],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      widget.plant.category,
                      style: TextStyle(
                        color: Colors.green[800],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Seller info
                  const Text(
                    'Seller Information',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Card(
                    child: ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: Colors.green,
                        child: Icon(Icons.person, color: Colors.white),
                      ),
                      title: Text(widget.plant.farmerName),
                      subtitle: Text(widget.plant.location),
                    ),
                  ),
                  
                  const SizedBox(height: 16),

                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            UserModel? currentUser = await _authService.getCurrentUser();
                            if (currentUser != null) {
                              bool success = await CartService().addToCart(
                                userId: currentUser.uid,
                                plant: widget.plant,
                              );
                              _showMessage(success ? 'Added to cart!' : 'Failed to add to cart');
                            }
                          },
                          icon: const Icon(Icons.shopping_cart),
                          label: const Text('Add to Cart'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            UserModel? currentUser = await _authService.getCurrentUser();
                            if (currentUser != null) {
                              bool success = await BookmarkService().addBookmark(
                                userId: currentUser.uid,
                                plant: widget.plant,
                              );
                              _showMessage(success ? 'Bookmarked!' : 'Failed to bookmark');
                            }
                          },
                          icon: const Icon(Icons.bookmark),
                          label: const Text('Bookmark'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),
                  
                  // Purchase button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _purchasePlant,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              'Purchase Now',
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
        ),
      ),
    );
  }
}
