import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import 'vehicle_setup_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final name = TextEditingController();
  final address = TextEditingController();
  final contact = TextEditingController();
  final username = TextEditingController();
  final password = TextEditingController();

  bool isLoading = false;

  // 🔥 SAVE USER + NAVIGATE
  void next() async {
    try {
      // ✅ VALIDATION
      if (name.text.isEmpty ||
          address.text.isEmpty ||
          contact.text.isEmpty ||
          username.text.isEmpty ||
          password.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please fill all fields")),
        );
        return;
      }

      setState(() => isLoading = true);

      print("Saving user...");

      int userId = await DatabaseHelper.instance.insertUser({
        'name': name.text.trim(),
        'address': address.text.trim(),
        'contact': contact.text.trim(),
        'username': username.text.trim(),
        'password': password.text.trim(),
      });

      print("User saved with ID: $userId");

      // ✅ NAVIGATE TO VEHICLE SETUP
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => VehicleSetupScreen(userId: userId),
        ),
      );
    } catch (e) {
      print("ERROR: $e");

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  // 🔥 INPUT FIELD WIDGET (Reusable)
  Widget buildField(
    TextEditingController controller,
    String label, {
    bool isPassword = false,
    TextInputType? type,
  }) {
    return Column(
      children: [
        TextField(
          controller: controller,
          obscureText: isPassword,
          keyboardType: type,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            labelText: label,
            labelStyle: const TextStyle(color: Colors.white70),
            filled: true,
            fillColor: Colors.black.withOpacity(0.4),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0F1C),
      appBar: AppBar(
        title: const Text("Create Account"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            const SizedBox(height: 10),

            const Text(
              "Create Your Account",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 20),

            buildField(name, "Name"),
            buildField(address, "Address"),
            buildField(contact, "Contact", type: TextInputType.phone),
            buildField(username, "Username"),
            buildField(password, "Password", isPassword: true),

            const SizedBox(height: 10),

            // 🔥 BUTTON WITH LOADING
            ElevatedButton(
              onPressed: isLoading ? null : next,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      "Next",
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}