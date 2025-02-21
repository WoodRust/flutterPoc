import 'package:card/play_session/wave_painter.dart';
import 'package:flutter/material.dart';

class WaveSlider extends StatefulWidget {
  final double width;
  final double height;
  final Color color;

  const WaveSlider(
      {this.width = 350.0, this.height = 50.0, this.color = Colors.black});

  @override
  State<WaveSlider> createState() => _WaveSliderState();
}

class _WaveSliderState extends State<WaveSlider> {
  double _dragPosition = 0;
  double _dragPercentage = 0;

  void _updateDragPosition(Offset val) {
    double newDragPosition = 0;

    if (val.dx <= 0) {
      newDragPosition = 0;
    } else if (val.dx >= widget.width) {
      newDragPosition = widget.width;
    } else {
      newDragPosition = val.dx;
    }
    setState(() {
      _dragPosition = newDragPosition;
      _dragPercentage = _dragPosition / widget.width;
    });
  }

  void _onDragUpdate(BuildContext context, DragUpdateDetails update) {
    RenderBox? box = context.findRenderObject() as RenderBox?;
    if (box != null) {
      Offset offset = box.globalToLocal(update.globalPosition);
      _updateDragPosition(offset);
    }
  }

  void _onDragStart(BuildContext context, DragStartDetails start) {
    RenderBox? box = context.findRenderObject() as RenderBox?;
    if (box != null) {
      Offset offset = box.globalToLocal(start.globalPosition);
      _updateDragPosition(offset);
    }
  }

  void _onDragEnd(BuildContext context, DragEndDetails end) {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
        width: widget.width,
        height: widget.height,
        //color: Colors.red, - uncommenting this will paint the geture area.
        child: CustomPaint(
          painter: WavePainter(
            sliderPosition: _dragPosition,
            dragPercentage: _dragPercentage,
            color: widget.color,
          ),
        ),
      ),
      onHorizontalDragUpdate: (DragUpdateDetails update) =>
          _onDragUpdate(context, update),
      onHorizontalDragStart: (DragStartDetails start) =>
          _onDragStart(context, start),
      onHorizontalDragEnd: (DragEndDetails end) => _onDragEnd(context, end),
    );
  }
}
