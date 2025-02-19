import 'package:flutter/material.dart';

class BattlefieldScreen extends StatefulWidget {
  const BattlefieldScreen({super.key});
  @override
  State<BattlefieldScreen> createState() => _BattlefieldScreenState();
}

class _BattlefieldScreenState extends State<BattlefieldScreen> {
  @override
  Widget build(BuildContext context) {
    // Get screen size
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    // Define battlefield dimensions (6:4 ratio)
    double battlefieldWidth = screenWidth;
    double battlefieldHeight = (battlefieldWidth * 4) / 6;

    // Ensure battlefield fits within screen height
    if (battlefieldHeight > screenHeight) {
      battlefieldHeight = screenHeight;
      battlefieldWidth = (battlefieldHeight * 6) / 4;
    }

    // Calculate minScale to prevent empty space on sides
    double minScale = screenWidth / battlefieldWidth;

    return Scaffold(
      appBar: AppBar(title: Text("Battlefield")),
      body: Center(
        child: InteractiveViewer(
          boundaryMargin: EdgeInsets.all(
              double.infinity), // Allow image to move beyond edges
          minScale: minScale, // Ensures battlefield fills width at minimum zoom
          maxScale: 3.0, // Allow zooming in
          child: SizedBox(
            width: battlefieldWidth,
            height: battlefieldHeight,
            child: Stack(
              children: [
                // Battlefield Image (Bottom Layer)
                Positioned.fill(
                  child: Image.asset(
                    'assets/images/battlefield.jpg', // Ensure this image is added to assets
                    fit: BoxFit.cover,
                  ),
                ),

                // Overlaying Rectangle (Scaled to battlefield)
                Positioned(
                  left: battlefieldWidth * 0.2, // Adjust position
                  top: battlefieldHeight * 0.2,
                  child: Container(
                    width: battlefieldWidth *
                        (8.5 / 72), // Scaled to 6ft battlefield
                    height: battlefieldHeight *
                        (2.5 / 48), // Scaled to 4ft battlefield
                    color: Colors.red.withOpacity(0.5),
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
