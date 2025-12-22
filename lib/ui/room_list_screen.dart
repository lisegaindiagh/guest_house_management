import 'package:flutter/material.dart';
import '../Common/app_common.dart';
import 'add_room_screen.dart';
import 'login_screen.dart';

class RoomListScreen extends StatefulWidget {
  const RoomListScreen({super.key});

  @override
  State<RoomListScreen> createState() => _RoomListScreenState();
}

class _RoomListScreenState extends State<RoomListScreen> {
  bool isLoading = true;
  dynamic roomList = [];
  bool isFirstTime = true;
  final dialogFormKey = GlobalKey<FormState>();
  int roomId = 0;
  String guestRoomName = "";

  Future<void> getGuestHouseRoomList(int roomId) async {
    try {
      var res = await AppCommon.apiProvider.getServerResponse(
        "api.php",
        "POST",
        queryParams: {"action": "getRooms", "guest_house_id": roomId},
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
      isFirstTime = false;
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    roomId = args["id"];
    guestRoomName = args["name"];
    if (isFirstTime) {
      getGuestHouseRoomList(roomId);
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(guestRoomName),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == "Setting") {
                Navigator.pushNamed(context, '/setting');
              } else if (value == "User Rights") {
                Navigator.pushNamed(context, '/users');
              } else if (value == "Reset Password") {
                _resetPasswordDialog();
              } else if (value == "Logout") {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                  (route) => false,
                );
              }
            },
            itemBuilder: (context) => [
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

      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.separated(
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
      floatingActionButton: AppCommon.canManageRooms
          ? FloatingActionButton(
              onPressed: () async {
                var res = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddRoomScreen(guestHouseId: roomId),
                  ),
                );
                if (res ?? false) {
                  await getGuestHouseRoomList(roomId);
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
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🛏️ Room name & status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Room $roomName",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                buildRoomStatusChip(isActive: isActive, isBooked: isBooked),
              ],
            ),

            const SizedBox(height: 8),

            // 👥 Occupancy info
            Row(
              children: [
                const Icon(Icons.person_outline, size: 16),
                const SizedBox(width: 6),
                Text(
                  "${occupancyType.isNotEmpty ? occupancyType[0].toUpperCase() + occupancyType.substring(1) : ""} • Max $maxOccupancy",
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Row(
              spacing: 12,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (AppCommon.canViewBooking)
                  Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          '/viewBooking',
                          arguments: roomId,
                        );
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppCommon.colors.btnColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          "View Booking",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                if (!isBooked && AppCommon.canBook)
                  Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          '/booking',
                          arguments: {
                            'roomId': roomId,
                            'guestHouseId': guestHouseId,
                          },
                        );
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppCommon.colors.btnColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          "Book Room",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildRoomStatusChip({required bool isActive, required bool isBooked}) {
    if (!isActive) {
      return _buildChip(
        label: "Inactive",
        bgColor: Colors.grey.shade300,
        textColor: Colors.grey.shade700,
      );
    }

    return _buildChip(
      label: isBooked ? "Booked" : "Available",
      bgColor: isBooked ? Colors.orange.shade100 : Colors.green.shade100,
      textColor: isBooked ? Colors.orange : Colors.green,
    );
  }

  Widget _buildChip({
    required String label,
    required Color bgColor,
    required Color textColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
      ),
    );
  }

  Future<void> _resetPassword({
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

  void _resetPasswordDialog() {
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
                borderRadius: BorderRadius.circular(12),
              ),
              child: Form(
                key: dialogFormKey,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      /// Title
                      const Text(
                        "Reset Password",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 16),

                      /// Current Password
                      TextFormField(
                        controller: currentPasswordCtrl,
                        obscureText: isOldObscure,
                        decoration: AppCommon.inputDecoration(
                          "Current Password",
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

                      const SizedBox(height: 12),

                      /// New Password
                      TextFormField(
                        controller: newPasswordCtrl,
                        obscureText: isNewObscure,
                        decoration: AppCommon.inputDecoration(
                          "New Password",
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

                      const SizedBox(height: 20),

                      /// Action Buttons
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
                            ),
                            onPressed: () {
                              if (dialogFormKey.currentState!.validate()) {
                                _resetPassword(
                                  currentPass: currentPasswordCtrl.text,
                                  newPass: newPasswordCtrl.text,
                                );
                              }
                            },
                            child: Text(
                              "Reset",
                              style: TextStyle(color: AppCommon.colors.white),
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
