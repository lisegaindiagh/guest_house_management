import 'package:flutter/material.dart';
import '../Common/app_common.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _defaultUserPassController =
      TextEditingController();
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    fetchSettingData();
  }

  Future<void> fetchSettingData() async {
    try {
      var res = await AppCommon.apiProvider.getServerResponse(
        "api.php",
        "GET",
        queryParams: {"action": "getSettings"},
      );
      if (res["success"]) {
        _mobileController.text = res["settings"]["notify_mobile"];
        _emailController.text = res["settings"]["notify_email"];
        _defaultUserPassController.text =
            res["settings"]["default_user_password"];
      } else {
        AppCommon.displayToast(res["error"]);
      }
    } catch (e) {
      AppCommon.displayToast("Server error");
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _updateSettings() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      var res = await AppCommon.apiProvider.getServerResponse(
        "api.php",
        "POST",
        queryParams: {"action": "updateSettings"},
        params: {
          "notify_mobile": _mobileController.text,
          "notify_email": _emailController.text,
          "default_user_password": _defaultUserPassController.text,
        },
      );
      if (res["success"]) {
        AppCommon.displayToast(res["message"]);
      } else {
        AppCommon.displayToast(res["error"]);
      }
    } catch (e) {
      AppCommon.displayToast("Server error");
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Settings")),
      body: _loading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 24.0,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  spacing: 12,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _mobileController,
                      maxLength: 10,
                      keyboardType: TextInputType.phone,
                      decoration: AppCommon.inputDecoration("Mobile Number"),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Mobile number is required";
                        } else if (!RegExp(r'^\d{10}$').hasMatch(value)) {
                          return "Enter a valid 10-digit mobile number";
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: AppCommon.inputDecoration("Email"),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Email is required";
                        } else if (!RegExp(
                          r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                        ).hasMatch(value)) {
                          return "Enter a valid email address";
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _defaultUserPassController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: AppCommon.inputDecoration(
                        "Default User Password",
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Default User Password is required";
                        } else if (value.length < 6) {
                          return "Password is short";
                        }
                        return null;
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 12.0),
                      child: ElevatedButton(
                        onPressed: _updateSettings,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppCommon.colors.primaryColor,
                        ),
                        child: Text(
                          "Update Settings",
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
