import 'package:flutter/material.dart';
import 'package:planthub/screens/explore.dart';
import 'package:planthub/screens/cart.dart';
import 'package:planthub/screens/bookmark.dart';
import 'package:planthub/screens/homepage.dart';


class Settings extends StatelessWidget{
  const Settings ({super.key});

  @override
  Widget build(BuildContext context) {
  return DefaultTabController(
      length: 2, 
      child: Scaffold(
        backgroundColor: Colors.green[100],
        appBar: AppBar(
          title: const Text('Settings'),
          backgroundColor: Colors.green[300],
          
          bottom: const TabBar(
            tabs: [
              Tab(text: 'App'),
              Tab(text: 'Profile'), 
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            AppTab(),
            ProfileTab(),
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
        currentIndex: 4,
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Homepage()));
              break;
            case 1:
              Navigator.push(context, MaterialPageRoute(builder: (context) => Explore()));
              break;
            case 2:
              Navigator.push(context, MaterialPageRoute(builder: (context) => Cart()));
              break;
            case 3:
              Navigator.push(context, MaterialPageRoute(builder: (context) => Bookmark()));
              break;
            case 4:
              Navigator.push(context, MaterialPageRoute(builder: (context) => const Settings()));
              break;
          }
        },
        backgroundColor: Colors.white,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey[600],
      ),
      ),
    );
  } 
}

class AppTab extends StatelessWidget {
  const AppTab ({super.key});

  @override
  Widget build(BuildContext context){
    return Scaffold();
  }
}

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context){
    return Scaffold();
  }
}  