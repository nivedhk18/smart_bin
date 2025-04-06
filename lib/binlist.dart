import 'package:flutter/material.dart';

class BinListPage extends StatelessWidget {
  final List<String> bins = ["BIN 1", "BIN 2", "BIN 3"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(children: bins.map((bin) => _buildBinCard(bin)).toList()),
      ),
    );
  }

  Widget _buildBinCard(String binName) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        title: Text(
          binName,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        trailing: Icon(Icons.location_pin, color: Colors.grey),
      ),
    );
  }
}
