import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'Common/app_common.dart';
import 'splash_screen.dart';
import 'ui/booking_screen.dart';
import 'ui/guest_house_list.dart';
import 'ui/login_screen.dart';
import 'ui/room_list_screen.dart';
import 'ui/setting_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorKey: AppCommon.navigatorKey,
      title: 'Guest House Management',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        primaryColor: AppCommon.colors.primaryColor,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppCommon.colors.primaryColor,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: AppCommon.colors.backgroundColor,
        appBarTheme: AppBarTheme(
          elevation: 0,
          centerTitle: true,
          backgroundColor: AppCommon.colors.primaryColor,
          iconTheme: IconThemeData(color: AppCommon.colors.white, size: 25.0),
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: AppCommon.colors.primaryColor.withValues(
              alpha: 0.2,
            ),
          ),
          titleTextStyle: TextStyle(
            fontSize: 20,
            color: AppCommon.colors.white,
            overflow: TextOverflow.ellipsis,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ),

      initialRoute: '/',
      routes: {
        '/': (_) => SplashScreen(),
        '/login': (_) => LoginScreen(),
        '/home': (_) => const RoomListScreen(),
        '/guestHouseList': (_) => GuestHouseListScreen(),
        "/setting": (_) => SettingsScreen(),
        "/booking": (_) => BookingScreen(),
        // '/about': (_) => const AboutScreen(),
      },
    );
  }
}
