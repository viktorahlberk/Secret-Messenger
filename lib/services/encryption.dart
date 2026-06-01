import 'dart:convert' show base64, json, utf8;
import 'package:flutter/foundation.dart';
import 'package:secure_messenger/services/firebase/database.dart';
import 'package:webcrypto/webcrypto.dart';

import 'dart:typed_data';
import 'package:shared_preferences/shared_preferences.dart';

class EncryptionService {
  static Future<bool> privateKeyExist() async {
    final sPreferences = await SharedPreferences.getInstance();
    String? privateKey = sPreferences.getString('key');
    return privateKey != null ? true : false;
  }

  static Future<KeyPair<EcdhPrivateKey, EcdhPublicKey>> generateKeys() async {
    KeyPair<EcdhPrivateKey, EcdhPublicKey> keyPair =
        await EcdhPrivateKey.generateKey(EllipticCurve.p256);

    return keyPair;
  }

  static Future<Uint8List> createCryptoKey(
    EcdhPrivateKey myPrivateKey,
    EcdhPublicKey receiverPublicKey,
  ) async {
    Uint8List cryptoKey = await myPrivateKey.deriveBits(256, receiverPublicKey);
    return cryptoKey;
  }

  static Future<String> encryptMessage(
      String message, receiverPublicKey) async {
    AesGcmSecretKey aesGcmSecretKey;

    final Uint8List iv = Uint8List.fromList('Initialization Vector'.codeUnits);

    // var encodedKey = preferences.getString('key');
    bool privateKeyExist = await EncryptionService.privateKeyExist();
    if (!privateKeyExist) {
      throw Exception('Private encryption key is missing from this device');
    }

    final preferences = await SharedPreferences.getInstance();
    String? encodedKey = preferences.getString('key');

    dynamic myPrivateKeyJwk = json.decode(encodedKey!);
    EcdhPrivateKey x = await EcdhPrivateKey.importJsonWebKey(
        myPrivateKeyJwk, EllipticCurve.p256);
    EcdhPublicKey y = await EcdhPublicKey.importJsonWebKey(
        json.decode(receiverPublicKey), EllipticCurve.p256);
    Uint8List cryptoKey = await EncryptionService.createCryptoKey(x, y);

    aesGcmSecretKey = await AesGcmSecretKey.importRawKey(cryptoKey);
    List<int> list = message.codeUnits;
    Uint8List data = Uint8List.fromList(list);
    Uint8List encryptedBytes = await aesGcmSecretKey.encryptBytes(data, iv);
    String encryptedString = String.fromCharCodes(encryptedBytes);
    // print('encryptedString $encryptedString');
    return encryptedString;
  }

  static Future<String> decryptMessage(
      String encryptedMessage, senderUid) async {
    final Uint8List iv = Uint8List.fromList('Initialization Vector'.codeUnits);
    final preferences = await SharedPreferences.getInstance();
    var encodedKey = preferences.getString('key');
    if (encodedKey == null) {
      throw Exception('Private encryption key is missing from this device');
    }
    var myPrivateKeyJwk = json.decode(encodedKey);
    EcdhPrivateKey x = await EcdhPrivateKey.importJsonWebKey(
        myPrivateKeyJwk, EllipticCurve.p256);
    var senderPublicKey = await DatabaseService.fetchUserPublicKey(senderUid);
    EcdhPublicKey y = await EcdhPublicKey.importJsonWebKey(
        json.decode(senderPublicKey), EllipticCurve.p256);
    Uint8List cryptoKey = await EncryptionService.createCryptoKey(x, y);

    var aesGcmSecretKey = await AesGcmSecretKey.importRawKey(cryptoKey);

    List<int> message = Uint8List.fromList(encryptedMessage.codeUnits);

    Uint8List decryptdBytes = await aesGcmSecretKey.decryptBytes(message, iv);

    String decryptdString = String.fromCharCodes(decryptdBytes);
    // print('decryptdString $decryptdString');
    return decryptdString;
  }
}
