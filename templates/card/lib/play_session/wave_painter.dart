import 'dart:ui';

import 'package:flutter/material.dart';

class WavePainter extends CustomPainter {
  final double sliderPosition;
  final double dragPercentage;
  final double expectedSuccessPercentage;
  final int numDice; // Number of dice
  final double expectedSuccesses; // Expected successes

  final Color badColor = Color(0xFFFF4136); // Red
  final Color neutralColor = Color(0xFFFFDC00); // Yellow
  final Color goodColor = Color(0xFF2ECC40); // Green

  final Paint fillPainter;
  final Paint expectedLinePainter;
  late Paint wavePainter;

  double _previousSliderPosition = 0;

  WavePainter({
    required this.sliderPosition,
    required this.dragPercentage,
    required this.expectedSuccessPercentage,
    this.numDice = 1, // Default to 1 if not provided
    this.expectedSuccesses = 0, // Default to 0 if not provided
  })  : fillPainter = Paint()
          ..color = Colors.black
          ..style = PaintingStyle.fill,
        expectedLinePainter = Paint()
          ..color = Colors.black // Changed to black as requested
          ..strokeWidth = 3.0 {
    wavePainter = Paint()
      ..color = _calculateWaveColor(dragPercentage, expectedSuccessPercentage)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
  }

  /// Computes the color of the wave based on the drag percentage.
  Color _calculateWaveColor(double dragPercentage, double expectedPercentage) {
    const double biasFactor = 0.4; // 70% of the transition range

    if (dragPercentage < expectedPercentage) {
      // Interpolate Red to Yellow with 70% bias
      double t = dragPercentage / (1 - expectedPercentage * biasFactor);
      t = t.clamp(0.0, 1.0); // Ensure stays in range
      return Color.lerp(badColor, neutralColor, t) ?? neutralColor;
    } else {
      // Interpolate Yellow to Green with 70% bias
      double t = (dragPercentage - expectedPercentage) /
          ((1 - expectedPercentage) * biasFactor);
      t = t.clamp(0.0, 1.0); // Ensure stays in range
      return Color.lerp(neutralColor, goodColor, t) ?? goodColor;
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    _paintAnchors(canvas, size);
    _paintWaveLine(canvas, size);
    _paintExpectedSuccessLine(canvas, size);
    _paintAnnotations(canvas, size);
  }

  void _paintAnnotations(Canvas canvas, Size size) {
    final textPainter = TextPainter(
      textAlign: TextAlign.left,
      textDirection: TextDirection.ltr,
    );

    // Annotate number of dice to the right of the right anchor point
    textPainter.text = TextSpan(
      text: '$numDice',
      style: TextStyle(
        color: Colors.black,
        fontSize: 14,
      ),
    );
    textPainter.layout();
    textPainter.paint(
        canvas,
        Offset(
            size.width + 10,
            size.height -
                (textPainter.height / 2)) // Vertically centered with anchor
        );

    // Annotate expected successes ABOVE the line (moved from below)
    double xPosition = expectedSuccessPercentage * size.width;
    textPainter.text = TextSpan(
      text: expectedSuccesses.toStringAsFixed(1),
      style: TextStyle(
        color: Colors.black,
        fontSize: 14,
        fontWeight: FontWeight.bold,
      ),
    );
    textPainter.layout(maxWidth: 100);

    // Center the text above the line
    double centeredXOffset = xPosition - (textPainter.width / 2);

    // Position it above the line instead of below it, but clearly visible
    textPainter.paint(canvas, Offset(centeredXOffset, 10));
  }

  void _paintAnchors(Canvas canvas, Size size) {
    // Move anchors up slightly to ensure full visibility
    double anchorY = size.height - 5.0;
    canvas.drawCircle(Offset(0.0, anchorY), 5.0, fillPainter);
    canvas.drawCircle(Offset(size.width, anchorY), 5.0, fillPainter);
  }

  void _paintWaveLine(Canvas canvas, Size size) {
    WaveCurveDefinitions waveCurve = _calculateWaveLineDefinitions(size);
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

  void _paintExpectedSuccessLine(Canvas canvas, Size size) {
    double xPosition = expectedSuccessPercentage * size.width;

    // Make the line 25% shorter from the top (start 25% down)
    double startY = size.height * 0.25;

    // End the line exactly at the waveline
    double endY = size.height - 2;

    canvas.drawLine(
      Offset(xPosition, startY),
      Offset(xPosition, endY),
      expectedLinePainter,
    );
  }

  WaveCurveDefinitions _calculateWaveLineDefinitions(Size size) {
    double minWaveHeight = size.height * 0.2;
    double maxWaveHeight = size.height * 0.8;
    double controlHeight =
        (size.height - minWaveHeight) - maxWaveHeight * dragPercentage;

    double bendWidth = 20 + 20 * dragPercentage;
    double bezierWidth = 20 + 20 * dragPercentage;

    double centerPoint = sliderPosition;
    centerPoint = (centerPoint > size.width) ? size.width : centerPoint;

    double startOfBend = sliderPosition - bendWidth / 2;
    double startOfBezier = startOfBend - bezierWidth;
    double endOfBend = sliderPosition + bendWidth / 2;
    double endOfBezier = endOfBend + bezierWidth;

    startOfBend = (startOfBend <= 0.0) ? 0.0 : startOfBend;
    startOfBezier = (startOfBezier <= 0.0) ? 0.0 : startOfBezier;
    endOfBend = (endOfBend >= size.width) ? size.width : endOfBend;
    endOfBezier = (endOfBezier >= size.width) ? size.width : endOfBezier;

    double leftControlPoint1 = startOfBend;
    double leftControlPoint2 = startOfBend;
    double rightControlPoint1 = endOfBend;
    double rightControlPoint2 = endOfBend;

    double bendability = 25.0;
    double maxSlideDifference =
        15; // how fast you need to move it to get max bendability.

    double slideDifference = (sliderPosition - _previousSliderPosition).abs();
    if (slideDifference > maxSlideDifference) {
      slideDifference = maxSlideDifference;
    }

    bool moveLeft = sliderPosition < _previousSliderPosition;

    double bend =
        lerpDouble(0.0, bendability, slideDifference / maxSlideDifference) ??
            0.0;

    bend = moveLeft ? -bend : bend;

    leftControlPoint1 = leftControlPoint1 + bend;
    leftControlPoint2 = leftControlPoint2 - bend;
    rightControlPoint1 = rightControlPoint1 - bend;
    rightControlPoint2 = rightControlPoint2 + bend;
    centerPoint = centerPoint - bend;

    return WaveCurveDefinitions(
      startofBezier: startOfBezier,
      endOfBezier: endOfBezier,
      leftControlPoint1: leftControlPoint1,
      leftControlPoint2: leftControlPoint2,
      rightControlPoint1: rightControlPoint1,
      rightControlPoint2: rightControlPoint2,
      controlHeight: controlHeight,
      centerPoint: centerPoint,
    );
  }

  @override
  bool shouldRepaint(covariant WavePainter oldDelegate) {
    _previousSliderPosition = oldDelegate.sliderPosition;
    return oldDelegate.sliderPosition != sliderPosition ||
        oldDelegate.dragPercentage != dragPercentage ||
        oldDelegate.expectedSuccessPercentage != expectedSuccessPercentage;
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
