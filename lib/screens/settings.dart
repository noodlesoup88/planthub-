import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:planthub/models/user_model.dart';
import 'package:planthub/screens/explore.dart';
import 'package:planthub/screens/cart.dart';
import 'package:planthub/screens/bookmark.dart';
import 'package:planthub/screens/homepage.dart';
import 'package:planthub/screens/login_page.dart';

class ThemeManager {
  static bool _isDarkMode = false;
  static bool get isDarkMode => _isDarkMode;
  
  static Future<void> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('isDarkMode') ?? false;
  }
  
  static Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', _isDarkMode);
  }
}

// Extension for your UserModel
extension UserModelFirestore on UserModel {
  static UserModel fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      email: data['email'] ?? '',
      firstName: data['firstName'] ?? '',
      lastName: data['lastName'] ?? '',
      username: data['username'] ?? '',
      phone: data['phone'] ?? '',
      userType: data['userType'] == 'farmer' ? UserType.farmer : UserType.client,
    );
  }
}

class Settings extends StatelessWidget {
  const Settings({super.key});

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

class AppTab extends StatefulWidget {
  const AppTab({super.key});

  @override
  State<AppTab> createState() => _AppTabState();
}

class _AppTabState extends State<AppTab> {
  bool darkMode = false;
  bool notifications = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  _loadSettings() async {
    await ThemeManager.loadTheme();
    setState(() {
      darkMode = ThemeManager.isDarkMode;
    });
  }

  void _showFAQsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Frequently Asked Questions'),
          content: const SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Q: How do I care for my plants?', style: TextStyle(fontWeight: FontWeight.bold)),
                Text('A: Water regularly, provide adequate sunlight, and use good soil.\n'),
                Text('Q: How often should I water my plants?', style: TextStyle(fontWeight: FontWeight.bold)),
                Text('A: It depends on the plant type. Most plants need water 2-3 times per week.\n'),
                Text('Q: What if my plant leaves are turning yellow?', style: TextStyle(fontWeight: FontWeight.bold)),
                Text('A: Yellow leaves usually indicate overwatering or poor drainage.\n'),
                Text('Q: How do I contact support?', style: TextStyle(fontWeight: FontWeight.bold)),
                Text('A: You can reach us through the app or email support@planthub.com'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _showAboutUsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('About PlantHub'),
          content: const SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Welcome to PlantHub!', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                SizedBox(height: 10),
                Text('PlantHub is your one-stop destination for all things plants. We help you discover, care for, and grow beautiful plants in your home and garden.'),
                SizedBox(height: 10),
                Text('Our Mission:', style: TextStyle(fontWeight: FontWeight.bold)),
                Text('To make plant care accessible and enjoyable for everyone.'),
                SizedBox(height: 10),
                Text('Version: 1.0.0', style: TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: darkMode ? Colors.grey[900] : Colors.green[100],
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            leading: Icon(
              Icons.help_outline,
              color: darkMode ? Colors.white : Colors.black,
            ),
            title: Text(
              'FAQs',
              style: TextStyle(color: darkMode ? Colors.white : Colors.black),
            ),
            subtitle: Text(
              'Common questions and answers',
              style: TextStyle(color: darkMode ? Colors.grey[300] : Colors.grey[600]),
            ),
            onTap: _showFAQsDialog,
          ),
          const Divider(),
          ListTile(
            leading: Icon(
              Icons.info_outline,
              color: darkMode ? Colors.white : Colors.black,
            ),
            title: Text(
              'About Us',
              style: TextStyle(color: darkMode ? Colors.white : Colors.black),
            ),
            subtitle: Text(
              'Learn more about PlantHub',
              style: TextStyle(color: darkMode ? Colors.grey[300] : Colors.grey[600]),
            ),
            onTap: _showAboutUsDialog,
          ),
          const Divider(),
          SwitchListTile(
            title: Text(
              'Dark Mode',
              style: TextStyle(color: darkMode ? Colors.white : Colors.black),
            ),
            secondary: Icon(
              Icons.dark_mode,
              color: darkMode ? Colors.white : Colors.black,
            ),
            value: darkMode,
            onChanged: (bool value) async {
              await ThemeManager.toggleTheme();
              setState(() {
                darkMode = value;
              });
            },
          ),
          const Divider(),
          SwitchListTile(
            title: Text(
              'Notifications',
              style: TextStyle(color: darkMode ? Colors.white : Colors.black),
            ),
            secondary: Icon(
              Icons.notifications,
              color: darkMode ? Colors.white : Colors.black,
            ),
            value: notifications,
            onChanged: (bool value) {
              setState(() {
                notifications = value;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Notification settings will be implemented soon!'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: Icon(
              Icons.privacy_tip_outlined,
              color: darkMode ? Colors.white : Colors.black,
            ),
            title: Text(
              'Privacy Policy',
              style: TextStyle(color: darkMode ? Colors.white : Colors.black),
            ),
            subtitle: Text(
              'View our privacy policy',
              style: TextStyle(color: darkMode ? Colors.grey[300] : Colors.grey[600]),
            ),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Privacy Policy will be available soon!'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  UserModel? currentUser;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        
        if (doc.exists) {
          setState(() {
            currentUser = UserModelFirestore.fromFirestore(doc);
            isLoading = false;
          });
        } else {
          setState(() {
            isLoading = false;
          });
        }
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading user data: $e')),
      );
    }
  }

  void _showEditProfileDialog() {
    if (currentUser == null) return;

    final emailController = TextEditingController(text: currentUser!.email);
    final firstNameController = TextEditingController(text: currentUser!.firstName);
    final lastNameController = TextEditingController(text: currentUser!.lastName);
    final phoneController = TextEditingController(text: currentUser!.phone);
    final usernameController = TextEditingController(text: currentUser!.username);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Profile'),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: firstNameController,
                    decoration: const InputDecoration(
                      labelText: 'First Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: lastNameController,
                    decoration: const InputDecoration(
                      labelText: 'Last Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: phoneController,
                    decoration: const InputDecoration(
                      labelText: 'Phone',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: usernameController,
                    decoration: const InputDecoration(
                      labelText: 'Username',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  final user = FirebaseAuth.instance.currentUser;
                  if (user != null) {
                    // Update email in Firebase Auth if changed
                    if (emailController.text != currentUser!.email) {
                      await user.updateEmail(emailController.text);
                    }
                    
                    // Update Firestore document
                    await FirebaseFirestore.instance
                        .collection('users')
                        .doc(user.uid)
                        .update({
                      'email': emailController.text,
                      'firstName': firstNameController.text,
                      'lastName': lastNameController.text,
                      'phone': phoneController.text,
                      'username': usernameController.text,
                    });

                    Navigator.of(context).pop();
                    _loadUserData(); // Reload data
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Profile updated successfully!')),
                    );
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error updating profile: $e')),
                  );
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _showChangePasswordDialog() {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Change Password'),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: currentPasswordController,
                    decoration: const InputDecoration(
                      labelText: 'Current Password',
                      border: OutlineInputBorder(),
                    ),
                    obscureText: true,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: newPasswordController,
                    decoration: const InputDecoration(
                      labelText: 'New Password',
                      border: OutlineInputBorder(),
                    ),
                    obscureText: true,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: confirmPasswordController,
                    decoration: const InputDecoration(
                      labelText: 'Confirm New Password',
                      border: OutlineInputBorder(),
                    ),
                    obscureText: true,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (newPasswordController.text != confirmPasswordController.text) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('New passwords do not match!')),
                  );
                  return;
                }

                try {
                  final user = FirebaseAuth.instance.currentUser;
                  if (user != null) {
                    // Re-authenticate user
                    final credential = EmailAuthProvider.credential(
                      email: user.email!,
                      password: currentPasswordController.text,
                    );
                    await user.reauthenticateWithCredential(credential);
                    
                    // Update password
                    await user.updatePassword(newPasswordController.text);
                    
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Password changed successfully!')),
                    );
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error changing password: $e')),
                  );
                }
              },
              child: const Text('Change'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _logout() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Logout'),
          content: const Text('Are you sure you want to log out?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                try {
                  await FirebaseAuth.instance.signOut();
                  Navigator.of(context).pop(); // Close dialog
                  
                  // Navigate to login page - 
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => LoginPage()), 
                    (route) => false,
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error logging out: $e')),
                  );
                }
              },
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (currentUser == null) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('No user data found'),
            Text('Please try logging in again'),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ListTile(
          leading: const Icon(Icons.person),
          title: Text('${currentUser!.firstName} ${currentUser!.lastName}'),
          subtitle: Text(currentUser!.email),
        ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.edit),
          title: const Text('Edit Profile'),
          onTap: _showEditProfileDialog,
        ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.security),
          title: const Text('Change Password'),
          onTap: _showChangePasswordDialog,
        ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.logout),
          title: const Text('Log Out'),
          onTap: _logout,
        ),
      ],
    );
  }
}
