import 'package:flutter/material.dart';

class BattlefieldScreen extends StatefulWidget {
  const BattlefieldScreen({super.key});

  @override
  State<BattlefieldScreen> createState() => _BattlefieldScreenState();
}

class _BattlefieldScreenState extends State<BattlefieldScreen> {
  bool _isSelected = false; // Track selection
  bool _isPanZoomEnabled = true; // Track pan and zoom state

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    double battlefieldAspectRatio = 6 / 4;
    double battlefieldWidth = screenWidth;
    double battlefieldHeight = screenWidth / battlefieldAspectRatio;

    if (battlefieldHeight > screenHeight) {
      battlefieldHeight = screenHeight;
      battlefieldWidth = screenHeight * battlefieldAspectRatio;
    }

    double minScale = screenWidth / battlefieldWidth;

    return Scaffold(
      appBar: AppBar(title: const Text("Battlefield")),
      body: InteractiveViewer(
        minScale: minScale,
        maxScale: 3.0,
        panAxis: PanAxis.horizontal,
        panEnabled: _isPanZoomEnabled, // Toggle pan
        scaleEnabled: _isPanZoomEnabled, // Toggle zoom
        child: Center(
          child: AspectRatio(
            aspectRatio: battlefieldAspectRatio,
            child: Stack(
              children: [
                // Battlefield Image
                Positioned.fill(
                  child: Image.asset(
                    'assets/images/battlefield.jpg',
                    fit: BoxFit.cover,
                  ),
                ),

                // Overlaying Selectable Rectangle
                Positioned(
                  left: battlefieldWidth * 0.2,
                  top: battlefieldHeight * 0.2,
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _isSelected = !_isSelected;
                        _isPanZoomEnabled =
                            !_isSelected; // Disable pan/zoom when selected
                      });
                    },
                    child: Container(
                      width: battlefieldWidth * (8.5 / 72),
                      height: battlefieldHeight * (2.5 / 48),
                      color: _isSelected
                          ? Colors.red.withOpacity(0.8) // Darker when selected
                          : Colors.red.withOpacity(0.5),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
