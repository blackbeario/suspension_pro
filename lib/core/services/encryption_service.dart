import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:ridemetrx/core/utilities/random_key_generator.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class EncryptionService {
  // The singleton instance
  static final EncryptionService _instance = EncryptionService._internal();

  // Private constructor
  EncryptionService._internal();

  // Factory constructor to return the same instance
  factory EncryptionService() => _instance;

  // Encryption key
  encrypt.Key? _key;

  // Create storage
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // Method to initialize the encryption key
  void init(String keyString) {
    // _key = encrypt.Key.fromUtf8(keyString);
    _key = encrypt.Key.fromBase64(keyString);
  }

  // Method to encrypt data
  Future<String> encryptData(String plainText) async {
    init(generateRandomKey());
    await _storage.write(key: 'encryptionKey', value: _key!.base64);

    if (_key == null) {
      throw Exception('Encryption key is not initialized.');
    }
    final iv = encrypt.IV.fromLength(16); // Generate a random IV
    final encrypter = encrypt.Encrypter(encrypt.AES(_key!, mode: encrypt.AESMode.cbc)); //  padding: null

    final encrypted = encrypter.encrypt(plainText, iv: iv);
    final ivBase64 = iv.base64;
    final encryptedBase64 = encrypted.base64;

    return '$ivBase64:$encryptedBase64'; // Store IV and ciphertext together
  }

  // Method to decrypt data
  Future<String> decryptData(String encryptedData) async {
    String? _base64Key = await _storage.read(key: 'encryptionKey');
    if (_base64Key == null) {
      throw Exception('Encryption key is not initialized.');
    }
    final parts = encryptedData.split(':');
    final iv = encrypt.IV.fromBase64(parts[0]); // Extract the IV
    final encrypted = encrypt.Encrypted.fromBase64(parts[1]);

    _key = encrypt.Key.fromBase64(_base64Key);
    final encrypter = encrypt.Encrypter(encrypt.AES(_key!, mode: encrypt.AESMode.cbc));
    final decrypted = encrypter.decrypt(encrypted, iv: iv);

    return decrypted;
  }
}
