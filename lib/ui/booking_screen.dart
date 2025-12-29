import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../Common/app_common.dart';
import '../service/send_sms.dart';

class BookingScreen extends StatefulWidget {
  final int roomId, guestHouseId;
  final String roomName;

  const BookingScreen({
    super.key,
    required this.roomId,
    required this.guestHouseId,
    required this.roomName,
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
  final _remarkController = TextEditingController();

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
      appBar: AppBar(title: const Text("New Booking")),
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          spacing: 12,
                          children: [
                            sectionCard(
                              title: "Guest Details",
                              icon: Icons.person_outline,
                              child: Column(
                                children: [
                                  inputField(
                                    controller: _guestController,
                                    label: "Guest Name",
                                    icon: Icons.person,
                                    maxLength: 20,
                                    validator: (v) => v!.isEmpty
                                        ? "Guest name required"
                                        : null,
                                  ),
                                  inputField(
                                    controller: _mobileController,
                                    label: "Contact Number",
                                    icon: Icons.phone,
                                    keyboard: TextInputType.phone,
                                    maxLength: 10,
                                    validator: (v) => v!.length != 10
                                        ? "Enter valid mobile number"
                                        : null,
                                  ),
                                ],
                              ),
                            ),

                            sectionCard(
                              title: "Stay Duration",
                              icon: Icons.calendar_month_outlined,
                              child: Column(
                                children: [
                                  dateField(
                                    controller: _arrivalController,
                                    label: "Check-in Date & Time",
                                    onTap: () => pickDateTime(true),
                                    validator: () => _arrivalDate == null
                                        ? "Required"
                                        : null,
                                  ),
                                  dateField(
                                    controller: _departureController,
                                    label: "Check-out Date & Time",
                                    onTap: () => pickDateTime(false),
                                    validator: () => _departureDate == null
                                        ? "Required"
                                        : null,
                                  ),
                                ],
                              ),
                            ),

                            sectionCard(
                              title: "Meal Preference",
                              icon: Icons.restaurant_outlined,
                              child: Wrap(
                                spacing: 8,
                                runSpacing: 6,
                                children: meals.keys.map((meal) {
                                  return ChoiceChip(
                                    label: Text(meal),
                                    selected: meals[meal]!,
                                    selectedColor: AppCommon.colors.primaryColor
                                        .withValues(alpha: .15),
                                    onSelected: (val) {
                                      setState(() => meals[meal] = val);
                                    },
                                  );
                                }).toList(),
                              ),
                            ),

                            sectionCard(
                              title: "Special Note",
                              icon: Icons.notes_outlined,
                              child: TextFormField(
                                controller: _remarkController,
                                maxLines: 3,
                                decoration: AppCommon.inputDecoration(
                                  "Enter remarks (optional)",
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  /// 🔒 Sticky Action Bar
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 8,
                          offset: Offset(0, -2),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: () => Navigator.pop(context),
                            child: const Text("Cancel"),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppCommon.colors.primaryColor,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: submit,
                            child: const Text(
                              "Confirm Booking",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  /// ---------- Widgets ----------
  Widget sectionCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Card(
      elevation: 1.5,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: AppCommon.colors.primaryColor),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const Divider(height: 20),
            child,
          ],
        ),
      ),
    );
  }

  Widget inputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboard = TextInputType.text,
    int? maxLength,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboard,
        maxLength: maxLength,
        validator: validator,
        decoration: AppCommon.inputDecoration(
          label,
        ).copyWith(prefixIcon: Icon(icon)),
      ),
    );
  }

  Widget dateField({
    required TextEditingController controller,
    required String label,
    required VoidCallback onTap,
    required String? Function() validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        readOnly: true,
        validator: (_) => validator(),
        onTap: onTap,
        decoration: AppCommon.inputDecoration(
          label,
        ).copyWith(prefixIcon: const Icon(Icons.calendar_today)),
      ),
    );
  }

  /// ---------- Logic ----------
  Future<void> submit() async {
    if (_formKey.currentState!.validate()) {
      final selectedMeals = meals.entries
          .where((e) => e.value)
          .map((e) => e.key)
          .toList();
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
    AppCommon.startLoadingProcess(context);
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
          "note": _remarkController.text,
          //selectedMeals
        },
      );
      if (res["success"]) {
        // for send Email
        try {
          //https://mediumvioletred-wallaby-126857.hostingersite.com/api/send_mailer.php
          // todo: change sender & receiver
          final emailText =
          '''
              Booking has been successfully confirmed.
              
              Guest Name : ${_guestController.text}
              Mobile     : ${_mobileController.text}
              Room No    : ${widget.roomName}
              Check-In   : ${DateFormat("dd MMM yyyy, hh:mm a").format(dateTime)}
              Check-Out  : ${DateFormat("dd MMM yyyy, hh:mm a").format(departureController)}
              Meals      : ${mealText().isEmpty ? "No meals selected" : mealText()}
              Note       : ${_remarkController.text.isEmpty ? "" : _remarkController.text}
              
              BOOKING CONFIRMED
              
              This is an automated message from the Guest House Management App.
              ''';

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
              "text": emailText,
            },
          );
        } finally {
          debugPrint("failed to send Email.");
        }
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
            note: _remarkController.text,
          );
          AppCommon.displayToast(res["message"]);
          AppCommon.endLoadingProcess(context);
          Navigator.pop(context, true);
        } finally {
          AppCommon.endLoadingProcess(context);
          debugPrint("failed to send SMS.");
        }
      } else {
        AppCommon.endLoadingProcess(context);
        AppCommon.displayToast(res["error"]);
      }
    } catch (e) {
      AppCommon.endLoadingProcess(context);
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

  String mealText() {
    List<String> mealsSelected = [];

    if (meals["Breakfast"] == true) mealsSelected.add("Breakfast");
    if (meals["Lunch"] == true) mealsSelected.add("Lunch");
    if (meals["Dinner"] == true) mealsSelected.add("Dinner");

    return mealsSelected.isEmpty
        ? "No meals selected"
        : mealsSelected.join(", ");
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
