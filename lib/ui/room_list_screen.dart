import 'package:flutter/material.dart';
import '../Common/app_common.dart';

class RoomListScreen extends StatefulWidget {
  const RoomListScreen({super.key});

  @override
  State<RoomListScreen> createState() => _RoomListScreenState();
}

class _RoomListScreenState extends State<RoomListScreen> {
  final List<Map<String, dynamic>> rooms = const [
    {
      "id": 1,
      "guest_house_id": 1,
      "room_name": "101",
      "occupancy_type": "single",
      "max_occupancy": 1,
      "is_active": 1,
      "created_at": "2025-12-20 06:01:59",
      "is_booked": 0,
    },
    {
      "id": 2,
      "guest_house_id": 1,
      "room_name": "102",
      "occupancy_type": "double",
      "max_occupancy": 2,
      "is_active": 1,
      "created_at": "2025-12-20 06:01:59",
      "is_booked": 1,
    },
    {
      "id": 3,
      "guest_house_id": 1,
      "room_name": "103",
      "occupancy_type": "single",
      "max_occupancy": 1,
      "is_active": 0,
      "created_at": "2025-12-20 06:01:59",
      "is_booked": 0,
    },
  ];

  @override
  void initState() {
    super.initState();
    // getReminderCount();
  }

  Future<dynamic> getRoomList() async {
    var res = await AppCommon.apiProvider.getServerResponse("getRooms", "GET");

    return res;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Guest House Rooms"),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == "Setting") {
                Navigator.pushNamed(context, '/setting');
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: "Setting", child: Text("Setting")),
              PopupMenuItem(value: "bookings", child: Text("View Bookings")),
              PopupMenuItem(value: "addRoom", child: Text("Add Room")),
            ],
          ),
        ],
      ),

      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: rooms.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final room = rooms[index];
          return buildRoomCard(
            roomName: room["room_name"],
            occupancyType: room["occupancy_type"],
            maxOccupancy: room["max_occupancy"],
            isActive: room["is_active"] == 1,
            isBooked: room["is_booked"] == 1,
          );
        },
      ),
    );
  }

  Widget buildRoomCard({
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
            if (isActive)
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () {
                    if (isBooked) {
                      // 👉 Navigate to booking details screen
                    } else {
                      Navigator.pushNamed(context, '/booking');
                    }
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppCommon.colors.btnColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      isBooked ? "View Booking" : "Book Room",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
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
}
