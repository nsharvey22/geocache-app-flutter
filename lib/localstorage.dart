import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:async';

class LocalStorage {

  final storage = new FlutterSecureStorage();

  void writeValue(String key, String value) {
    storage.write(key: key, value: value);
  }

  void deleteValue(String key) async {
    await storage.delete(key: key);
  }

  Future readValue(String key) async {
    String value = await storage.read(key: key);
    return value;
  }

}