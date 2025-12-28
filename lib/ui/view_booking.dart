import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../Common/app_common.dart';


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
    bool isExit = false;
    try {
      var res = await AppCommon.apiProvider.getServerResponse(
        "api.php",
        "GET",
        queryParams: {"action": "getRoomBooking", "room_id": widget.roomId},
      );
      if (!AppCommon.isEmpty(res) && res["success"]) {
        bookingDetailsList = res["bookings"];
      } else {
        bookingDetailsList = [];
        isExit = true;
        AppCommon.displayToast(res["message"]);
      }
    } catch (e) {
      AppCommon.displayToast("Server error");
    } finally {
      isLoading = false;
      setState(() {});
      if(isExit){
        WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pop(context, true);
        });
      }
    }
  }

  Future<void> cancelBooking(int bookingId) async {
    AppCommon.startLoadingProcess(context);
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
      AppCommon.endLoadingProcess(context);
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

            const SizedBox(height: 8),

            Wrap(spacing: 8, runSpacing: 8, children: mealChips(booking)),

            if (!AppCommon.isEmpty(booking["note"])) ...[
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.sticky_note_2_outlined,
                      size: 18,
                      color: Colors.blueGrey,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Note",
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Colors.blueGrey,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            booking["note"],
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],

            if (!AppCommon.isEmpty(booking["booked_by"])) ...[
              const SizedBox(height: 8),

              Row(
                children: [
                  const Icon(
                    Icons.person_outline,
                    size: 16,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    "Booked by: ",
                    style: const TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                  Expanded(
                    child: Text(
                      booking["booked_by"],
                      style: const TextStyle(fontSize: 13, color: Colors.black),
                    ),
                  ),

                ],
              ),
            ],

            Divider(color: Colors.grey.shade200, thickness: 1),
            if (AppCommon.canBook)
            Align(
              alignment: Alignment.centerRight,
               child: SizedBox(
                  height: 40,
                  child: ElevatedButton(
                    onPressed: () async {
                      final confirm = await showCancelBookingDialog(context);

                      if (confirm == true) {
                        await cancelBooking(booking["booking_id"]);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      backgroundColor:  AppCommon.colors.primaryColor.withValues(alpha: 0.1),
                      foregroundColor:  Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 0,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.cancel_outlined, size: 18),
                        const SizedBox(width: 4),
                        Text(
                          "Cancel Booking",
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                )
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
                fontWeight: FontWeight.w900,
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

  Future<bool?> showCancelBookingDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// ⚠️ Header
                Row(
                  children: [
                    Container(
                      height: 44,
                      width: 44,
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.cancel_outlined,
                        color: Colors.red,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        "Cancel Booking",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                /// Message
                const Text(
                  "Are you sure you want to cancel this booking?\n"
                  "This action cannot be undone.",
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),

                const SizedBox(height: 20),

                /// Divider
                Divider(color: Colors.grey.shade200, thickness: 1),

                const SizedBox(height: 12),

                /// Actions
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text("No"),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text(
                        "Yes, Cancel",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
