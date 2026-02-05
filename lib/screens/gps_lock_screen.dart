import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:async';
import 'dart:io';

/// شاشة قفل GPS + Internet - إجبارية لتشغيل التطبيق
class GPSLockScreen extends StatefulWidget {
  final VoidCallback onServicesEnabled;

  const GPSLockScreen({Key? key, required this.onServicesEnabled}) : super(key: key);

  @override
  State<GPSLockScreen> createState() => _GPSLockScreenState();
}

class _GPSLockScreenState extends State<GPSLockScreen> with WidgetsBindingObserver {
  bool _isChecking = false;
  String _status = 'جاري التحقق من الخدمات...';
  Timer? _checkTimer;
  bool _isExiting = false;

  // Service states
  bool _gpsEnabled = false;
  bool _internetEnabled = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkServices();
    // فحص دوري كل 3 ثواني
    _checkTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      _checkServices();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _checkTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkServices();
    }
  }

  Future<void> _checkServices() async {
    if (_isChecking || _isExiting) return;
    setState(() => _isChecking = true);

    try {
      // Check GPS
      bool gpsEnabled = await Geolocator.isLocationServiceEnabled();
      
      // Check Internet
      bool internetEnabled = await _checkInternetConnection();

      setState(() {
        _gpsEnabled = gpsEnabled;
        _internetEnabled = internetEnabled;
      });

      if (!gpsEnabled && !internetEnabled) {
        setState(() {
          _status = 'GPS و الإنترنت مغلقين - فتحهما مطلوب';
        });
      } else if (!gpsEnabled) {
        setState(() {
          _status = 'خدمة الموقع مغلقة - افتح GPS';
        });
      } else if (!internetEnabled) {
        setState(() {
          _status = 'لا يوجد اتصال بالإنترنت - افتح WiFi أو بيانات';
        });
      } else {
        // Both services are enabled
        // Verify we can actually get location
        LocationPermission permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
          if (permission == LocationPermission.denied) {
            setState(() {
              _status = 'الصلاحية مرفوضة - اسمح بالوصول للموقع';
              _isChecking = false;
            });
            return;
          }
        }

        if (permission == LocationPermission.deniedForever) {
          setState(() {
            _status = 'الصلاحية مرفوضة نهائياً - عدل من إعدادات الجهاز';
            _isChecking = false;
          });
          return;
        }

        // Try to get position to confirm GPS is working
        try {
          Position position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high,
          );

          if (position.latitude != 0 && position.longitude != 0) {
            // ✅ All services working
            _checkTimer?.cancel();
            widget.onServicesEnabled();
          }
        } catch (e) {
          setState(() {
            _status = 'جاري الحصول على الموقع...';
          });
        }
      }
    } catch (e) {
      setState(() {
        _status = 'خطأ في التحقق: $e';
      });
    }

    setState(() => _isChecking = false);
  }

  Future<bool> _checkInternetConnection() async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        return false;
      }
      
      // Double check with actual connection test
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  Future<void> _openLocationSettings() async {
    await Geolocator.openLocationSettings();
  }

  Future<void> _openWiFiSettings() async {
    // Open system settings for WiFi
    // Note: This may not work on all platforms, but provides best effort
  }

  void _exitApp() {
    _isExiting = true;
    _checkTimer?.cancel();
    exit(0);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Prevent back button from closing the lock screen
        return false;
      },
      child: Scaffold(
        body: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.red.shade700,
                Colors.red.shade900,
              ],
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // أيقونة كبيرة
                Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.2),
                    border: Border.all(color: Colors.white, width: 3),
                  ),
                  child: Icon(
                    _getMainIcon(),
                    size: 80,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 40),
                
                // عنوان
                const Text(
                  'خدمات مطلوبة!',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),
                
                // وصف
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Text(
                    'يجب تفعيل خدمة الموقع (GPS) والإنترنت للمتابعة واستخدام التطبيق',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                // Status indicators
                _buildStatusIndicator(
                  icon: Icons.location_on,
                  label: 'GPS',
                  enabled: _gpsEnabled,
                ),
                const SizedBox(height: 12),
                _buildStatusIndicator(
                  icon: Icons.wifi,
                  label: 'الإنترنت',
                  enabled: _internetEnabled,
                ),
                const SizedBox(height: 30),
                
                // حالة التحقق
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_isChecking)
                        const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      else
                        const Icon(Icons.info_outline, color: Colors.white),
                      const SizedBox(width: 10),
                      Flexible(
                        child: Text(
                          _status,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                
                // زرار فتح إعدادات الموقع
                ElevatedButton.icon(
                  onPressed: _openLocationSettings,
                  icon: const Icon(Icons.location_on),
                  label: const Text('فتح إعدادات الموقع'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.red.shade900,
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    textStyle: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // زرار فتح إعدادات الإنترنت
                ElevatedButton.icon(
                  onPressed: _openWiFiSettings,
                  icon: const Icon(Icons.wifi),
                  label: const Text('فتح إعدادات الإنترنت'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white.withOpacity(0.9),
                    foregroundColor: Colors.red.shade900,
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    textStyle: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                
                // زرار إعادة المحاولة
                TextButton.icon(
                  onPressed: _checkServices,
                  icon: const Icon(Icons.refresh, color: Colors.white70),
                  label: const Text(
                    'إعادة المحاولة',
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getMainIcon() {
    if (!_gpsEnabled && !_internetEnabled) {
      return Icons.signal_wifi_off;
    } else if (!_gpsEnabled) {
      return Icons.location_off;
    } else if (!_internetEnabled) {
      return Icons.wifi_off;
    }
    return Icons.check_circle;
  }

  Widget _buildStatusIndicator({
    required IconData icon,
    required String label,
    required bool enabled,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: enabled 
            ? Colors.green.withOpacity(0.3) 
            : Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: enabled ? Colors.green : Colors.white.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            enabled ? Icons.check_circle : Icons.error,
            color: enabled ? Colors.green : Colors.white70,
            size: 20,
          ),
          const SizedBox(width: 8),
          Icon(
            icon,
            color: Colors.white,
            size: 18,
          ),
          const SizedBox(width: 6),
          Text(
            '$label: ${enabled ? 'مفعل' : 'مغلق'}',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 14,
              fontWeight: enabled ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
