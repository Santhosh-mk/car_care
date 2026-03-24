import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../database/database_helper.dart';
import '../models/vehicle.dart';
import '../services/reminder_service.dart';

class BrakePadsScreen extends StatefulWidget {
  final int userId;
  const BrakePadsScreen({super.key, required this.userId});

  @override
  State<BrakePadsScreen> createState() => _BrakePadsScreenState();
}

class _BrakePadsScreenState extends State<BrakePadsScreen> {
  List<Vehicle> vehicles = [];
  Vehicle? selectedVehicle;

  final currentMileageController = TextEditingController();
  DateTime changeDate = DateTime.now();

  Map<String, dynamic>? lastBrakePads;

  String statusText = "";
  Color statusColor = Colors.grey;

  bool _notifiedNearDue = false;

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
        all.where((s) => (s['serviceType'] ?? '') == 'Brake Pads').toList();

    lastBrakePads = records.isNotEmpty ? records.first : null;

    _notifiedNearDue = false;
    statusText = "";
    statusColor = Colors.grey;

    if (mounted) setState(() {});
  }

  (int minKm, int maxKm) _lifeRange(String type) {
    switch (type.toLowerCase()) {
      case 'bike':
        return (8000, 15000);
      case 'van':
        return (20000, 60000);
      case 'lorry':
        return (40000, 80000);
      case 'jeep':
        return (30000, 70000);
      case 'car':
      default:
        return (30000, 70000);
    }
  }

  Future<void> _updateStatusAndMaybeNotify() async {
    final v = selectedVehicle;
    if (v == null || lastBrakePads == null) return;

    final typedMileage = int.tryParse(currentMileageController.text.trim());
    if (typedMileage == null) return;

    final lastMileage = (lastBrakePads?['mileage'] as int?) ?? 0;
    final range = _lifeRange(v.vehicleType);

    final used = typedMileage - lastMileage;
    final remaining = range.$2 - used;

    if (remaining <= 0) {
      setState(() {
        statusText = "OVERDUE ❌ Change brake pads now!";
        statusColor = Colors.red;
      });
      return;
    }

    if (remaining <= 5000) {
      setState(() {
        statusText = "NEAR DUE ⚠️ Only $remaining km remaining";
        statusColor = Colors.orange;
      });

      if (!_notifiedNearDue) {
        _notifiedNearDue = true;
        await ReminderService.showInstant(
          id: 8000 + (v.id ?? 0),
          title: "Brake Pads Near Due",
          body:
              "${v.vehicleType} • ${v.model} (${v.plateNumber}) - Only $remaining km left",
        );
      }
      return;
    }

    setState(() {
      statusText = "OK ✅ About $remaining km remaining";
      statusColor = Colors.green;
    });
  }

  Future<void> saveBrakePadsChange() async {
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
      'serviceType': 'Brake Pads',
      'date': DateFormat('yyyy-MM-dd').format(changeDate),
      'mileage': mileage,
    };

    final serviceId =
        await DatabaseHelper.instance.insertService(service);

    // 6 month reminder
    await ReminderService.scheduleSixMonthReminder(
      baseId: serviceId,
      fromDate: changeDate,
      title: "Brake Pads Check Reminder",
      body:
          "${selectedVehicle!.vehicleType} • ${selectedVehicle!.model} (${selectedVehicle!.plateNumber}) - Check brake pads",
    );

    currentMileageController.clear();
    _notifiedNearDue = false;

    await loadLastRecord();

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Saved + 6 month reminder set")),
    );
  }

  InputDecoration _dec(String label, {IconData? icon}) {
    return InputDecoration(
      labelText: label,
      filled: true,
      prefixIcon: icon == null ? null : Icon(icon),
    );
  }

  @override
  Widget build(BuildContext context) {
    final v = selectedVehicle;
    final type = v?.vehicleType ?? "Car";
    final range = _lifeRange(type);

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
          title: const Text("Brake Pads"),
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: Colors.white,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: ListView(
            children: [

              // VEHICLE DROPDOWN
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
                  await loadLastRecord();
                },
                decoration: _dec("Select Vehicle", icon: Icons.directions_car),
              ),

              const SizedBox(height: 16),

              // RANGE CARD
              _darkCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Brake Pads Lifespan",
                        style: TextStyle(
                            fontWeight: FontWeight.w800,
                            color: Colors.white)),
                    const SizedBox(height: 6),
                    Text("$type: ${range.$1} – ${range.$2} km",
                        style: const TextStyle(color: Colors.white70)),
                    const SizedBox(height: 4),
                    const Text("Alert when within last 5000 km",
                        style: TextStyle(color: Colors.white60)),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // LAST RECORD
              _darkCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Last Change",
                        style: TextStyle(
                            fontWeight: FontWeight.w800,
                            color: Colors.white)),
                    const SizedBox(height: 6),
                    if (lastBrakePads == null)
                      const Text("No records yet.",
                          style: TextStyle(color: Colors.white70))
                    else ...[
                      Text("Date: ${lastBrakePads!['date']}",
                          style: const TextStyle(color: Colors.white70)),
                      Text("Mileage: ${lastBrakePads!['mileage']} km",
                          style: const TextStyle(color: Colors.white70)),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 16),

              const Text("Add Brake Pads Change",
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Colors.white)),

              const SizedBox(height: 10),

              TextField(
                controller: currentMileageController,
                keyboardType: TextInputType.number,
                onChanged: (_) => _updateStatusAndMaybeNotify(),
                decoration: _dec("Current Mileage (km)", icon: Icons.speed),
              ),

              const SizedBox(height: 10),

              ElevatedButton(
                onPressed: saveBrakePadsChange,
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

  Widget _darkCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
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
}