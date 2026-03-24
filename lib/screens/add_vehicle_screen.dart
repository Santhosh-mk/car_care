import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/vehicle.dart';

class AddVehicleScreen extends StatefulWidget {
  final int userId;
  const AddVehicleScreen({super.key, required this.userId});

  @override
  State<AddVehicleScreen> createState() => _AddVehicleScreenState();
}

class _AddVehicleScreenState extends State<AddVehicleScreen> {
  final modelController = TextEditingController();
  final yearController = TextEditingController();
  final mileageController = TextEditingController();
  final chassisController = TextEditingController();
  final plateController = TextEditingController();

  String vehicleType = "Car";
  String fuelType = "Petrol";

  final vehicleTypes = const ["Car", "Bike", "Van", "Lorry", "Jeep"];
  final fuelTypes = const ["Petrol", "Diesel", "Hybrid", "Electric"];

  InputDecoration _dec(String label, {IconData? icon}) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white70),
      filled: true,
      fillColor: const Color(0xFF1C1C1C),
      prefixIcon: icon == null ? null : Icon(icon, color: Colors.blueAccent),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
    );
  }

  Future<void> saveVehicle() async {
    if (modelController.text.trim().isEmpty ||
        yearController.text.trim().isEmpty ||
        mileageController.text.trim().isEmpty ||
        chassisController.text.trim().isEmpty ||
        plateController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields")),
      );
      return;
    }

    final year = int.tryParse(yearController.text.trim());
    final mileage = int.tryParse(mileageController.text.trim());

    if (year == null || mileage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Year and Mileage must be numbers")),
      );
      return;
    }

    final vehicle = Vehicle(
      userId: widget.userId,
      vehicleType: vehicleType,
      model: modelController.text.trim(),
      year: year,
      mileage: mileage,
      chassisNumber: chassisController.text.trim(),
      plateNumber: plateController.text.trim(),
      fuelType: fuelType,
    );

    await DatabaseHelper.instance.insertVehicle(vehicle);

    if (!mounted) return;
    Navigator.pop(context, true); // ✅ refresh vehicles list
  }

  @override
  void dispose() {
    modelController.dispose();
    yearController.dispose();
    mileageController.dispose();
    chassisController.dispose();
    plateController.dispose();
    super.dispose();
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
          title: const Text("Add Vehicle"),
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: Colors.white,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Theme(
            data: Theme.of(context).copyWith(
              canvasColor: const Color(0xFF111111), // dropdown bg
            ),
            child: ListView(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF111111),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.blueAccent.withOpacity(0.25),
                    ),
                    boxShadow: const [
                      BoxShadow(
                        blurRadius: 16,
                        color: Colors.black54,
                        offset: Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      DropdownButtonFormField<String>(
                        value: vehicleType,
                        dropdownColor: const Color(0xFF111111),
                        iconEnabledColor: Colors.white,
                        style: const TextStyle(color: Colors.white),
                        items: vehicleTypes
                            .map(
                              (t) => DropdownMenuItem(
                                value: t,
                                child: Text(
                                  t,
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (v) => setState(() => vehicleType = v!),
                        decoration: _dec("Vehicle Type", icon: Icons.directions_car),
                      ),
                      const SizedBox(height: 10),

                      TextField(
                        controller: modelController,
                        style: const TextStyle(color: Colors.white),
                        decoration: _dec("Model", icon: Icons.directions_car_filled),
                      ),
                      const SizedBox(height: 10),

                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: yearController,
                              keyboardType: TextInputType.number,
                              style: const TextStyle(color: Colors.white),
                              decoration: _dec("Year", icon: Icons.calendar_month),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: mileageController,
                              keyboardType: TextInputType.number,
                              style: const TextStyle(color: Colors.white),
                              decoration: _dec("Mileage (km)", icon: Icons.speed),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      TextField(
                        controller: chassisController,
                        style: const TextStyle(color: Colors.white),
                        decoration: _dec("Chassis Number", icon: Icons.confirmation_number),
                      ),
                      const SizedBox(height: 10),

                      TextField(
                        controller: plateController,
                        style: const TextStyle(color: Colors.white),
                        decoration: _dec("Number Plate", icon: Icons.credit_card),
                      ),
                      const SizedBox(height: 10),

                      DropdownButtonFormField<String>(
                        value: fuelType,
                        dropdownColor: const Color(0xFF111111),
                        iconEnabledColor: Colors.white,
                        style: const TextStyle(color: Colors.white),
                        items: fuelTypes
                            .map(
                              (f) => DropdownMenuItem(
                                value: f,
                                child: Text(
                                  f,
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (v) => setState(() => fuelType = v!),
                        decoration: _dec("Fuel Type", icon: Icons.local_gas_station),
                      ),
                      const SizedBox(height: 16),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: saveVehicle,
                          icon: const Icon(Icons.save),
                          label: const Text("Save Vehicle"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ),
                    ],
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