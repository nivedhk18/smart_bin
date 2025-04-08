import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'bin_details.dart';

class BinTrackingPage extends StatefulWidget {
  @override
  _BinTrackingPageState createState() => _BinTrackingPageState();
}

class _BinTrackingPageState extends State<BinTrackingPage> {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref('bin');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('Track Bin', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Search Bar
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: "Search for bin",
                  prefixIcon: Icon(Icons.search, color: Colors.black54),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 15,
                    horizontal: 10,
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            // Bin Grid
            Expanded(
              child: StreamBuilder<DatabaseEvent>(
                stream: _dbRef.onValue,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData ||
                      snapshot.data!.snapshot.value == null) {
                    return Center(
                      child: Text(
                        "No data available",
                        style: TextStyle(color: Colors.white),
                      ),
                    );
                  }

                  Map<dynamic, dynamic> bins =
                      snapshot.data!.snapshot.value as Map<dynamic, dynamic>;

                  List<Map<String, dynamic>> binList = [];

                  bins.forEach((key, value) {
                    String wetStr = value['binLevels']?['wet'] ?? "0%";
                    String dryStr = value['binLevels']?['dry'] ?? "0%";
                    int wet = int.tryParse(wetStr.replaceAll('%', '')) ?? 0;
                    int dry = int.tryParse(dryStr.replaceAll('%', '')) ?? 0;

                    final location = value['binLevels']?['location'] ?? {};
                    double latitude = 0.0;
                    double longitude = 0.0;

                    if (location['latitude'] != null) {
                      latitude =
                          location['latitude'] is double
                              ? location['latitude']
                              : double.tryParse(
                                    location['latitude'].toString(),
                                  ) ??
                                  0.0;
                    }

                    if (location['longitude'] != null) {
                      longitude =
                          location['longitude'] is double
                              ? location['longitude']
                              : double.tryParse(
                                    location['longitude'].toString(),
                                  ) ??
                                  0.0;
                    }

                    String timestamp =
                        location['timestamp']?.toString() ?? "Unknown";

                    binList.add({
                      'binId': key,
                      'wet': wet,
                      'dry': dry,
                      'average': (wet + dry) ~/ 2,
                      'latitude': latitude,
                      'longitude': longitude,
                      'timestamp': timestamp,
                    });
                  });

                  binList.sort((a, b) => b['average'].compareTo(a['average']));

                  return GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.85,
                    ),
                    itemCount: binList.length,
                    itemBuilder: (context, index) {
                      final bin = binList[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => BinDetailsPage(
                                    binNumber: index + 1,
                                    fillLevel: bin['average'],
                                    wetLevel: bin['wet'],
                                    dryLevel: bin['dry'],
                                    latitude: bin['latitude'],
                                    longitude: bin['longitude'],
                                    timestamp: bin['timestamp'],
                                  ),
                            ),
                          );
                        },
                        child: BinCard(
                          binNumber: index + 1,
                          wetLevel: bin['wet'],
                          dryLevel: bin['dry'],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BinCard extends StatelessWidget {
  final int binNumber;
  final int wetLevel;
  final int dryLevel;

  const BinCard({
    required this.binNumber,
    required this.wetLevel,
    required this.dryLevel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 10, spreadRadius: 2),
        ],
      ),
      padding: EdgeInsets.all(12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.delete, size: 40, color: Colors.black54),
          SizedBox(height: 10),
          Text("BIN $binNumber", style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(height: 10),
          CircularPercentIndicator(
            radius: 45.0,
            lineWidth: 8.0,
            percent: wetLevel / 100,
            center: Text("Wet\n$wetLevel%", textAlign: TextAlign.center),
            progressColor: Colors.green,
          ),
          SizedBox(height: 10),
          CircularPercentIndicator(
            radius: 45.0,
            lineWidth: 8.0,
            percent: dryLevel / 100,
            center: Text("Dry\n$dryLevel%", textAlign: TextAlign.center),
            progressColor: Colors.brown,
          ),
        ],
      ),
    );
  }
}
