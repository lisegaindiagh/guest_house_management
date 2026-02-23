import 'package:flutter/material.dart';
import '../Common/app_common.dart';

/// AddEditUserScreen
///
/// Used to add a new user or edit an existing user.
/// If [userData] is provided → Edit mode
/// If [userData] is null → Add mode
class AddEditUserScreen extends StatefulWidget {
  final Map<String, dynamic>? userData;

  /// [userData] → Existing user data for edit mode
  const AddEditUserScreen({super.key, this.userData});

  @override
  State<AddEditUserScreen> createState() => _AddEditUserScreenState();
}

class _AddEditUserScreenState extends State<AddEditUserScreen> {
  /// 🔑 Form key
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  /// 📝 Controllers
  late TextEditingController _emailController;
  late TextEditingController _nameController;
  late TextEditingController _passwordController;

  /// Role
  String _selectedRole = "user";

  /// Permissions
  bool _canBook = false;
  bool _canViewBookings = false;
  bool _canManageRooms = false;
  bool _canManageUsers = false;
  bool _canUpdateSetting = false;

  /// Check if screen is in edit mode
  bool get isEditMode => widget.userData != null;
  bool _autoValidate = false;

  @override
  void initState() {
    super.initState();

    // 📝 Initialize controllers with edit data if available
    _emailController = TextEditingController(
      text: widget.userData?["email"] ?? "",
    );
    _nameController = TextEditingController(
      text: widget.userData?["name"] ?? "",
    );
    _passwordController = TextEditingController();

    _selectedRole = widget.userData?["role"] ?? "user";
    _canBook = widget.userData?["can_book"] == "1";
    _canViewBookings = widget.userData?["can_view_bookings"] == "1";
    _canManageRooms = widget.userData?["can_manage_rooms"] == "1";
    _canManageUsers = widget.userData?["can_manage_users"] == "1";
    _canUpdateSetting = widget.userData?["can_update_setting"] == "1";
  }

  @override
  void dispose() {
    _emailController.dispose();
    _nameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Submit form
  Future<void> _submitForm() async {
    setState(() => _autoValidate = true);
    if (_formKey.currentState!.validate()) {
      final payload = {
        "email": _emailController.text.trim(),
        "name": _nameController.text.trim(),
        "password": _passwordController.text.trim(),
        "role": _selectedRole,
        "can_book": _canBook ? 1 : 0,
        "can_view_bookings": _canViewBookings ? 1 : 0,
        "can_manage_rooms": _canManageRooms ? 1 : 0,
        "can_manage_users": _canManageUsers ? 1 : 0,
        "can_update_setting": _canUpdateSetting ? 1 : 0,
      };

      if (isEditMode) {
        payload.addAll({
          "user_id": int.tryParse(widget.userData!["id"]) ?? 0,
          "is_active": int.tryParse(widget.userData!["is_active"]) ?? 0,
        });
      }

      var res = await AppCommon.apiProvider.getServerResponse(
        "api.php",
        "POST",
        queryParams: {"action": isEditMode ? "updateUser" : "addUser"},
        params: payload,
      );

      if (!AppCommon.isEmpty(res) && res["success"]) {
        AppCommon.displayToast(
          isEditMode ? res["message"] : "User added successfully",
        );
        Navigator.pop(context, true);
      } else if (res is Map && res.containsKey("error")) {
        AppCommon.displayToast(res["error"]);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(isEditMode ? "Edit User" : "Add User")),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  autovalidateMode: _autoValidate
                      ? AutovalidateMode.onUserInteraction
                      : AutovalidateMode.disabled,
                  child: Column(
                    children: [
                      /// 👤 Profile Header
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          radius: 40,
                          backgroundColor: AppCommon.colors.primaryColor
                              .withValues(alpha: 0.15),
                          child: Icon(
                            Icons.person_outline,
                            size: 48,
                            color: AppCommon.colors.primaryColor,
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      /// 📄 User Details
                      sectionCard(
                        title: "User Information",
                        icon: Icons.person_outline,
                        child: Column(
                          children: [
                            inputField(
                              controller: _emailController,
                              label: "Email Address",
                              icon: Icons.email_outlined,
                              keyboard: TextInputType.emailAddress,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "Email is required";
                                }
                                if (!value.contains("@")) {
                                  return "Enter valid email";
                                }
                                return null;
                              },
                            ),
                            inputField(
                              controller: _nameController,
                              label: "Full Name",
                              icon: Icons.badge_outlined,
                              validator: (value) =>
                                  value!.isEmpty ? "Name is required" : null,
                            ),
                            if (!isEditMode)
                              inputField(
                                controller: _passwordController,
                                label: "Password",
                                icon: Icons.lock_outline,
                                keyboard: TextInputType.visiblePassword,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return "Password is required";
                                  } else if (value.length < 6) {
                                    return "Minimum 6 characters required";
                                  }
                                  return null;
                                },
                              ),
                            DropdownButtonFormField<String>(
                              value: _selectedRole,
                              decoration: AppCommon.inputDecoration("User Role")
                                  .copyWith(
                                    prefixIcon: const Icon(
                                      Icons.admin_panel_settings,
                                    ),
                                  ),
                              items: const [
                                DropdownMenuItem(
                                  value: "admin",
                                  child: Text("Admin"),
                                ),
                                DropdownMenuItem(
                                  value: "user",
                                  child: Text("User"),
                                ),
                              ],
                              onChanged: (value) =>
                                  setState(() => _selectedRole = value!),
                            ),
                          ],
                        ),
                      ),

                      /// 🔐 Permissions
                      sectionCard(
                        title: "Permissions",
                        icon: Icons.security_outlined,
                        child: Column(
                          children: [
                            permissionTile(
                              "Create Bookings",
                              _canBook,
                              (v) => setState(() => _canBook = v),
                            ),
                            permissionTile(
                              "View Bookings",
                              _canViewBookings,
                              (v) => setState(() => _canViewBookings = v),
                            ),
                            permissionTile(
                              "Manage Rooms",
                              _canManageRooms,
                              (v) => setState(() => _canManageRooms = v),
                            ),
                            permissionTile(
                              "Manage Users",
                              _canManageUsers,
                              (v) => setState(() => _canManageUsers = v),
                            ),
                            permissionTile(
                              "Manage Settings",
                              _canUpdateSetting,
                              (v) => setState(() => _canUpdateSetting = v),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ),
            ),

            /// 🔒 Sticky Action Button
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
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppCommon.colors.primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    isEditMode ? "Update User" : "Add User",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
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

  /// ---------- UI HELPERS ----------
  Widget sectionCard({
    required String title,
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
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
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
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        autovalidateMode: AutovalidateMode.onUserInteraction,
        controller: controller,
        keyboardType: keyboard,
        validator: validator,
        decoration: AppCommon.inputDecoration(
          label,
        ).copyWith(prefixIcon: Icon(icon)),
      ),
    );
  }

  Widget permissionTile(
    String label,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(label),
      value: value,
      onChanged: onChanged,
    );
  }
}
