import 'package:flutter/material.dart';
import 'package:group_smskit/group_smskit.dart';
import 'package:permission_handler/permission_handler.dart';

import '../Common/app_common.dart';

class SendSMSService {
  Future<void> sendSMS(BuildContext context, {required int roomId, required String guestName, required String mobile, required String arrival, required String departure, dynamic mealOnArrival, dynamic note}) async {
    // Request permission before sending SMS
    await requestSmsPermission();

    var notifyMobile = await AppCommon.sharePref.getString(
      AppCommon.sessionKey.notifyMobile,
    );

    // Call the plugin method to send SMS
    final result = await GroupSMSKit.sendSms(
      // List of recipient numbers
      numbers: [notifyMobile],
      // Message body
      message:
    "Booking has been successfully confirmed.\n"
    "Guest: $guestName\n"
    "Mobile: $mobile\n"
    "Check-In: $arrival\n"
    "Check-Out: $departure\n"
    "Meals: ${mealOnArrival?.isNotEmpty == true ? mealOnArrival : "No meals selected"}\n"
    "Note: $note\n\n"
    "Guest House Management"
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
