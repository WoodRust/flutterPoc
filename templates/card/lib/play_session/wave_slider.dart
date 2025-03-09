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
    this.height = 50.0,
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
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: widget.width,
          height: widget.height +
              40, // Add extra height for visibility of all elements
          child: CustomPaint(
            painter: WavePainter(
              sliderPosition: _dragPosition,
              dragPercentage: _dragPercentage,
              expectedSuccessPercentage: widget.expectedSuccessPercentage,
              numDice: widget.numDice,
              expectedSuccesses: widget.expectedSuccesses,
            ),
          ),
        ),
        // Center the value indicator with the wave and position above the wave line
        Positioned(
          left: _dragPosition - 15, // Center the value indicator with the wave
          top: widget.height - 25, // Position it just above the wave line
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.5), // More transparent
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
    );
  }
}
