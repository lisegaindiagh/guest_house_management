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
  final _arrivalController = TextEditingController();
  final _departureController = TextEditingController();

  DateTime? _arrivalDate;
  DateTime? _departureDate;

  Map<String, bool> meals = {
    "Breakfast": false,
    "Lunch": false,
    "Dinner": false,
  };

  bool isLoading = false, isFirstTime = true, isEdit = false;

  @override
  void initState() {
    super.initState();
  }

  Future<void> getBookingDetails(int roomId) async {
    isLoading = true;
    setState(() {});

    try {
      var res = await AppCommon.apiProvider.getServerResponse(
        "api.php",
        "GET",
        queryParams: {"action": "getRoomBooking", "room_id": roomId},
      );
      if (!AppCommon.isEmpty(res)) {
        if (res is Map && res.containsKey("booking")) {
          var booking = res["booking"];
          _guestController.text = booking["guest_name"];
          _mobileController.text = booking["mobile"];
          _arrivalController.text = convertDate(booking["arrival_datetime"]);
          _departureController.text = convertDate(
            booking["departure_datetime"],
          );
          _arrivalDate = DateTime.parse(booking["arrival_datetime"]);
          _departureDate = DateTime.parse(booking["departure_datetime"]);

          String mealOnArrival = booking["meal_on_arrival"];
          meals[mealOnArrival[0].toUpperCase() + mealOnArrival.substring(1)] =
              true;
          isEdit = true;
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

  String convertDate(String input) {
    DateTime date = DateTime.parse(input);
    return DateFormat("dd/MM/yyyy hh:mm a").format(date);
  }

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
    final int roomId = (ModalRoute.of(context)!.settings.arguments ?? 0) as int;
    if (isFirstTime && roomId != 0) {
      getBookingDetails(roomId);
    }
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
                              isEdit ? "Cancel Booking" : "Cancel",
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
                            child: Text(
                              isEdit ? "Update" : "Submit",
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
  void _submit() {
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
        : (_departureDate ?? _arrivalDate!);
    DateTime firstDate = isArrival
        ? (isEdit ? _arrivalDate! : DateTime.now())
        : _arrivalDate!;
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
    _arrivalController.dispose();
    _departureController.dispose();
    super.dispose();
  }
}
