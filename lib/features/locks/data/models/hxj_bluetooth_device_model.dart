/// Model representing a Bluetooth device discovered during BLE scanning
/// Mirrors the native Android HxjBluetoothDevice class
class HxjBluetoothDeviceModel {
  final String mac;
  final String name;
  final int rssi;
  final String? manufacturerData;

  HxjBluetoothDeviceModel({
    required this.mac,
    required this.name,
    required this.rssi,
    this.manufacturerData,
  });

  /// Parse from JSON received from native platform
  factory HxjBluetoothDeviceModel.fromJson(Map<String, dynamic> json) {
    return HxjBluetoothDeviceModel(
      mac: json['mac'] as String? ?? '',
      name: json['name'] as String? ?? '',
      rssi: json['rssi'] as int? ?? 0,
      manufacturerData: json['manufacturerData'] as String?,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() => {
    'mac': mac,
    'name': name,
    'rssi': rssi,
    if (manufacturerData != null) 'manufacturerData': manufacturerData,
  };
}
