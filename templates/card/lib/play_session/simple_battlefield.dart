import 'package:flutter/material.dart';

class SimpleBattlefieldScreen extends StatefulWidget {
  const SimpleBattlefieldScreen({super.key});
  @override
  State<SimpleBattlefieldScreen> createState() =>
      _SimpleBattlefieldScreenState();
}

class _SimpleBattlefieldScreenState extends State<SimpleBattlefieldScreen> {
  @override
  Widget build(BuildContext context) {
// Get screen size
    // double screenWidth = MediaQuery.of(context).size.width;
    // double screenHeight = MediaQuery.of(context).size.height;

    // // Define battlefield aspect ratio (6:4)
    // double battlefieldAspectRatio = 6 / 4;

    // // Set initial battlefield size to fit screen while maintaining aspect ratio
    // double battlefieldWidth = screenWidth;
    // double battlefieldHeight = screenWidth / battlefieldAspectRatio;

    // // Ensure it fits within screen height
    // if (battlefieldHeight > screenHeight) {
    //   battlefieldHeight = screenHeight;
    //   battlefieldWidth = screenHeight * battlefieldAspectRatio;
    // }

    // // Calculate minScale to ensure the battlefield always fits the width or height
    // double minScale = screenWidth / battlefieldWidth;

    return Stack(
      children: [
        InteractiveViewer(
          minScale: 0.1, // Minimum scale based on the width
          constrained: false,
          maxScale: 3.0, // Max zoom in
          child: Stack(children: [
            // Battlefield Image
            Image.asset(
              'assets/images/battlefield.jpg',
            ),
          ]),
        ),
      ],
    );
  }
}
