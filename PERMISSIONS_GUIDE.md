# Permission Handling Guide

## Overview

The WisMan IoT app now includes comprehensive permission handling for Bluetooth and Location access, which are required for BLE operations on Android devices.

## Package Added

- **permission_handler** (^11.0.1) - Handles runtime permissions

## Permissions Required

### Android
- **Bluetooth Scan** (Android 12+) - For discovering BLE devices
- **Bluetooth Connect** (Android 12+) - For connecting to BLE devices
- **Bluetooth** (Android 11 and below) - Legacy Bluetooth permission
- **Location** (All versions) - Required by Android for BLE scanning
- **Internet** - For WisMan API communication

### iOS
- **Bluetooth** - For BLE operations

## How It Works

### Automatic Permission Requests

All BLE operations in `HxjBleManager` now **automatically request permissions** before executing:

```dart
// Example: Scanning for devices
final bleManager = HxjBleManager();

// Permissions are automatically requested when you call startScan
bleManager.startScan(timeoutMillis: 10000).listen(
  (devices) {
    print('Found ${devices.length} devices');
  },
  onError: (error) {
    // Handle permission denied or other errors
    print('Error: $error');
  },
);
```

### Methods with Auto-Permission

These methods automatically request permissions:

1. **`startScan()`** - Requests Bluetooth + Location
2. **`connect(mac)`** - Requests Bluetooth
3. **`syncLockKeys(lock)`** - Requests Bluetooth
4. **`openLock(lock)`** - Requests Bluetooth

### Manual Permission Check

You can manually check/request permissions:

```dart
import 'package:wiseman_iot/core/utils/permission_manager.dart';

// Check if permissions are granted
final hasPermissions = await PermissionManager.checkBlePermissions();

if (!hasPermissions) {
  // Request permissions
  final granted = await PermissionManager.requestBlePermissions();
  
  if (!granted) {
    print('Permissions denied');
  }
}
```

### Using Permission Dialogs

For better UX, use `PermissionDialogs` to show user-friendly dialogs:

```dart
import 'package:wiseman_iot/core/utils/permission_dialogs.dart';

// Request with dialog flow
final granted = await PermissionDialogs.requestPermissionsWithDialog(context);

if (granted) {
  // Proceed with BLE operations
  bleManager.startScan();
} else {
  // Show error message
  PermissionDialogs.showPermissionError(
    context, 
    'Cannot scan without permissions'
  );
}
```

## Example: Complete Permission Flow in UI

```dart
class LockScanPage extends StatelessWidget {
  final HxjBleManager bleManager = HxjBleManager();

  Future<void> _startScanning(BuildContext context) async {
    try {
      // Option 1: Let HxjBleManager handle permissions automatically
      bleManager.startScan(timeoutMillis: 10000).listen(
        (devices) {
          // Update UI with devices
          print('Found: ${devices.map((d) => d.name).join(", ")}');
        },
        onError: (error) {
          // Show error to user
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Scan error: $error')),
          );
        },
      );
    } catch (e) {
      // Handle permission denied exception
      if (e.toString().contains('permission')) {
        PermissionDialogs.showPermissionDeniedDialog(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan for Locks')),
      body: Center(
        child: ElevatedButton(
          onPressed: () => _startScanning(context),
          child: const Text('Start Scan'),
        ),
      ),
    );
  }
}
```

## Example: Pre-request Permissions

If you want to request permissions upfront (e.g., on app launch):

```dart
class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    // Check on app start
    final hasPermissions = await PermissionManager.checkBlePermissions();
    
    if (!hasPermissions) {
      // Optionally show a dialog explaining why
      // But don't force request until user tries to use BLE
      print('BLE permissions not granted - will request when needed');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WisMan IoT',
      home: LoginPage(),
    );
  }
}
```

## Handling Permission States

### Permission Granted
```dart
final granted = await PermissionManager.requestBlePermissions();
if (granted) {
  // Proceed with BLE operations
}
```

### Permission Denied (First Time)
```dart
if (!granted) {
  // User denied, but can request again
  // Show explanation and try again later
}
```

### Permission Permanently Denied
```dart
final isPermanent = await PermissionManager.isPermissionPermanentlyDenied();
if (isPermanent) {
  // User denied and selected "Don't ask again"
  // Must open app settings
  await PermissionManager.openAppSettings();
}
```

## Android Manifest

Permissions are already configured in `android/app/src/main/AndroidManifest.xml`:

```xml
<!-- Bluetooth Permissions for Android 12+ -->
<uses-permission android:name="android.permission.BLUETOOTH_SCAN" />
<uses-permission android:name="android.permission.BLUETOOTH_CONNECT" />
<uses-permission android:name="android.permission.BLUETOOTH_ADVERTISE" />

<!-- Bluetooth Permissions for Android 11 and below -->
<uses-permission android:name="android.permission.BLUETOOTH" 
    android:maxSdkVersion="30" />
<uses-permission android:name="android.permission.BLUETOOTH_ADMIN" 
    android:maxSdkVersion="30" />

<!-- Location (required for BLE on Android) -->
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
```

## Testing Permissions

### Test on Real Device
Permissions work differently on emulators. Test on a real Android device:

1. Install app
2. Try to scan for locks
3. Permission dialog should appear
4. Grant or deny permissions
5. Test the flow

### Reset Permissions (For Testing)
To test permission flow multiple times:

```bash
# Via ADB (Android Debug Bridge)
adb shell pm reset-permissions com.example.wiseman_iot

# Or manually:
# Settings → Apps → WisMan IoT → Permissions → Reset
```

## Common Issues

### Issue: "Location permission required for BLE scanning"
**Solution**: This is required by Android for BLE scanning. The app doesn't actually use your location - it's an Android system requirement.

### Issue: Permissions granted but BLE still doesn't work
**Solution**: 
- Ensure Bluetooth is enabled in device settings
- Ensure Location services are enabled (Android requirement)
- Check Android version compatibility

### Issue: Permission dialog doesn't appear
**Solution**:
- Check that permissions are declared in AndroidManifest.xml
- Ensure app has `compileSdkVersion` 31+ for Android 12 permissions
- Try uninstalling and reinstalling the app

## Best Practices

1. **Request Just-in-Time**: Request permissions only when the user tries to use a feature
2. **Explain Why**: Use dialogs to explain why permissions are needed
3. **Handle Denial Gracefully**: Don't crash if permissions are denied
4. **Provide Alternatives**: If permissions denied, disable features gracefully
5. **Settings Shortcut**: Provide easy way to open app settings

## Permission Flow Diagram

```
User taps "Scan for Locks"
    ↓
Check if permissions granted
    ↓
    ├─ Yes → Start scanning
    └─ No → Request permissions
              ↓
              ├─ Granted → Start scanning
              └─ Denied → Show error/explanation
                          ↓
                          ├─ Try again later
                          └─ Permanently denied → Open Settings
```

## API Reference

### PermissionManager

```dart
// Request BLE permissions
Future<bool> requestBlePermissions()

// Check if permissions are granted
Future<bool> checkBlePermissions()

// Request location permission specifically
Future<bool> requestLocationPermission()

// Check if location permission is granted
Future<bool> checkLocationPermission()

// Check if any permission is permanently denied
Future<bool> isPermissionPermanentlyDenied()

// Open app settings
Future<void> openAppSettings()

// Get permission rationale text
String getPermissionRationale()
```

### PermissionDialogs

```dart
// Show rationale dialog
Future<bool?> showPermissionRationaleDialog(BuildContext context)

// Show permanently denied dialog
Future<bool?> showPermissionDeniedDialog(BuildContext context)

// Show permission error snackbar
void showPermissionError(BuildContext context, String message)

// Complete permission request flow with dialogs
Future<bool> requestPermissionsWithDialog(BuildContext context)
```

---

**Note**: The permission system is fully integrated into `HxjBleManager`, so in most cases, you don't need to manually handle permissions - they're requested automatically when you call BLE methods!
