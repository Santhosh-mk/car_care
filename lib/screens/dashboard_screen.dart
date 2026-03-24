import 'package:flutter/material.dart';
import '../widgets/feature_card.dart';
import 'vehicle_screen.dart';
import 'maintenance_screen.dart';
import 'tyre_screen.dart';
import 'breakdown_screen.dart';
import 'emergency_screen.dart';

class DashboardScreen extends StatelessWidget {
  final int userId;

  const DashboardScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("CarCare Dashboard")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            FeatureCard(
              title: "My Vehicles",
              icon: Icons.directions_car,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => VehicleScreen(userId: userId),
                ),
              ),
            ),
            FeatureCard(
              title: "Maintenance",
              icon: Icons.build,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => MaintenanceScreen(userId: userId),
                ),
              ),
            ),
            FeatureCard(
              title: "Tyre Pressure",
              icon: Icons.tire_repair,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const TyreScreen()),
              ),
            ),
            FeatureCard(
              title: "Breakdown Risk",
              icon: Icons.warning,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const BreakdownScreen()),
              ),
            ),
            FeatureCard(
              title: "Emergency",
              icon: Icons.emergency,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const EmergencyScreen()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}