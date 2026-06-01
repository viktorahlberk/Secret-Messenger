import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  // String? _privateKey;

  Future<bool> privateKeyExist() async {
    final sPreferences = await SharedPreferences.getInstance();
    String? privateKey = sPreferences.getString('key');
    return privateKey != null ? true : false;
  }

  Future<String> getPrivateKey() async {
    final preferences = await SharedPreferences.getInstance();
    String? key = preferences.getString('key');
    if (key == null) {
      throw Exception('Private encryption key is missing from this device');
    }
    return key;
  }
}
