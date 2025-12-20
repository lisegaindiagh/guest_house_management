import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../Common/app_common.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  /// 🔑 Form key
  final _formKey = GlobalKey<FormState>();

  /// 📝 Controllers
  final _guestController = TextEditingController();
  final _mobileController = TextEditingController();
  final _fromController = TextEditingController();
  final _arrivalController = TextEditingController();
  final _departureController = TextEditingController();

  DateTime? _arrivalDate;
  DateTime? _departureDate;

  Map<String, bool> meals = {
    "Breakfast": false,
    "Lunch": false,
    "Dinner": false,
  };

  /// 🎨 Common InputDecoration
  InputDecoration _inputDecoration(String label, {Widget? suffixIcon}) {
    return InputDecoration(
      labelText: label,
      suffixIcon: suffixIcon,
      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      floatingLabelStyle: TextStyle(color: AppCommon.colors.primaryColor),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: AppCommon.colors.primaryColor, width: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Guest Booking")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            spacing: 12,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// 👤 Guest Name
              TextFormField(
                controller: _guestController,
                maxLength: 20,
                decoration: _inputDecoration("Guest Name"),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Guest name is required";
                  }
                  return null;
                },
              ),

              /// 📱 Mobile Number
              TextFormField(
                controller: _mobileController,
                keyboardType: TextInputType.phone,
                maxLength: 10,
                decoration: _inputDecoration("Mobile Number"),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Mobile number is required";
                  }
                  if (value.length != 10) {
                    return "Enter valid 10 digit mobile number";
                  }
                  return null;
                },
              ),

              /// 📍 From
              TextFormField(
                controller: _fromController,
                decoration: _inputDecoration("From"),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "From location is required";
                  }
                  return null;
                },
              ),

              /// 📅 Arrival
              TextFormField(
                controller: _arrivalController,
                readOnly: true,
                decoration: _inputDecoration(
                  "Arrival",
                  suffixIcon: Icon(
                    Icons.calendar_today,
                    color: AppCommon.colors.primaryColor,
                  ),
                ),
                validator: (_) {
                  if (_arrivalDate == null) {
                    return "Please select arrival date & time";
                  }
                  return null;
                },
                onTap: () => pickDateTime(true),
              ),

              /// 📅 Departure
              TextFormField(
                controller: _departureController,
                readOnly: true,
                decoration: _inputDecoration(
                  "Departure",
                  suffixIcon: Icon(
                    Icons.calendar_today,
                    color: AppCommon.colors.primaryColor,
                  ),
                ),
                validator: (_) {
                  if (_departureDate == null) {
                    return "Please select departure date & time";
                  }
                  return null;
                },
                onTap: () => pickDateTime(false),
              ),

              /// 🍽 Meals
              Column(
                spacing: 4,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    "Meal on Arrival",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Wrap(
                    spacing: 10,
                    children: meals.keys.map((meal) {
                      return FilterChip(
                        label: Text(meal),
                        selected: meals[meal]!,
                        onSelected: (val) {
                          setState(() => meals[meal] = val);
                        },
                      );
                    }).toList(),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              /// ✅ Submit Button
              Row(
                spacing: 12,
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        "Cancel",
                        style: TextStyle(
                          fontSize: 16,
                          color: AppCommon.colors.primaryColor,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppCommon.colors.primaryColor,
                      ),
                      onPressed: _submit,
                      child: const Text(
                        "Submit",
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 📤 Submit
  void _submit() {
    if (_formKey.currentState!.validate()) {
      final selectedMeals = meals.entries
          .where((e) => e.value)
          .map((e) => e.key)
          .toList();

      debugPrint("Guest: ${_guestController.text}");
      debugPrint("Mobile: ${_mobileController.text}");
      debugPrint("From: ${_fromController.text}");
      debugPrint("Arrival: ${_arrivalController.text}");
      debugPrint("Departure: ${_departureController.text}");
      debugPrint("Meals: $selectedMeals");

      Navigator.pop(context);
    }
  }

  /// 📅 Date & Time Picker
  Future<void> pickDateTime(bool isArrival) async {
    if (!isArrival && _arrivalDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select Arrival first")),
      );
      return;
    }

    DateTime initialDate = isArrival
        ? (_arrivalDate ?? DateTime.now())
        : _arrivalDate!;
    DateTime firstDate = isArrival ? DateTime.now() : _arrivalDate!;
    DateTime lastDate = DateTime(2100);

    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppCommon.colors.primaryColor, // Header & selected date
              onPrimary: AppCommon.colors.white, // Header text
              onSurface: AppCommon.colors.black, // Calendar text
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: AppCommon.colors.primaryColor, // OK / CANCEL
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate == null) return;

    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppCommon.colors.primaryColor, // Header & selected date
              onPrimary: AppCommon.colors.white, // Header text
              onSurface: AppCommon.colors.black, // Calendar text
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: AppCommon.colors.primaryColor, // OK / CANCEL
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedTime == null) return;

    final dateTime = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );

    setState(() {
      if (isArrival) {
        _arrivalDate = dateTime;
        _arrivalController.text = DateFormat(
          "dd/MM/yyyy hh:mm a",
        ).format(dateTime);
        _departureDate = null;
        _departureController.clear();
      } else {
        _departureDate = dateTime;
        _departureController.text = DateFormat(
          "dd/MM/yyyy hh:mm a",
        ).format(dateTime);
      }
    });
  }

  @override
  void dispose() {
    _guestController.dispose();
    _mobileController.dispose();
    _fromController.dispose();
    _arrivalController.dispose();
    _departureController.dispose();
    super.dispose();
  }
}
