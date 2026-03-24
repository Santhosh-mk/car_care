import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EmergencyScreen extends StatefulWidget {
  const EmergencyScreen({super.key});

  @override
  State<EmergencyScreen> createState() => _EmergencyScreenState();
}

class _EmergencyScreenState extends State<EmergencyScreen> {
  static const LatLng _fallback = LatLng(6.9271, 79.8612);

  GoogleMapController? _controller;

  LatLng? _myLocation;
  final Set<Marker> _markers = {};

  bool _loading = true;

  String _selectedType = "garage";

  @override
  void initState() {
    super.initState();
    _setupLocation();
  }

  Future<void> getNearbyPlaces(double lat, double lng, String type) async {
    final apiKey = "AIzaSyCIpmtP03ujt32eB1sCSXFKwfpH7Ke4WaU"; 

    final url =
        "https://maps.googleapis.com/maps/api/place/nearbysearch/json"
        "?location=$lat,$lng"
        "&radius=5000"
        "&type=$type"
        "&key=$apiKey";

    try {
      final response = await http.get(Uri.parse(url));

      print("API RESPONSE: ${response.body}");

      final data = json.decode(response.body);

      if (data["status"] != "OK") {
        _showMsg("API Error: ${data["status"]}");
        return;
      }

      _markers.clear();



      for (var place in data["results"]) {
        final loc = place["geometry"]["location"];

        _markers.add(
          Marker(
            markerId: MarkerId(place["place_id"]),
            position: LatLng(loc["lat"], loc["lng"]),
            infoWindow: InfoWindow(
              title: place["name"],
              snippet: place["vicinity"],
            ),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              type == "gas_station"
                  ? BitmapDescriptor.hueOrange
                  : BitmapDescriptor.hueAzure,
            ),
          ),
        );
      }

      setState(() {});
    } catch (e) {
      _showMsg("Error: $e");
    }
  }

  Future<void> _setupLocation() async {
    setState(() => _loading = true);

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showMsg("Turn ON GPS");
        setState(() => _loading = false);
        return;
      }

      final status = await Permission.locationWhenInUse.request();
      if (!status.isGranted) {
        _showMsg("Permission denied");
        setState(() => _loading = false);
        return;
      }

      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      _myLocation = LatLng(pos.latitude, pos.longitude);

      await getNearbyPlaces(pos.latitude, pos.longitude, "car_repair");

      setState(() => _loading = false);

      if (_controller != null) {
        await _controller!.animateCamera(
          CameraUpdate.newLatLngZoom(_myLocation!, 14),
        );
      }
    } catch (e) {
      _showMsg("Location error: $e");
      setState(() => _loading = false);
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    _controller = controller;
  }

  void _showMsg(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(text)));
  }

  Widget _buildFilterButton({
    required String label,
    required IconData icon,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: selected ? Colors.blue : Colors.black87,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final initialTarget = _myLocation ?? _fallback;

    return Scaffold(
      appBar: AppBar(title: const Text("Emergency Assistance")),
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: initialTarget,
              zoom: 12,
            ),
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            markers: _markers,
          ),

          Positioned(
            top: 20,
            left: 10,
            right: 10,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildFilterButton(
                  label: "Garages",
                  icon: Icons.build,
                  selected: _selectedType == "garage",
                  onTap: () {
                    setState(() {
                      _selectedType = "garage";
                    });

                    if (_myLocation != null) {
                      getNearbyPlaces(
                        _myLocation!.latitude,
                        _myLocation!.longitude,
                        "car_repair",
                      );
                    }
                  },
                ),
                const SizedBox(width: 10),
                _buildFilterButton(
                  label: "Fuel",
                  icon: Icons.local_gas_station,
                  selected: _selectedType == "fuel",
                  onTap: () {
                    setState(() {
                      _selectedType = "fuel";
                    });

                    if (_myLocation != null) {
                      getNearbyPlaces(
                        _myLocation!.latitude,
                        _myLocation!.longitude,
                        "gas_station",
                      );
                    }
                  },
                ),
              ],
            ),
          ),

          if (_loading)
            Container(
              color: Colors.black.withOpacity(0.2),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: _setupLocation,
        child: const Icon(Icons.my_location),
      ),
    );
  }
}