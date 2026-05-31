import 'dart:convert';
import 'package:fast_rsa/fast_rsa.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:cryptography/cryptography.dart' hide Hash;

class PickRecipient {
  final String recipientId;
  final String publicKey;

  const PickRecipient({
    required this.recipientId,
    required this.publicKey,
  });
}

class EncryptedBundle {
  final Map<String, String> decryptionKeys;
  final String nonce;
  final String ciphertext;
  final String tag;

  const EncryptedBundle({
    required this.decryptionKeys,
    required this.nonce,
    required this.ciphertext,
    required this.tag,
  });
}

class Crypto {
  static const _privateKeyStorageKey = 'private_key';
  static const _publicKeyStorageKey = 'public_key';

  final FlutterSecureStorage _storage;

  String? _cachedPrivateKey;
  String? _cachedPublicKey;

  Crypto({FlutterSecureStorage? storage})
      : _storage = storage ??
      const FlutterSecureStorage(
        aOptions: AndroidOptions(encryptedSharedPreferences: true),
        iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
      );

  Future<void> generateAndStoreKeyPair() async {
    final keyPair = await RSA.generate(2048);
    await Future.wait([
      _storage.write(key: _privateKeyStorageKey, value: keyPair.privateKey),
      _storage.write(key: _publicKeyStorageKey, value: keyPair.publicKey),
    ]);
    _cachedPrivateKey = keyPair.privateKey;
    _cachedPublicKey = keyPair.publicKey;
  }

  Future<bool> hasKeyPair() async {
    final key = await _storage.read(key: _publicKeyStorageKey);
    return key != null;
  }

  Future<void> ensureKeyPair() async {
    if (_cachedPublicKey != null) return;
    if (!await hasKeyPair()) {
      await generateAndStoreKeyPair();
      return;
    }
    final results = await Future.wait([
      _storage.read(key: _privateKeyStorageKey),
      _storage.read(key: _publicKeyStorageKey),
    ]);
    _cachedPrivateKey = results[0];
    _cachedPublicKey = results[1];
  }

  Future<String> getPublicKey() async {
    await ensureKeyPair();
    return _cachedPublicKey!;
  }

  Future<void> deleteKeyPair() async {
    await Future.wait([
      _storage.delete(key: _privateKeyStorageKey),
      _storage.delete(key: _publicKeyStorageKey),
    ]);
    _cachedPrivateKey = null;
    _cachedPublicKey = null;
  }

  Future<EncryptedBundle> encrypt(
      String plaintext,
      List<PickRecipient> recipients,
      ) async {
    final aesAlgorithm = AesGcm.with256bits();
    final aesSecretKey = await aesAlgorithm.newSecretKey();
    final aesKeyBytes = await aesSecretKey.extractBytes();
    final aesKeyB64 = base64.encode(aesKeyBytes);

    final nonce = aesAlgorithm.newNonce();
    final secretBox = await aesAlgorithm.encrypt(
      utf8.encode(plaintext),
      secretKey: aesSecretKey,
      nonce: nonce,
    );

    final wrappedKeys = await Future.wait(
      recipients.map(
            (r) async => MapEntry(
          r.recipientId,
          await RSA.encryptOAEP(aesKeyB64, '', Hash.SHA256, r.publicKey),
        ),
      ),
    );

    return EncryptedBundle(
      decryptionKeys: Map.fromEntries(wrappedKeys),
      nonce: base64.encode(secretBox.nonce),
      ciphertext: base64.encode(secretBox.cipherText),
      tag: base64.encode(secretBox.mac.bytes),
    );
  }

  Future<String> decrypt(EncryptedBundle bundle, String myRecipientId) async {
    await ensureKeyPair();

    final wrappedKey = bundle.decryptionKeys[myRecipientId];
    if (wrappedKey == null) {
      throw ArgumentError('No decryption key found for recipient $myRecipientId');
    }

    final aesKeyB64 = await RSA.decryptOAEP(
      wrappedKey,
      '',
      Hash.SHA256,
      _cachedPrivateKey!,
    );

    final aesAlgorithm = AesGcm.with256bits();
    final aesSecretKey = await aesAlgorithm.newSecretKeyFromBytes(
      base64.decode(aesKeyB64),
    );

    final plainBytes = await aesAlgorithm.decrypt(
      SecretBox(
        base64.decode(bundle.ciphertext),
        nonce: base64.decode(bundle.nonce),
        mac: Mac(base64.decode(bundle.tag)),
      ),
      secretKey: aesSecretKey,
    );
    return utf8.decode(plainBytes);
  }
}