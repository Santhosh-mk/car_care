import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../database/database_helper.dart';
import '../models/vehicle.dart';

class EditVehicleScreen extends StatefulWidget {
  final Vehicle vehicle;
  const EditVehicleScreen({super.key, required this.vehicle});

  @override
  State<EditVehicleScreen> createState() => _EditVehicleScreenState();
}

class _EditVehicleScreenState extends State<EditVehicleScreen> {
  late final TextEditingController modelController;
  late final TextEditingController yearController;
  late final TextEditingController mileageController;
  late final TextEditingController chassisController;
  late final TextEditingController plateController;

  late String vehicleType;
  late String fuelType;

  final vehicleTypes = const ["Car", "Bike", "Van", "Lorry", "Jeep"];
  final fuelTypes = const ["Petrol", "Diesel", "Hybrid", "Electric"];

  // 🔥 IMAGE VARIABLES
  File? newImage;
  String? currentImage;

  @override
  void initState() {
    super.initState();
    final v = widget.vehicle;

    modelController = TextEditingController(text: v.model);
    yearController = TextEditingController(text: v.year.toString());
    mileageController = TextEditingController(text: v.mileage.toString());
    chassisController = TextEditingController(text: v.chassisNumber);
    plateController = TextEditingController(text: v.plateNumber);

    vehicleType = v.vehicleType;
    fuelType = v.fuelType;

    currentImage = v.vehicleImage; // 🔥 LOAD IMAGE
  }

  // 🔥 PICK IMAGE
  Future<void> pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      setState(() {
        newImage = File(picked.path);
      });
    }
  }

  Future<void> save() async {
    final year = int.tryParse(yearController.text.trim());
    final mileage = int.tryParse(mileageController.text.trim());

    if (modelController.text.trim().isEmpty ||
        year == null ||
        mileage == null ||
        chassisController.text.trim().isEmpty ||
        plateController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields correctly")),
      );
      return;
    }

    // 🔥 HANDLE IMAGE
    String? imagePath = currentImage;

    if (newImage != null) {
      imagePath = newImage!.path;
    }

    final updated = Vehicle(
      id: widget.vehicle.id,
      userId: widget.vehicle.userId,
      vehicleType: vehicleType,
      model: modelController.text.trim(),
      year: year,
      mileage: mileage,
      chassisNumber: chassisController.text.trim(),
      plateNumber: plateController.text.trim(),
      fuelType: fuelType,
      vehicleImage: imagePath, // 🔥 SAVE IMAGE
    );

    await DatabaseHelper.instance.updateVehicle(updated);

    if (!mounted) return;
    Navigator.pop(context, true);
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
          title: const Text("Edit Vehicle"),
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: Colors.white,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Theme(
            data: Theme.of(context).copyWith(
              canvasColor: const Color(0xFF111111),
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

                      // 🔥 VEHICLE IMAGE UI
                      Center(
                        child: GestureDetector(
                          onTap: pickImage,
                          child: CircleAvatar(
                            radius: 50,
                            backgroundColor: Colors.grey[300],
                            backgroundImage: newImage != null
                                ? FileImage(newImage!)
                                : (currentImage != null
                                    ? FileImage(File(currentImage!))
                                    : null),
                            child: newImage == null && currentImage == null
                                ? const Icon(Icons.camera_alt)
                                : null,
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),
                      const Text(
                        "Tap to change vehicle image",
                        style: TextStyle(color: Colors.white70),
                      ),

                      const SizedBox(height: 20),

                      DropdownButtonFormField<String>(
                        value: vehicleType,
                        dropdownColor: const Color(0xFF111111),
                        iconEnabledColor: Colors.white,
                        style: const TextStyle(color: Colors.white),
                        items: vehicleTypes
                            .map((t) => DropdownMenuItem(
                                  value: t,
                                  child: Text(t),
                                ))
                            .toList(),
                        onChanged: (v) => setState(() => vehicleType = v!),
                        decoration: _dec("Vehicle Type", icon: Icons.directions_car),
                      ),

                      const SizedBox(height: 10),

                      TextField(
                        controller: modelController,
                        style: const TextStyle(color: Colors.white),
                        decoration: _dec("Model", icon: Icons.directions_car),
                      ),

                      const SizedBox(height: 10),

                      TextField(
                        controller: yearController,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(color: Colors.white),
                        decoration: _dec("Year", icon: Icons.calendar_month),
                      ),

                      const SizedBox(height: 10),

                      TextField(
                        controller: mileageController,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(color: Colors.white),
                        decoration: _dec("Mileage", icon: Icons.speed),
                      ),

                      const SizedBox(height: 10),

                      TextField(
                        controller: chassisController,
                        style: const TextStyle(color: Colors.white),
                        decoration: _dec("Chassis Number"),
                      ),

                      const SizedBox(height: 10),

                      TextField(
                        controller: plateController,
                        style: const TextStyle(color: Colors.white),
                        decoration: _dec("Plate Number"),
                      ),

                      const SizedBox(height: 10),

                      DropdownButtonFormField<String>(
                        value: fuelType,
                        dropdownColor: const Color(0xFF111111),
                        iconEnabledColor: Colors.white,
                        style: const TextStyle(color: Colors.white),
                        items: fuelTypes
                            .map((f) => DropdownMenuItem(
                                  value: f,
                                  child: Text(f),
                                ))
                            .toList(),
                        onChanged: (v) => setState(() => fuelType = v!),
                        decoration: _dec("Fuel Type", icon: Icons.local_gas_station),
                      ),

                      const SizedBox(height: 18),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: save,
                          icon: const Icon(Icons.save),
                          label: const Text("Save Changes"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
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