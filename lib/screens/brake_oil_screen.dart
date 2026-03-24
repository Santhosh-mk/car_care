import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../database/database_helper.dart';
import '../models/vehicle.dart';
import '../services/reminder_service.dart';

class BrakeOilScreen extends StatefulWidget {
  final int userId;
  const BrakeOilScreen({super.key, required this.userId});

  @override
  State<BrakeOilScreen> createState() => _BrakeOilScreenState();
}

// ✅ Works on all Dart versions (no records)
class KmRange {
  final int minKm;
  final int maxKm;
  const KmRange(this.minKm, this.maxKm);
}

class _BrakeOilScreenState extends State<BrakeOilScreen> {
  List<Vehicle> vehicles = [];
  Vehicle? selectedVehicle;

  final currentMileageController = TextEditingController();
  DateTime changeDate = DateTime.now();

  Map<String, dynamic>? lastBrakeOil;

  String statusText = "";
  Color statusColor = Colors.grey;

  @override
  void initState() {
    super.initState();
    loadVehicles();
  }

  Future<void> loadVehicles() async {
    vehicles = await DatabaseHelper.instance.getVehicles(widget.userId);
    if (vehicles.isNotEmpty) {
      selectedVehicle = vehicles.first;
      await loadLastRecord();
    }
    if (mounted) setState(() {});
  }

  Future<void> loadLastRecord() async {
    if (selectedVehicle == null) return;

    final all = await DatabaseHelper.instance.getServices(selectedVehicle!.id!);
    final records =
        all.where((s) => (s['serviceType'] ?? '') == 'Brake Oil').toList();

    lastBrakeOil = records.isNotEmpty ? records.first : null;
    if (mounted) setState(() {});
  }

  // ======================
  // RULES
  // ======================

  KmRange _kmRange(String type) {
    switch (type.toLowerCase()) {
      case 'bike':
        return const KmRange(15000, 30000);
      case 'van':
        return const KmRange(30000, 45000);
      case 'jeep':
        return const KmRange(45000, 50000);
      case 'lorry':
        return const KmRange(30000, 50000);
      case 'car':
      default:
        return const KmRange(40000, 70000);
    }
  }

  int _intervalMonths(String type) {
    switch (type.toLowerCase()) {
      case 'bike':
        return 18; // 1.5 years
      default:
        return 30; // 2.5 years
    }
  }

  DateTime _addMonths(DateTime dt, int months) {
    final y = dt.year + ((dt.month - 1 + months) ~/ 12);
    final m = ((dt.month - 1 + months) % 12) + 1;
    final lastDay = DateTime(y, m + 1, 0).day;
    final day = dt.day <= lastDay ? dt.day : lastDay;
    return DateTime(y, m, day, 9, 0);
  }

  Future<void> pickDate() async {
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      initialDate: changeDate,
    );
    if (picked != null) setState(() => changeDate = picked);
  }

  void _evaluateMileageStatus({
    required int currentMileage,
    required int lastChangeMileage,
    required int maxKm,
  }) {
    final used = currentMileage - lastChangeMileage;
    final remaining = maxKm - used;

    if (remaining <= 0) {
      statusText = "OVERDUE ❌ Change Brake Oil now!";
      statusColor = Colors.red;
    } else if (remaining <= 5000) {
      statusText = "NEAR DUE ⚠️ Only $remaining km remaining";
      statusColor = Colors.orange;
    } else {
      statusText = "OK ✅ About $remaining km remaining";
      statusColor = Colors.green;
    }
  }

  InputDecoration _dec(String label, {IconData? icon}) {
    return InputDecoration(
      labelText: label,
      filled: true,
      prefixIcon: icon == null ? null : Icon(icon),
    );
  }

  // ======================
  // SAVE + NOTIFICATIONS
  // ======================

  Future<void> saveBrakeOilChange() async {
    if (selectedVehicle == null) return;

    final mileage = int.tryParse(currentMileageController.text.trim());
    if (mileage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Mileage must be a number")),
      );
      return;
    }

    final service = {
      'vehicleId': selectedVehicle!.id,
      'serviceType': 'Brake Oil',
      'date': DateFormat('yyyy-MM-dd').format(changeDate),
      'mileage': mileage,
    };

    final serviceId = await DatabaseHelper.instance.insertService(service);

    final months = _intervalMonths(selectedVehicle!.vehicleType);
    final dueDate = _addMonths(changeDate, months);

    // ✅ 2 months before + on due date (inexact schedules)
    await ReminderService.scheduleTwoDateReminders(
      baseId: serviceId,
      dueDate: dueDate,
      monthsBefore: 2,
      titleSoon: "Brake Oil Due Soon",
      bodySoon:
          "${selectedVehicle!.vehicleType} • ${selectedVehicle!.model} (${selectedVehicle!.plateNumber}) - Brake oil due in 2 months",
      titleDue: "Brake Oil Due Today",
      bodyDue:
          "${selectedVehicle!.vehicleType} • ${selectedVehicle!.model} (${selectedVehicle!.plateNumber}) - Change brake oil today",
    );

    currentMileageController.clear();
    await loadLastRecord();

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "Saved! Reminders set for ${DateFormat('yyyy-MM-dd').format(dueDate)}",
        ),
      ),
    );
  }

  @override
  void dispose() {
    currentMileageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final v = selectedVehicle;
    final type = v?.vehicleType ?? "Car";

    final kmRange = _kmRange(type);
    final months = _intervalMonths(type);

    int? lastMileage;
    DateTime? lastDate;

    if (lastBrakeOil != null) {
      lastMileage = lastBrakeOil!['mileage'] as int?;
      final d = lastBrakeOil!['date'] as String?;
      if (d != null) lastDate = DateTime.tryParse(d);
    }

    final dueDate = (lastDate != null) ? _addMonths(lastDate, months) : null;

    final typedMileage = int.tryParse(currentMileageController.text.trim());
    if (typedMileage != null && lastMileage != null) {
      _evaluateMileageStatus(
        currentMileage: typedMileage,
        lastChangeMileage: lastMileage,
        maxKm: kmRange.maxKm,
      );
    }

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0D1B2A), Color(0xFF1B263B), Color(0xFF000000)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text("Brake Oil"),
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
                  setState(() {
                    selectedVehicle = newV;
                    statusText = "";
                  });
                  await loadLastRecord();
                },
                decoration: _dec("Select Vehicle", icon: Icons.directions_car),
              ),

              const SizedBox(height: 12),

              // Rules card
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF111111),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Colors.blueAccent.withOpacity(0.22)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Brake Oil Rule",
                        style: TextStyle(fontWeight: FontWeight.w800, color: Colors.white)),
                    const SizedBox(height: 6),
                    Text("$type mileage: ${kmRange.minKm} – ${kmRange.maxKm} km",
                        style: const TextStyle(color: Colors.white70)),
                    Text("Time interval: ${months / 12} years ($months months)",
                        style: const TextStyle(color: Colors.white70)),
                    const SizedBox(height: 6),
                   
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Last record + due date
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF111111),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Colors.blueAccent.withOpacity(0.22)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Last Brake Oil Change",
                        style: TextStyle(fontWeight: FontWeight.w800, color: Colors.white)),
                    const SizedBox(height: 6),
                    if (lastBrakeOil == null)
                      const Text("No brake oil records yet.",
                          style: TextStyle(color: Colors.white70))
                    else ...[
                      Text("Date: ${lastBrakeOil!['date']}",
                          style: const TextStyle(color: Colors.white70)),
                      Text("Mileage: ${lastBrakeOil!['mileage']} km",
                          style: const TextStyle(color: Colors.white70)),
                      const SizedBox(height: 8),
                      Divider(color: Colors.white.withOpacity(0.12)),
                      const SizedBox(height: 8),
                      Text(
                        "Next Due Date: ${dueDate != null ? DateFormat('yyyy-MM-dd').format(dueDate) : '-'}",
                        style: const TextStyle(fontWeight: FontWeight.w800, color: Colors.white),
                      ),
                    ]
                  ],
                ),
              ),

              const SizedBox(height: 14),

              const Text(
                "Add Brake Oil Change",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white),
              ),
              const SizedBox(height: 10),

              TextField(
                controller: currentMileageController,
                keyboardType: TextInputType.number,
                onChanged: (_) => setState(() {}),
                decoration: _dec("Current Mileage (km)", icon: Icons.speed),
              ),

              const SizedBox(height: 10),

              Row(
                children: [
                  Expanded(
                    child: Text(
                      "Change Date: ${DateFormat('yyyy-MM-dd').format(changeDate)}",
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: pickDate,
                    icon: const Icon(Icons.date_range, color: Colors.blueAccent),
                    label: const Text("Pick", style: TextStyle(color: Colors.blueAccent)),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              ElevatedButton(
                onPressed: saveBrakeOilChange,
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
                    style: TextStyle(fontWeight: FontWeight.bold, color: statusColor),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}