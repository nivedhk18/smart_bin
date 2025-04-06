import 'package:flutter/material.dart';
import 'bin_details.dart'; // Import the Bin Details page

class BinTrackingPage extends StatelessWidget {
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
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.8,
                ),
                itemCount: 5,
                itemBuilder: (context, index) {
                  int fillLevel = [82, 68, 55, 34, 18][index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => BinDetailsPage(
                                binNumber: index + 1,
                                fillLevel: fillLevel,
                                locationName: "Chilla Art Cafe",
                                address:
                                    "Old Picnic Spot, Beach Road, Alappuzha, Kerala",
                                distance: "45 Km",
                                time: "20 min",
                              ),
                        ),
                      );
                    },
                    child: BinCard(binNumber: index + 1, fillLevel: fillLevel),
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
  final int fillLevel;

  const BinCard({required this.binNumber, required this.fillLevel});

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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.delete, size: 50, color: Colors.black54),
          SizedBox(height: 10),
          Text("BIN $binNumber", style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(height: 5),
          Text(
            "$fillLevel%",
            style: TextStyle(
              color: fillLevel >= 50 ? Colors.red : Colors.green,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }
}
