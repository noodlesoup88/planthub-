import 'package:flutter/material.dart';
import 'package:planthub/screens/homepage.dart';
import 'package:planthub/screens/explore.dart';
import 'package:planthub/screens/bookmark.dart';
import 'package:planthub/screens/settings.dart';

class Cart extends StatelessWidget{
  const Cart ({super.key});

  @override
  Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Text('Cart'),
      backgroundColor: Colors.green[300],
      
    ),
  
  backgroundColor: Colors.green[100],

  body: Center(
    child: Text('No new items yet'),
    
    
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
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Homepage()));
              break;
            case 1:
              Navigator.push(context, MaterialPageRoute(builder: (context) => Explore()));
              break;
            case 2:
              Navigator.push(context, MaterialPageRoute(builder: (context) => const Cart()));
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
