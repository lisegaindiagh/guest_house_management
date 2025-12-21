import 'package:flutter/material.dart';

import '../Common/app_common.dart';
import 'add_edit_user_screen.dart';

/// UserListScreen
///
/// Displays a list of system users.
/// Supports swipe actions:
/// - Swipe LEFT → View user details
/// - Swipe RIGHT → Update / Delete user
class UserListScreen extends StatefulWidget {
  const UserListScreen({super.key});

  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  List<Map<String, dynamic>> users = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    getUsers();
  }

  Future<void> getUsers() async {
    if (!isLoading) {
      isLoading = true;
      setState(() {});
    }
    try {
      var res = await AppCommon.apiProvider.getServerResponse(
        "api.php",
        "POST",
        queryParams: {"action": "getUsers"},
      );
      if (!AppCommon.isEmpty(res) && res["success"]) {
        users = res["data"];
      } else if (res is Map && res.containsKey("error")) {
        AppCommon.displayToast(res["message"]);
      }
    } catch (e) {
      users = [];
      AppCommon.displayToast("Server error");
    } finally {
      isLoading = false;
      setState(() {});
    }
  }

  Future<void> deleteUser(int userId) async {
    if (!isLoading) {
      isLoading = true;
      setState(() {});
    }
    try {
      var res = await AppCommon.apiProvider.getServerResponse(
        "api.php",
        "POST",
        queryParams: {"action": "deleteUser"},
        params: {"user_id": userId},
      );
      if (!AppCommon.isEmpty(res) && res["success"]) {
        AppCommon.displayToast(res["message"]);
        await getUsers();
      }
    } catch (e) {
      AppCommon.displayToast("Server error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Users")),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: users.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final user = users[index];

                return buildUserSwipeCard(user: user);
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          var res = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddEditUserScreen()),
          );
          if (res) {
            await getUsers();
          }
        },
        child: Icon(Icons.add),
      ),
    );
  }

  Widget buildUserSwipeCard({required Map<String, dynamic> user}) {
    final bool isActive = user["is_active"] == "1";

    return Dismissible(
      key: ValueKey(user["id"]),
      direction: DismissDirection.horizontal,

      // 👉 Swipe RIGHT (Start → End) : Update / Delete
      background: buildSwipAction(
        color: Colors.green,
        icon: Icons.edit,
        label: "Update",
        alignment: Alignment.centerLeft,
      ),

      // 👉 Swipe LEFT (End → Start) : View Details
      secondaryBackground: buildSwipAction(
        color: Colors.red,
        icon: Icons.delete,
        label: "Delete",
        alignment: Alignment.centerRight,
      ),

      confirmDismiss: (direction) async {
        if (direction == DismissDirection.endToStart) {
          var res = await showDeleteUserDialog(context);
          if (res ?? false) await deleteUser(int.tryParse(user["id"]) ?? 0);
          return false;
        } else if (direction == DismissDirection.startToEnd) {
          var res = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddEditUserScreen(userData: user),
            ),
          );
          if (res) {
            await getUsers();
          }
          return false;
        }
        return null;
      },

      child: buildUserCard(
        name: user["name"],
        email: user["email"],
        role: user["role"],
        isActive: isActive,
        permissions: user,
      ),
    );
  }

  Widget buildUserCard({
    required String name,
    required String email,
    required String role,
    required bool isActive,
    required Map<String, dynamic> permissions,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 👤 Name & status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                buildStatusChip(isActive: isActive),
              ],
            ),

            const SizedBox(height: 6),

            // 📧 Email
            Text(email, style: const TextStyle(color: Colors.grey)),

            const SizedBox(height: 6),

            // 🧩 Role
            Text(
              "Role: ${role.toUpperCase()}",
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            ),

            const SizedBox(height: 10),

            // 🔐 Permissions
            Wrap(
              spacing: 6,
              children: [
                buildPermissionChip("Book", permissions["can_book"] == "1"),
                buildPermissionChip(
                  "View Bookings",
                  permissions["can_view_bookings"] == "1",
                ),
                buildPermissionChip(
                  "Manage Rooms",
                  permissions["can_manage_rooms"] == "1",
                ),
                buildPermissionChip(
                  "Manage Users",
                  permissions["can_manage_users"] == "1",
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildStatusChip({required bool isActive}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isActive ? Colors.green.shade100 : Colors.red.shade100,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        isActive ? "Active" : "Inactive",
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: isActive ? Colors.green : Colors.red,
        ),
      ),
    );
  }

  Widget buildPermissionChip(String label, bool enabled) {
    return Chip(
      label: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          color: enabled ? Colors.green : Colors.grey,
        ),
      ),
      backgroundColor: enabled ? Colors.green.shade50 : Colors.grey.shade200,
    );
  }

  Widget buildSwipAction({
    required Color color,
    required IconData icon,
    required String label,
    required Alignment alignment,
  }) {
    return Container(
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      color: color.withValues(alpha: 0.9),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Future<bool?> showDeleteUserDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false, // ❌ Prevent accidental dismiss
      builder: (context) {
        return AlertDialog(
          title: const Text("Delete User"),
          content: const Text(
            "Are you sure you want to delete this user?\n"
            "This action cannot be undone.",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false); // ❌ Cancel
              },
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppCommon.colors.primaryColor,
              ),
              onPressed: () {
                Navigator.pop(context, true); // ✅ Confirm
              },
              child: Text(
                "Delete",
                style: TextStyle(color: AppCommon.colors.white),
              ),
            ),
          ],
        );
      },
    );
  }
}
