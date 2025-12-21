import 'package:flutter/material.dart';
import '../common/app_common.dart';

class ViewBookingScreen extends StatefulWidget {
  const ViewBookingScreen({super.key});

  @override
  State<ViewBookingScreen> createState() => _ViewBookingScreenState();
}

class _ViewBookingScreenState extends State<ViewBookingScreen> {
  bool isLoading = true, isFirstTime = true;
  Map<String,dynamic> bookingDetails = {};



  Future<void> getBookingDetails(int roomId) async {
    try {
      var res = await AppCommon.apiProvider.getServerResponse(
        "api.php",
        "GET",
        queryParams: {"action": "getRoomBooking", "room_id": roomId},
      );
      if (!AppCommon.isEmpty(res)) {
        if (res is Map && res.containsKey("booking")) {
          bookingDetails = res["booking"];

        } else if (res is Map && res.containsKey("error")) {
          AppCommon.displayToast(res["error"]);
        }
      }
    } catch (e) {
      AppCommon.displayToast("Server error");
    } finally {
      isLoading = false;
      isFirstTime = false;
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final int roomId = (ModalRoute.of(context)!.settings.arguments ?? 0) as int;
    if (isFirstTime && roomId != 0) {
      getBookingDetails(roomId);
    }
    return Scaffold(
      appBar: AppBar(title: const Text("View Booking")),
      body: isLoading
          ? Center(child: CircularProgressIndicator()):
         buildBookingDetails(
    guestName: bookingDetails["guest_name"],
        arrivalDate: bookingDetails["arrival_datetime"],
        departureDate: bookingDetails["departure_datetime"],
        mealONArrival: bookingDetails["meal_on_arrival"],
        bookedBy:bookingDetails["booked_by"]
    )
    );
  }
  Widget buildBookingDetails({
    required String guestName,
    required String arrivalDate,
    required String departureDate,
    required String mealONArrival,
    required String bookedBy,
  }) {
    return SizedBox(
      width: double.infinity,
      child: Card(
        elevation: 3,
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, // ✅ left aligned
            mainAxisSize: MainAxisSize.min, // ✅ not full screen
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                        ),
                        children: [
                          const TextSpan(
                            text: "Guest Name : ",
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          TextSpan(
                            text: guestName,
                            style: const TextStyle(fontWeight: FontWeight.w400),
                          ),
                        ],
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {

                    },
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.red,
                    ),
                    child: const Text("Cancel"),
                  ),
                ],
              ),

              const Divider(),
              _detailRow("Guest Name", guestName),
              _detailRow("Arrival Date", arrivalDate),
              _detailRow("Departure Date", departureDate),
              _detailRow("Meal On Arrival", mealONArrival),
              _detailRow("Booked By", bookedBy),
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
