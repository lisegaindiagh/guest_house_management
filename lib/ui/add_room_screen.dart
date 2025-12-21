import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../Common/app_common.dart';

/// AddRoomScreen
///
/// Form screen used to add a new room
/// under a selected guest house.
///
/// Required fields:
/// - room name
/// - occupancy type
/// - max occupancy
class AddRoomScreen extends StatefulWidget {
  final int guestHouseId;

  /// [guestHouseId] → ID of the guest house
  /// in which the room will be added.
  const AddRoomScreen({super.key, required this.guestHouseId});

  @override
  State<AddRoomScreen> createState() => _AddRoomScreenState();
}

class _AddRoomScreenState extends State<AddRoomScreen> {
  /// Form key for validation
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  /// Controllers
  final TextEditingController _roomNameController = TextEditingController();
  final TextEditingController _maxOccupancyController = TextEditingController();

  /// Selected occupancy type
  String? _selectedOccupancyType;

  /// Occupancy type options
  final List<String> _occupancyTypes = ["single", "double", "triple"];

  @override
  void dispose() {
    _roomNameController.dispose();
    _maxOccupancyController.dispose();
    super.dispose();
  }

  Future<void> addRoom(var requestParam) async {
    try {
      var res = await AppCommon.apiProvider.getServerResponse(
        "api.php",
        "POST",
        queryParams: {"action": "addRoom"},
        params: requestParam,
      );
      if (res["success"]) {
        AppCommon.displayToast("Room added successfully");
      } else {
        AppCommon.displayToast(res["error"]);
      }
    } catch (e) {
      AppCommon.displayToast("Server error");
    } finally {}
  }

  /// Validate and submit form
  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final Map<String, dynamic> payload = {
        "guest_house_id": widget.guestHouseId,
        "room_name": _roomNameController.text.trim(),
        "occupancy_type": _selectedOccupancyType,
        "max_occupancy": int.parse(_maxOccupancyController.text.trim()),
      };
      await addRoom(payload);
      // ✅ API call will go here
      debugPrint("Room Payload: $payload");

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add New Room")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🛏️ Room Name
              TextFormField(
                controller: _roomNameController,
                decoration: AppCommon.inputDecoration(
                  "Room Name / Number",
                  hint: "e.g. 105",
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Room name is required";
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // 👥 Occupancy Type
              DropdownButtonFormField<String>(
                initialValue: _selectedOccupancyType,
                style: TextStyle(
                  color: AppCommon.colors.black,
                  fontWeight: FontWeight.w500,
                ),
                decoration: InputDecoration(
                  isDense: true,
                  labelText: "Occupancy Type",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: AppCommon.colors.primaryColor,
                      width: 2,
                    ),
                  ),
                ),
                items: _occupancyTypes
                    .map(
                      (type) => DropdownMenuItem(
                        value: type,
                        child: Text(type.toUpperCase()),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedOccupancyType = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return "Please select occupancy type";
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // 🔢 Max Occupancy
              TextFormField(
                controller: _maxOccupancyController,
                keyboardType: TextInputType.number,
                decoration: AppCommon.inputDecoration(
                  "Max Occupancy",
                  hint: "e.g. 1",
                ),
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Max occupancy is required";
                  }

                  final int? number = int.tryParse(value);
                  if (number == null || number <= 0) {
                    return "Enter a valid number greater than 0";
                  }

                  return null;
                },
              ),

              const SizedBox(height: 24),

              // ✅ Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppCommon.colors.primaryColor,
                  ),
                  onPressed: _submitForm,
                  child: Text(
                    "Add Room",
                    style: TextStyle(color: AppCommon.colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
