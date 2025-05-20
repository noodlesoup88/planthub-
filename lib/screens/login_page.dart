import 'package:flutter/material.dart';
import 'package:planthub/screens/homepage.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[200],
      appBar: AppBar(
        title: const Text('Login Page'),
        backgroundColor: Colors.green[200],
      ),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Sign into your account',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.4),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const TextField(
                    keyboardType: TextInputType.name,
                    decoration: InputDecoration(
                      label: Text("First Name"),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const TextField(
                    keyboardType: TextInputType.name,
                    decoration: InputDecoration(
                      label: Text("Second Name"),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const TextField(
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      label: Text("Email"),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const TextField(
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      label: Text("Phone number"),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const TextField(
                    keyboardType: TextInputType.text,
                    obscureText: true,
                    decoration: InputDecoration(
                      label: Text("Password"),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Homepage()),
                      );
                    },
                    child: const Text('Login'),
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