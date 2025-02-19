import 'package:flutter/material.dart';

class BattlefieldScreen extends StatefulWidget {
  const BattlefieldScreen({super.key});
  @override
  State<BattlefieldScreen> createState() => _BattlefieldScreenState();
}

class _BattlefieldScreenState extends State<BattlefieldScreen> {
  late TransformationController _controller;
  late double minScale;
  late double battlefieldWidth, battlefieldHeight;

  @override
  void initState() {
    super.initState();
    _controller = TransformationController();
  }

  @override
  Widget build(BuildContext context) {
    // Get screen dimensions
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    // Define battlefield dimensions (6:4 ratio)
    battlefieldWidth = screenWidth;
    battlefieldHeight = (battlefieldWidth * 4) / 6;

    // Adjust if battlefield is too tall for the screen
    if (battlefieldHeight > screenHeight) {
      battlefieldHeight = screenHeight;
      battlefieldWidth = (battlefieldHeight * 6) / 4;
    }

    // Calculate minimum scale to ensure full battlefield fills width
    minScale = screenWidth / battlefieldWidth;

    return Scaffold(
      appBar: AppBar(title: Text("Battlefield")),
      body: Center(
        child: InteractiveViewer(
          transformationController: _controller,
          boundaryMargin: EdgeInsets.zero, // Prevents white space
          minScale: minScale,
          maxScale: 3.0,
          constrained: false, // Allows free movement
          onInteractionUpdate: (_) {
            _limitPan(); // Apply pan limits dynamically
          },
          child: SizedBox(
            width: battlefieldWidth,
            height: battlefieldHeight,
            child: Stack(
              children: [
                // Battlefield Image (Bottom Layer)
                Positioned.fill(
                  child: Image.asset(
                    'assets/images/battlefield.jpg', // Make sure this image exists in assets
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

  /// Restrict panning to prevent white space while keeping zoom functional
  void _limitPan() {
    final Matrix4 matrix = _controller.value;
    double scale = matrix.getMaxScaleOnAxis();

    // Calculate scaled battlefield dimensions
    double scaledWidth = battlefieldWidth * scale;
    double scaledHeight = battlefieldHeight * scale;

    // Calculate screen limits
    double maxX = (scaledWidth - battlefieldWidth) / 2;
    double maxY = (scaledHeight - battlefieldHeight) / 2;

    // Get current translation values
    double currentX = matrix[12];
    double currentY = matrix[13];

    // Clamp panning within battlefield limits
    double clampedX = currentX.clamp(-maxX, maxX);
    double clampedY = currentY.clamp(-maxY, maxY);

    // Apply only if needed to prevent unnecessary resets
    if (clampedX != currentX || clampedY != currentY) {
      _controller.value = Matrix4.identity()
        ..translate(clampedX, clampedY)
        ..scale(scale);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
