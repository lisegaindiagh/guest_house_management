import 'package:flutter/material.dart';
import '../Common/app_common.dart';

/// SettingsScreen
///
/// Professional settings screen to manage
/// notification and default user configurations.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  /// 🔑 Form key
  final _formKey = GlobalKey<FormState>();

  /// 📝 Controllers
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _defaultUserPassController =
      TextEditingController();

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchSettingData();
  }

  /// Fetch settings from API
  Future<void> fetchSettingData() async {
    try {
      var res = await AppCommon.apiProvider.getServerResponse(
        "api.php",
        "GET",
        queryParams: {"action": "getSettings"},
      );

      if (res["success"]) {
        _mobileController.text = res["settings"]["notify_mobile"] ?? "";
        _emailController.text = res["settings"]["notify_email"] ?? "";
        _defaultUserPassController.text =
            res["settings"]["default_user_password"] ?? "";
      } else {
        AppCommon.displayToast(res["error"]);
      }
    } catch (e) {
      AppCommon.displayToast("Server error");
    } finally {
      setState(() => isLoading = false);
    }
  }

  /// Update settings
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
        AppCommon.sharePref.setPreference({
          AppCommon.sessionKey.notifyEmail: _emailController.text,
          AppCommon.sessionKey.notifyMobile: _mobileController.text,
        });
        Navigator.pop(context, true);
      } else {
        AppCommon.displayToast(res["error"]);
      }
    } catch (e) {
      AppCommon.displayToast("Server error");
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("App Settings")),
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  /// FORM CONTENT
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            /// 📢 Notification Settings
                            sectionCard(
                              title: "Contact details for system notifications",
                              subtitle: "Used for booking alerts & updates",
                              icon: Icons.notifications_outlined,
                              child: Column(
                                children: [
                                  inputField(
                                    controller: _mobileController,
                                    label: "Notification Phone Number",
                                    icon: Icons.phone_android,
                                    keyboard: TextInputType.phone,
                                    maxLength: 10,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return "Mobile number is required";
                                      } else if (!RegExp(
                                        r'^\d{10}$',
                                      ).hasMatch(value)) {
                                        return "Enter valid 10-digit mobile";
                                      }
                                      return null;
                                    },
                                  ),
                                  inputField(
                                    controller: _emailController,
                                    label: "Notification Email Address",
                                    icon: Icons.email_outlined,
                                    keyboard: TextInputType.emailAddress,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return "Email is required";
                                      } else if (!RegExp(
                                        r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                                      ).hasMatch(value)) {
                                        return "Enter valid email address";
                                      }
                                      return null;
                                    },
                                  ),
                                ],
                              ),
                            ),

                            /// 🔐 User Settings
                            sectionCard(
                              title: "User Settings",
                              subtitle:
                                  "Default credentials for newly created users",
                              icon: Icons.security_outlined,
                              child: inputField(
                                controller: _defaultUserPassController,
                                label: "Default Password for New Users",
                                icon: Icons.lock_outline,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return "Password is required";
                                  } else if (value.length < 6) {
                                    return "Minimum 6 characters required";
                                  }
                                  return null;
                                },
                              ),
                            ),

                            const SizedBox(height: 80),
                          ],
                        ),
                      ),
                    ),
                  ),

                  /// 🔒 STICKY UPDATE BUTTON
                  Container(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 10,
                          offset: const Offset(0, -4),
                        ),
                      ],
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _updateSettings,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppCommon.colors.primaryColor,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          "Save Changes",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  /// ---------- UI COMPONENTS ----------
  Widget sectionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppCommon.colors.primaryColor),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 12, color: Colors.black),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  Widget inputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboard = TextInputType.text,
    int? maxLength,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboard,
        maxLength: maxLength,
        validator: validator,
        decoration: AppCommon.inputDecoration(
          label,
        ).copyWith(prefixIcon: Icon(icon)),
      ),
    );
  }
}
