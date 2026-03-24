import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/vehicle.dart';
import 'edit_vehicle_screen.dart';
import 'add_vehicle_screen.dart';

class VehicleScreen extends StatefulWidget {
  final int userId;

  const VehicleScreen({super.key, required this.userId});

  @override
  State<VehicleScreen> createState() => _VehicleScreenState();
}

class _VehicleScreenState extends State<VehicleScreen> {
  List<Vehicle> vehicles = [];

  @override
  void initState() {
    super.initState();
    loadVehicles();
  }

  Future<void> loadVehicles() async {
    vehicles = await DatabaseHelper.instance.getVehicles(widget.userId);
    if (mounted) setState(() {});
  }

  Widget _chip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1C),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.blueAccent.withOpacity(0.25)),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 12, color: Colors.white70),
      ),
    );
  }

  Widget _vehicleCard(Vehicle v) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.blueAccent.withOpacity(0.25)),
        boxShadow: const [
          BoxShadow(
            blurRadius: 16,
            color: Colors.black54,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  "${v.vehicleType} • ${v.model}",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
              IconButton(
                tooltip: "Edit",
                icon: const Icon(Icons.edit, color: Colors.lightBlueAccent),
                onPressed: () async {
                  final changed = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EditVehicleScreen(vehicle: v),
                    ),
                  );
                  if (changed == true) {
                    await loadVehicles();
                  }
                },
              ),
            ],
          ),

          const SizedBox(height: 6),

          Text(
            "Plate: ${v.plateNumber}",
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),

          const SizedBox(height: 8),

          Wrap(
            spacing: 10,
            runSpacing: 6,
            children: [
              _chip("Fuel: ${v.fuelType}"),
              _chip("Year: ${v.year}"),
              _chip("Mileage: ${v.mileage} km"),
            ],
          ),

          const SizedBox(height: 10),

          Text(
            "Chassis: ${v.chassisNumber}",
            style: const TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF0D1B2A),
            Color(0xFF1B263B),
            Color(0xFF000000),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text("My Vehicles"),
          elevation: 0,
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
        ),

        // ✅ Add Vehicle Button opens another screen
        floatingActionButton: FloatingActionButton.extended(
          backgroundColor: Colors.blueAccent,
          foregroundColor: Colors.white,
          onPressed: () async {
            final added = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => AddVehicleScreen(userId: widget.userId),
              ),
            );

            if (added == true) {
              await loadVehicles();
            }
          },
          icon: const Icon(Icons.add),
          label: const Text("Add Vehicle"),
        ),

        body: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
          child: vehicles.isEmpty
              ? Center(
                  child: Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: const Color(0xFF111111),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: Colors.blueAccent.withOpacity(0.25),
                      ),
                    ),
                    child: const Text(
                      "No Vehicles Added",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                )
              : ListView.builder(
                  itemCount: vehicles.length,
                  itemBuilder: (_, index) => _vehicleCard(vehicles[index]),
                ),
        ),
      ),
    );
  }
}