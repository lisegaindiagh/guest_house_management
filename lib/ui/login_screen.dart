import 'package:flutter/material.dart';

import '../Common/app_common.dart';
import '../service/sign_with_google.dart';
import 'home_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  Future<void> _signIn(BuildContext context) async {
    final googleService = SignInWithGoogleService.instance;

    final user = await googleService.signIn();

    if (user == null) {
      AppCommon.displayToast("Google sign-in cancelled");
      return;
    }

    AppCommon.displayToast("Signed in as ${user.email}");

    // Navigate to next screen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => HomeScreen()),
    );
  }

  Future<void> getLoginDetails() async {
    var res = await AppCommon.apiProvider.getServerResponse(
      "auth.php",
      "POST",
      params: {"email": "admin@mail.com"},
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
          onPressed: () {
            getLoginDetails();
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
