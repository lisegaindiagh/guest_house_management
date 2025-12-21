import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../Api/api_provider.dart';
import '../ui/login_screen.dart';
import 'colors.dart';
import 'session_key.dart';
import 'session_manager.dart';

class AppCommon {
  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  static AppColors colors = AppColors();
  static SharePref sharePref = SharePref();
  static SessionKey sessionKey = SessionKey();
  static ApiProvider apiProvider = ApiProvider();

  /*
  * Method is used to listen the internet connectivity changes
  * This method is called from Build of MyApp class
  * */
  static displayNetworkPopup() {
    Connectivity().onConnectivityChanged.listen((
      List<ConnectivityResult> result,
    ) {
      if (result[0] == ConnectivityResult.none) {
        AppCommon.offlineDialog();
      }
    });
  }

  /*
  * This Method is used to show dialog if no-internet
  * */
  static Future<dynamic> offlineDialog() async {
    if (!await AppCommon.isOnline()) {
      showDialog(
        context: navigatorKey.currentContext!,
        builder: (context) {
          return AlertDialog(
            title: Text("Alert"),
            content: Text("Please check your internet."),
            actions: [
              ElevatedButton(
                onPressed: () async {
                  if (await AppCommon.isOnline()) {
                    Navigator.pop(AppCommon.navigatorKey.currentContext!, true);
                    Navigator.pushReplacement(
                      navigatorKey.currentContext!,
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(),
                      ),
                    );
                  }
                },
                child: Text("Retry"),
              ),
            ],
          );
        },
      );
    }
  }

  /*
  * This Method is used to find internet connectivity in phone
  * */
  static Future<bool> isOnline() async {
    List<ConnectivityResult> isConnected = await Connectivity()
        .checkConnectivity();
    if (isConnected[0] == ConnectivityResult.mobile ||
        isConnected[0] == ConnectivityResult.wifi) {
      return true;
    } else {
      return false;
    }
  }

  /*
  * Method is use to check Empty blank or null of the variable
  * */
  static bool isEmpty<T>(T value) {
    if (value == null) {
      return true;
    }

    if (value is String && value.trim().isEmpty) {
      return true;
    }

    if (value is Iterable && value.isEmpty) {
      return true;
    }

    if (value is Map && value.isEmpty) {
      return true;
    }

    if (value.toString().trim() == "{}") {
      return true;
    }

    if (value.toString().trim() == "null") {
      return true;
    }

    return false;
  }

  /*
  * Method is use to convert any object to dynamic(Json).
  * */
  static dynamic decodeJson(var value) {
    return jsonDecode(value);
  }

  /*
  * Method is use to convert any object to dynamic(Json).
  * */
  static dynamic encodeJsonData(var value) {
    return jsonEncode(value);
  }

  /*
    Method is use to displayToast message
  * Parameters -
  *             BuildContext - Pass Context of you Screen.
  *             String - Pass String message witch one Display in Toast
  */
  static void displayToast(String message) {
    Fluttertoast.showToast(msg: message, gravity: ToastGravity.BOTTOM);
  }

  /// 🎨 Common InputDecoration
  static InputDecoration inputDecoration(
    String label, {
    String? hint,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      suffixIcon: suffixIcon,
      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      floatingLabelStyle: TextStyle(color: AppCommon.colors.primaryColor),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: AppCommon.colors.primaryColor, width: 2),
      ),
    );
  }
}
