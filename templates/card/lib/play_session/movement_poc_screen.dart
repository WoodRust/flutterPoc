import 'package:flutter/material.dart';

class BattlefieldScreen extends StatefulWidget {
  const BattlefieldScreen({super.key});
  @override
  State<BattlefieldScreen> createState() => _BattlefieldScreenState();
}

class _BattlefieldScreenState extends State<BattlefieldScreen> {
  late TransformationController _controller;
  late double minScale;
  late double maxX, maxY;

  @override
  void initState() {
    super.initState();
    _controller = TransformationController();
  }

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

    // Calculate minScale so battlefield always fills screen width
    minScale = screenWidth / battlefieldWidth;

    // Define max panning limits based on zoom
    maxX = (battlefieldWidth * minScale - screenWidth) / 2;
    maxY = (battlefieldHeight * minScale - screenHeight) / 2;

    return Scaffold(
      appBar: AppBar(title: Text("Battlefield")),
      body: Center(
        child: InteractiveViewer(
          transformationController: _controller,
          boundaryMargin: EdgeInsets.zero, // Prevents moving outside bounds
          minScale: minScale,
          maxScale: 3.0,
          constrained: false, // Allows proper panning
          onInteractionUpdate: (details) {
            _limitPan();
          },
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

  // Restrict panning to prevent white space
  void _limitPan() {
    final Matrix4 matrix = _controller.value;
    double scale = matrix.getMaxScaleOnAxis();

    // Calculate max translation values
    double maxX = (scale * 6 / minScale - 6) / 2 * minScale;
    double maxY = (scale * 4 / minScale - 4) / 2 * minScale;

    // Clamp translation values
    double clampedX = matrix[12].clamp(-maxX, maxX);
    double clampedY = matrix[13].clamp(-maxY, maxY);

    _controller.value = Matrix4.identity()
      ..translate(clampedX, clampedY)
      ..scale(scale);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
