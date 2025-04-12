import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'globals.dart' as globals;

class ComplaintPage extends StatefulWidget {
  const ComplaintPage({Key? key, required String username}) : super(key: key);

  @override
  State<ComplaintPage> createState() => _ComplaintPageState();
}

class _ComplaintPageState extends State<ComplaintPage> {
  final Map<String, Map<String, dynamic>> binLevelsCache = {};

  Future<Map<String, dynamic>> fetchBinLevels(String binName) async {
    if (binLevelsCache.containsKey(binName)) {
      return binLevelsCache[binName]!;
    }

    final DatabaseReference dbRef = FirebaseDatabase.instance.ref(
      'bin/$binName/level',
    );
    final snapshot = await dbRef.get();

    final levels = {
      'wet': snapshot.child('wet').value ?? 'N/A',
      'dry': snapshot.child('dry').value ?? 'N/A',
    };

    binLevelsCache[binName] = levels;
    return levels;
  }

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
              try {
                final complaint =
                    complaints[index].data() as Map<String, dynamic>;

                final text = complaint['complaint'] ?? 'No complaint text';
                final timestamp = complaint['timestamp'];
                final time = timestamp is Timestamp ? timestamp.toDate() : null;
                final binName = complaint['binName'] ?? 'Unknown Bin';

                return FutureBuilder<Map<String, dynamic>>(
                  future: fetchBinLevels(binName),
                  builder: (context, snapshot) {
                    final wet =
                        snapshot.data?['wet']?.toString() ?? 'Loading...';
                    final dry =
                        snapshot.data?['dry']?.toString() ?? 'Loading...';

                    return Card(
                      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: ListTile(
                        title: Text(text),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Bin: $binName"),
                            if (time != null) Text("Time: ${time.toLocal()}"),
                            Text("Wet Level: $wet%"),
                            Text("Dry Level: $dry%"),
                          ],
                        ),
                      ),
                    );
                  },
                );
              } catch (e) {
                print("Error displaying complaint: $e");
                return ListTile(
                  title: Text("Error displaying this complaint"),
                  subtitle: Text("Please check the complaint format."),
                );
              }
            },
          );
        },
      ),
    );
  }
}
