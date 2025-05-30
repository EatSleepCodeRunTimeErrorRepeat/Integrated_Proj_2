import 'package:flutter/material.dart';

class EnergyTipsScreen extends StatefulWidget {
  const EnergyTipsScreen({super.key});

  @override
  State<EnergyTipsScreen> createState() => _EnergyTipsScreenState();
}

class _EnergyTipsScreenState extends State<EnergyTipsScreen> {
  bool isOnPeak = false;
  bool isEditing = false; // Flag to switch between edit mode and view mode

  final List<String> onPeakTips =
      List<String>.generate(6, (_) => 'Unplug the Laptop in the living room!');
  final List<String> offPeakTips = [
    'You can plug in the Laptop now.',
    'Do the laundry now!',
    'You can use the computer now :)',
    'Unplug the Laptop in the living room!',
    'Unplug the Laptop in the living room!',
    'Unplug the Laptop in the living room!',
  ];

  final TextEditingController _newTipController = TextEditingController();

  @override
  void dispose() {
    _newTipController.dispose();
    super.dispose();
  }

  Future<void> _showAddTipDialog() async {
    _newTipController.clear();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Add New Tip',
          style: TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        content: Container(
          decoration: BoxDecoration(
            color: const Color.fromARGB(
                255, 255, 255, 255), // Darker beige background
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
            borderRadius: BorderRadius.circular(8),
          ),
          child: TextField(
            controller: _newTipController,
            autofocus: true,
            maxLines: 3,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              color: Colors.black.withOpacity(0.6),
            ),
            decoration: InputDecoration(
              hintText: 'Enter your custom energy saving tip',
              hintStyle: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                color: Colors.black.withOpacity(0.3),
              ),
              border: InputBorder.none, // removes underline
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              filled: false,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: Color(0xFF366D34),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              final newTip = _newTipController.text.trim();
              if (newTip.isNotEmpty) {
                setState(() {
                  if (isOnPeak) {
                    onPeakTips.add(newTip);
                  } else {
                    offPeakTips.add(newTip);
                  }
                });
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF366D34),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Add',
              style: TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: const Color(0xFFFBF8F0),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Custom green top bar with back arrow
            Container(
              height: 76,
              width: double.infinity,
              color: const Color(0xFF366D34),
              child: Padding(
                padding: const EdgeInsets.only(left: 25, top: 43),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(
                      Icons.arrow_back_ios,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ),

            // Title below green bar
            const Padding(
              padding: EdgeInsets.fromLTRB(35, 35, 35, 2),
              child: Text(
                "Energy Saving Tips",
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600, // SemiBold
                  fontSize: 24,
                  color: Colors.black,
                ),
              ),
            ),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 35.0),
              child: Text(
                "Customize your own energy saving tips",
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w300, // Light
                  fontSize: 10,
                  color: Color(0xFFABABAB),
                ),
              ),
            ),

            const SizedBox(height: 28),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                children: [
                  // Buttons row with edit/add button
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Container wrapping On-Peak and Off-Peak buttons
                      Container(
                        width: 277,
                        height: 59,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8F2E5),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            GestureDetector(
                              onTap: () => setState(() => isOnPeak = true),
                              child: Container(
                                width: 128.5,
                                height: 38,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: isOnPeak
                                      ? const Color(0xFFFF5B52)
                                      : Colors.transparent,
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(10),
                                    bottomLeft: Radius.circular(10),
                                  ),
                                ),
                                child: Text(
                                  "On-Peak Hours",
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14,
                                    color:
                                        isOnPeak ? Colors.white : Colors.black,
                                  ),
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () => setState(() => isOnPeak = false),
                              child: Container(
                                width: 128.5,
                                height: 38,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: !isOnPeak
                                      ? const Color(0xFF4CAF50)
                                      : Colors.transparent,
                                  borderRadius: const BorderRadius.only(
                                    topRight: Radius.circular(12),
                                    bottomRight: Radius.circular(12),
                                  ),
                                ),
                                child: Text(
                                  "Off-Peak Hours",
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14,
                                    color:
                                        !isOnPeak ? Colors.white : Colors.black,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 24),

                      // Edit/add button toggle
                      GestureDetector(
                        onTap: () {
                          if (isEditing) {
                            // If already editing, clicking "+" opens add tip dialog
                            _showAddTipDialog();
                          } else {
                            // Switch to editing mode
                            setState(() {
                              isEditing = true;
                            });
                          }
                        },
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: const Color(0xFF366D34),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.25),
                                blurRadius: 6,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Image.asset(
                              isEditing
                                  ? 'assets/icons/add.png'
                                  : 'assets/icons/editpencil.png',
                              width: 24,
                              height: 24,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(
                    width: 350,
                    height: MediaQuery.of(context).size.height - 350,
                    child: ListView.builder(
                      itemCount:
                          isOnPeak ? onPeakTips.length : offPeakTips.length,
                      itemBuilder: (context, index) {
                        final tip =
                            isOnPeak ? onPeakTips[index] : offPeakTips[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          height: 59,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          alignment: Alignment.centerLeft,
                          decoration: BoxDecoration(
                            color: const Color(0x0F545454),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              if (isEditing)
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      if (isOnPeak) {
                                        onPeakTips.removeAt(index);
                                      } else {
                                        offPeakTips.removeAt(index);
                                      }
                                    });
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.only(right: 12),
                                    child: Image.asset(
                                      'assets/icons/cancel.png',
                                      width: 18,
                                      height: 18,
                                    ),
                                  ),
                                ),
                              Expanded(
                                child: Text(
                                  tip,
                                  style: const TextStyle(
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w400,
                                    fontSize: 16,
                                    color: Color(0xFF545454),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            if (isEditing)
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 100),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          isEditing = false;
                        });
                      },
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: const Color(0xFF366D34),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.25),
                              blurRadius: 6,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Image.asset(
                            'assets/icons/donedit.png',
                            width: 24,
                            height: 24,
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
}
