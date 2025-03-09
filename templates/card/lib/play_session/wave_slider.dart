import 'package:flutter/material.dart';
import 'wave_painter.dart';

class WaveSlider extends StatefulWidget {
  final double width;
  final double height;
  final Color color;
  final ValueChanged<double> onChanged;
  final double dragPercentage;
  final double expectedSuccessPercentage;
  final int numDice;
  final double expectedSuccesses;

  const WaveSlider({
    this.width = 350.0,
    this.height = 60.0,
    this.color = Colors.black,
    required this.onChanged,
    this.dragPercentage = 0.0,
    this.expectedSuccessPercentage = 0.0,
    this.numDice = 1,
    this.expectedSuccesses = 0,
  }) : assert(height >= 50 && height <= 600);

  @override
  State<WaveSlider> createState() => _WaveSliderState();
}

class _WaveSliderState extends State<WaveSlider> {
  double _dragPosition = 0;
  double _dragPercentage = 0;

  @override
  void didUpdateWidget(covariant WaveSlider oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.dragPercentage != oldWidget.dragPercentage) {
      setState(() {
        _dragPercentage = widget.dragPercentage;
        _dragPosition = _dragPercentage * widget.width;
      });
    }
  }

  void _updateDragPosition(Offset val) {
    double newDragPosition = val.dx.clamp(0, widget.width);
    setState(() {
      _dragPosition = newDragPosition;
      _dragPercentage = _dragPosition / widget.width;
    });
    widget.onChanged(_dragPercentage);
  }

  @override
  Widget build(BuildContext context) {
    // Create a buffer around the slider for visual elements
    final horizontalBuffer = 20.0;
    final verticalBuffer = 15.0; // Reduced to allow more vertical space

    // Calculate the actual drawing area dimensions
    final drawingWidth = widget.width - (horizontalBuffer * 2);
    final drawingHeight = widget.height;

    // Calculate the adjusted drag position within the drawing area
    final adjustedDragPosition =
        (drawingWidth * _dragPercentage) + horizontalBuffer;

    return Container(
      width: widget.width,
      height: widget.height + 35, // Slightly reduced extra height
      // Add a light border for debugging
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Drawing container with buffer space
          Positioned(
            left: 0,
            top: 0,
            right: 0,
            bottom: 0,
            child: CustomPaint(
              painter: WavePainter(
                sliderPosition: adjustedDragPosition,
                dragPercentage: _dragPercentage,
                expectedSuccessPercentage: widget.expectedSuccessPercentage,
                numDice: widget.numDice,
                expectedSuccesses: widget.expectedSuccesses,
                horizontalBuffer: horizontalBuffer,
                verticalBuffer: verticalBuffer,
                drawingWidth: drawingWidth,
                drawingHeight: drawingHeight,
              ),
            ),
          ),

          // Value indicator - adjusted position to match new wave layout
          Positioned(
            left: adjustedDragPosition - 15, // Center it on the wave
            top: widget.height - 40, // Moved higher to be above wave line
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '${(widget.numDice * _dragPercentage).round()}',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
