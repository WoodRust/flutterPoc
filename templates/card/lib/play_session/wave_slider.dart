import 'package:flutter/material.dart';
import 'wave_painter.dart'; // Ensure this path is correct

class WaveSlider extends StatefulWidget {
  final double width;
  final double height;
  final Color color;
  final ValueChanged<double> onChanged;
  final double dragPercentage;
  final double expectedSuccessPercentage;
  final int numDice; // New parameter
  final double expectedSuccesses; // New parameter

  const WaveSlider({
    this.width = 350.0,
    this.height = 50.0,
    this.color = Colors.black,
    required this.onChanged,
    this.dragPercentage = 0.0,
    this.expectedSuccessPercentage = 0.0,
    this.numDice = 1, // Default to 1
    this.expectedSuccesses = 0, // Default to 0
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
    return GestureDetector(
      onHorizontalDragUpdate: (DragUpdateDetails update) {
        RenderBox? box = context.findRenderObject() as RenderBox?;
        if (box != null) {
          Offset offset = box.globalToLocal(update.globalPosition);
          _updateDragPosition(offset);
        }
      },
      child: Container(
        width: widget.width,
        height: widget.height,
        child: CustomPaint(
          painter: WavePainter(
            sliderPosition: _dragPosition,
            dragPercentage: _dragPercentage,
            expectedSuccessPercentage: widget.expectedSuccessPercentage,
            numDice: widget.numDice, // Pass the number of dice
            expectedSuccesses:
                widget.expectedSuccesses, // Pass expected successes
          ),
        ),
      ),
    );
  }
}
