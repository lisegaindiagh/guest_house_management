import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'Common/app_common.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    // FULL SCREEN (hide status bar)
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    );

    _scaleAnimation = Tween<double>(
      begin: 0.4,
      end: 1.2,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 1.2),
      end: Offset(0, 0),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();

    // AppCommon.displayNetworkPopup();
    navigateToLogin();
  }

  void navigateToLogin() {
    Future.delayed(const Duration(seconds: 5), () async {
      if (await AppCommon.isOnline()) {
        String email = await AppCommon.sharePref.getString(AppCommon.sessionKey.email);
        String password = await AppCommon.sharePref.getString(AppCommon.sessionKey.password);
        if(!AppCommon.isEmpty(email) && !AppCommon.isEmpty(password)){
          await getLoginDetails(email, password);
        }else{
          Navigator.pushReplacementNamed(context, '/login');
        }

      }
    });
  }


  Future<void> getLoginDetails(String email,String password) async {
    var res = await AppCommon.apiProvider.getServerResponse(
      "auth.php",
      "POST",
      params: {"email": email,
        "password":password},
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
        context,
        '/guestHouseList',
      );
    }
    // return res;
  }
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Colors.white70, Colors.transparent],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SlideTransition(
            position: _slideAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Image.asset(
                "assets/images/lisega_logo.png",
                width: 250, // LARGE LOGO
                height: 250,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
