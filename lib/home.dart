import 'package:flutter/material.dart';
import 'login.dart'; // Import LoginPage for Admin
import 'userlogin.dart'; // Import UserLoginPage for User
import 'collectorlogin.dart'; // Import CollectorLoginPage for Collector

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('SmartBin')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLoginButton(context, 'Admin Login', Colors.blue, () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LoginPage(),
                  ), // Navigate to Admin LoginPage
                );
              }),
              SizedBox(height: 16),
              _buildLoginButton(context, 'User Login', Colors.green, () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UserLoginPage(),
                  ), // Navigate to User LoginPage
                );
              }),
              SizedBox(height: 16),
              _buildLoginButton(context, 'Collector Login', Colors.orange, () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CollectorLoginPage(),
                  ), // Navigate to Collector LoginPage
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoginButton(
    BuildContext context,
    String title,
    Color color,
    VoidCallback onTap,
  ) {
    return SizedBox(
      width: double.infinity,
      child: Card(
        color: color, // Button background color
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
