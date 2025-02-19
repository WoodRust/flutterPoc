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

    // Define battlefield aspect ratio (6:4)
    double battlefieldAspectRatio = 6 / 4;

    // Set initial battlefield size to fit screen while maintaining aspect ratio
    double battlefieldWidth = screenWidth;
    double battlefieldHeight = screenWidth / battlefieldAspectRatio;

    // Ensure it fits within screen height
    if (battlefieldHeight > screenHeight) {
      battlefieldHeight = screenHeight;
      battlefieldWidth = screenHeight * battlefieldAspectRatio;
    }

    // Calculate minScale to ensure the battlefield always fits the width or height
    double minScale = screenWidth / battlefieldWidth;

    // Define boundary margin to restrict panning horizontally (10% of screen width)
    double horizontalBoundaryMargin = screenWidth * 0.05; // 5% from each side

    return Scaffold(
      appBar: AppBar(title: Text("Battlefield")),
      body: InteractiveViewer(
        boundaryMargin: EdgeInsets.symmetric(
          horizontal: horizontalBoundaryMargin, // Limit horizontal panning
          vertical: double.infinity, // Allow full vertical panning
        ),
        minScale: minScale, // Minimum scale based on the width
        maxScale: 3.0, // Max zoom in
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

                // Overlaying Rectangle (Scaled to battlefield)
                Positioned(
                  left: battlefieldWidth * 0.2,
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
