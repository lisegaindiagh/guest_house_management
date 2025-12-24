import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../common/app_common.dart';

class ViewBookingScreen extends StatefulWidget {
  final int roomId;

  const ViewBookingScreen({super.key, required this.roomId});

  @override
  State<ViewBookingScreen> createState() => _ViewBookingScreenState();
}

class _ViewBookingScreenState extends State<ViewBookingScreen> {
  bool isLoading = true;
  dynamic bookingDetailsList = [];

  @override
  void initState() {
    super.initState();
    getBookingDetails();
  }

  Future<void> getBookingDetails() async {
    try {
      var res = await AppCommon.apiProvider.getServerResponse(
        "api.php",
        "GET",
        queryParams: {"action": "getRoomBooking", "room_id": widget.roomId},
      );
      if (!AppCommon.isEmpty(res) && res["success"]) {
        bookingDetailsList = res["bookings"];
      } else {
        AppCommon.displayToast(res["message"]);
      }
    } catch (e) {
      AppCommon.displayToast("Server error");
    } finally {
      isLoading = false;
      setState(() {});
    }
  }

  Future<void> cancelBooking(int bookingId) async {
    try {
      var res = await AppCommon.apiProvider.getServerResponse(
        "api.php",
        "POST",
        queryParams: {"action": "cancelBooking"},
        params: {"booking_id": bookingId},
      );
      if (!AppCommon.isEmpty(res) && res["success"]) {
        AppCommon.displayToast(res["message"]);
        await getBookingDetails();
      } else {
        AppCommon.displayToast(res["error"]);
      }
    } catch (e) {
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
        title: const Text("View Booking"),
        leading: BackButton(
          onPressed: () {
            Navigator.pop(context, true);
          },
        ),
      ),
      body: SafeArea(
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: bookingDetailsList.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  return buildBookingDetails(bookingDetailsList[index]);
                },
              ),
      ),
    );
  }

  String getMealText(Map<String, dynamic> data) {
    final mealMap = {
      "is_breakfast": "Breakfast",
      "is_lunch": "Lunch",
      "is_dinner": "Dinner",
    };

    final selectedMeals = mealMap.entries
        .where((e) => data[e.key] == 1)
        .map((e) => e.value)
        .toList();

    return selectedMeals.isNotEmpty ? selectedMeals.join(", ") : "No Meals";
  }

  Widget buildBookingDetails(Map<String, dynamic> booking) {
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// 👤 Guest Name + Status
            Text(
              booking["guest_name"] ?? "",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),

            const SizedBox(height: 10),

            /// 📅 Date Range
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 📅 Arrival
                  Row(
                    children: [
                      const Icon(Icons.login, size: 16, color: Colors.grey),
                      const SizedBox(width: 8),
                      const Text(
                        "Arrival:",
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          convertDateFormat(
                            booking["arrival_datetime"],
                            "yyyy-MM-dd HH:mm:ss",
                            "dd/MM/yyyy hh:mm a",
                          ),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // 📅 Departure
                  Row(
                    children: [
                      const Icon(Icons.logout, size: 16, color: Colors.grey),
                      const SizedBox(width: 8),
                      const Text(
                        "Departure:",
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          convertDateFormat(
                            booking["departure_datetime"],
                            "yyyy-MM-dd HH:mm:ss",
                            "dd/MM/yyyy hh:mm a",
                          ),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            /// 🍽️ Meals
            Wrap(spacing: 8, runSpacing: 8, children: mealChips(booking)),

            if (!AppCommon.isEmpty(booking["booked_by"])) ...[
              const SizedBox(height: 14),

              /// 👤 Booked By
              Row(
                children: [
                  const Icon(
                    Icons.person_outline,
                    size: 16,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    "Booked by: ${booking["booked_by"]}",
                    style: const TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 18),

            /// Divider
            Divider(color: Colors.grey.shade200, thickness: 1),

            /// ❌ Cancel Action
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () async {
                  await cancelBooking(booking["booking_id"]);
                },
                icon: const Icon(Icons.cancel_outlined, size: 18),
                label: const Text("Cancel Booking"),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.red,
                  textStyle: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> mealChips(Map<String, dynamic> data) {
    final meals = {
      "is_breakfast": "Breakfast",
      "is_lunch": "Lunch",
      "is_dinner": "Dinner",
    };

    final selectedMeals = meals.entries
        .where((e) => data[e.key] == 1)
        .map(
          (e) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              e.value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.green,
              ),
            ),
          ),
        )
        .toList();

    if (selectedMeals.isEmpty) {
      return [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Text(
            "No Meals",
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
        ),
      ];
    }

    return selectedMeals;
  }

  String convertDateFormat(String input, String fromFormat, String toFormat) {
    final inputFormatter = DateFormat(fromFormat);
    final outputFormatter = DateFormat(toFormat);
    final dateTime = inputFormatter.parse(input);
    return outputFormatter.format(dateTime);
  }
}
