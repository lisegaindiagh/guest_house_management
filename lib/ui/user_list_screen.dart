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
  List users = [];
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
        AppCommon.displayToast(res["error"]);
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
      body: SafeArea(
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : ScrollConfiguration(
                behavior: const ScrollBehavior().copyWith(overscroll: false),
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: users.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final user = users[index];
        
                    return buildUserSwipeCard(user: user);
                  },
                ),
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          var res = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddEditUserScreen()),
          );
          if (res ?? false) {
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
          if (res ?? false) {
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

  Widget buildUserCard({
    required String name,
    required String email,
    required String role,
    required bool isActive,
    required Map<String, dynamic> permissions,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// 👤 Header (Avatar + Name + Status)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Avatar
                Container(
                  height: 44,
                  width: 44,
                  decoration: BoxDecoration(
                    color: AppCommon.colors.primaryColor.withValues(
                      alpha: 0.15,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.person_outline,
                    color: AppCommon.colors.primaryColor,
                  ),
                ),

                const SizedBox(width: 12),

                /// Name + Email
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        email,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),

                /// Status
                statusBadge(isActive),
              ],
            ),

            const SizedBox(height: 12),

            /// Role
            Row(children: [roleChip(role)]),

            const SizedBox(height: 12),

            /// Permissions
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                permissionPill("Book", permissions["can_book"] == "1"),
                permissionPill(
                  "View Bookings",
                  permissions["can_view_bookings"] == "1",
                ),
                permissionPill(
                  "Manage Rooms",
                  permissions["can_manage_rooms"] == "1",
                ),
                permissionPill(
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

  Widget statusBadge(bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isActive
            ? Colors.green.withValues(alpha: 0.12)
            : Colors.red.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        isActive ? "Active" : "Inactive",
        style: TextStyle(
          fontWeight: FontWeight.w900,
          color: isActive ? Colors.green : Colors.red,
        ),
      ),
    );
  }

  Widget roleChip(String role) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppCommon.colors.primaryColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        role.toUpperCase(),
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: AppCommon.colors.primaryColor,
        ),
      ),
    );
  }

  Widget permissionPill(String label, bool enabled) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: enabled
            ? Colors.green.withValues(alpha: 0.12)
            : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          color: enabled ? Colors.green : Colors.grey,
        ),
      ),
    );
  }

  Future<bool?> showDeleteUserDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// ⚠️ Header
                Row(
                  children: [
                    Container(
                      height: 44,
                      width: 44,
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.warning_amber_rounded,
                        color: Colors.red,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        "Delete User",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                /// Message
                const Text(
                  "Are you sure you want to delete this user?\n"
                  "This action cannot be undone.",
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),

                const SizedBox(height: 20),

                /// Divider
                Divider(color: Colors.grey.shade200, thickness: 1),

                const SizedBox(height: 12),

                /// Actions
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text("Cancel"),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text(
                        "Delete",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
