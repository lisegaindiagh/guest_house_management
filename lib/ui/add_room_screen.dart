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
  final List<String> _occupancyTypes = [
    "single",
    "double",
    "triple",
    "quadruple",
  ];

  @override
  void dispose() {
    _roomNameController.dispose();
    _maxOccupancyController.dispose();
    super.dispose();
  }

  /// Submit form
  Future<void> submitForm() async {
    if (_formKey.currentState!.validate()) {
      final payload = {
        "guest_house_id": widget.guestHouseId,
        "room_name": _roomNameController.text.trim(),
        "occupancy_type": _selectedOccupancyType,
        "max_occupancy": int.parse(_maxOccupancyController.text.trim()),
      };

      try {
        var res = await AppCommon.apiProvider.getServerResponse(
          "api.php",
          "POST",
          queryParams: {"action": "addRoom"},
          params: payload,
        );

        if (res["success"]) {
          AppCommon.displayToast("Room added successfully");
          Navigator.pop(context, true);
        } else {
          AppCommon.displayToast(res["error"]);
        }
      } catch (e) {
        AppCommon.displayToast("Server error");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Room")),
      body: SafeArea(
        child: Column(
          children: [
            /// FORM CONTENT
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      /// 🛏️ Room Details
                      sectionCard(
                        title: "Room Details",
                        subtitle: "Define room capacity and type",
                        icon: Icons.meeting_room_outlined,
                        child: Column(
                          children: [
                            inputField(
                              controller: _roomNameController,
                              label: "Room Name / Number",
                              hint: "e.g. 105",
                              icon: Icons.tag,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return "Room name is required";
                                }
                                return null;
                              },
                            ),

                            dropdownField(),

                            inputField(
                              controller: _maxOccupancyController,
                              label: "Max Occupancy",
                              hint: "e.g. 1",
                              icon: Icons.person_outline,
                              keyboard: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return "Max occupancy is required";
                                }
                                final int? number = int.tryParse(value);
                                if (number == null || number <= 0) {
                                  return "Enter a valid number";
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ),
            ),

            /// 🔒 STICKY ACTION BAR
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 10,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppCommon.colors.primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    "Save Room",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// ---------- UI COMPONENTS ----------
  Widget sectionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppCommon.colors.primaryColor),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  Widget inputField({
    required TextEditingController controller,
    required String label,
    String? hint,
    required IconData icon,
    TextInputType keyboard = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboard,
        inputFormatters: inputFormatters,
        validator: validator,
        decoration: AppCommon.inputDecoration(
          label,
          hint: hint,
        ).copyWith(prefixIcon: Icon(icon)),
      ),
    );
  }

  Widget dropdownField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: DropdownButtonFormField<String>(
        value: _selectedOccupancyType,
        decoration: AppCommon.inputDecoration(
          "Occupancy Type",
        ).copyWith(prefixIcon: const Icon(Icons.people_outline)),
        items: _occupancyTypes
            .map(
              (type) => DropdownMenuItem(
                value: type,
                child: Text(type.toUpperCase()),
              ),
            )
            .toList(),
        onChanged: (value) => setState(() => _selectedOccupancyType = value),
        validator: (value) => value == null ? "Select occupancy type" : null,
      ),
    );
  }
}
