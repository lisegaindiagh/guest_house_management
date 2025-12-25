import 'package:flutter/material.dart';
import '../Common/app_common.dart';
import 'add_room_screen.dart';
import 'booking_screen.dart';
import 'login_screen.dart';
import 'setting_screen.dart';
import 'user_list_screen.dart';
import 'view_booking.dart';

class RoomListScreen extends StatefulWidget {
  final int roomId;
  final String guestRoomName;

  const RoomListScreen({
    super.key,
    required this.roomId,
    required this.guestRoomName,
  });

  @override
  State<RoomListScreen> createState() => _RoomListScreenState();
}

class _RoomListScreenState extends State<RoomListScreen> {
  bool isLoading = true;
  dynamic roomList = [];
  final dialogFormKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    getGuestHouseRoomList();
  }

  Future<void> getGuestHouseRoomList() async {
    try {
      var res = await AppCommon.apiProvider.getServerResponse(
        "api.php",
        "POST",
        queryParams: {"action": "getRooms", "guest_house_id": widget.roomId},
      );

      if (!AppCommon.isEmpty(res) && res["success"]) {
        roomList = res["data"];
      } else if (res is Map && res.containsKey("error")) {
        AppCommon.displayToast(res["error"]);
      }
    } catch (e) {
      roomList = [];
      AppCommon.displayToast("Server error");
    } finally {
      isLoading = false;
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.guestRoomName),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) async {
              if (value == "Setting") {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SettingsScreen()),
                );
              } else if (value == "User Rights") {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => UserListScreen()),
                );
              } else if (value == "Reset Password") {
                resetPasswordDialog();
              } else if (value == "Logout") {
                final shouldLogout = await AppCommon.showLogoutConfirmationDialog(context);
                if (shouldLogout == true) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => LoginScreen()),
                        (route) => false,
                  );
                }
              }
            },
            itemBuilder: (context) => [
              if(AppCommon.canUpdateSetting)
              PopupMenuItem(value: "Setting", child: Text("Setting")),
              PopupMenuItem(
                value: "Reset Password",
                child: Text("Reset Password"),
              ),
              if (AppCommon.canMangeUsers)
                PopupMenuItem(value: "User Rights", child: Text("User Rights")),
              PopupMenuItem(value: "Logout", child: Text("Logout")),
            ],
          ),
        ],
      ),

      body: SafeArea(
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : ScrollConfiguration(
                behavior: const ScrollBehavior().copyWith(overscroll: false),
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: roomList.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final room = roomList[index];
                    return buildRoomCard(
                      roomId: room["id"],
                      roomName: room["room_name"],
                      occupancyType: room["occupancy_type"],
                      maxOccupancy: room["max_occupancy"],
                      isActive: room["is_active"] == 1,
                      isBooked: room["is_booked"] == 1,
                      guestHouseId: room["guest_house_id"],
                    );
                  },
                ),
              ),
      ),
      floatingActionButton: AppCommon.canManageRooms
          ? FloatingActionButton(
              onPressed: () async {
                var res = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        AddRoomScreen(guestHouseId: widget.roomId),
                  ),
                );
                if (res ?? false) {
                  await getGuestHouseRoomList();
                }
              },
              child: Icon(Icons.add),
            )
          : SizedBox(),
    );
  }

  Widget buildRoomCard({
    required int roomId,
    required String roomName,
    required String occupancyType,
    required int maxOccupancy,
    required bool isActive,
    required bool isBooked,
    required int guestHouseId,
  }) {
    final Color statusColor = !isActive
        ? Colors.grey
        : isBooked
        ? Colors.orange
        : Colors.green;

    final String statusText = !isActive
        ? "Inactive"
        : isBooked
        ? "Booked"
        : "Available";

    return Card(
      color: statusColor,
      child: Container(
        margin: EdgeInsets.only(left: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.horizontal(
            left: Radius.circular(4),
            right: Radius.circular(12),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Stack(
          children: [
            /// Status Badge (Top Right)
            Positioned(
              top: 12,
              right: 12,
              child: statusBadge(statusText, statusColor),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// 🛏️ Room Title
                  Text(
                    "Room $roomName",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.2,
                    ),
                  ),

                  const SizedBox(height: 12),

                  /// Occupancy Info
                  Row(
                    children: [
                      infoItem(
                        Icons.people_alt_outlined,
                        occupancyType[0].toUpperCase() +
                            occupancyType.substring(1),
                      ),
                      const SizedBox(width: 20),
                      infoItem(Icons.person_outline, "Max $maxOccupancy"),
                    ],
                  ),

                  /// Divider
                  Divider(color: Colors.grey.shade200, thickness: 1),

                  /// Action Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (AppCommon.canViewBooking)
                        _actionButton(
                          label: "View Bookings",
                          icon: Icons.receipt_long_outlined,
                          onTap: () async {
                            var res = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    ViewBookingScreen(roomId: roomId),
                              ),
                            );
                            if (res ?? false) {
                              await getGuestHouseRoomList();
                            }
                          },
                        ),

                      if (AppCommon.canBook) const SizedBox(width: 12),

                      if (AppCommon.canBook)
                        _actionButton(
                          label: "Book Room",
                          icon: Icons.add,
                          primary: true,
                          onTap: () async {
                            var res = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => BookingScreen(
                                  roomId: roomId,
                                  guestHouseId: guestHouseId,
                                ),
                              ),
                            );
                            if (res ?? false) {
                              await getGuestHouseRoomList();
                            }
                          },
                        ),
                    ],
                  ),
              ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget _actionButton({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
    bool primary = false,
  }) {
    return SizedBox(
      height: 40,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          backgroundColor: primary
              ? AppCommon.colors.primaryColor
              : AppCommon.colors.primaryColor.withValues(alpha: 0.1),
          foregroundColor: primary ? Colors.white : Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 0,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18),
            const SizedBox(width: 4), // 👈 spacing control here
            Text(
              label,
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget statusBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  Widget infoItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey.shade600),
        const SizedBox(width: 6),
        Text(
          text,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Future<void> resetPassword({
    required String currentPass,
    required String newPass,
  }) async {
    setState(() {
      isLoading = true;
    });

    if (!dialogFormKey.currentState!.validate()) return;

    try {
      var res = await AppCommon.apiProvider.getServerResponse(
        "api.php",
        "POST",
        queryParams: {"action": "changePassword"},
        params: {"current_password": currentPass, "new_password": newPass},
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
        isLoading = false;
      });
    }
  }

  void resetPasswordDialog() {
    final currentPasswordCtrl = TextEditingController();
    final newPasswordCtrl = TextEditingController();

    bool isOldObscure = true;
    bool isNewObscure = true;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Form(
                key: dialogFormKey,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// 🔐 Header
                      Row(
                        children: [
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
                              Icons.lock_reset_outlined,
                              color: AppCommon.colors.primaryColor,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              "Reset Password",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      const Text(
                        "For security, please enter your current password "
                        "and choose a new one.",
                        style: TextStyle(fontSize: 13, color: Colors.grey),
                      ),

                      const SizedBox(height: 20),

                      /// 🔑 Current Password
                      TextFormField(
                        controller: currentPasswordCtrl,
                        obscureText: isOldObscure,
                        decoration:
                            AppCommon.inputDecoration(
                              "Current Password",
                            ).copyWith(
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  isOldObscure
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                ),
                                onPressed: () {
                                  setState(() {
                                    isOldObscure = !isOldObscure;
                                  });
                                },
                              ),
                            ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Current password is required";
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 14),

                      /// 🔐 New Password
                      TextFormField(
                        controller: newPasswordCtrl,
                        obscureText: isNewObscure,
                        decoration: AppCommon.inputDecoration("New Password")
                            .copyWith(
                              prefixIcon: const Icon(Icons.lock_reset),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  isNewObscure
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                ),
                                onPressed: () {
                                  setState(() {
                                    isNewObscure = !isNewObscure;
                                  });
                                },
                              ),
                            ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "New password is required";
                          } else if (value.length < 6) {
                            return "Minimum 6 characters required";
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 24),

                      /// Divider
                      Divider(color: Colors.grey.shade200, thickness: 1),

                      const SizedBox(height: 12),

                      /// 🔘 Action Buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text("Cancel"),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppCommon.colors.primaryColor,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: () {
                              if (dialogFormKey.currentState!.validate()) {
                                resetPassword(
                                  currentPass: currentPasswordCtrl.text,
                                  newPass: newPasswordCtrl.text,
                                );
                              }
                            },
                            child: Text(
                              "Reset Password",
                              style: TextStyle(
                                color: AppCommon.colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
