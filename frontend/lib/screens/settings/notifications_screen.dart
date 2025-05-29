import 'package:flutter/material.dart';

void main() {
  runApp(const EnergyTipsApp());
}

class EnergyTipsApp extends StatelessWidget {
  const EnergyTipsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Energy Saving Tips',
      theme: ThemeData(
        primarySwatch: Colors.green,
        fontFamily: 'Poppins',
      ),
      home: const EnergyTipsScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class EnergyTipsScreen extends StatefulWidget {
  const EnergyTipsScreen({super.key});

  @override
  State<EnergyTipsScreen> createState() => _EnergyTipsScreenState();
}

class _EnergyTipsScreenState extends State<EnergyTipsScreen> {
  bool isOnPeak = false;

  final onPeakTips = List<String>.generate(
      6, (_) => 'Unplug the Laptop in the living room!');

  final offPeakTips = [
    'You can plug in the Laptop now.',
    'Do the laundry now!',
    'You can use the computer now :)',
    'Unplug the Laptop in the living room!',
    'Unplug the Laptop in the living room!',
    'Unplug the Laptop in the living room!',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(""),
        backgroundColor: Colors.green.shade800,
        leading: const Icon(Icons.arrow_back, color: Colors.white),
        elevation: 0,
        toolbarHeight: 40,
      ),
      body: Column(
        children: [
          Container(
            color: Colors.green.shade800,
            width: double.infinity,
            padding: const EdgeInsets.only(left: 16, bottom: 16),
            alignment: Alignment.centerLeft,
            child: const Text(
              "Energy Saving Tips",
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              "Customize your own energy saving tips",
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ToggleButton(
                text: "On-Peak Hours",
                isSelected: isOnPeak,
                color: Colors.red,
                onTap: () => setState(() => isOnPeak = true),
              ),
              const SizedBox(width: 8),
              ToggleButton(
                text: "Off-Peak Hours",
                isSelected: !isOnPeak,
                color: Colors.green,
                onTap: () => setState(() => isOnPeak = false),
              ),
              const SizedBox(width: 8),
              const CircleAvatar(
                radius: 16,
                backgroundColor: Colors.grey,
                child: Icon(Icons.edit, color: Colors.white, size: 16),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: isOnPeak ? onPeakTips.length : offPeakTips.length,
              itemBuilder: (context, index) {
                final tip = isOnPeak ? onPeakTips[index] : offPeakTips[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(tip),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class ToggleButton extends StatelessWidget {
  final String text;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  const ToggleButton({
    super.key,
    required this.text,
    required this.isSelected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? Colors.white : color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
