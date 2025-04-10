import 'package:flutter/material.dart';
import 'bin_tracking.dart';
import 'adduser.dart';
import 'add_collector.dart'; // ✅ Import AddCollectorPage
import 'complaint.dart';

class DashboardPage extends StatelessWidget {
  final String username;

  const DashboardPage({Key? key, required this.username}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Dashboard", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 50),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 20),
              _buildCard(
                context,
                Icons.local_shipping,
                "Track Bin",
                BinTrackingPage(),
              ),
              SizedBox(height: 20),
              _buildCard(context, Icons.person_add, "Add User", AddUserPage()),
              SizedBox(height: 20),
              _buildCard(
                context,
                Icons.report_problem,
                "Complaints",
                ComplaintPage(username: username),
              ),
              SizedBox(height: 20),
              _buildCard(
                context,
                Icons.group_add,
                "Add Collector",
                AddCollectorPage(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard(
    BuildContext context,
    IconData icon,
    String title,
    Widget page,
  ) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, size: 40),
        title: Text(title, style: TextStyle(fontSize: 18)),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => page),
          );
        },
      ),
    );
  }
}
