import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'Common/app_common.dart';
import 'splash_screen.dart';

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
        primarySwatch: Colors.blue,
        primaryColor: AppCommon.colors.primaryColor,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppCommon.colors.primaryColor,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: AppCommon.colors.backgroundColor,
        appBarTheme: AppBarTheme(
          elevation: 0,
          centerTitle: true,
          backgroundColor: AppCommon.colors.backgroundColor,
          iconTheme: IconThemeData(
            color: AppCommon.colors.primaryColor,
            size: 25.0,
          ),
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: AppCommon.colors.white.withValues(alpha: 0.2),
          ),
          titleTextStyle: TextStyle(
            fontSize: 20,
            color: AppCommon.colors.primaryColor,
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
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: AppCommon.colors.primaryColor,
          foregroundColor: AppCommon.colors.white,
        ),
      ),

      home: SplashScreen(),
    );
  }
}
