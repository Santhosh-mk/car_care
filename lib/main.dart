import 'package:flutter/material.dart';
import 'Core/theme.dart';
import 'services/reminder_service.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ReminderService.init();
  runApp(const CarCareApp());
}

class CarCareApp extends StatelessWidget {
  const CarCareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "CarCare",
      theme: AppTheme.darkBlueTheme,
      home: const SplashScreen(), 
    );
  }
}