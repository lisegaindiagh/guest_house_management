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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Google sign-in cancelled')));
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Signed in as ${user.email}')));

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
        params: {
          "email": "admin@mail.com"
        }
    );
    if(res["success"]){
      Navigator.pushReplacementNamed(AppCommon.navigatorKey.currentContext!, '/guestHouseList');
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
