import 'package:flutter/material.dart';
import 'collector_bin.dart'; // Updated to point to CollectorBinPage
import 'package:cloud_firestore/cloud_firestore.dart'; // Firestore

class CollectorLoginPage extends StatefulWidget {
  @override
  _CollectorLoginPageState createState() => _CollectorLoginPageState();
}

class _CollectorLoginPageState extends State<CollectorLoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _keepLoggedIn = false;

  void _login() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    try {
      final querySnapshot =
          await FirebaseFirestore.instance
              .collection('collectors')
              .where('username', isEqualTo: username)
              .where('password', isEqualTo: password)
              .get();

      if (querySnapshot.docs.isNotEmpty) {
        // Login success - Navigate to CollectorBinPage
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => CollectorBinPage()),
        );
      } else {
        _showErrorDialog('Invalid username or password');
      }
    } catch (e) {
      _showErrorDialog('Error logging in. Please try again.');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Login Failed'),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('OK'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Login",
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Username",
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Password",
                suffixIcon: Icon(Icons.visibility_off),
              ),
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Checkbox(
                  value: _keepLoggedIn,
                  onChanged: (bool? value) {
                    setState(() {
                      _keepLoggedIn = value ?? false;
                    });
                  },
                ),
                Text("Keep me logged in"),
              ],
            ),
            SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _login,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                child: Text(
                  "Login",
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
