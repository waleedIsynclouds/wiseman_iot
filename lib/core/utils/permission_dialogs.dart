import 'package:flutter/material.dart';
import 'package:wiseman_iot/core/utils/permission_manager.dart';

/// Utility widget for displaying permission-related dialogs
class PermissionDialogs {
  /// Show a dialog explaining why permissions are needed
  static Future<bool?> showPermissionRationaleDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Permissions Required'),
        content: Text(PermissionManager.getPermissionRationale()),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Grant Permissions'),
          ),
        ],
      ),
    );
  }

  /// Show a dialog when permissions are permanently denied
  static Future<bool?> showPermissionDeniedDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Permissions Denied'),
        content: const Text(
          'Bluetooth and Location permissions are required for this app to function properly.\n\n'
          'Please enable them in Settings to use BLE features.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await PermissionManager.openAppSettings();
              if (context.mounted) {
                Navigator.of(context).pop(true);
              }
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  /// Show a snackbar for permission errors
  static void showPermissionError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'Settings',
          textColor: Colors.white,
          onPressed: () {
            PermissionManager.openAppSettings();
          },
        ),
      ),
    );
  }

  /// Request permissions with user-friendly dialog flow
  static Future<bool> requestPermissionsWithDialog(BuildContext context) async {
    // First check if already granted
    final hasPermission = await PermissionManager.checkBlePermissions();
    if (hasPermission) {
      return true;
    }

    // Show rationale dialog
    final shouldRequest = await showPermissionRationaleDialog(context);
    if (shouldRequest != true) {
      return false;
    }

    // Request permissions
    final granted = await PermissionManager.requestBlePermissions();

    if (!granted) {
      // Check if permanently denied
      final isPermanentlyDenied =
          await PermissionManager.isPermissionPermanentlyDenied();

      if (isPermanentlyDenied && context.mounted) {
        await showPermissionDeniedDialog(context);
      } else if (context.mounted) {
        showPermissionError(
          context,
          'Permissions are required to use BLE features',
        );
      }
    }

    return granted;
  }
}
