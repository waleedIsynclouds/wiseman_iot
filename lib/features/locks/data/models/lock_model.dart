/// Model representing a lock device
/// Mirrors the native Android Lock class from the BLE SDK
class LockModel {
  final String lockMac;
  final String lockName;
  final int deviceType;
  final int projectID;
  final String hardWareVer;
  final String softWareVer;
  final int protocolVer;
  final int lockFunctionType;
  final int maxVolume;
  final int maxUserNum;
  final int menuFeature;
  final int rFModuleType;
  final String rFModuleMac;
  final int lockSystemFunction;
  final int lockNetSystemFunction;
  final String adminAuthCode;
  final String aesKey;

  LockModel({
    required this.lockMac,
    required this.lockName,
    required this.deviceType,
    required this.projectID,
    required this.hardWareVer,
    required this.softWareVer,
    required this.protocolVer,
    required this.lockFunctionType,
    required this.maxVolume,
    required this.maxUserNum,
    required this.menuFeature,
    required this.rFModuleType,
    required this.rFModuleMac,
    required this.lockSystemFunction,
    required this.lockNetSystemFunction,
    required this.adminAuthCode,
    required this.aesKey,
  });

  /// Convert to JSON for native platform communication
  Map<String, dynamic> toJson() => {
    'lockMac': lockMac,
    'lockName': lockName,
    'deviceType': deviceType,
    'projectID': projectID,
    'hardWareVer': hardWareVer,
    'softWareVer': softWareVer,
    'protocolVer': protocolVer,
    'lockFunctionType': lockFunctionType,
    'maxVolume': maxVolume,
    'maxUserNum': maxUserNum,
    'menuFeature': menuFeature,
    'rFModuleType': rFModuleType,
    'rFModuleMac': rFModuleMac,
    'lockSystemFunction': lockSystemFunction,
    'lockNetSystemFunction': lockNetSystemFunction,
    'adminAuthCode': adminAuthCode,
    'aesKey': aesKey,
  };

  /// Parse from JSON received from native platform
  factory LockModel.fromJson(Map<String, dynamic> json) {
    return LockModel(
      lockMac: json['lockMac'] as String? ?? '',
      lockName: json['lockName'] as String? ?? '',
      deviceType: json['deviceType'] as int? ?? 0,
      projectID: json['projectID'] as int? ?? 0,
      hardWareVer: json['hardWareVer'] as String? ?? '',
      softWareVer: json['softWareVer'] as String? ?? '',
      protocolVer: json['protocolVer'] as int? ?? 0,
      lockFunctionType: json['lockFunctionType'] as int? ?? 0,
      maxVolume: json['maxVolume'] as int? ?? 0,
      maxUserNum: json['maxUserNum'] as int? ?? 0,
      menuFeature: json['menuFeature'] as int? ?? 0,
      rFModuleType: json['rFModuleType'] as int? ?? 0,
      rFModuleMac: json['rFModuleMac'] as String? ?? '',
      lockSystemFunction: json['lockSystemFunction'] as int? ?? 0,
      lockNetSystemFunction: json['lockNetSystemFunction'] as int? ?? 0,
      adminAuthCode: json['adminAuthCode'] as String? ?? '',
      aesKey: json['aesKey'] as String? ?? '',
    );
  }
}
