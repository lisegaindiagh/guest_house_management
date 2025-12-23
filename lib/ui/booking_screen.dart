import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../Common/app_common.dart';
import '../service/send_sms.dart';

class BookingScreen extends StatefulWidget {
  final int roomId, guestHouseId;

  const BookingScreen({
    super.key,
    required this.roomId,
    required this.guestHouseId,
  });

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  /// 🔑 Form key
  final _formKey = GlobalKey<FormState>();

  /// 📝 Controllers
  final _guestController = TextEditingController();
  final _mobileController = TextEditingController();
  final _arrivalController = TextEditingController();
  final _departureController = TextEditingController();

  DateTime? _arrivalDate;
  DateTime? _departureDate;

  Map<String, bool> meals = {
    "Breakfast": false,
    "Lunch": false,
    "Dinner": false,
  };

  bool isLoading = false;

  String convertDate(String input) {
    DateTime date = DateTime.parse(input);
    return DateFormat("dd/MM/yyyy HH:mm:ss").format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Guest Booking")),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
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
                      decoration: AppCommon.inputDecoration("Guest Name"),
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
                      decoration: AppCommon.inputDecoration("Mobile Number"),
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

                    /// 📅 Arrival
                    TextFormField(
                      controller: _arrivalController,
                      readOnly: true,
                      decoration: AppCommon.inputDecoration(
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
                      decoration: AppCommon.inputDecoration(
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
                            onPressed: () async {
                              await _submit();
                            },
                            child: Text(
                              "Submit",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
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
  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      final selectedMeals = meals.entries
          .where((e) => e.value)
          .map((e) => e.key)
          .toList();

      debugPrint("Guest: ${_guestController.text}");
      debugPrint("Mobile: ${_mobileController.text}");
      debugPrint("Arrival: ${_arrivalController.text}");
      debugPrint("Departure: ${_departureController.text}");
      debugPrint("Meals: $selectedMeals");
      await bookedRoom();
    }
  }

  Future<void> bookedRoom() async {
    final selectedMeals = meals.entries
        .where((e) => e.value)
        .map((e) => e.key)
        .toList();

    DateTime dateTime = DateFormat(
      "dd/MM/yyyy HH:mm:ss",
    ).parse(_arrivalController.text);

    DateTime departureController = DateFormat(
      "dd/MM/yyyy HH:mm:ss",
    ).parse(_departureController.text);

    try {
      var res = await AppCommon.apiProvider.getServerResponse(
        "api.php",
        "POST",
        queryParams: {"action": "createBooking"},
        params: {
          "guest_house_id": widget.guestHouseId,
          "room_id": widget.roomId,
          "guest_name": _guestController.text,
          "mobile": _mobileController.text,
          "arrival_datetime": DateFormat(
            "yyyy-MM-dd HH:mm:ss",
          ).format(dateTime),
          "departure_datetime": DateFormat(
            "yyyy-MM-dd HH:mm:ss",
          ).format(departureController),
          "is_breakfast": meals["Breakfast"] == true ? 1 : 0,
          "is_lunch": meals["Lunch"] == true ? 1 : 0,
          "is_dinner": meals["Dinner"] == true ? 1 : 0,
          /* "is_breakfast": 1,
              "is_lunch": 0,
              "is_dinner": 1,*/
          "note": "Late arrival, please keep room ready",
          //selectedMeals
        },
      );
      if (res["success"]) {
        // for send SMS
        try {
          await SendSMSService().sendSMS(
            context,
            roomId: widget.roomId,
            guestName: _guestController.text,
            mobile: _mobileController.text,
            arrival: _arrivalController.text,
            departure: _departureController.text,
            mealOnArrival: selectedMeals.isEmpty ? "" : selectedMeals,
          );
          AppCommon.displayToast(res["message"]);
          Navigator.pop(context, true);
        } finally {
          debugPrint("failed to send SMS.");
        }
        // for send Email
        try {
          //https://mediumvioletred-wallaby-126857.hostingersite.com/api/send_mailer.php
          // todo: change sender & receiver
          var email = await AppCommon.sharePref.getString(
            AppCommon.sessionKey.email,
          );
          var notifyEmail = await AppCommon.sharePref.getString(
            AppCommon.sessionKey.notifyEmail,
          );
          var sendEmailResponse = await AppCommon.apiProvider.getServerResponse(
            "send_mailer.php",
            "POST",
            params: {
              "sender_email": email,
              "receiver_email": notifyEmail,
              "text": "test mail",
            },
          );
        } finally {
          debugPrint("failed to send Email.");
        }
      } else {
        AppCommon.displayToast(res["error"]);
      }
    } catch (e) {
      AppCommon.displayToast("Server error");
    }
  }

  /// 📅 Date & Time Picker
  Future<void> pickDateTime(bool isArrival) async {
    if (!isArrival && _arrivalDate == null) {
      AppCommon.displayToast("Please select Arrival first");
      return;
    }

    DateTime initialDate = isArrival
        ? (_arrivalDate ?? DateTime.now())
        : (_departureDate ?? _arrivalDate!);
    DateTime firstDate = isArrival ? (DateTime.now()) : _arrivalDate!;
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
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            alwaysUse24HourFormat: true, // ✅ 24-hour format
          ),
          child: Theme(
            data: Theme.of(context).copyWith(
              colorScheme: ColorScheme.light(
                primary: AppCommon.colors.primaryColor,
                onPrimary: AppCommon.colors.white,
                onSurface: AppCommon.colors.black,
              ),
              textButtonTheme: TextButtonThemeData(
                style: TextButton.styleFrom(
                  foregroundColor: AppCommon.colors.primaryColor,
                ),
              ),
            ),
            child: child!,
          ),
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
          "dd/MM/yyyy HH:mm:ss",
        ).format(dateTime);
        _departureDate = null;
        _departureController.clear();
      } else {
        _departureDate = dateTime;
        _departureController.text = DateFormat(
          "dd/MM/yyyy HH:mm:ss",
        ).format(dateTime);
      }
    });
  }

  @override
  void dispose() {
    _guestController.dispose();
    _mobileController.dispose();
    _arrivalController.dispose();
    _departureController.dispose();
    super.dispose();
  }
}
