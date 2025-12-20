import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:guest_house_management/splash_screen.dart';

import 'Common/app_common.dart';
import 'screens/login_screen.dart';
import 'ui/booking_screen.dart';
import 'ui/guest_house_list.dart';
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
      title: 'Guest House Management',
      theme: ThemeData(primarySwatch: Colors.blue,
        primaryColor: Colors.blue,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
        ),
        useMaterial3: true,

        appBarTheme: AppBarTheme(
          centerTitle: false,
          iconTheme: IconThemeData(color: Colors.white, size: 25.0),
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: Colors.blue.shade200,
          ),
          titleTextStyle: TextStyle(
            fontSize: 18,
            color: Colors.white,
            overflow: TextOverflow.ellipsis,
            fontWeight: FontWeight.bold,
          ),
          backgroundColor: Colors.blue,
          elevation: 0,
        ),),

      initialRoute: '/',
      routes: {
        '/': (_) =>  SplashScreen(),
        '/login': (_) =>  LoginScreen(),
        '/home': (_) => const RoomListScreen(),
        '/guestHouseList': (_) =>  GuestHouseListScreen(),
        "/setting":(_) => SettingsScreen(),
        "/booking":(_)=> BookingScreen()
        // '/about': (_) => const AboutScreen(),
      },
    );
  }
}
