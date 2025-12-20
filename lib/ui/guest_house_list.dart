import 'package:flutter/material.dart';
import '../common/app_common.dart';

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
      guestHousesList = AppCommon.apiProvider.handleListResponse(res);
    } catch (e) {
      guestHousesList = [];
      AppCommon.displayToast("Server error");
    } finally {
      isLoading = false;
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Guest Houses")),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: guestHousesList.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final guestHouse = guestHousesList[index];
                final bool isActive = guestHouse["is_active"] == "1";

                return GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/home',
                      arguments: int.parse(guestHouse["id"]),
                    );
                  },
                  child: buildGestHouseCard(
                    name: guestHouse["name"],
                    address: guestHouse["address"],
                    isActive: isActive,
                  ),
                );
              },
            ),
    );
  }

  Widget buildGestHouseCard({
    required String name,
    required String address,
    required bool isActive,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Row(
          spacing: 12,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 64,
              width: 64,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                gradient: LinearGradient(
                  colors: [
                    AppCommon.colors.primaryColor.withValues(alpha: 0.4),
                    AppCommon.colors.primaryColor.withValues(alpha: 0.7),
                    AppCommon.colors.primaryColor,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: const Icon(Icons.apartment, color: Colors.white, size: 36),
            ),
            Expanded(
              child: Column(
                spacing: 8,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 8,
                    children: [
                      Expanded(
                        child: Text(
                          name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      buildStatusChip(isActive: isActive),
                    ],
                  ),
                  Row(
                    spacing: 8,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.location_on_outlined, size: 18),
                      Expanded(
                        child: Text(
                          address,
                          style: const TextStyle(color: Colors.grey),
                        ),
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
          color: isActive ? Colors.green : Colors.red,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
