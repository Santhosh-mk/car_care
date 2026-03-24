import 'package:flutter/material.dart';

class TyreScreen extends StatefulWidget {
  const TyreScreen({super.key});

  @override
  State<TyreScreen> createState() => _TyreScreenState();
}

class _TyreScreenState extends State<TyreScreen> {
  final controller = TextEditingController();
  String result = "";

  void checkPressure() {
    final value = double.parse(controller.text);

    if (value < 28) {
      result = "⚠ Low Pressure - Fill Air Immediately";
    } else if (value <= 35) {
      result = "✅ Normal Pressure";
    } else {
      result = "⚠ High Pressure - Release Air";
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Tyre Pressure Assistant")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: controller,
              decoration: const InputDecoration(labelText: "Enter Tyre PSI"),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: checkPressure,
              child: const Text("Check Pressure"),
            ),
            const SizedBox(height: 20),
            Text(result, style: const TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}