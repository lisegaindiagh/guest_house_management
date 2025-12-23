import 'package:flutter/material.dart';
import '../common/app_common.dart';
import 'login_screen.dart';
import 'room_list_screen.dart';

class GuestHouseListScreen extends StatefulWidget {
  const GuestHouseListScreen({super.key});

  @override
  State<GuestHouseListScreen> createState() => _GuestHouseListState();
}

class _GuestHouseListState extends State<GuestHouseListScreen> {
  bool isLoading = true;
  dynamic guestHousesList = [];

  @override
  void initState() {
    super.initState();
    getGuestHouseList();
  }

  Future<void> getGuestHouseList() async {
    isLoading = true;
    setState(() {});

    try {
      var res = await AppCommon.apiProvider.getServerResponse(
        "api.php",
        "POST",
        queryParams: {"action": "getGuestHouses"},
      );
      if (res["success"]) {
        guestHousesList = res["data"];
        await fetchSettingData();
      } else {
        AppCommon.displayToast(res["error"]);
      }
    } catch (e) {
      guestHousesList = [];
      AppCommon.displayToast("Server error");
    }
  }

  Future<void> fetchSettingData() async {
    try {
      var res = await AppCommon.apiProvider.getServerResponse(
        "api.php",
        "GET",
        queryParams: {"action": "getSettings"},
      );
      if (res["success"]) {
        await AppCommon.sharePref.setPreference({
          AppCommon.sessionKey.notifyEmail: res["settings"]["notify_email"],
          AppCommon.sessionKey.notifyMobile: res["settings"]["notify_mobile"],
        });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Guest Houses"),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == "Logout") {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                  (route) => false,
                );
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(value: "Logout", child: Text("Logout")),
            ],
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : guestHousesList.isEmpty
          ? const Center(child: Text("No guest houses found"))
          : ScrollConfiguration(
              behavior: const ScrollBehavior().copyWith(overscroll: false),
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: guestHousesList.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final guestHouse = guestHousesList[index];
                  final bool isActive = guestHouse["is_active"] == "1";

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RoomListScreen(
                            roomId: int.parse(guestHouse["id"].toString()),
                            guestRoomName: guestHouse["name"],
                          ),
                        ),
                      );
                    },
                    child: buildGuestHouseCard(
                      name: guestHouse["name"] ?? "",
                      address: guestHouse["address"] ?? "",
                      isActive: isActive,
                      totalRooms: guestHouse["total_rooms"] ?? "0",
                    ),
                  );
                },
              ),
            ),
    );
  }

  /// Guest house card UI
  Widget buildGuestHouseCard({
    required String name,
    required String address,
    required bool isActive,
    required dynamic totalRooms,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
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
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// 🏢 Guest House Icon (Professional)
            Container(
              height: 68,
              width: 68,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  colors: [
                    AppCommon.colors.primaryColor.withValues(alpha: 0.85),
                    AppCommon.colors.primaryColor.withValues(alpha: 0.55),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppCommon.colors.primaryColor.withValues(
                      alpha: 0.35,
                    ),
                    blurRadius: 10,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: const Center(
                child: Icon(
                  Icons.apartment_rounded,
                  color: Colors.white,
                  size: 34,
                ),
              ),
            ),

            const SizedBox(width: 14),

            /// 📄 Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// Title + Status
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                      statusBadge(isActive),
                    ],
                  ),

                  const SizedBox(height: 8),

                  /// 📍 Address
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 18,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          address,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  /// Divider
                  Divider(color: Colors.grey.shade200, thickness: 1),

                  const SizedBox(height: 10),

                  /// Footer
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      infoChip(
                        icon: Icons.meeting_room_outlined,
                        label: "$totalRooms Rooms",
                      ),
                      const Icon(Icons.chevron_right, color: Colors.grey),
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

  Widget statusBadge(bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isActive
            ? Colors.green.withValues(alpha: 0.12)
            : Colors.red.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        isActive ? "Active" : "Inactive",
        style: TextStyle(
          color: isActive ? Colors.green : Colors.red,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget infoChip({required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey.shade700),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
