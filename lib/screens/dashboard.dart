import 'package:flutter/material.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  
  String selectedPeriod = '7 Days';
  
  // Sample data 
  final Map<String, Map<String, dynamic>> salesData = {
    '7 Days': {
      'totalSales': 1250,
      'plantsSold': 25,
      'topPlant': 'Rose Bush',
      'topPlantSales': 8,
    },
    '1 Month': {
      'totalSales': 4800,
      'plantsSold': 96,
      'topPlant': 'Cactus',
      'topPlantSales': 32,
    },
    '6 Months': {
      'totalSales': 28500,
      'plantsSold': 570,
      'topPlant': 'Aloe Vera',
      'topPlantSales': 185,
    },
    '1 Year': {
      'totalSales': 62000,
      'plantsSold': 1240,
      'topPlant': 'Monstera',
      'topPlantSales': 410,
    },
  };

  @override
  Widget build(BuildContext context) {
    
    final currentData = salesData[selectedPeriod]!;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Seller Dashboard'),
        backgroundColor: Colors.green,
      ),
      body: Padding(
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
              child: ListView(
                children: [
                  _buildSaleItem('Rose Bush', '2 days ago', '\$50'),
                  _buildSaleItem('Cactus Collection', '3 days ago', '\$35'),
                  _buildSaleItem('Aloe Vera', '5 days ago', '\$25'),
                  _buildSaleItem('Snake Plant', '6 days ago', '\$30'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to build period selection buttons
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

  // Helper method to build summary items
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

  // Helper method to build sale items
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
