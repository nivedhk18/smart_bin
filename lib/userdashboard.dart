import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'userlogin.dart'; // Importing login page for navigation

class UserDashboard extends StatefulWidget {
  final String binName;
  final int wetWaste;
  final int dryWaste;

  const UserDashboard({
    Key? key,
    required this.binName,
    required this.wetWaste,
    required this.dryWaste,
  }) : super(key: key);

  @override
  _UserDashboardState createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard> {
  final TextEditingController _complaintController = TextEditingController();

  void _submitComplaint() async {
    String complaintText = _complaintController.text.trim();
    if (complaintText.isNotEmpty) {
      await FirebaseFirestore.instance.collection('complaints').add({
        'complaint': complaintText,
        'timestamp': Timestamp.now(),
        'binName': widget.binName,
        'wetWaste': widget.wetWaste,
        'dryWaste': widget.dryWaste,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Complaint registered successfully!")),
      );
      _complaintController.clear();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please enter a complaint before submitting.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Waste Bin Details'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => UserLoginPage()),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 20),

            // Waste Bin Information Card
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blueGrey.shade200,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  Icon(Icons.delete, size: 50, color: Colors.black54),
                  SizedBox(height: 10),
                  Text(
                    widget.binName,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildWasteInfo("Wet", widget.wetWaste),
                      SizedBox(width: 40),
                      _buildWasteInfo("Dry", widget.dryWaste),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: 20),

            // Complaint Text Field (Replacing the previous "Waste status" text)
            TextField(
              controller: _complaintController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: "Enter your complaint",
                border: OutlineInputBorder(),
                hintText: "Describe your complaint here...",
              ),
            ),

            SizedBox(height: 20),

            // Register Complaint Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _submitComplaint,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  "REGISTER COMPLAINT",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper Widget for Waste Information
  Widget _buildWasteInfo(String label, int percentage) {
    return Column(
      children: [
        Text(label, style: TextStyle(fontSize: 18)),
        Text(
          "$percentage%",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
