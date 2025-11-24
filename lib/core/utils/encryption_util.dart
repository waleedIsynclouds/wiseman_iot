import 'dart:convert';
import 'package:crypto/crypto.dart';

class EncryptionUtil {
  /// Returns the MD5 hash of the password as an uppercase hexadecimal string.
  static String md5Encrypt(String password) {
    final bytes = utf8.encode(password);
    final digest = md5.convert(bytes);
    return digest.toString().toUpperCase();
  }
}
