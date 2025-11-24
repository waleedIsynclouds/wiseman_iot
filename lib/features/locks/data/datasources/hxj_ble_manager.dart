import 'dart:async';
import 'package:flutter/services.dart';
import 'package:wiseman_iot/core/utils/permission_manager.dart';
import 'package:wiseman_iot/features/locks/data/models/hxj_bluetooth_device_model.dart';
import 'package:wiseman_iot/features/locks/data/models/lock_key_result_model.dart';
import 'package:wiseman_iot/features/locks/data/models/lock_model.dart';

/// Flutter manager for HXJ BLE SDK operations
/// Communicates with native Android code via MethodChannel and EventChannel
///
/// This class wraps the native Android BLE SDK (HxjScanner, HxjBleClient, MyBleClient)
/// and provides a Dart API for:
/// - Scanning for BLE locks
/// - Connecting/disconnecting
/// - Syncing lock keys
/// - Opening locks
/// - Other lock operations
///
/// All methods automatically request necessary permissions before executing
class HxjBleManager {
  static const MethodChannel _channel = MethodChannel(
    'com.example.hxjblesdk/ble',
  );
  static const EventChannel _scanChannel = EventChannel(
    'com.example.hxjblesdk/ble_scan',
  );

  StreamController<List<HxjBluetoothDeviceModel>>? _scanStreamController;

  /// Start BLE scan for locks
  /// [timeoutMillis] - Scan timeout in milliseconds
  /// Returns a stream of discovered devices
  ///
  /// Automatically requests Bluetooth and Location permissions before scanning
  /// Throws [Exception] if permissions are denied
  Stream<List<HxjBluetoothDeviceModel>> startScan({
    int timeoutMillis = 10000,
  }) async* {
    // Request permissions first
    final hasPermission = await PermissionManager.requestBlePermissions();
    if (!hasPermission) {
      final isPermanentlyDenied =
          await PermissionManager.isPermissionPermanentlyDenied();
      if (isPermanentlyDenied) {
        throw Exception(
          'Bluetooth and Location permissions are required for scanning. '
          'Please enable them in Settings.\n\n'
          '${PermissionManager.getPermissionRationale()}',
        );
      } else {
        throw Exception(
          'Bluetooth and Location permissions are required for scanning.\n\n'
          '${PermissionManager.getPermissionRationale()}',
        );
      }
    }

    _scanStreamController?.close();
    _scanStreamController = StreamController<List<HxjBluetoothDeviceModel>>();

    // Start listening to scan results from native
    _scanChannel
        .receiveBroadcastStream(timeoutMillis)
        .listen(
          (event) {
            if (event is List) {
              final devices = event
                  .map(
                    (json) => HxjBluetoothDeviceModel.fromJson(
                      json as Map<String, dynamic>,
                    ),
                  )
                  .toList();
              _scanStreamController?.add(devices);
            }
          },
          onError: (error) {
            _scanStreamController?.addError(error);
          },
          onDone: () {
            _scanStreamController?.close();
          },
        );

    // Invoke native method to start scan
    try {
      await _channel.invokeMethod('startScan', {
        'timeoutMillis': timeoutMillis,
      });
    } catch (e) {
      _scanStreamController?.addError(e);
    }

    yield* _scanStreamController!.stream;
  }

  /// Stop BLE scan
  Future<void> stopScan() async {
    try {
      await _channel.invokeMethod('stopScan');
      _scanStreamController?.close();
      _scanStreamController = null;
    } on PlatformException catch (e) {
      throw Exception('Failed to stop scan: ${e.message}');
    }
  }

  /// Connect to a lock device
  /// [mac] - MAC address of the lock
  ///
  /// Automatically requests Bluetooth permissions before connecting
  /// Throws [Exception] if permissions are denied
  Future<bool> connect(String mac) async {
    // Request permissions first
    final hasPermission = await PermissionManager.requestBlePermissions();
    if (!hasPermission) {
      throw Exception(
        'Bluetooth permission is required to connect to locks.\n\n'
        '${PermissionManager.getPermissionRationale()}',
      );
    }

    try {
      final result = await _channel.invokeMethod('connect', {'mac': mac});
      return result as bool? ?? false;
    } on PlatformException catch (e) {
      throw Exception('Failed to connect: ${e.message}');
    }
  }

  /// Disconnect from current lock
  Future<void> disconnect() async {
    try {
      await _channel.invokeMethod('disconnect');
    } on PlatformException catch (e) {
      throw Exception('Failed to disconnect: ${e.message}');
    }
  }

  /// Sync lock keys with the device
  /// This corresponds to the syncLockKeys operation in LockFunViewModel
  /// [lock] - Lock model with device information
  ///
  /// Automatically requests Bluetooth permissions before syncing
  /// TODO: Add additional parameters based on native LockFunViewModel implementation
  Future<LockKeyResultModel> syncLockKeys(LockModel lock) async {
    // Request permissions first
    final hasPermission = await PermissionManager.requestBlePermissions();
    if (!hasPermission) {
      return LockKeyResultModel(
        success: false,
        message:
            'Bluetooth permission is required to sync lock keys.\n\n'
            '${PermissionManager.getPermissionRationale()}',
        errorCode: -1,
      );
    }

    try {
      final result = await _channel.invokeMethod('syncLockKeys', {
        'lock': lock.toJson(),
      });
      return LockKeyResultModel.fromJson(result as Map<String, dynamic>);
    } on PlatformException catch (e) {
      return LockKeyResultModel(
        success: false,
        message: e.message,
        errorCode: int.tryParse(e.code),
      );
    }
  }

  /// Open a lock
  /// [lock] - Lock model with device information
  ///
  /// Automatically requests Bluetooth permissions before opening
  /// TODO: Add additional parameters (e.g., user credentials) based on native implementation
  Future<LockKeyResultModel> openLock(LockModel lock) async {
    // Request permissions first
    final hasPermission = await PermissionManager.requestBlePermissions();
    if (!hasPermission) {
      return LockKeyResultModel(
        success: false,
        message:
            'Bluetooth permission is required to open locks.\n\n'
            '${PermissionManager.getPermissionRationale()}',
        errorCode: -1,
      );
    }

    try {
      final result = await _channel.invokeMethod('openLock', {
        'lock': lock.toJson(),
      });
      return LockKeyResultModel.fromJson(result as Map<String, dynamic>);
    } on PlatformException catch (e) {
      return LockKeyResultModel(
        success: false,
        message: e.message,
        errorCode: int.tryParse(e.code),
      );
    }
  }

  // TODO: Add more methods based on LockFunViewModel:
  // - closeLock()
  // - deleteUser()
  // - addUser()
  // - updateFirmware()
  // - queryLockStatus()
  // etc.

  /// Dispose resources
  void dispose() {
    _scanStreamController?.close();
  }
}
