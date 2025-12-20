import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}
class _BookingScreenState extends State<BookingScreen>{
  final _guestController = TextEditingController();
  final _mobileController = TextEditingController();
  final _fromController = TextEditingController();
  final _arrivalController = TextEditingController();
  final _departureController = TextEditingController();

  DateTime? _arrivalDate;
  TimeOfDay? _arrivalTime;
  DateTime? _departureDate;
  TimeOfDay? _departureTime;

  Map<String, bool> meals = {
    "Breakfast": false,
    "Lunch": false,
    "Dinner": false,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
     backgroundColor: const Color(0xFFF2F5FA),
     appBar: AppBar(
       elevation: 0,
       centerTitle: true,
       backgroundColor: const Color(0xFF2F80ED),
       title: const Text(
         "Guest Houses",
         style: TextStyle(
           fontSize: 17,
           fontWeight: FontWeight.w600,
           color: Colors.white,
         ),
       ),
       iconTheme: const IconThemeData(color: Colors.white),
     ),
     body: SingleChildScrollView(
       padding: const EdgeInsets.all(16),
       child: Column(
         crossAxisAlignment: CrossAxisAlignment.start,
         children: [
           TextField(
             controller: _guestController,
             keyboardType: TextInputType.text,
             maxLength: 20,
             decoration: InputDecoration(
               labelText: "Guest Name",
               contentPadding: const EdgeInsets.symmetric(
                 horizontal: 10,
                 vertical: 5,
               ),
               border: OutlineInputBorder(
                 borderRadius: BorderRadius.circular(10),
               ),
               floatingLabelStyle: TextStyle(color: Colors.blue),
               focusedBorder: OutlineInputBorder(
                 borderRadius: BorderRadius.circular(10),
                 borderSide: BorderSide(
                   color: Colors.blue, // Focused border color
                   width: 2.0, // Border width
                 ),

               ),

             ),
           ),
           SizedBox(height: 10),
           TextField(
             controller: _mobileController,
             keyboardType: TextInputType.phone,
             maxLength: 10,
             decoration: InputDecoration(
               labelText: "Mobile Number",
               contentPadding: const EdgeInsets.symmetric(
                 horizontal: 10,
                 vertical: 5,
               ),
               floatingLabelStyle: TextStyle(color: Colors.blue),
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

           ),
           SizedBox(height: 10),
           TextField(
             controller: _fromController,
             decoration: InputDecoration(
               labelText: "From",
               contentPadding: const EdgeInsets.symmetric(
                 horizontal: 10,
                 vertical: 5,
               ),
               floatingLabelStyle: TextStyle(color: Colors.blue),
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

           ),
           SizedBox(height: 10),
           TextFormField(
             readOnly: true,
             controller: _arrivalController,

             decoration: InputDecoration(
               suffixIcon: const Icon(
                 Icons.calendar_today,
                 color: Colors.blue, // icon color
               ),
               labelText: "Arrival",
               contentPadding: const EdgeInsets.symmetric(
                 horizontal: 10,
                 vertical: 5,
               ),
               floatingLabelStyle: TextStyle(color: Colors.blue),
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

             onTap: () => pickDateTime(true),
           ),
           SizedBox(height: 10),
           TextFormField(
             readOnly: true,
             controller: _departureController,
             decoration: InputDecoration(
               suffixIcon: const Icon(
                 Icons.calendar_today,
                 color: Colors.blue, // icon color
               ),
               labelText: "Departure",
               contentPadding: const EdgeInsets.symmetric(
                 horizontal: 10,
                 vertical: 5,
               ),
               floatingLabelStyle: TextStyle(color: Colors.blue),
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
             onTap: () => pickDateTime(false),
           ),
           SizedBox(height: 10),
           Text("Meal on Arrival", style: TextStyle(fontWeight: FontWeight.bold)),
           Wrap(
             spacing: 10,
             children: meals.keys.map((meal) {
               return FilterChip(
                 label: Text(meal),
                 selected: meals[meal]!,
                 onSelected: (val) {
                   setState(() {
                     meals[meal] = val;
                   });
                 },
               );
             }).toList(),
           ),
           SizedBox(height: 20),
           Center(
             child: ElevatedButton(
               style: ElevatedButton.styleFrom(
                 backgroundColor: Colors.blue, // LISEGA blue
                 shape: RoundedRectangleBorder(
                   borderRadius: BorderRadius.circular(10),
                 ),
               ),
               onPressed: () {
                 print("Guest: ${_guestController.text}");
                 print("Mobile: ${_mobileController.text}");
                 print("From: ${_fromController.text}");
                 print("Arrival: ${_arrivalController.text}");
                 print("Departure: ${_departureController.text}");
                 print("Meals: ${meals.entries.where((e) => e.value).map((e) => e.key).toList()}");
                 Navigator.pop(context);
               },
               child: Text("Submit",style: TextStyle(fontSize: 16, color: Colors.white),),
             ),
           ),
           SizedBox(height: 20),
         ],
       ),
     ),
   );
  }
  Future<void> pickDateTime(bool isArrival) async {
    // Prevent selecting departure before arrival
    if (!isArrival && _arrivalDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please select Arrival date first")),
      );
      return;
    }

    DateTime initialDate = DateTime.now();
    DateTime firstDate = DateTime.now();
    DateTime lastDate = DateTime(2100);

    if (isArrival) {
      initialDate = _arrivalDate ?? DateTime.now();
      firstDate = DateTime.now();

      // 🔥 Arrival cannot be AFTER departure
      if (_departureDate != null) {
        lastDate = _departureDate!;
      }
    } else {
      initialDate = _departureDate ?? _arrivalDate!;
      firstDate = _arrivalDate!; // 🔥 Departure cannot be BEFORE arrival
    }

    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );

    if (pickedDate != null) {
      TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (pickedTime != null) {
        setState(() {
          if (isArrival) {
            _arrivalDate = pickedDate;
            _arrivalTime = pickedTime;
            _arrivalController.text = DateFormat("dd/MM/yyyy hh:mm a").format(
              DateTime(
                pickedDate.year,
                pickedDate.month,
                pickedDate.day,
                pickedTime.hour,
                pickedTime.minute,
              ),
            );

            // Clear departure if arrival > departure
            if (_departureDate != null &&
                _arrivalDate!.isAfter(_departureDate!)) {
              _departureDate = null;
              _departureTime = null;
              _departureController.clear();
            }
          } else {
            _departureDate = pickedDate;
            _departureTime = pickedTime;
            _departureController.text = DateFormat("dd/MM/yyyy hh:mm a").format(
              DateTime(
                pickedDate.year,
                pickedDate.month,
                pickedDate.day,
                pickedTime.hour,
                pickedTime.minute,
              ),
            );
          }
        });
      }
    }
  }

}