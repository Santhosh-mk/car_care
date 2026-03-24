import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../database/database_helper.dart';
import '../models/vehicle.dart';
import 'login_screen.dart';

class VehicleSetupScreen extends StatefulWidget {
  final int userId;
  const VehicleSetupScreen({super.key, required this.userId});

  @override
  State<VehicleSetupScreen> createState() => _VehicleSetupScreenState();
}

class _VehicleSetupScreenState extends State<VehicleSetupScreen> {
  final modelController = TextEditingController();
  final yearController = TextEditingController();
  final mileageController = TextEditingController();
  final chassisController = TextEditingController();
  final plateController = TextEditingController();

  String vehicleType = "Car";
  String fuelType = "Petrol";

  final vehicleTypes = const ["Car", "Bike", "Van", "Lorry", "Jeep"];
  final fuelTypes = const ["Petrol", "Diesel", "Hybrid", "Electric"];

  // 🔥 IMAGE VARIABLES
  File? selectedVehicleImage;
  String? defaultVehicleImage;

  // 📷 PICK IMAGE
  Future<void> pickVehicleImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      setState(() {
        selectedVehicleImage = File(picked.path);
        defaultVehicleImage = null;
      });
    }
  }

  // 🖼 SELECT DEFAULT
  void selectVehicleDefault(String path) {
    setState(() {
      defaultVehicleImage = path;
      selectedVehicleImage = null;
    });
  }

  // 🔵 DEFAULT ICON WIDGET
  Widget _vehicleAvatar(String path) {
    return GestureDetector(
      onTap: () => selectVehicleDefault(path),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 6),
        child: CircleAvatar(
          radius: 25,
          backgroundImage: AssetImage(path),
        ),
      ),
    );
  }

  Future<void> save() async {
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

    final int? year = int.tryParse(yearController.text.trim());
    final int? mileage = int.tryParse(mileageController.text.trim());

    if (year == null || mileage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Year and Mileage must be numbers")),
      );
      return;
    }

    // 🔥 SAVE IMAGE PATH
    String? imagePath;
    if (selectedVehicleImage != null) {
      imagePath = selectedVehicleImage!.path;
    } else if (defaultVehicleImage != null) {
      imagePath = defaultVehicleImage;
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
      vehicleImage: imagePath, // 🔥 ADD THIS IN MODEL
    );

    await DatabaseHelper.instance.insertVehicle(vehicle);

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
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
    return Scaffold(
      appBar: AppBar(title: const Text("Add Vehicle")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [

            // 🔥 IMAGE SECTION
            Center(
              child: Column(
                children: [
                  GestureDetector(
                    onTap: pickVehicleImage,
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.grey[300],
                      backgroundImage: selectedVehicleImage != null
                          ? FileImage(selectedVehicleImage!)
                          : defaultVehicleImage != null
                              ? AssetImage(defaultVehicleImage!) as ImageProvider
                              : null,
                      child: selectedVehicleImage == null && defaultVehicleImage == null
                          ? const Icon(Icons.directions_car, size: 30)
                          : null,
                    ),
                  ),

                  const SizedBox(height: 10),
                  const Text("Tap to add vehicle image"),

                  const SizedBox(height: 10),
                  const Text("Or choose default"),

                  const SizedBox(height: 10),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _vehicleAvatar("assets/car.png"),
                      _vehicleAvatar("assets/bike.png"),
                      _vehicleAvatar("assets/van.png"),
                      _vehicleAvatar("assets/jeep.png"),
                      _vehicleAvatar("assets/lorry.png"),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            DropdownButtonFormField<String>(
              value: vehicleType,
              items: vehicleTypes
                  .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                  .toList(),
              onChanged: (v) => setState(() => vehicleType = v!),
              decoration: const InputDecoration(labelText: "Vehicle Type"),
            ),

            const SizedBox(height: 12),

            TextField(
              controller: modelController,
              decoration: const InputDecoration(labelText: "Vehicle Model"),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: yearController,
              decoration: const InputDecoration(labelText: "Year"),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),

            TextField(
              controller: mileageController,
              decoration: const InputDecoration(labelText: "Mileage"),
              keyboardType: TextInputType.number,
            ),

            const SizedBox(height: 12),

            TextField(
              controller: chassisController,
              decoration: const InputDecoration(labelText: "Chassis Number"),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: plateController,
              decoration: const InputDecoration(labelText: "Number Plate"),
            ),

            const SizedBox(height: 12),

            DropdownButtonFormField<String>(
              value: fuelType,
              items: fuelTypes
                  .map((f) => DropdownMenuItem(value: f, child: Text(f)))
                  .toList(),
              onChanged: (v) => setState(() => fuelType = v!),
              decoration: const InputDecoration(labelText: "Fuel Type"),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: save,
              child: const Text("Save"),
            ),
          ],
        ),
      ),
    );
  }
}