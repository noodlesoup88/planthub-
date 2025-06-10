import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:planthub/screens/settings.dart' as app_settings;
import 'package:planthub/screens/store.dart';
import 'package:planthub/services/auth_service.dart';
import 'package:planthub/models/user_model.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _authService = AuthService();
  
  String selectedPeriod = '7 Days';
  bool isLoading = true;
  UserModel? currentUser;
  
  // Sales data
  Map<String, Map<String, dynamic>> salesData = {
    '7 Days': {
      'totalSales': 0,
      'plantsSold': 0,
      'topPlant': 'None',
      'topPlantSales': 0,
    },
    '1 Month': {
      'totalSales': 0,
      'plantsSold': 0,
      'topPlant': 'None',
      'topPlantSales': 0,
    },
    '6 Months': {
      'totalSales': 0,
      'plantsSold': 0,
      'topPlant': 'None',
      'topPlantSales': 0,
    },
    '1 Year': {
      'totalSales': 0,
      'plantsSold': 0,
      'topPlant': 'None',
      'topPlantSales': 0,
    },
  };
  
  // Recent sales list
  List<Map<String, dynamic>> recentSales = [];

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }
  
  Future<void> _loadCurrentUser() async {
    try {
      currentUser = await _authService.getCurrentUser();
      if (currentUser != null) {
        _loadSalesData();
      }
    } catch (e) {
      print('Error loading user: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _loadSalesData() async {
    if (currentUser == null) return;
    
    try {
      // Get current date
      final now = DateTime.now();
      
      // Calculate date ranges
      final sevenDaysAgo = now.subtract(const Duration(days: 7));
      final oneMonthAgo = DateTime(now.year, now.month - 1, now.day);
      final sixMonthsAgo = DateTime(now.year, now.month - 6, now.day);
      final oneYearAgo = DateTime(now.year - 1, now.month, now.day);
      
      // Get sales for this farmer
      final salesQuery = await _firestore
          .collection('sales')
          .where('farmerId', isEqualTo: currentUser!.uid)
          .orderBy('saleDate', descending: true)
          .get();
      
      if (salesQuery.docs.isEmpty) {
        setState(() {
          isLoading = false;
        });
        return;
      }
      
      // Process sales data
      final allSales = salesQuery.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'plantId': data['plantId'] ?? '',
          'plantName': data['plantName'] ?? 'Unknown Plant',
          'price': (data['price'] ?? 0).toDouble(),
          'saleDate': (data['saleDate'] as Timestamp).toDate(),
          'buyerName': data['buyerName'] ?? 'Unknown Buyer',
        };
      }).toList();
      
      // Recent sales for display
      recentSales = allSales.take(10).toList();
      
      // Calculate period data
      _calculatePeriodData(allSales, '7 Days', sevenDaysAgo);
      _calculatePeriodData(allSales, '1 Month', oneMonthAgo);
      _calculatePeriodData(allSales, '6 Months', sixMonthsAgo);
      _calculatePeriodData(allSales, '1 Year', oneYearAgo);
      
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      print('Error loading sales data: $e');
      setState(() {
        isLoading = false;
      });
    }
  }
  
  void _calculatePeriodData(List<Map<String, dynamic>> allSales, String period, DateTime startDate) {
    // Filter sales for this period
    final periodSales = allSales.where((sale) => sale['saleDate'].isAfter(startDate)).toList();
    
    if (periodSales.isEmpty) {
      return; // No sales in this period
    }
    
    // Calculate total sales
    double totalSales = 0;
    for (var sale in periodSales) {
      totalSales += sale['price'];
    }
    
    // Count plants sold
    final plantsSold = periodSales.length;
    
    // Find top selling plant
    final plantCounts = <String, int>{};
    for (var sale in periodSales) {
      final plantName = sale['plantName'];
      plantCounts[plantName] = (plantCounts[plantName] ?? 0) + 1;
    }
    
    String topPlant = 'None';
    int topPlantSales = 0;
    
    plantCounts.forEach((plant, count) {
      if (count > topPlantSales) {
        topPlant = plant;
        topPlantSales = count;
      }
    });
    
    // Update sales data
    salesData[period] = {
      'totalSales': totalSales.round(),
      'plantsSold': plantsSold,
      'topPlant': topPlant,
      'topPlantSales': topPlantSales,
    };
  }

  @override
  Widget build(BuildContext context) {
    final currentData = salesData[selectedPeriod]!;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Seller Dashboard'),
        backgroundColor: Colors.green,
      ),
      body: isLoading 
        ? const Center(child: CircularProgressIndicator())
        : Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // time selector
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Select Time Period:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _buildPeriodButton('7 Days'),
                              _buildPeriodButton('1 Month'),
                              _buildPeriodButton('6 Months'),
                              _buildPeriodButton('1 Year'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Sales summary
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Sales Summary ($selectedPeriod)',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Divider(),
                        _buildSummaryItem(
                          'Total Sales', 
                          '\$${currentData['totalSales']}',
                          Icons.attach_money,
                          Colors.green,
                        ),
                        _buildSummaryItem(
                          'Plants Sold', 
                          '${currentData['plantsSold']} units',
                          Icons.local_florist,
                          Colors.orange,
                        ),
                        _buildSummaryItem(
                          'Top Selling Plant', 
                          '${currentData['topPlant']} (${currentData['topPlantSales']} sold)',
                          Icons.star,
                          Colors.amber,
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Recent sales
                const Text(
                  'Recent Sales',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: recentSales.isEmpty
                    ? const Center(
                        child: Text(
                          'No sales yet',
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        itemCount: recentSales.length,
                        itemBuilder: (context, index) {
                          final sale = recentSales[index];
                          final saleDate = sale['saleDate'] as DateTime;
                          final daysAgo = DateTime.now().difference(saleDate).inDays;
                          final timeAgo = daysAgo == 0 
                              ? 'Today' 
                              : daysAgo == 1 
                                  ? 'Yesterday' 
                                  : '$daysAgo days ago';
                          
                          return _buildSaleItem(
                            sale['plantName'], 
                            timeAgo, 
                            '\$${sale['price'].toStringAsFixed(2)}'
                          );
                        },
                      ),
                ),
              ],
            ),
          ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.shopify), label: 'Store'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
        ],
        currentIndex: 0,
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const Dashboard()));
              break;
            case 1:
              Navigator.push(context, MaterialPageRoute(builder: (context) => const Store()));
              break;
            case 2:
              Navigator.push(context, MaterialPageRoute(builder: (context) => const app_settings.Settings()));
              break;
          }
        },
        backgroundColor: Colors.white,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey[600],
      ),
    );
  }

  Widget _buildPeriodButton(String period) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: selectedPeriod == period ? Colors.green : Colors.grey.shade200,
          foregroundColor: selectedPeriod == period ? Colors.white : Colors.black,
        ),
        onPressed: () {
          setState(() {
            selectedPeriod = period;
          });
        },
        child: Text(period),
      ),
    );
  }

  Widget _buildSummaryItem(String title, String value, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: Colors.grey)),
              Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSaleItem(String plantName, String time, String price) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: Colors.green,
          child: Icon(Icons.local_florist, color: Colors.white),
        ),
        title: Text(plantName),
        subtitle: Text(time),
        trailing: Text(
          price,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
      ),
    );  
  }
}
