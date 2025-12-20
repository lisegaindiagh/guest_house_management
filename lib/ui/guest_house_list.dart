import 'package:flutter/material.dart';
import '../common/app_common.dart';

class GuestHouseListScreen extends StatefulWidget {
  const GuestHouseListScreen({super.key});

  @override
  State<GuestHouseListScreen> createState() => _GuestHouseListState();
}

class _GuestHouseListState extends State<GuestHouseListScreen> {
  bool isLoading = true;

  final List<Map<String, dynamic>> guestHouses = [
    {"name": "Guest House-1 (Akota)", "location": "Baroda", "rooms": 12},
    {"name": "Guest House-2 (Gotri)", "location": "Baroda", "rooms": 8},
    {"name": "Guest House-3 (Alkapuri)", "location": "Baroda", "rooms": 5},
  ];

  @override
  void initState() {
    super.initState();
    getGuestHouseList();
  }

  Future<void> getGuestHouseList() async {
    var res = await AppCommon.apiProvider.getServerResponse("auth.php", "POST");
    res;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F5FA),

      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: const Color(0xFF2F80ED),
        title: const Text(
          "Guest Houses",
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      body: ListView.builder(
        itemCount: guestHouses.length,
        itemBuilder: (context, index) {
          final house = guestHouses[index];

          return InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: () {
              Navigator.pushNamed(context, '/home');
            },
            child: Card(
              margin: const EdgeInsets.all(14),
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Container(
                      height: 64,
                      width: 64,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        gradient: const LinearGradient(
                          colors: [Color(0xFF56CCF2), Color(0xFF2F80ED)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: const Icon(
                        Icons.apartment,
                        color: Colors.white,
                        size: 36,
                      ),
                    ),

                    const SizedBox(width: 14),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            house["name"],
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 6),

                          Row(
                            children: [
                              const Icon(
                                Icons.location_on,
                                size: 14,
                                color: Colors.black,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                house["location"],
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 10),

                          Align(
                            alignment: Alignment.bottomRight,
                            child: Container(
                              height: 28,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF7ED321), // light green (left)
                                    Color(0xFF4CAF1D), // dark green (right)
                                  ],
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                ),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                "${house["rooms"]} Rooms Available",
                                style: const TextStyle(
                                  fontSize: 12.5,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.chevron_right,
                      size: 26,
                      color: Colors.grey,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
