import 'package:flutter/material.dart';

class BreakdownScreen extends StatefulWidget {
  const BreakdownScreen({super.key});

  @override
  State<BreakdownScreen> createState() => _BreakdownScreenState();
}

class _BreakdownScreenState extends State<BreakdownScreen> {
  final mileageController = TextEditingController();
  String risk = "";

  void calculateRisk() {
    final mileage = int.parse(mileageController.text);

    if (mileage > 8000) {
      risk = "🔴 HIGH RISK - Immediate Service Required";
    } else if (mileage > 5000) {
      risk = "🟡 MEDIUM RISK - Service Recommended Soon";
    } else {
      risk = "🟢 LOW RISK";
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Breakdown Prediction")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: mileageController,
              decoration: const InputDecoration(labelText: "Mileage After Last Service"),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: calculateRisk,
              child: const Text("Check Risk"),
            ),
            const SizedBox(height: 20),
            Text(risk, style: const TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}