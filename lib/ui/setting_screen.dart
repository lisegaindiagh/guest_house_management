import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  bool _loading = false;

  final Dio _dio = Dio(); // Dio instance

  @override
  void initState() {
    super.initState();
    //_fetchSettings();
    _mobileController.text = "9090909090";
    _emailController.text = "nidhiLisega@gmail.com";
  }

  Future<void> _fetchSettings() async {
    try {
      final response = await _dio.get('https://yourdomain.com/api.php?action=getSettings');
      if (response.statusCode == 200 && response.data['success'] == true) {
        _mobileController.text = response.data['settings']['notify_mobile'];
        _emailController.text = response.data['settings']['notify_email'];
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to fetch settings")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _updateSettings() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final response = await _dio.post(
        'https://yourdomain.com/api.php?action=updateSettings',
        data: {
          'notify_mobile': _mobileController.text,
          'notify_email': _emailController.text,
        },
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Settings updated successfully")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to update settings")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Settings")),
      body: _loading
          ? Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 16.0,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: 40),
              TextFormField(
                controller: _mobileController,
                keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: "Mobile Number",
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                  focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
              color: Colors.blue, // Focused border color
              width: 2.0, // Border width
            ),
          ),
              ),

                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Mobile number is required";
                  } else if (!RegExp(r'^\d{10}$').hasMatch(value)) {
                    return "Enter a valid 10-digit mobile number";
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(
                  labelText: "Email",
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: Colors.blue, // Focused border color
                      width: 2.0, // Border width
                    ),
                  ),
                ),
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Email is required";
                  } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                    return "Enter a valid email address";
                  }
                  return null;
                },
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: _updateSettings,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text("Update Settings", style: TextStyle(fontSize: 16, color: Colors.white),),
              ),
            ],
          ),
        ),
      ),
    );
  }
}