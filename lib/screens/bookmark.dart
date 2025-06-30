import 'package:flutter/material.dart';
import 'package:planthub/screens/homepage.dart';
import 'package:planthub/screens/explore.dart';
import 'package:planthub/screens/cart.dart';
import 'package:planthub/screens/settings.dart';
import 'dart:async';
import '../services/bookmark_service.dart';
import '../services/auth_service.dart';
import '../models/plant_model.dart';
import '../models/user_model.dart';
import '../screens/plant_detail.dart';

class Bookmark extends StatefulWidget {
  const Bookmark({super.key});

  @override
  State<Bookmark> createState() => _BookmarkState();
}

class _BookmarkState extends State<Bookmark> {
  final BookmarkService _bookmarkService = BookmarkService();
  final AuthService _authService = AuthService();
  
  UserModel? currentUser;
  bool isLoading = true;
  List<Map<String, dynamic>> _bookmarks = [];
  StreamSubscription? _bookmarkSubscription;
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
        _startListeningToBookmarks();
      }
    }
  }

  @override
  void dispose() {
    _bookmarkSubscription?.cancel();
    super.dispose();
  }

  Future<void> _loadCurrentUser() async {
    try {
      currentUser = await _authService.getCurrentUser();
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading user: $e');
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void _startListeningToBookmarks() {
    _bookmarkSubscription?.cancel(); // Cancel any existing subscription
    _bookmarkSubscription = _bookmarkService.getBookmarks(currentUser!.uid).listen(
      (bookmarks) {
        if (mounted) {
          setState(() {
            _bookmarks = bookmarks;
          });
        }
      },
      onError: (error) {
        print('Error listening to bookmarks: $error');
        if (mounted) {
          setState(() {
            _error = error.toString();
          });
        }
      },
    );
  }

  Future<void> _removeFromBookmarks(String bookmarkId) async {
    try {
      // Show confirmation dialog
      final shouldRemove = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Remove Bookmark'),
          content: const Text('Are you sure you want to remove this bookmark?'),
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
        await _bookmarkService.removeBookmark(bookmarkId);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bookmark removed!')),
        );
      }
    } catch (e) {
      print('Error removing bookmark: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error removing bookmark')),
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
          title: const Text('Bookmarks'),
          backgroundColor: Colors.green[300],
        ),
        body: const Center(
          child: Text('Please log in to view your bookmarks'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bookmarks'),
        backgroundColor: Colors.green[300],
      ),
      backgroundColor: Colors.green[100],
      body: Column(
        children: [
          if (_error != null)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Error loading bookmarks. Please try again later.',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            )
          else
            Expanded(
              child: _bookmarks.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.bookmark_outline, size: 80, color: Colors.grey),
                          SizedBox(height: 16),
                          Text(
                            'No bookmarks yet',
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Save your favorite plants here!',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _bookmarks.length,
                      itemBuilder: (context, index) {
                        final bookmark = _bookmarks[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                bookmark['plantImage'],
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
                            title: Text(bookmark['plantName']),
                            subtitle: Text('By ${bookmark['farmerName']}'),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'KES ${bookmark['price'].toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () => _removeFromBookmarks(bookmark['id']),
                                ),
                              ],
                            ),
                            onTap: () {
                              final plant = PlantModel(
                                id: bookmark['plantId'],
                                name: bookmark['plantName'],
                                imageUrl: bookmark['plantImage'],
                                category: '',
                                price: bookmark['price'].toDouble(),
                                location: '',
                                farmerId: bookmark['farmerId'],
                                farmerName: bookmark['farmerName'],
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
        currentIndex: 3,
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
