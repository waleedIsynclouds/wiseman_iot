import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

/// Utility class for handling runtime permissions
/// Manages Bluetooth and Location permissions required for BLE operations
class PermissionManager {
  /// Request all necessary permissions for BLE operations
  /// Returns true if all permissions are granted, false otherwise
  static Future<bool> requestBlePermissions() async {
    if (Platform.isAndroid) {
      // Check Android version to request appropriate permissions
      final androidInfo = await _getAndroidVersion();

      Map<Permission, PermissionStatus> statuses;

      if (androidInfo >= 31) {
        // Android 12+ (API 31+)
        statuses = await [
          Permission.bluetoothScan,
          Permission.bluetoothConnect,
          Permission.location, // Still needed for some devices
        ].request();
      } else if (androidInfo >= 23) {
        // Android 6.0 - 11 (API 23-30)
        statuses = await [
          Permission.bluetooth,
          Permission.location,
          Permission.locationWhenInUse,
        ].request();
      } else {
        // Below Android 6.0, permissions are granted at install time
        return true;
      }

      // Check if all permissions are granted
      return statuses.values.every((status) => status.isGranted);
    } else if (Platform.isIOS) {
      // iOS permissions
      final status = await Permission.bluetooth.request();
      return status.isGranted;
    }

    return false;
  }

  /// Check if BLE permissions are currently granted
  static Future<bool> checkBlePermissions() async {
    if (Platform.isAndroid) {
      final androidInfo = await _getAndroidVersion();

      if (androidInfo >= 31) {
        // Android 12+
        final bluetoothScan = await Permission.bluetoothScan.status;
        final bluetoothConnect = await Permission.bluetoothConnect.status;
        final location = await Permission.location.status;

        return bluetoothScan.isGranted &&
            bluetoothConnect.isGranted &&
            location.isGranted;
      } else if (androidInfo >= 23) {
        // Android 6.0 - 11
        final bluetooth = await Permission.bluetooth.status;
        final location = await Permission.location.status;

        return bluetooth.isGranted && location.isGranted;
      } else {
        return true;
      }
    } else if (Platform.isIOS) {
      final status = await Permission.bluetooth.status;
      return status.isGranted;
    }

    return false;
  }

  /// Request location permission specifically
  static Future<bool> requestLocationPermission() async {
    final status = await Permission.location.request();
    return status.isGranted;
  }

  /// Check if location permission is granted
  static Future<bool> checkLocationPermission() async {
    final status = await Permission.location.status;
    return status.isGranted;
  }

  /// Open app settings if permissions are permanently denied
  static Future<void> openAppSettings() async {
    await openAppSettings();
  }

  /// Check if any permission is permanently denied
  static Future<bool> isPermissionPermanentlyDenied() async {
    if (Platform.isAndroid) {
      final androidInfo = await _getAndroidVersion();

      if (androidInfo >= 31) {
        final bluetoothScan = await Permission.bluetoothScan.status;
        final bluetoothConnect = await Permission.bluetoothConnect.status;
        final location = await Permission.location.status;

        return bluetoothScan.isPermanentlyDenied ||
            bluetoothConnect.isPermanentlyDenied ||
            location.isPermanentlyDenied;
      } else {
        final bluetooth = await Permission.bluetooth.status;
        final location = await Permission.location.status;

        return bluetooth.isPermanentlyDenied || location.isPermanentlyDenied;
      }
    }

    return false;
  }

  /// Get Android SDK version
  static Future<int> _getAndroidVersion() async {
    if (Platform.isAndroid) {
      // This is a simplified version
      // In production, you might want to use device_info_plus package
      // for accurate Android version detection
      return 31; // Default to Android 12+ for safety
    }
    return 0;
  }

  /// Show permission rationale dialog info
  static String getPermissionRationale() {
    if (Platform.isAndroid) {
      return 'This app requires Bluetooth and Location permissions to scan for and connect to smart locks. '
          'Location permission is needed by Android for BLE scanning, but your location data is not collected.';
    } else if (Platform.isIOS) {
      return 'This app requires Bluetooth permission to scan for and connect to smart locks.';
    }
    return 'Permissions are required for BLE functionality.';
  }
}
