import 'package:flutter/material.dart';
import '../Common/app_common.dart';
import 'guest_house_list.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool showPassword = true;
  bool isRemember = false;
  bool isLoading = false;

  TextEditingController emailController = TextEditingController(
    text: "cjgabani1409@gmail.com",
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

  Future<void> getLoginDetails(BuildContext context) async {
    var res = await AppCommon.apiProvider.getServerResponse(
      "auth.php",
      "POST",
      params: {
        "email": emailController.text,
        "password": passwordController.text,
      },
    );

    if (res["success"]) {
      await setSession(res, context);
    }
  }

  Future<void> setSession(var res, BuildContext context) async {
    Map user = res["user"];

    AppCommon.canBook = user["can_book"] == 1;
    AppCommon.canViewBooking = user["can_view_bookings"] == 1;
    AppCommon.canManageRooms = user["can_manage_rooms"] == 1;
    AppCommon.canMangeUsers = user["can_manage_users"] == 1;

    await AppCommon.sharePref.setPreference({
      AppCommon.sessionKey.token: res["token"],
      AppCommon.sessionKey.email: user["email"],
      AppCommon.sessionKey.password: passwordController.text,
    });

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => GuestHouseListScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Login", textAlign: TextAlign.center)),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Card(
                elevation: 12,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(
                    left: 24,
                    right: 24,
                    bottom: 24,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      /// Logo
                      Image.asset(
                        "assets/images/lisega_logo.png",
                        height: 150,
                        width: 230,
                      ),

                      /// Title
                      const Text(
                        "Guest House Login",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        "Sign in to manage bookings",
                        style: TextStyle(color: Colors.grey),
                      ),

                      const SizedBox(height: 30),

                      /// Username
                      TextFormField(
                        controller: emailController,
                        decoration: AppCommon.inputDecoration("Email"),
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

                      const SizedBox(height: 18),

                      /// Password
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

                      const SizedBox(height: 12),

                      /// Remember Me
                      Row(
                        children: [
                          Checkbox(
                            value: isRemember,
                            onChanged: (v) {
                              setState(() {
                                isRemember = v!;
                              });
                            },
                          ),
                          const Text("Remember me"),
                        ],
                      ),

                      const SizedBox(height: 20),

                      /// Login Button
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppCommon.colors.primaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () async {
                            AppCommon.sharePref.setBool(
                              AppCommon.sessionKey.isRemember,
                              isRemember,
                            );
                            await getLoginDetails(context);
                          },
                          child: const Text(
                            "LOGIN",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
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
