import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../Common/app_common.dart';
import '../service/send_sms.dart';

class ViewBookingScreen extends StatefulWidget {
  final int roomId;
  final String roomName;

  const ViewBookingScreen({super.key, required this.roomId, required this.roomName});

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
        bookingDetailsList = [];
        AppCommon.displayToast(res["message"]);
      }
    } catch (e) {
      AppCommon.displayToast("Server error");
    } finally {
      isLoading = false;
      setState(() {});
    }
  }

  Future<void> sendMessage(dynamic bookingDetails) async {
    // for send Email
    try {
      var email = await AppCommon.sharePref.getString(
        AppCommon.sessionKey.email,
      );
      var notifyEmail = await AppCommon.sharePref.getString(
        AppCommon.sessionKey.notifyEmail,
      );

      final htmlText = bookingCancelledHtml(
        guestName: bookingDetails["guest_name"],
        mobile: bookingDetails["mobile"],
        roomNo: widget.roomName,
        checkIn: bookingDetails["arrival_datetime"],
        checkOut: bookingDetails["departure_datetime"],
        meals: getMealText(bookingDetails),
        note: bookingDetails["note"],
      );

      var sendEmailResponse = await AppCommon.apiProvider.getServerResponse(
        "send_mailer.php",
        "POST",
        params: {
          "sender_email": email,
          "receiver_email": notifyEmail,
          "subject": "Booking Cancelled | Guest House Management App",
          "text": htmlText,
        },
      );

    } finally {
      debugPrint("failed to send Email.");
    }
    // for send SMS
    try {
      await SendSMSService().sendSMS(
          context,
          roomName: widget.roomName,
          guestName: bookingDetails["guest_name"],
          mobile: bookingDetails["mobile"],
          arrival:bookingDetails["arrival_datetime"],
          departure: bookingDetails["departure_datetime"],
          note: bookingDetails["note"],
          mealOnArrival: getMealText(bookingDetails),
          isConfirmed: false
      );
      AppCommon.endLoadingProcess(context);
    } finally {
      AppCommon.endLoadingProcess(context);
      debugPrint("failed to send SMS.");
    }
  }

  String bookingCancelledHtml({
    required String guestName,
    required String mobile,
    required String roomNo,
    required String checkIn,
    required String checkOut,
    required String meals,
    required String note,
  }) {
    final year = DateTime.now().year;
    return '''
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
</head>
<body style="margin:0;padding:0;background:#f4f6f8;font-family:Arial,Helvetica,sans-serif;">

<table width="100%" cellpadding="0" cellspacing="0">
  <tr>
    <td align="center" style="padding:20px;">
      
      <table width="600" cellpadding="0" cellspacing="0" style="background:#ffffff;border-radius:8px;overflow:hidden;">
        
        <!-- Header -->
        <tr>
          <td style="background:#dc3545;color:#ffffff;padding:20px;text-align:center;">
            <h2 style="margin:0;">BOOKING CANCELLED</h2>
          </td>
        </tr>

        <!-- Content -->
        <tr>
          <td style="padding:24px;color:#333333;">
            
            <p style="font-size:16px;">
              <strong style="color:#dc3545;">The booking has been cancelled.</strong>
            </p>

            <table width="100%" cellpadding="8" cellspacing="0" style="border-collapse:collapse;margin-top:15px;">
              <tr>
                <td style="background:#f8f9fa;width:40%;"><strong>Guest Name</strong></td>
                <td>$guestName</td>
              </tr>
              <tr>
                <td style="background:#f8f9fa;"><strong>Mobile</strong></td>
                <td>$mobile</td>
              </tr>
              <tr>
                <td style="background:#f8f9fa;"><strong>Room No</strong></td>
                <td>$roomNo</td>
              </tr>
              <tr>
                <td style="background:#f8f9fa;"><strong>Check-In</strong></td>
                <td>$checkIn</td>
              </tr>
              <tr>
                <td style="background:#f8f9fa;"><strong>Check-Out</strong></td>
                <td>$checkOut</td>
              </tr>
              <tr>
                <td style="background:#f8f9fa;"><strong>Meals</strong></td>
                <td>$meals</td>
              </tr>
              ${note.isEmpty ? '' : '''
              <tr>
                <td style="background:#f8f9fa;"><strong>Note</strong></td>
                <td>$note</td>
              </tr>
              '''}
            </table>

            <p style="margin-top:25px;font-size:13px;color:#6c757d;">
              This is an automated message from the <strong>Guest House Management App</strong>.
            </p>

          </td>
        </tr>

        <!-- Footer -->
        <tr>
          <td style="background:#f1f3f5;padding:12px;text-align:center;font-size:12px;color:#6c757d;">
            © $year Guest House Management App
          </td>
        </tr>

      </table>

    </td>
  </tr>
</table>

</body>
</html>
''';
  }

  Future<void> cancelBooking(dynamic bookingDetails) async {
    AppCommon.startLoadingProcess(context);
    try {
      var res = await AppCommon.apiProvider.getServerResponse(
        "api.php",
        "POST",
        queryParams: {"action": "cancelBooking"},
        params: {"booking_id": bookingDetails["booking_id"]},
      );

      if (!AppCommon.isEmpty(res) && res["success"]) {
        AppCommon.displayToast(res["message"]);
        await sendMessage(bookingDetails);
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
        title: const Text("Booking Details "),
        leading: BackButton(
          onPressed: () {
            Navigator.pop(context, true);
          },
        ),
      ),
      body: SafeArea(
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : bookingDetailsList.isEmpty
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    spacing: 12,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "No upcoming bookings found. You can create a new booking for this room.",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 18),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppCommon.colors.primaryColor,
                        ),
                        onPressed: () {
                          Navigator.pop(context, true);
                        },
                        child: Text(
                          "Go Back",
                          style: TextStyle(color: AppCommon.colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              )
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

    return selectedMeals.isNotEmpty
        ? selectedMeals.join(", ")
        : "No Meals Selected";
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
                        "Check-in:",
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
                          style: const TextStyle(fontWeight: FontWeight.w500),
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
                        "Check-out:",
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
                          style: const TextStyle(fontWeight: FontWeight.w500),
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
                            "Special Note",
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
                        await cancelBooking(booking);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      backgroundColor: AppCommon.colors.primaryColor.withValues(
                        alpha: 0.1,
                      ),
                      foregroundColor: Colors.red,
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
                        Text("Cancel Booking"),
                      ],
                    ),
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
                        "Confirm Cancellation",
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
                const Text("Are you sure you want to cancel this booking?"),

                const SizedBox(height: 14),

                /// Actions
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text("Go Back"),
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
