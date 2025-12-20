import 'package:flutter/material.dart';

import '../service/send_mail.dart';
import '../service/send_sms.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () async {
                await SendMailService().sendEmail(context);
              },
              child: const Text('Send Email'),
            ),
            ElevatedButton(
              onPressed: () async {
                await SendSMSService().sendSMS(context);
              },
              child: const Text("SEND SMS"),
            ),
          ],
        ),
      ),
    );
  }
}
