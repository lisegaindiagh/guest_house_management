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
  static bool isLoadingProcess = false;
  static bool canBook = false;
  static bool canViewBooking = false;
  static bool canManageRooms = false;
  static bool canMangeUsers = false;

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
  static Future<void> offlineDialog() async {
    if (!await AppCommon.isOnline()) {
      showDialog(
        context: AppCommon.navigatorKey.currentContext!,
        barrierDismissible: false,
        builder: (context) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// 🌐 Header
                  Row(
                    children: [
                      Container(
                        height: 44,
                        width: 44,
                        decoration: BoxDecoration(
                          color: Colors.orange.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.wifi_off_rounded,
                          color: Colors.orange,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          "No Internet Connection",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  /// 📄 Message
                  const Text(
                    "Please check your internet connection and try again.",
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),

                  const SizedBox(height: 20),

                  /// Divider
                  Divider(color: Colors.grey.shade200, thickness: 1),

                  const SizedBox(height: 12),

                  /// 🔘 Actions
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppCommon.colors.primaryColor,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () async {
                        if (await AppCommon.isOnline()) {
                          Navigator.pop(context);
                          Navigator.pushReplacement(
                            AppCommon.navigatorKey.currentContext!,
                            MaterialPageRoute(
                              builder: (_) => const LoginScreen(),
                            ),
                          );
                        }
                      },
                      child: const Text(
                        "Retry",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
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

  static void startLoadingProcess(BuildContext context) {
    if (!isLoadingProcess) {
      isLoadingProcess = true;
      // Show the loading dialog
      showLoadingDialog(context);
    }
  }

  /*
  * Method to decrement processCount when the process is complete
  * This method is called from event of individual screen to close the loader dialog
  * */
  static void endLoadingProcess(BuildContext context) {
    if (isLoadingProcess) {
      isLoadingProcess = false;
      Navigator.of(
        context,
        rootNavigator: true,
      ).pop();
    }
  }
  /*
  * Method is used to show Central Loader
  * This method called from startProcess method of this class
  * */
  static void showLoadingDialog(BuildContext context) {
    AlertDialog alert = AlertDialog(
      content: Row(
        children: [
          Transform.scale(
            scale: 0.8,
            child: CircularProgressIndicator(color:AppCommon.colors.primaryColor),
          ),
          Container(
            margin: const EdgeInsets.only(left: 7),
            child: Text("Loading..."),
          ),
        ],
      ),
    );
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return WillPopScope(
          child: alert,
          onWillPop: () async {
            endLoadingProcess(context);
            return false;
          },
        );
      },
    );
  }
  static Future<bool?> showLogoutConfirmationDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// ⚠️ Header
                Row(
                  children: [
                    Container(
                      height: 44,
                      width: 44,
                      decoration: BoxDecoration(
                        color: Colors.orange.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.logout,
                        color: Colors.red,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        "Logout",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                /// Message
                const Text(
                  "Are you sure you want to logout?\n"
                      "You will need to login again to continue.",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),

                const SizedBox(height: 20),

                /// Divider
                Divider(color: Colors.grey.shade200, thickness: 1),

                const SizedBox(height: 12),

                /// Actions
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text("Cancel"),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text(
                        "Logout",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
