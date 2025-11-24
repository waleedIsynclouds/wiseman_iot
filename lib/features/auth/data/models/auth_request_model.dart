class AuthRequestModel {
  final String accountName;
  final String password; // MD5 hashed password

  AuthRequestModel({required this.accountName, required this.password});
  Map<String, dynamic> toMap() {
    return {'accountName': accountName, 'password': password};
  }

  factory AuthRequestModel.fromMap(Map<String, dynamic> map) {
    return AuthRequestModel(
      accountName: map['accountName'] ?? '',
      password: map['password'] ?? '',
    );
  }
  AuthRequestModel copyWith({String? accountName, String? password}) {
    return AuthRequestModel(
      accountName: accountName ?? this.accountName,
      password: password ?? this.password,
    );
  }
}
