import 'package:flutter/material.dart';
import '../Common/app_common.dart';
import 'add_room_screen.dart';

class RoomListScreen extends StatefulWidget {
  const RoomListScreen({super.key});

  @override
  State<RoomListScreen> createState() => _RoomListScreenState();
}

class _RoomListScreenState extends State<RoomListScreen> {
  bool isLoading = true;
  dynamic roomList = [];
  bool isFirstTime = true;

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
        AppCommon.displayToast(res["message"]);
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
    final int roomId = ModalRoute.of(context)!.settings.arguments as int;
    if (isFirstTime) {
      getGuestHouseRoomList(roomId);
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text("Guest House Rooms"),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == "Setting") {
                Navigator.pushNamed(context, '/setting');
              } else if (value == "User Rights") {
                Navigator.pushNamed(context, '/users');
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(value: "Setting", child: Text("Setting")),
              if (AppCommon.canMangeUsers)
                PopupMenuItem(value: "User Rights", child: Text("User Rights")),
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
                );
              },
            ),
      floatingActionButton: AppCommon.canManageRooms
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddRoomScreen(guestHouseId: roomId),
                  ),
                );
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
                  "${occupancyType[0].toUpperCase()}${occupancyType.substring(1)} • Max $maxOccupancy",
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // 🔘 Action buttons (only if room is active)
            if (isActive) ...[
              if (isBooked && AppCommon.canViewBooking)
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        '/booking',
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
                      Navigator.pushNamed(context, '/booking');
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
}
