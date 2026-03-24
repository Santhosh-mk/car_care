import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../database/database_helper.dart';
import '../models/vehicle.dart';

class TyrePressureScreen extends StatefulWidget {
  final int userId;
  const TyrePressureScreen({super.key, required this.userId});

  @override
  State<TyrePressureScreen> createState() => _TyrePressureScreenState();
}

class _TyrePressureScreenState extends State<TyrePressureScreen> {
  List<Vehicle> vehicles = [];
  Vehicle? selectedVehicle;

  final psiController = TextEditingController();
  final mileageController = TextEditingController();

  DateTime checkedDate = DateTime.now();

  String statusText = "";
  Color statusColor = Colors.grey;

  Map<String, dynamic>? latestTyre;

  @override
  void initState() {
    super.initState();
    loadVehicles();
  }

  Future<void> loadVehicles() async {
    vehicles = await DatabaseHelper.instance.getVehicles(widget.userId);

    if (vehicles.isNotEmpty) {
      selectedVehicle = vehicles.first;
      await loadLatestTyre();
    }

    if (mounted) setState(() {});
  }

  Future<void> loadLatestTyre() async {
    if (selectedVehicle == null) return;

    final all = await DatabaseHelper.instance.getServices(selectedVehicle!.id!);

    final tyreRecords =
        all.where((s) => (s['serviceType'] ?? '') == 'Tyre Pressure').toList();

    latestTyre = tyreRecords.isNotEmpty ? tyreRecords.first : null;

    if (mounted) setState(() {});
  }

  // ======================
  // PSI RANGE RULES
  // ======================
  (double, double) _psiRange(String type) {
    switch (type.toLowerCase()) {
      case 'bike':
        return (28, 40);
      case 'car':
        return (31, 35);
      case 'lorry':
        return (116, 131);
      case 'jeep':
        return (30, 40);
      case 'van':
        return (30, 35);
      default:
        return (30, 35);
    }
  }

  void _evaluatePressure(double psi, double min, double max) {
    if (psi < min) {
      final diff = (min - psi).toStringAsFixed(1);
      statusText = "LOW ⚠️ Increase air by $diff PSI";
      statusColor = Colors.orange;
    } else if (psi > max) {
      final diff = (psi - max).toStringAsFixed(1);
      statusText = "HIGH ⚠️ Release $diff PSI";
      statusColor = Colors.red;
    } else {
      statusText = "NORMAL ✅ Tyre pressure is within safe range";
      statusColor = Colors.green;
    }
  }

  Future<void> pickDate() async {
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      initialDate: checkedDate,
    );
    if (picked != null) setState(() => checkedDate = picked);
  }

  Future<void> saveCheck() async {
    print("Entered saveCheck");

    if (selectedVehicle == null) {
      print("No vehicle selected");
      return;
    }

    final psi = double.tryParse(psiController.text.trim());
    final mileage = int.tryParse(mileageController.text.trim());

    print("PSI: $psi");
    print("Mileage: $mileage");

    if (psi == null || mileage == null) {
      print("Invalid input");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Enter valid PSI and mileage")),
      );
      return;
    }

    try {
      final service = {
        'vehicleId': selectedVehicle!.id,
        'serviceType': 'Tyre Pressure',
        'date': DateFormat('yyyy-MM-dd').format(checkedDate),
        'mileage': mileage,
        'tyrePressure': psi,
      };

      print("Inserting into DB...");

      final serviceId = await DatabaseHelper.instance.insertService(service);

      print("Inserted with ID: $serviceId");

      // refresh latest + clear fields
      psiController.clear();
      mileageController.clear();
      await loadLatestTyre();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Saved Successfully")),
      );
    } catch (e) {
      print("ERROR OCCURRED:");
      print(e);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  InputDecoration _dec(String label, {IconData? icon}) {
    return InputDecoration(
      labelText: label,
      filled: true,
      prefixIcon: icon == null ? null : Icon(icon),
    );
  }

  Widget _darkCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.blueAccent.withOpacity(0.22)),
        boxShadow: const [
          BoxShadow(
            blurRadius: 18,
            color: Colors.black54,
            offset: Offset(0, 10),
          )
        ],
      ),
      child: child,
    );
  }

  @override
  void dispose() {
    psiController.dispose();
    mileageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final v = selectedVehicle;
    final range = v == null ? (30.0, 35.0) : _psiRange(v.vehicleType);

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
          title: const Text("Tyre Pressure"),
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: Colors.white,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: ListView(
            children: [
              DropdownButtonFormField<Vehicle>(
                value: v,
                items: vehicles
                    .map((item) => DropdownMenuItem(
                          value: item,
                          child: Text("${item.vehicleType} • ${item.model}"),
                        ))
                    .toList(),
                onChanged: (newV) async {
                  setState(() => selectedVehicle = newV);
                  await loadLatestTyre();
                },
                decoration:
                    _dec("Select Vehicle", icon: Icons.directions_car),
              ),
              const SizedBox(height: 14),

              if (latestTyre != null)
                _darkCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Last Tyre Check",
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text("Date: ${latestTyre!['date']}",
                          style: const TextStyle(color: Colors.white70)),
                      Text("PSI: ${latestTyre!['tyrePressure']}",
                          style: const TextStyle(color: Colors.white70)),
                      Text("Mileage: ${latestTyre!['mileage']} km",
                          style: const TextStyle(color: Colors.white70)),
                    ],
                  ),
                ),

              _darkCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Suggested Tyre Pressure",
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text("Range: ${range.$1} – ${range.$2} PSI",
                        style: const TextStyle(color: Colors.white70)),
                  ],
                ),
              ),

              TextField(
                controller: psiController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                onChanged: (value) {
                  final psi = double.tryParse(value);
                  if (psi != null && selectedVehicle != null) {
                    final (min, max) =
                        _psiRange(selectedVehicle!.vehicleType);
                    _evaluatePressure(psi, min, max);
                    setState(() {});
                  }
                },
                decoration: _dec("Enter current PSI", icon: Icons.tire_repair),
              ),
              const SizedBox(height: 10),

              TextField(
                controller: mileageController,
                keyboardType: TextInputType.number,
                decoration: _dec("Current Mileage (km)", icon: Icons.speed),
              ),
              const SizedBox(height: 10),

              _darkCard(
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        "Checked Date: ${DateFormat('yyyy-MM-dd').format(checkedDate)}",
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: pickDate,
                      icon: const Icon(Icons.date_range),
                      label: const Text("Pick"),
                    ),
                  ],
                ),
              ),

              ElevatedButton(
                onPressed: saveCheck,
                child: const Text("Save"),
              ),

              const SizedBox(height: 14),

              if (statusText.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF111111),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: statusColor),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: statusColor),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}