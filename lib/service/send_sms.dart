import 'package:flutter/material.dart';
import 'package:group_smskit/group_smskit.dart';
import 'package:permission_handler/permission_handler.dart';

import '../Common/app_common.dart';

class SendSMSService {
  Future<void> sendSMS(BuildContext context, {required int roomId, required String guestName, required String mobile, required String arrival, required String departure, dynamic mealOnArrival}) async {
    // Request permission before sending SMS
    await requestSmsPermission();

    // Call the plugin method to send SMS
    final result = await GroupSMSKit.sendSms(
      // List of recipient numbers
      numbers: ['6353520694'],
      // Message body
      message: "Room Booking Alert \nGuest: $guestName \nMobile: $mobile \nRoom: $roomId \nArrival: $arrival \nDeparture: $departure \nMeal on Arrival: ${mealOnArrival ?? ""} \n\n- Booked via Guest House App"
    );

    if (context.mounted) {
      AppCommon.displayToast(result ?? "Message sent.");
    }
  }

  // Function to request SMS permission on Android
  Future<void> requestSmsPermission() async {
    // Check current permission status
    var status = await Permission.sms.status;

    // If not granted, request permission from user
    if (!status.isGranted) {
      await Permission.sms.request();
    } else if (status.isPermanentlyDenied) {
      await openAppSettings();
    }
  }
}
