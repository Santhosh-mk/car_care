import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'vehicle_screen.dart';
import 'maintenance_screen.dart';
import 'emergency_screen.dart';
import 'settings_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  final int userId;

  const MainNavigationScreen({super.key, required this.userId});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();

    _pages = [
      HomeScreen(userId: widget.userId),
      VehicleScreen(userId: widget.userId),
      MaintenanceScreen(userId: widget.userId),
      const EmergencyScreen(),
      SettingsScreen(userId: widget.userId), // ✅ new
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed, // ✅ needed for 5 items
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.directions_car), label: "Vehicles"),
          BottomNavigationBarItem(icon: Icon(Icons.build), label: "Maintenance"),
          BottomNavigationBarItem(icon: Icon(Icons.map), label: "Emergency"),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Settings"), // ✅ new
        ],
      ),
    );
  }
}