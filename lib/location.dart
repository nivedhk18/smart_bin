import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationPage extends StatefulWidget {
  final int binNumber;

  const LocationPage({
    Key? key,
    required this.binNumber,
    required double latitude,
    required double longitude,
  }) : super(key: key);

  @override
  State<LocationPage> createState() => _LocationPageState();
}

class _LocationPageState extends State<LocationPage> {
  LatLng? binLatLng;
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _fetchBinLocation();
  }

  Future<void> _fetchBinLocation() async {
    try {
      String binPath = 'bin/bin${widget.binNumber}/location';
      DatabaseReference ref = FirebaseDatabase.instance.ref(binPath);

      DatabaseEvent event = await ref.once();
      Map<dynamic, dynamic>? data =
          event.snapshot.value as Map<dynamic, dynamic>?;

      if (data != null &&
          data.containsKey('latitude') &&
          data.containsKey('longitude')) {
        double latitude = data['latitude'].toDouble();
        double longitude = data['longitude'].toDouble();

        setState(() {
          binLatLng = LatLng(latitude, longitude);
          isLoading = false;
        });
      } else {
        setState(() {
          error = 'Location data not found.';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = 'Error fetching location: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Bin ${widget.binNumber} Location"),
        backgroundColor: Colors.orange,
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : error != null
              ? Center(child: Text(error!))
              : GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: binLatLng!,
                  zoom: 17,
                ),
                markers: {
                  Marker(
                    markerId: const MarkerId("binMarker"),
                    position: binLatLng!,
                    infoWindow: InfoWindow(title: "Bin ${widget.binNumber}"),
                  ),
                },
                mapType: MapType.normal,
              ),
    );
  }
}
