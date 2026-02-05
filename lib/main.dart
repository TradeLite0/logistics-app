import 'package:flutter/material.dart';
import 'screens/gps_lock_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/client_dashboard.dart';
import 'screens/driver_dashboard.dart';
import 'screens/admin_dashboard.dart';
import 'screens/profile_screen.dart';
import 'screens/map_screen.dart';

void main() {
  runApp(const LogisticsApp());
}

class LogisticsApp extends StatefulWidget {
  const LogisticsApp({Key? key}) : super(key: key);

  @override
  State<LogisticsApp> createState() => _LogisticsAppState();
}

class _LogisticsAppState extends State<LogisticsApp> with WidgetsBindingObserver {
  bool _servicesEnabled = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Check services when app resumes
    if (state == AppLifecycleState.resumed) {
      _checkServices();
    }
  }

  Future<void> _checkServices() async {
    // This will trigger the GPSLockScreen to re-check
    setState(() {
      _servicesEnabled = false;
    });
  }

  void _onServicesEnabled() {
    setState(() {
      _servicesEnabled = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'نظام اللوجستيات',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF4CAF50),
        primarySwatch: Colors.green,
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.grey.shade100,
        // ستايل عام للأزرار
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        // ستايل عام لحقول الإدخال
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          filled: true,
          fillColor: Colors.grey.shade50,
        ),
      ),
      // شاشة البداية مع GPS Lock
      home: !_servicesEnabled
          ? GPSLockScreen(
              onServicesEnabled: _onServicesEnabled,
            )
          : const LoginScreen(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/client_dashboard': (context) => const ClientDashboard(),
        '/driver_dashboard': (context) => const DriverDashboard(),
        '/admin': (context) => const AdminDashboard(),
        '/profile': (context) => const ProfileScreen(),
        '/map': (context) => const MapScreen(
          destination: 'الموقع',
          lat: 30.0444,
          lng: 31.2357,
        ),
      },
    );
  }
}
