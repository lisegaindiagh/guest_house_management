import 'package:flutter/material.dart';
import 'package:guest_house_management/Api/api_provider.dart';
import '../Common/app_common.dart';


class RoomListScreen extends StatefulWidget {
  const RoomListScreen({super.key});

  @override
  State<RoomListScreen> createState() => _RoomListScreenState();
}

class _RoomListScreenState extends State<RoomListScreen> {
  List<Map<String, dynamic>> rooms = [
    {"roomNo": "101", "type": "Single", "isBooked": false},
    {"roomNo": "102", "type": "Single", "isBooked": false},
    {"roomNo": "103", "type": "Single", "isBooked": false},
    {"roomNo": "104", "type": "Double", "isBooked": true},
  ];


  @override
  void initState() {
    super.initState();
   // getReminderCount();
  }

  Future<dynamic> getRoomList() async {
    var res = await ApiProvider.getServerResponse(
     "getRooms",
      "GET",
    );


    return res;
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F5FA),

      appBar: AppBar(
        title: const Text("Guest House Rooms"),
        backgroundColor: Colors.blue,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == "Setting") {
                Navigator.pushNamed(context, '/setting');
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: "Setting",
                child: Text("Setting"),
              ),
              PopupMenuItem(
                value: "bookings",
                child: Text("View Bookings"),
              ),
              PopupMenuItem(
                value: "addRoom",
                child: Text("Add Room"),
              ),
            ],
          )
        ],
      ),

      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: rooms.length,
        itemBuilder: (context, index) {
          final room = rooms[index];

          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Room ${room["roomNo"]}",
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(
                            height: 34,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: room["isBooked"]
                                    ? Colors.red
                                    : const Color(0xFF2F80ED),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                              ),
                              onPressed: () {
                                if (room["isBooked"]) {
                                  setState(() {
                                    room["isBooked"] = false;
                                  });
                                } else {
                                  Navigator.pushNamed(context, '/booking');
                                }
                              },
                              child: Text(
                                room["isBooked"] ? "Cancel" : "Book",
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        room["type"],
                        style: const TextStyle(
                          fontSize: 15,
                          color: Colors.black,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        room["isBooked"] ? "Booked" : "Available",
                        style: const TextStyle(
                          fontSize: 15,
                          color: Colors.black,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}