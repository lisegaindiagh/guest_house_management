import 'package:flutter/material.dart';
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
        AppCommon.displayToast(res["error"]);
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
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: bookingDetailsList.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                return buildBookingDetails(bookingDetailsList[index]);
              },
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

  Widget buildBookingDetails(var bookingDetails) {
    return SizedBox(
      width: double.infinity,
      child: Card(
        elevation: 2,
        margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _detailRow("Guest Name", bookingDetails["guest_name"]),
              _detailRow("Arrival Date", bookingDetails["arrival_datetime"]),
              _detailRow(
                "Departure Date",
                bookingDetails["departure_datetime"],
              ),
              _detailRow("Meal On Arrival", getMealText(bookingDetails)),
              _detailRow("Booked By", bookingDetails["booked_by"]),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () async {
                    await cancelBooking(bookingDetails["booking_id"]);
                  },
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                  child: const Text("Cancel Booking "),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _detailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(color: Colors.black, fontSize: 14),
          children: [
            TextSpan(
              text: "$title : ",
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            TextSpan(
              text: value,
              style: const TextStyle(fontWeight: FontWeight.w400),
            ),
          ],
        ),
      ),
    );
  }
}
