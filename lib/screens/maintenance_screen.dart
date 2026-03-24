import 'package:flutter/material.dart';
import 'engine_oil_screen.dart';
import 'tyre_pressure_screen.dart';
import 'brake_pads_screen.dart';
import 'brake_oil_screen.dart';

class MaintenanceScreen extends StatelessWidget {
  final int userId;
  const MaintenanceScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Container(
      // ✅ Gradient Background (Blue → Black)
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
          title: const Text("Maintenance"),
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: Colors.white,
        ),
        body: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ✅ Header Card (Dark + Blue Glow)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFF111111),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.blueAccent.withOpacity(0.35)),
                  boxShadow: const [
                    BoxShadow(
                      blurRadius: 18,
                      color: Colors.black54,
                      offset: Offset(0, 10),
                    )
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      height: 52,
                      width: 52,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: const LinearGradient(
                          colors: [Colors.blueAccent, Color(0xFF00D4FF)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: const Icon(Icons.build, color: Colors.white),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Keep your vehicle safe",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(
                            "Track and schedule important maintenance tasks easily.",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),

              const SizedBox(height: 18),

              const Text(
                "Maintenance Tasks",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),

              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 14,
                  childAspectRatio: 0.95,
                  children: [
                    _TaskCard(
                      title: "Engine Oil",
                      subtitle: "Next due reminder",
                      icon: Icons.oil_barrel,
                      accent: Colors.orangeAccent,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => EngineOilScreen(userId: userId),
                        ),
                      ),
                    ),
                    _TaskCard(
                      title: "Tyre Pressure",
                      subtitle: "PSI check + reminder",
                      icon: Icons.tire_repair,
                      accent: Colors.greenAccent,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => TyrePressureScreen(userId: userId),
                        ),
                      ),
                    ),
                    _TaskCard(
                      title: "Brake Pads",
                      subtitle: "Wear + alerts",
                      icon: Icons.car_repair,
                      accent: Colors.redAccent,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BrakePadsScreen(userId: userId),
                        ),
                      ),
                    ),
                    _TaskCard(
                      title: "Brake Oil",
                      subtitle: "Time + KM rules",
                      icon: Icons.water_drop,
                      accent: Colors.lightBlueAccent,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BrakeOilScreen(userId: userId),
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
    );
  }
}

class _TaskCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color accent;
  final VoidCallback onTap;

  const _TaskCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Ink(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF111111),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: accent.withOpacity(0.25)),
          boxShadow: const [
            BoxShadow(
              blurRadius: 16,
              color: Colors.black54,
              offset: Offset(0, 10),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon badge
            Container(
              height: 46,
              width: 46,
              decoration: BoxDecoration(
                color: accent.withOpacity(0.18),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: accent),
            ),

            const SizedBox(height: 14),

            Text(
              title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 12.5,
                color: Colors.white70,
                height: 1.25,
              ),
            ),

            const Spacer(),

            Align(
              alignment: Alignment.bottomRight,
              child: Icon(Icons.arrow_forward_ios, size: 16, color: accent),
            ),
          ],
        ),
      ),
    );
  }
}