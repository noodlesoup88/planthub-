import 'package:flutter/material.dart';
import 'package:planthub/screens/homepage.dart';
import 'package:planthub/screens/cart.dart';
import 'package:planthub/screens/bookmark.dart';
import 'package:planthub/screens/settings.dart';

// UPDATED: Added optional parameter to start on specific tab
class Explore extends StatefulWidget {
  final int initialTabIndex;
  
  const Explore({super.key, this.initialTabIndex = 0});

  @override
  State<Explore> createState() => _ExploreState();
}

class _ExploreState extends State<Explore> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 3,
      vsync: this,
      initialIndex: widget.initialTabIndex,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[100],
      appBar: AppBar(
        title: const Text('Explore Plants'),
        backgroundColor: Colors.green[300],
        
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Discover'),
            Tab(text: 'Categories'), 
            Tab(text: 'Fresh Picks'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          DiscoverTab(),
          CategoriesTab(),
          FreshPicksTab(),
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
        currentIndex: 1,
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const Homepage()));
              break;
            case 1:
              Navigator.push(context, MaterialPageRoute(builder: (context) => const Explore()));
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

// Recommended plants
class DiscoverTab extends StatelessWidget {
  const DiscoverTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recommended for You',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView(
              children: [
                _buildPlantItem('Rose Plant', '\$25'),
                _buildPlantItem('Cactus', '\$15'),
                _buildPlantItem('Sunflower', '\$20'),
                _buildPlantItem('Tulip', '\$18'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlantItem(String name, String price) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: const Icon(Icons.local_florist, color: Colors.green, size: 40),
        title: Text(name),
        subtitle: const Text('Perfect for your garden'),
        trailing: Text(price, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }
}

// Plant categories
class CategoriesTab extends StatelessWidget {
  const CategoriesTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: GridView.count(
        crossAxisCount: 2, 
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        children: [
          _buildCategoryItem('🌸', 'Flowers'),
          _buildCategoryItem('🌳', 'Trees'),
          _buildCategoryItem('🪴', 'Indoor Plants'),
          _buildCategoryItem('🥬', 'Vegetables'),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(String emoji, String name) {
    return Card(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 40)),
          const SizedBox(height: 8),
          Text(name, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}

// New plants from farmers
class FreshPicksTab extends StatelessWidget {
  const FreshPicksTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Just Posted by Farmers',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView(
              children: [
                _buildFreshItem('Tomato Plants', 'Farmer John', '2 hours ago', '\$12'),
                _buildFreshItem('Mint Herbs', 'Farmer Mary', '4 hours ago', '\$8'),
                _buildFreshItem('Pepper Plants', 'Farmer Bob', '6 hours ago', '\$15'),
                _buildFreshItem('Basil', 'Farmer Sarah', '8 hours ago', '\$10'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFreshItem(String plantName, String farmerName, String timeAgo, String price) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: const Icon(Icons.new_releases, color: Colors.orange, size: 40),
        title: Text(plantName),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('By $farmerName'),
            Text('Posted $timeAgo', style: const TextStyle(fontSize: 12)),
          ],
        ),
        trailing: Text(price, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }
}
