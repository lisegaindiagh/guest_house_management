import 'package:shared_preferences/shared_preferences.dart';

/*
* class is use to store data in sharedPref
* */
class SharePref {
  /*
  * Method is used to Store string.
  * Parameters - Key = Mention key to store data
  *            - value = String type value here
  * */
  Future<bool> setString(String key, String value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return await prefs.setString(key, value);
  }

  /*
  * Method is used to Store Int.
  * Parameters - Key = Mention key to store data
  *            - value = int type value here
  * */
  Future<bool> setInt(String key, int value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return await prefs.setInt(key, value);
  }

  /*
  * Method is used to Store Int.
  * Parameters - Key = Mention key to store data
  *            - value = bool type value here
  * */
  Future<bool> setBool(String key, bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return await prefs.setBool(key, value);
  }

  /*
  * Method is used to get string.
  * Parameters - Key = Here we have to mention key from which data is stored.
  * */
  Future<String> getString(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(key) ?? "";
  }

  /*
  * Method is used to get Int.
  * Parameters - Key = Here we have to mention key from which data is stored.
  * */
  Future<int?> getInt(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt(key);
  }

  /*
  * Method is used to get bool.
  * Parameters - Key = Here we have to mention key from which data is stored.
  * */
  Future<bool?> getBool(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(key);
  }

  /*
  * Method is used to clear all the stored sharedPref
  * */
  Future<void> clearAllSharedPref() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  /*
  * Method iterates through each key-value pair in the map
  * and sets the preference in the SharedPreferences accordingly.
  * Throws [ArgumentError] if an unsupported value type is encountered.
  *
  * Parameters - prefMap = The map of key-value pair to store it in preference.
  * Ex. Map<String, dynamic> preferences = {
          SessionKey.LOGINTOKEN: res["NewToken"],
          SessionKey.CMPSETUP: res["CMPSetup"],
          SessionKey.COMPANYNAME: res["CompanyName"],
          SessionKey.GSTSTATEID: res["GSTStateId"],
        };
  */
  Future<void> setPreference(Map<String, dynamic> prefMap) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    prefMap.forEach((key, value) {
      if (value is String) {
        prefs.setString(key, value);
      } else if (value is int) {
        prefs.setInt(key, value);
      } else if (value is bool) {
        prefs.setBool(key, value);
      } else if (value is double) {
        prefs.setDouble(key, value);
      } else {
        throw ArgumentError('Unsupported value type');
      }
    });
  }

  /*
  * Method iterates through each key of list
  * and removes the preference in the SharedPreferences accordingly.
  *
  * Parameters - keyList = The list of key to remove it from preference.
  * Ex. List<String> keysToRemove = [
           SessionKey.LOGINTOKEN,
           SessionKey.CMPSETUP,
           SessionKey.COMPANYNAME,
           SessionKey.GSTSTATEID,
        ];
  * */
  Future<void> clearKeyBasedPref(List<String> keyList) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    for (var key in keyList) {
      prefs.remove(key);
    }
  }
}
