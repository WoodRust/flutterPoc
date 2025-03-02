import 'package:card/play_session/wave_painter.dart';
import 'package:flutter/material.dart';

class WaveSlider extends StatefulWidget {
  final double width;
  final double height;
  final Color color;
  final ValueChanged<double> onChanged;
  final double dragPercentage; // New parameter for external updates

  const WaveSlider({
    this.width = 350.0,
    this.height = 50.0,
    this.color = Colors.black,
    required this.onChanged,
    this.dragPercentage = 0.0, // Required percentage
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
        _dragPosition =
            _dragPercentage * widget.width; // Convert percentage to position
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
            color: widget.color,
          ),
        ),
      ),
    );
  }
}
