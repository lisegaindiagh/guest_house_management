import 'package:flutter/material.dart';
import '../Common/app_common.dart';

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
    var res = await AppCommon.apiProvider.getServerResponse("api.php?action=getRooms&guest_house_id=${roomId}", "POST");
    /*  if(AppCommon.isEmpty(res["error"])){

    }*/
    roomList = res;
    isLoading = false;
    isFirstTime = false;
    setState(() {});
    res;
  }

  @override
  Widget build(BuildContext context) {
    final int roomId =
    ModalRoute.of(context)!.settings.arguments as int;
    if(isFirstTime){
      getGuestHouseRoomList(roomId);
    }
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
              PopupMenuItem(value: "Setting", child: Text("Setting")),
              PopupMenuItem(value: "bookings", child: Text("View Bookings")),
              PopupMenuItem(value: "addRoom", child: Text("Add Room")),
            ],
          ),
        ],
      ),

      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: roomList.length,
        itemBuilder: (context, index) {
          final room = roomList[index];

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
                            "Room ${room["room_name"]}",
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(
                            height: 34,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: room["is_booked"] == 0
                                    ?
                                     const Color(0xFF2F80ED)
                                      :Colors.red,

                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                              ),
                              onPressed: () {
                                if (room["is_booked"] == 0) {
                                  Navigator.pushNamed(context, '/booking');
                                } else {

                                }
                              },
                              child: Text(
                                room["is_booked"] == 0 ? "Book" : "Cancel",
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
                        room["occupancy_type"],
                        style: const TextStyle(
                          fontSize: 15,
                          color: Colors.black,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        room["is_booked"] == 0 ? "Available":"Booked",
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
