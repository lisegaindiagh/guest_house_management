import 'package:flutter/material.dart';

import '../common/app_common.dart';
import 'guest_house_list.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool showPassword = true, isRemember = false, isLoading = false;

  TextEditingController emailController = TextEditingController(
    text: "admin@mail.com",
  );
  TextEditingController passwordController = TextEditingController(
    text: "admin@123",
  );

  @override
  void initState() {
    super.initState();
    getUserData();
  }

  Future<void> getUserData() async {
    isLoading = true;
    setState(() {});
    bool res =
        await AppCommon.sharePref.getBool(AppCommon.sessionKey.isRemember) ??
        false;

    if (res) {
      emailController.text = await AppCommon.sharePref.getString(
        AppCommon.sessionKey.email,
      );
      passwordController.text = await AppCommon.sharePref.getString(
        AppCommon.sessionKey.password,
      );
    }
    isLoading = false;
    setState(() {});
  }

  Future<void> getLoginDetails(BuildContext contex) async {
    var res = await AppCommon.apiProvider.getServerResponse(
      "auth.php",
      "POST",
      params: {
        "email": emailController.text,
        "password": passwordController.text,
      },
    );
    if (res["success"]) {
      await setSession(res);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => GuestHouseListScreen()),
      );
    }
  }

  Future<void> setSession(var res) async {
    await AppCommon.sharePref.setString(
      AppCommon.sessionKey.token,
      res["token"],
    );
    await AppCommon.sharePref.setString(
      AppCommon.sessionKey.email,
      res["user"]["email"],
    );
    await AppCommon.sharePref.setString(
      AppCommon.sessionKey.password,
      passwordController.text,
    );

    Map user = res["user"];
    AppCommon.canBook = user["can_book"] == 1;
    AppCommon.canViewBooking = user["can_view_bookings"] == 1;
    AppCommon.canManageRooms = user["can_manage_rooms"] == 1;
    AppCommon.canMangeUsers = user["can_manage_users"] == 1;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Login", textAlign: TextAlign.center)),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Card(
                elevation: 6,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        height: 180,
                        width: 230,
                        child: Image.asset("assets/images/lisega_logo.png"),
                      ),
                      const Text(
                        "Welcome",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 5),
                      const Text(
                        "Login to continue",
                        style: TextStyle(color: Colors.grey),
                      ),

                      const SizedBox(height: 20),

                      // Dealer Code / Username
                      TextFormField(
                        controller: emailController,
                        decoration: AppCommon.inputDecoration("User Name"),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Email is required';
                          }
                          if (!isValidEmail(value)) {
                            return 'Enter a valid email address';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      // Password
                      TextFormField(
                        controller: passwordController,
                        obscureText: showPassword,
                        decoration: AppCommon.inputDecoration(
                          "Password",
                          suffixIcon: IconButton(
                            icon: Icon(
                              showPassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: () {
                              setState(() {
                                showPassword = !showPassword;
                              });
                            },
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return "Password is required";
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 10),

                      // Remember me
                      Row(
                        children: [
                          Checkbox(
                            value: isRemember,
                            onChanged: (v) {
                              isRemember = !isRemember;
                              setState(() {});
                            },
                          ),
                          const Text("Remember me"),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Login Button
                      SizedBox(
                        width: double.infinity,
                        height: 45,
                        child: ElevatedButton(
                          onPressed: () async {
                            AppCommon.sharePref.setBool(
                              AppCommon.sessionKey.isRemember,
                              isRemember,
                            );
                            await getLoginDetails(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppCommon.colors.primaryColor,
                          ),
                          child: const Text(
                            "Login",
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  bool isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }
}
