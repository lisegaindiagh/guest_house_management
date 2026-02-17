import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Common/app_common.dart';

class GuestHouseInstructions extends StatefulWidget {
  const GuestHouseInstructions({Key? key}) : super(key: key);

  @override
  State<GuestHouseInstructions> createState() =>
      _GuestHouseInstructionsState();
}

class _GuestHouseInstructionsState extends State<GuestHouseInstructions> {
  bool isAgreed = false;

  @override
  void initState() {
    super.initState();
    _loadAgreement();
  }

  Future<void> _loadAgreement() async {
    bool res =
        await AppCommon.sharePref.getBool(AppCommon.sessionKey.isAgree) ??
            false;
    setState(() {

      isAgreed = res;
    });
  }

  Future<void> _saveAgreement() async {
    AppCommon.sharePref.setBool(
      AppCommon.sessionKey.isAgree,
      true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Guest House Instructions"),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [

              // ---------------- ORIGINAL INSTRUCTIONS ----------------

              buildCard(Icons.wifi, "Internet Connection",
                  "To connect your company laptop and company mobile phone:\n"
                      "• Go to WLAN Connection Settings\n"
                      "• Use following credentials:\n\n"
                      "Company Users:\n"
                      "SSID: VADODARA-Employee\n"
                      "Passphrase: Your Windows credentials\n\n"
                      "Note: Only LISEGAGROUP domain users can access the internet. "
                      "A net extender is not required to connect to Outlook, as VPN tunnel exists between LISEGA-SE and LISEGA India.\n\n"
                      "For Guests:\n"
                      "SSID: Lisega\n"
                      "Passphrase: 9265595402"),

              buildCard(Icons.hot_tub, "Hot Water Usage",
                  "Switch on the specified color button for hot water in wash area and bathroom."),

              buildCard(Icons.local_laundry_service, "Laundry",
                  "Place linen and towels that need cleaning in the laundry basket provided in your room."),

              buildCard(Icons.restaurant, "Meal Timings & Food Guidelines",
                  "Breakfast: 7:30 A.M. – 8:30 A.M.\n"
                      "Lunch: 12:30 P.M. – 1:30 P.M.\n"
                      "Dinner: 7:30 P.M. – 8:30 P.M.\n\n"
                      "Please inform Ramesh in advance if there is any change in your meal plan or timings.\n"
                      "Please serve yourself wisely — finish what’s on your plate."),

              buildMenuCard(),

              buildCard(Icons.rule, "Additional Guidelines",
                  "• No food is allowed inside the rooms.\n"
                      "• Smoking and chewing tobacco are strictly prohibited inside the rooms.\n"
                      "• Please switch off lights, AC, and other appliances when not in use.\n"
                      "• Valuables: Please keep your valuables safe and secure in your luggage."),

              buildCard(Icons.support_agent, "Support",
                  "We wish you a good stay!\n\n"
                      "Caretaker Ramesh: +91 7764942033\n"
                      "Nidhi Shah: +91 9428068777"),

              // ---------------- TERMS + CHECKBOX ----------------

              Card(
                color: Colors.white,
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Terms & Conditions",
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      const Text(
                        "• Guests must follow all instructions"
                      ),
                      Row(
                        children: [
                          Checkbox(
                            value: isAgreed,
                            activeColor:
                            AppCommon.colors.primaryColor,
                            onChanged: (value) {
                              setState(() {
                                isAgreed = value ?? false;
                              });
                            },
                          ),
                          const Expanded(
                            child: Text(
                              "I have read and agree to the Terms & Conditions",
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // ---------------- BUTTON (ENABLE / DISABLE) ----------------

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                    AppCommon.colors.primaryColor,
                    disabledBackgroundColor:
                    AppCommon.colors.primaryColor.withValues(alpha: 0.3),
                  ),
                  onPressed: isAgreed
                      ? () async {
                    await _saveAgreement();
                    Navigator.pop(context);
                  }
                      : null, // ❌ disabled when unchecked
                  child: const Text("Agree & Continue",style: TextStyle(color: Colors.white),),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------- ORIGINAL METHODS (UNCHANGED) ----------------

  Widget buildCard(IconData icon, String title, String text) {
    return SizedBox(
      width: double.infinity,
      child: Card(
        color: Colors.white,
        margin: const EdgeInsets.only(bottom: 12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon,
                      color: AppCommon.colors.primaryColor,
                      size: 22),
                  const SizedBox(width: 8),
                  Text(title,
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 8),
              Text(text),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildMenuCard() {
    return SizedBox(
      width: double.infinity,
      child: Card(
        color: Colors.white,
        margin: const EdgeInsets.only(bottom: 12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.restaurant_menu,
                      color: AppCommon.colors.primaryColor,
                      size: 22),
                  const SizedBox(width: 8),
                  const Text("Menu (Indian Food)",
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 10),
              Table(
                border:
                TableBorder.all(color: Colors.grey),
                columnWidths: const {
                  0: FlexColumnWidth(1),
                  1: FlexColumnWidth(3),
                  2: FlexColumnWidth(3),
                },
                children: [
                  TableRow(children: [
                    buildTableHeader("No"),
                    buildTableHeader("Vegetarian Meal"),
                    buildTableHeader("Non-Vegetarian Meal"),
                  ]),
                  menuRow("1", "Dal", "Chicken Curry"),
                  menuRow("2", "Vegetable Curry", "Dry Vegetable"),
                  menuRow("3", "Dry Vegetable", "Curd"),
                  menuRow("4", "Curd", "Rice"),
                  menuRow("5", "Rice", "Roti"),
                  menuRow("6", "Roti", "Pickle / Papad"),
                  menuRow("7", "Pickle / Papad", "Salad"),
                  menuRow("8", "Salad", ""),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  TableRow menuRow(String no, String veg, String nonVeg) {
    return TableRow(children: [
      buildTableCell(no),
      buildTableCell(veg),
      buildTableCell(nonVeg),
    ]);
  }

  Widget buildTableCell(String text) {
    return Padding(
      padding: const EdgeInsets.all(6),
      child: Center(child: Text(text)),
    );
  }

  Widget buildTableHeader(String text) {
    return Padding(
      padding: const EdgeInsets.all(6),
      child: Center(
        child: Text(text,
            style:
            const TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }
}
