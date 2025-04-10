import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'userlogin.dart';
import 'globals.dart' as globals;

class UserDashboard extends StatefulWidget {
  const UserDashboard({Key? key}) : super(key: key);

  @override
  _UserDashboardState createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard> {
  final TextEditingController _complaintController = TextEditingController();
  int wetWaste = 0;
  int dryWaste = 0;
  String binName = "";

  @override
  void initState() {
    super.initState();
    _loadBinData();
  }

  void _loadBinData() async {
    String username = globals.loggedInUsername;

    if (username.length < 2) return;

    String binNumber = username[1];

    if (!RegExp(r'\d').hasMatch(binNumber)) {
      print('Invalid bin number in username: $username');
      return;
    }

    String binId = 'bin$binNumber';
    setState(() {
      binName = 'Bin $binNumber';
    });

    try {
      final dbRef = FirebaseDatabase.instance
          .ref()
          .child('bin')
          .child(binId)
          .child('binLevels');

      final snapshot = await dbRef.get();

      if (snapshot.exists) {
        final data = snapshot.value as Map<dynamic, dynamic>;
        setState(() {
          wetWaste = data['wet'] ?? 0;
          dryWaste = data['dry'] ?? 0;
        });
      } else {
        print('No data found for $binId');
      }
    } catch (e) {
      print('Error loading data for $binId: $e');
    }
  }

  void _submitComplaint() async {
    String complaintText = _complaintController.text.trim();
    if (complaintText.isNotEmpty) {
      await FirebaseFirestore.instance.collection('complaints').add({
        'complaint': complaintText,
        'timestamp': Timestamp.now(),
        'binName': binName,
        'wetWaste': wetWaste,
        'dryWaste': dryWaste,
        'username': globals.loggedInUsername,
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
                    binName.isNotEmpty ? binName : "Loading bin...",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildWasteInfo("Wet", wetWaste),
                      SizedBox(width: 40),
                      _buildWasteInfo("Dry", dryWaste),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 30),
            Text(
              "Report a Complaint",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
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

  Widget _buildWasteInfo(String label, int percentage) {
    return Column(
      children: [
        Text(label, style: TextStyle(fontSize: 18)),
        SizedBox(height: 8),
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 60,
              height: 60,
              child: CircularProgressIndicator(
                value: percentage / 100,
                strokeWidth: 6,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(
                  label == "Wet" ? Colors.green : Colors.brown,
                ),
              ),
            ),
            Text(
              "$percentage%",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ],
    );
  }
}
