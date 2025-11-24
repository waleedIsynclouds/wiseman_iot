/// Model representing the result of a lock key synchronization operation
/// Mirrors the native Android LockKeyResult class from LockFunViewModel
class LockKeyResultModel {
  final bool success;
  final String? message;
  final int? errorCode;

  LockKeyResultModel({required this.success, this.message, this.errorCode});

  /// Parse from JSON received from native platform
  factory LockKeyResultModel.fromJson(Map<String, dynamic> json) {
    return LockKeyResultModel(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String?,
      errorCode: json['errorCode'] as int?,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() => {
    'success': success,
    if (message != null) 'message': message,
    if (errorCode != null) 'errorCode': errorCode,
  };
}
