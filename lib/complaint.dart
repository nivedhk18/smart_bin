import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'globals.dart' as globals;

class ComplaintPage extends StatelessWidget {
  const ComplaintPage({Key? key, required String username})
    : super(key: key); // No username param here

  @override
  Widget build(BuildContext context) {
    final String username = globals.loggedInUsername;

    if (username.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text("My Complaints")),
        body: Center(child: Text("No user logged in.")),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text("My Complaints")),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection('complaints')
                .where('username', isEqualTo: username)
                .orderBy('timestamp', descending: true)
                .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text("Error loading complaints"));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          final complaints = snapshot.data!.docs;

          if (complaints.isEmpty) {
            return Center(child: Text("No complaints found for $username"));
          }

          return ListView.builder(
            itemCount: complaints.length,
            itemBuilder: (context, index) {
              final complaint = complaints[index];
              final text = complaint['complaint'] ?? '';
              final timestamp = complaint['timestamp'] as Timestamp?;
              final time = timestamp?.toDate();
              final binName = complaint['binName'] ?? 'Unknown Bin';

              return Card(
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(text),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Bin: $binName"),
                      if (time != null) Text("Time: ${time.toLocal()}"),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
