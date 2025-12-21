import 'package:flutter/material.dart';
import 'package:group_smskit/group_smskit.dart';
import 'package:permission_handler/permission_handler.dart';

import '../Common/app_common.dart';

class SendSMSService {
  Future<void> sendSMS(BuildContext context) async {
    // Request permission before sending SMS
    await requestSmsPermission();

    // Call the plugin method to send SMS
    final result = await GroupSMSKit.sendSms(
      // List of recipient numbers
      numbers: ['6353520694'],
      // Message body
      message: 'Hii...!!',
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
    }
  }
}
