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
  /// Form key
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  /// Controllers
  late TextEditingController _emailController;
  late TextEditingController _nameController;

  /// Role
  String _selectedRole = "user";

  /// Permissions
  bool _canBook = false;
  bool _canViewBookings = false;
  bool _canManageRooms = false;
  bool _canManageUsers = false;

  /// Check if screen is in edit mode
  bool get isEditMode => widget.userData != null;

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

    _selectedRole = widget.userData?["role"] ?? "user";

    _canBook = widget.userData?["can_book"] == "1";
    _canViewBookings = widget.userData?["can_view_bookings"] == "1";
    _canManageRooms = widget.userData?["can_manage_rooms"] == "1";
    _canManageUsers = widget.userData?["can_manage_users"] == "1";
  }

  @override
  void dispose() {
    _emailController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  /// Submit form
  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final Map<String, dynamic> payload = {
        "email": _emailController.text.trim(),
        "name": _nameController.text.trim(),
        "role": _selectedRole,
        "can_book": _canBook ? 1 : 0,
        "can_view_bookings": _canViewBookings ? 1 : 0,
        "can_manage_rooms": _canManageRooms ? 1 : 0,
        "can_manage_users": _canManageUsers ? 1 : 0,
      };

      if (isEditMode) {
        payload.addAll({
          "user_id": int.tryParse(widget.userData!["id"]) ?? 0,
          "is_active": int.tryParse(widget.userData!["is_active"] ?? 0),
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 📧 Email
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: AppCommon.inputDecoration("Email"),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Email is required";
                  }
                  if (!value.contains("@")) {
                    return "Enter a valid email address";
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // 👤 Name
              TextFormField(
                controller: _nameController,
                decoration: AppCommon.inputDecoration("Name"),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Name is required";
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // 🧩 Role
              DropdownButtonFormField<String>(
                initialValue: _selectedRole,
                isDense: true,
                decoration: AppCommon.inputDecoration("Role"),
                items: const [
                  DropdownMenuItem(value: "admin", child: Text("Admin")),
                  DropdownMenuItem(value: "user", child: Text("User")),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedRole = value!;
                  });
                },
              ),

              const SizedBox(height: 24),

              // 🔐 Permissions
              const Text(
                "Permissions",
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),

              const SizedBox(height: 8),

              buildPermissionCheckBox(
                label: "Can Book Room",
                value: _canBook,
                onChanged: (value) {
                  setState(() => _canBook = value);
                },
              ),

              buildPermissionCheckBox(
                label: "Can View Bookings",
                value: _canViewBookings,
                onChanged: (value) {
                  setState(() => _canViewBookings = value);
                },
              ),

              buildPermissionCheckBox(
                label: "Can Manage Rooms",
                value: _canManageRooms,
                onChanged: (value) {
                  setState(() => _canManageRooms = value);
                },
              ),

              buildPermissionCheckBox(
                label: "Can Manage Users",
                value: _canManageUsers,
                onChanged: (value) {
                  setState(() => _canManageUsers = value);
                },
              ),

              const SizedBox(height: 24),

              // ✅ Submit button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppCommon.colors.primaryColor,
                  ),
                  onPressed: _submitForm,
                  child: Text(
                    isEditMode ? "Update User" : "Add User",
                    style: TextStyle(color: AppCommon.colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildPermissionCheckBox({
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      children: [
        Expanded(child: Text(label, style: const TextStyle(fontSize: 14))),
        Checkbox(
          value: value,
          onChanged: (val) => onChanged(val ?? false),
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          visualDensity: VisualDensity.compact,
        ),
      ],
    );
  }
}
