import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

class CollectorBinPage extends StatefulWidget {
  @override
  _CollectorBinPageState createState() => _CollectorBinPageState();
}

class _CollectorBinPageState extends State<CollectorBinPage> {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref('bin');
  late Position _currentPosition;

  @override
  void initState() {
    super.initState();
    _determinePosition();
  }

  Future<void> _determinePosition() async {
    LocationPermission permission;

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
    }

    _currentPosition = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  void _openGoogleMaps(double destLat, double destLng) {
    final url =
        'https://www.google.com/maps/dir/?api=1&origin=${_currentPosition.latitude},${_currentPosition.longitude}&destination=$destLat,$destLng&travelmode=driving';
    launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('Bins Above 80%', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: StreamBuilder<DatabaseEvent>(
          stream: _dbRef.onValue,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
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

              if (wet > 80 || dry > 80) {
                double? lat = value['location']?['latitude']?.toDouble();
                double? lng = value['location']?['longitude']?.toDouble();

                if (lat != null && lng != null) {
                  binList.add({
                    'binId': key,
                    'wet': wet,
                    'dry': dry,
                    'latitude': lat,
                    'longitude': lng,
                    'average': (wet + dry) ~/ 2,
                  });
                }
              }
            });

            if (binList.isEmpty) {
              return Center(
                child: Text(
                  "No bins above 80%",
                  style: TextStyle(color: Colors.white),
                ),
              );
            }

            binList.sort((a, b) => b['average'].compareTo(a['average']));

            return SingleChildScrollView(
              child: Column(
                children: List.generate(binList.length, (index) {
                  final bin = binList[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: BinCard(
                      binNumber: index + 1,
                      wetLevel: bin['wet'],
                      dryLevel: bin['dry'],
                      onNavigate:
                          () => _openGoogleMaps(
                            bin['latitude'],
                            bin['longitude'],
                          ),
                    ),
                  );
                }),
              ),
            );
          },
        ),
      ),
    );
  }
}

class BinCard extends StatelessWidget {
  final int binNumber;
  final int wetLevel;
  final int dryLevel;
  final VoidCallback onNavigate;

  const BinCard({
    required this.binNumber,
    required this.wetLevel,
    required this.dryLevel,
    required this.onNavigate,
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
      padding: EdgeInsets.all(10),
      child: Column(
        children: [
          Icon(Icons.delete, size: 30, color: Colors.black54),
          SizedBox(height: 6),
          Text(
            "BIN $binNumber",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              CircularPercentIndicator(
                radius: 35.0,
                lineWidth: 6.0,
                percent: (wetLevel.clamp(0, 100)) / 100,
                center: Text(
                  "Wet\n$wetLevel%",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 10),
                ),
                progressColor: Colors.green,
              ),
              CircularPercentIndicator(
                radius: 35.0,
                lineWidth: 6.0,
                percent: (dryLevel.clamp(0, 100)) / 100,
                center: Text(
                  "Dry\n$dryLevel%",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 10),
                ),
                progressColor: const Color.fromARGB(255, 238, 3, 3),
              ),
            ],
          ),
          SizedBox(height: 10),
          ElevatedButton.icon(
            onPressed: onNavigate,
            icon: Icon(Icons.location_on),
            label: Text("Go to Location"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
