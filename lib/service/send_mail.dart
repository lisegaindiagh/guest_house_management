import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import 'sign_with_google.dart';

class SendMailService {
  Future<void> sendEmail(BuildContext context) async {
    final googleService = SignInWithGoogleService.instance;
    final account = googleService.currentUser;
    if (account == null) {
      return;
    }

    final accessToken = googleService.accessToken;
    if (accessToken == null) {
      return;
    }

    final from = account.email; // send FROM the signed-in user
    final to = 'lisegaindiagh@gmail.com'; // change this
    final subject = 'Hello from Flutter (Gmail API) ${DateTime.now()}';
    final htmlBody =
        '<h3>Hi!</h3><p>This email was sent using Gmail API + OAuth2.</p>';

    final raw = _createRawMessage(
      from: from,
      to: to,
      subject: subject,
      bodyHtml: htmlBody,
    );

    final rawBase64 = _toBase64Url(raw);

    final url = Uri.parse(
      'https://gmail.googleapis.com/gmail/v1/users/me/messages/send',
    );

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'raw': rawBase64}),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Email sent ✅')));
    } else {
      print('Send failed (${response.statusCode}): ${response.body}');
    }
  }

  // Build a raw RFC 2822 email string.
  String _createRawMessage({
    required String from,
    required String to,
    required String subject,
    required String bodyHtml,
    String bodyPlain = '',
  }) {
    final dateStr = DateFormat(
      'EEE, dd MMM yyyy HH:mm:ss +0000',
    ).format(DateTime.now().toUtc());
    final raw = StringBuffer()
      ..writeln('From: $from')
      ..writeln('To: $to')
      ..writeln('Subject: $subject')
      ..writeln('Date: $dateStr')
      ..writeln('MIME-Version: 1.0')
      ..writeln('Content-Type: text/html; charset="UTF-8"')
      ..writeln('Content-Transfer-Encoding: 7bit')
      ..writeln()
      ..writeln(bodyHtml);
    return raw.toString();
  }

  // Encode raw RFC 2822 message into base64url string as required by Gmail API.
  String _toBase64Url(String rawMessage) {
    final bytes = utf8.encode(rawMessage);
    final b64 = base64UrlEncode(bytes); // URL-safe base64
    // Gmail often accepts with padding removed:
    return b64.replaceAll('=', '');
  }
}
