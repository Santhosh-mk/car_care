import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/vehicle.dart';
import 'vehicle_screen.dart';
import 'maintenance_screen.dart';
import '../core/theme.dart';

class HomeScreen extends StatefulWidget {
  final int userId;
  const HomeScreen({super.key, required this.userId});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Vehicle> vehicles = [];
  Vehicle? selectedVehicle;

  @override
  void initState() {
    super.initState();
    loadVehicles();
  }

  Future<void> loadVehicles() async {
    vehicles = await DatabaseHelper.instance.getVehicles(widget.userId);
    if (vehicles.isNotEmpty) {
      selectedVehicle = vehicles.first;
    }
    if (mounted) setState(() {});
  }

  String _vehicleImage(String type) {
    switch (type.toLowerCase()) {
      case 'bike':
        return 'assets/bike.png';
      case 'van':
        return 'assets/van.png';
      case 'lorry':
        return 'assets/lorry.png';
      case 'jeep':
        return 'assets/jeep.png';
      case 'car':
      default:
        return 'assets/car.png';
    }
  }

  @override
  Widget build(BuildContext context) {
    final v = selectedVehicle;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.bgTop, AppTheme.bgMid, AppTheme.bgBottom],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // TOP TITLE
                const Text(
                  "My Dashboard",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),

                // VEHICLE SELECTOR
                if (vehicles.isNotEmpty)
                  Theme(
                    data: Theme.of(context).copyWith(
                      canvasColor: AppTheme.card, // dropdown menu background
                    ),
                    child: DropdownButtonFormField<Vehicle>(
                      value: v,
                      dropdownColor: AppTheme.card,
                      iconEnabledColor: Colors.white,
                      style: const TextStyle(color: Colors.white),
                      items: vehicles
                          .map((item) => DropdownMenuItem(
                                value: item,
                                child: Text(
                                  "${item.vehicleType} • ${item.model}",
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ))
                          .toList(),
                      onChanged: (newV) {
                        setState(() => selectedVehicle = newV);
                      },
                      decoration: InputDecoration(
                        labelText: "Selected Vehicle",
                        labelStyle: const TextStyle(color: Colors.white70),
                        filled: true,
                        fillColor: AppTheme.field,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),

                const SizedBox(height: 16),

                // IF NO VEHICLE
                if (vehicles.isEmpty)
                  Expanded(
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppTheme.card,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.blueAccent.withOpacity(0.35),
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.directions_car,
                                size: 60, color: Colors.white),
                            const SizedBox(height: 10),
                            const Text(
                              "No vehicles found",
                              style: TextStyle(color: Colors.white),
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              width: 180,
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          VehicleScreen(userId: widget.userId),
                                    ),
                                  ).then((_) => loadVehicles());
                                },
                                child: const Text("Add Vehicle"),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                // MAIN CARD
                if (vehicles.isNotEmpty && v != null)
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.card,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color: Colors.blueAccent.withOpacity(0.30),
                        ),
                        boxShadow: const [
                          BoxShadow(
                            blurRadius: 18,
                            color: Colors.black54,
                            offset: Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // DETAILS TOP PART
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "${v.vehicleType} • ${v.model}",
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      "Plate: ${v.plateNumber}",
                                      style: const TextStyle(
                                          color: Colors.white70),
                                    ),
                                    Text(
                                      "Fuel: ${v.fuelType}",
                                      style: const TextStyle(
                                          color: Colors.white70),
                                    ),
                                    Text(
                                      "Mileage: ${v.mileage} km",
                                      style: const TextStyle(
                                          color: Colors.white70),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.verified,
                                  color: Colors.lightBlueAccent),
                            ],
                          ),

                          const SizedBox(height: 10),
                          Divider(color: Colors.white.withOpacity(0.15)),

                          // IMAGE BOTTOM HALF
                          Expanded(
                            child: Center(
                              child: Image.asset(
                                _vehicleImage(v.vehicleType),
                                height: 190,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),

                          const SizedBox(height: 10),

                          // BUTTONS
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => VehicleScreen(
                                            userId: widget.userId),
                                      ),
                                    ).then((_) => loadVehicles());
                                  },
                                  icon: const Icon(Icons.directions_car),
                                  label: const Text("VEHICLES"),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            MaintenanceScreen(userId: widget.userId),
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.build),
                                  label: const Text("MAINTENANCE"),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        Colors.lightBlueAccent.withOpacity(0.9),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}