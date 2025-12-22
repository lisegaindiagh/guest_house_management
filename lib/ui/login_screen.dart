import 'package:flutter/material.dart';

import '../Common/app_common.dart';
import '../service/send_sms.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  Future<void> getLoginDetails(context) async {
    var res = await AppCommon.apiProvider.getServerResponse(
      "auth.php",
      "POST",
      params: {"email": "admin@mail.com", "password":"admin@123"},
    );
    if (res["success"]) {
      await AppCommon.sharePref.setString(
        AppCommon.sessionKey.token,
        res["token"],
      );

      Map user = res["user"];
      AppCommon.canBook = user["can_book"] == 1;
      AppCommon.canViewBooking = user["can_view_bookings"] == 1;
      AppCommon.canManageRooms = user["can_manage_rooms"] == 1;
      AppCommon.canMangeUsers = user["can_manage_users"] == 1;

      Navigator.pushReplacementNamed(
        AppCommon.navigatorKey.currentContext!,
        '/guestHouseList',
      );
    }
    // return res;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton.icon(
          onPressed: () async {
            await getLoginDetails(context);
          },
          //_signIn(context),
          icon: const Icon(Icons.login),
          label: const Text(
            "Sign in with Google",
            style: TextStyle(fontSize: 16),
          ),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
    );
  }
}
