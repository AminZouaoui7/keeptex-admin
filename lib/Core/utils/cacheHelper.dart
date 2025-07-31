
import 'package:shared_preferences/shared_preferences.dart';

class CacheHelper {
  static late SharedPreferences sharedPreferences;

  // Initialize the SharedPreferences instance
  static Future<void> init() async {
    sharedPreferences = await SharedPreferences.getInstance();
  }



  // Get data as a string (specific method for String type)
  String? getDataString({required String key}) {
    return sharedPreferences.getString(key);
  }

  // Generic method to save any data type (bool, String, int, double)
  Future<bool> saveData({required String key, required dynamic value}) async {
    if (value is bool) {
      return await sharedPreferences.setBool(key, value);
    } else if (value is String) {
      return await sharedPreferences.setString(key, value);
    } else if (value is int) {
      return await sharedPreferences.setInt(key, value);
    } else if (value is double) {
      return await sharedPreferences.setDouble(key, value);
    } else {
      throw Exception("Unsupported data type");
    }
  }

  // Generic method to get any data type
  dynamic getData({required String key}) {
    return sharedPreferences.get(key);
  }

  // Remove data for a specific key
  Future<bool> removeData({required String key}) async {
    return await sharedPreferences.remove(key);
  }

  // Check if a key exists in SharedPreferences
  Future<bool> containsKey({required String key}) async {
    return sharedPreferences.containsKey(key);
  }

  // Clear all data stored in SharedPreferences
  Future<bool> clearData() async {
    return sharedPreferences.clear();
  }

  // Put method is similar to saveData, using specific types.
  Future<bool> put({
    required String key,
    required dynamic value,
  }) async {
    return await saveData(key: key, value: value);
  }

}

