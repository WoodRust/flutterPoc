import 'package:flutter/material.dart';
import 'd6_Dice_Roller.dart';
import 'wave_slider.dart';

class WaveScreen extends StatefulWidget {
  const WaveScreen({super.key});

  @override
  State<WaveScreen> createState() => _WaveScreenState();
}

class _WaveScreenState extends State<WaveScreen>
    with SingleTickerProviderStateMixin {
  double _dragPercentage = 0.0;
  double _expectedSuccessPercentage = 0.0;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1500),
    );
  }

  void _animateWave(double successRate) {
    _controller.reset();

    final up1 = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
          parent: _controller,
          curve: Interval(0.0, 0.33, curve: Curves.easeInOut)),
    );
    final down = Tween<double>(begin: 1, end: 0).animate(
      CurvedAnimation(
          parent: _controller,
          curve: Interval(0.33, 0.66, curve: Curves.easeInOut)),
    );
    final up2 = Tween<double>(begin: 0, end: successRate).animate(
      CurvedAnimation(
          parent: _controller,
          curve: Interval(0.66, 1.0, curve: Curves.easeInOut)),
    );

    _controller.addListener(() {
      setState(() {
        if (_controller.value <= 0.33) {
          _dragPercentage = up1.value;
        } else if (_controller.value <= 0.66) {
          _dragPercentage = down.value;
        } else {
          _dragPercentage = up2.value;
        }
      });
    });

    _controller.forward();
  }

  void _updateResults(int result, int numDice, double expectedSuccesses) {
    setState(() {
      _expectedSuccessPercentage =
          numDice > 0 ? expectedSuccesses / numDice : 0;
    });
    double successPercentage = numDice > 0 ? result / numDice : 0;
    _animateWave(successPercentage);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.all(32.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              DiceRoller(
                onResult: _updateResults,
              ),
              Text(
                'Success Rate',
                style: TextStyle(fontSize: 45, fontFamily: 'Permanent Marker'),
              ),
              WaveSlider(
                dragPercentage: _dragPercentage,
                expectedSuccessPercentage: _expectedSuccessPercentage,
                onChanged: (double value) {},
              ),
              SizedBox(height: 50.0),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                mainAxisAlignment: MainAxisAlignment.end,
                textBaseline: TextBaseline.alphabetic,
                children: <Widget>[
                  Text(
                    '${(_dragPercentage * 100).round()}%',
                    style: TextStyle(fontSize: 45),
                  ),
                  SizedBox(width: 15),
                  Text(
                    'Success Rate',
                    style: TextStyle(fontSize: 20, fontFamily: 'TextMeOne'),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
