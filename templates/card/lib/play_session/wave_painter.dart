import 'dart:ui';

import 'package:flutter/material.dart';

class WavePainter extends CustomPainter {
  final double sliderPosition;
  final double dragPercentage;

  final Color color;

  double _previousSliderPosition = 0;

  final Paint fillpainter;
  final Paint wavePainter;

  WavePainter({
    required this.sliderPosition,
    required this.dragPercentage,
    required this.color,
  })  : fillpainter = Paint()
          ..color = color
          ..style = PaintingStyle.fill,
        wavePainter = Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5;

  @override
  void paint(Canvas canvas, Size size) {
    _paintAnchors(canvas, size);
    _paintWaveLine(canvas, size);
    //_paintline(canvas, size);
    //_paintBlock(canvas, size);
  }

// small dots at each end of the drag box.
  _paintAnchors(Canvas canvas, Size size) {
    canvas.drawCircle(Offset(0.0, size.height), 5.0, fillpainter);
    canvas.drawCircle(Offset(size.width, size.height), 5.0, fillpainter);
  }

  WaveCurveDefinitions _calculateWaveLineDefinitions() {
    double bendWidth = 40.0;
    double bezierWidth = 40.0;

    double startOfBend = sliderPosition - bendWidth / 2;
    double startofBezier = startOfBend - bezierWidth;
    double endOfBend = sliderPosition + bendWidth / 2;
    double endOfBezier = endOfBend + bezierWidth;

    double controlHeight = 0.0;
    double centerPoint = sliderPosition;

    double leftControlPoint1 = startOfBend;
    double leftControlPoint2 = startOfBend;
    double rightControlPoint1 = endOfBend;
    double rightControlPoint2 = endOfBend;

    double bendability = 25.0;
    double maxSlideDifference =
        20; // how fast you need to move it to get to max bendability.

    double slideDifference = (sliderPosition - _previousSliderPosition).abs();
    if (slideDifference > maxSlideDifference) {
      slideDifference = maxSlideDifference;
    }

    double bend =
        lerpDouble(0.0, bendability, slideDifference / maxSlideDifference) ??
            0.0;

    bool moveLeft = sliderPosition < _previousSliderPosition;

    if (moveLeft) {
      leftControlPoint1 = leftControlPoint1 - bend;
      leftControlPoint2 = leftControlPoint2 + bend;
      rightControlPoint1 = rightControlPoint1 + bend;
      rightControlPoint2 = rightControlPoint2 - bend;
      centerPoint = centerPoint + bend;
    } else {
      leftControlPoint1 = leftControlPoint1 + bend;
      leftControlPoint2 = leftControlPoint2 - bend;
      rightControlPoint1 = rightControlPoint1 - bend;
      rightControlPoint2 = rightControlPoint2 + bend;
      centerPoint = centerPoint - bend;
    }

    return WaveCurveDefinitions(
        startofBezier: startofBezier,
        endOfBezier: endOfBezier,
        leftControlPoint1: leftControlPoint1,
        leftControlPoint2: leftControlPoint2,
        rightControlPoint1: rightControlPoint1,
        rightControlPoint2: rightControlPoint2,
        controlHeight: controlHeight,
        centerPoint: centerPoint);
  }

  _paintWaveLine(Canvas canvas, Size size) {
    WaveCurveDefinitions waveCurve = _calculateWaveLineDefinitions();
    Path path = Path();
    path.moveTo(0.0, size.height);
    path.lineTo(waveCurve.startofBezier, size.height);
    path.cubicTo(
        waveCurve.leftControlPoint1,
        size.height,
        waveCurve.leftControlPoint2,
        waveCurve.controlHeight,
        waveCurve.centerPoint,
        waveCurve.controlHeight);
    path.cubicTo(
        waveCurve.rightControlPoint1,
        waveCurve.controlHeight,
        waveCurve.rightControlPoint2,
        size.height,
        waveCurve.endOfBezier,
        size.height);
    path.lineTo(size.width, size.height);
    canvas.drawPath(path, wavePainter);
  }

  _paintline(Canvas canvas, Size size) {
    Path path = Path();
    path.moveTo(0.0, size.height);
    path.lineTo(size.width, size.height);
    canvas.drawPath(path, wavePainter);
  }

  _paintBlock(Canvas canvas, Size size) {
    Rect sliderRect =
        Offset(sliderPosition, size.height - 5.0) & Size(3.0, 10.0);
    canvas.drawRect(sliderRect, fillpainter);
  }

  @override
  bool shouldRepaint(covariant WavePainter oldDelegate) {
    _previousSliderPosition = oldDelegate.sliderPosition;
    return true;
  }
}

class WaveCurveDefinitions {
  double startofBezier;
  double endOfBezier;
  double leftControlPoint1;
  double leftControlPoint2;
  double rightControlPoint1;
  double rightControlPoint2;
  double controlHeight;
  double centerPoint;

  WaveCurveDefinitions(
      {required this.startofBezier,
      required this.endOfBezier,
      required this.leftControlPoint1,
      required this.leftControlPoint2,
      required this.rightControlPoint1,
      required this.rightControlPoint2,
      required this.controlHeight,
      required this.centerPoint});
}
