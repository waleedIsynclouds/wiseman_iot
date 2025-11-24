/// Authentication response model from WisMan apartmentLogin
/// Contains the authentication token and expiration time
class AuthResponseModel {
  final String tokenId;
  final int expireTime; // in seconds

  AuthResponseModel({required this.tokenId, required this.expireTime});

  /// Parse from WisMan response data field
  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    return AuthResponseModel(
      tokenId: json['tokenId'] as String,
      expireTime: json['expireTime'] as int,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() => {
    'tokenId': tokenId,
    'expireTime': expireTime,
  };
}
