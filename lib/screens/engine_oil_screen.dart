import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../database/database_helper.dart';
import '../models/vehicle.dart';
import '../services/reminder_service.dart';

class EngineOilScreen extends StatefulWidget {
  final int userId;
  const EngineOilScreen({super.key, required this.userId});

  @override
  State<EngineOilScreen> createState() => _EngineOilScreenState();
}

class _EngineOilScreenState extends State<EngineOilScreen> {
  List<Vehicle> vehicles = [];
  Vehicle? selectedVehicle;

  final mileageController = TextEditingController();
  final oilController = TextEditingController(); // litres (decimal allowed)
  DateTime selectedDate = DateTime.now();

  Map<String, dynamic>? latestOil;

  @override
  void initState() {
    super.initState();
    loadVehicles();
  }

  Future<void> loadVehicles() async {
    vehicles = await DatabaseHelper.instance.getVehicles(widget.userId);
    if (vehicles.isNotEmpty) {
      selectedVehicle = vehicles.first;
      await loadLatest();
    }
    if (mounted) setState(() {});
  }

  Future<void> loadLatest() async {
    if (selectedVehicle == null) return;

    final all = await DatabaseHelper.instance.getServices(selectedVehicle!.id!);
    final engineOil =
        all.where((s) => (s['serviceType'] ?? '') == 'Engine Oil').toList();

    latestOil = engineOil.isNotEmpty ? engineOil.first : null;
    if (mounted) setState(() {});
  }

  // ======================
  // VEHICLE RULES
  // ======================

  int _kmInterval(String type) {
    switch (type.toLowerCase()) {
      case 'bike':
        return 4000;
      case 'van':
        return 5000;
      case 'jeep':
        return 9000;
      case 'lorry':
        return 35000;
      case 'car':
      default:
        return 12000;
    }
  }

  int _monthInterval(String type) {
    switch (type.toLowerCase()) {
      case 'bike':
        return 6;
      default:
        return 8;
    }
  }

  DateTime _addMonths(DateTime dt, int months) {
    final y = dt.year + ((dt.month - 1 + months) ~/ 12);
    final m = ((dt.month - 1 + months) % 12) + 1;
    final lastDay = DateTime(y, m + 1, 0).day;
    final day = dt.day <= lastDay ? dt.day : lastDay;
    return DateTime(y, m, day, 9, 0);
  }

  // ======================
  // SAVE + NOTIFICATION
  // ======================

  Future<void> saveEngineOil() async {
    if (selectedVehicle == null) return;

    final mileage = int.tryParse(mileageController.text.trim());
    final oilLitres = double.tryParse(oilController.text.trim()); // ✅ decimal

    if (mileage == null || oilLitres == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Mileage must be number and Oil must be decimal (Litres)")),
      );
      return;
    }

    final service = {
      'vehicleId': selectedVehicle!.id,
      'serviceType': 'Engine Oil',
      'date': DateFormat('yyyy-MM-dd').format(selectedDate),
      'mileage': mileage,
      'oilAmount': oilLitres, // ✅ REAL column
    };

    final serviceId = await DatabaseHelper.instance.insertService(service);

    await ReminderService.scheduleServiceReminders(
      baseId: serviceId,
      serviceDate: selectedDate,
      title: "Engine Oil Service Due",
      body:
          "${selectedVehicle!.vehicleType} • ${selectedVehicle!.model} (${selectedVehicle!.plateNumber})",
    );

    mileageController.clear();
    oilController.clear();

    await loadLatest();

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Engine oil saved & reminder set")),
    );
  }

  @override
  void dispose() {
    mileageController.dispose();
    oilController.dispose();
    super.dispose();
  }

  // ======================
  // UI HELPERS
  // ======================

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

    int? baseMileage;
    DateTime? baseDate;
    final type = v?.vehicleType ?? "Car";

    if (latestOil != null) {
      baseMileage = latestOil!['mileage'] as int?;
      final d = latestOil!['date'] as String?;
      if (d != null) baseDate = DateTime.tryParse(d);
    }

    final kmAdd = _kmInterval(type);
    final monthAdd = _monthInterval(type);

    final nextMileage = (baseMileage != null) ? (baseMileage + kmAdd) : null;
    final nextDate = (baseDate != null) ? _addMonths(baseDate, monthAdd) : null;

    final lastOilLitres = (latestOil?['oilAmount'] as num?)?.toDouble();

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
          title: const Text("Engine Oil"),
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
                  await loadLatest();
                },
                decoration: _dec("Select Vehicle", icon: Icons.directions_car),
              ),

              const SizedBox(height: 12),

              // LAST + NEXT CARD
              Container(
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Last Engine Oil Change",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white),
                    ),
                    const SizedBox(height: 8),
                    if (latestOil == null)
                      const Text("No engine oil records yet.", style: TextStyle(color: Colors.white70))
                    else ...[
                      Text("Date: ${latestOil!['date']}", style: const TextStyle(color: Colors.white70)),
                      Text("Mileage: ${latestOil!['mileage']} km", style: const TextStyle(color: Colors.white70)),
                      Text(
                        "Oil Used: ${lastOilLitres?.toStringAsFixed(1) ?? '-'} L",
                        style: const TextStyle(color: Colors.white70),
                      ),
                      const SizedBox(height: 10),
                      Divider(color: Colors.white.withOpacity(0.12)),
                      const SizedBox(height: 8),
                      Text(
                        "Next Due (for $type):",
                        style: const TextStyle(fontWeight: FontWeight.w800, color: Colors.white),
                      ),
                      const SizedBox(height: 6),
                      Text("Next Mileage: ${nextMileage ?? '-'} km", style: const TextStyle(color: Colors.white70)),
                      Text(
                        "Next Date: ${nextDate != null ? DateFormat('yyyy-MM-dd').format(nextDate) : '-'}",
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 18),

              const Text(
                "Add Engine Oil Change",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white),
              ),
              const SizedBox(height: 10),

              TextField(
                controller: mileageController,
                keyboardType: TextInputType.number,
                decoration: _dec("Current Mileage (km)", icon: Icons.speed),
              ),
              const SizedBox(height: 10),

              TextField(
                controller: oilController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: _dec("Oil Used (Litres)", icon: Icons.oil_barrel),
              ),

              const SizedBox(height: 10),

              Row(
                children: [
                  Expanded(
                    child: Text(
                      "Date: ${DateFormat('yyyy-MM-dd').format(selectedDate)}",
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2035),
                        initialDate: selectedDate,
                      );
                      if (picked != null) setState(() => selectedDate = picked);
                    },
                    icon: const Icon(Icons.date_range, color: Colors.blueAccent),
                    label: const Text("Pick", style: TextStyle(color: Colors.blueAccent)),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              ElevatedButton(
                onPressed: saveEngineOil,
                child: const Text("Save & Set Reminder"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}