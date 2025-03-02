import 'package:card/play_session/d6_Dice_Roller.dart';
import 'package:card/play_session/target_selector.dart';
import 'package:card/play_session/wave_slider.dart';
import 'package:flutter/material.dart';

class WaveScreen extends StatefulWidget {
  const WaveScreen({super.key});

  @override
  State<WaveScreen> createState() => _WaveScreenState();
}

class _WaveScreenState extends State<WaveScreen> {
  int _result = 0;
  int _numDice = 1;
  double _dragPercentage = 0.0;

  void _updateResults(int result, int numDice) {
    setState(() {
      _result = result;
      _numDice = numDice;
      _dragPercentage = numDice > 0 ? result / numDice : 0; // Update percentage
    });
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
                onResult: _updateResults, // Update success rate
              ),
              Text(
                'Success Rate',
                style: TextStyle(fontSize: 45, fontFamily: 'Permanent Marker'),
              ),
              WaveSlider(
                dragPercentage: _dragPercentage, // Pass percentage to slider
                onChanged: (double value) {
                  // No manual update needed
                },
              ),
              SizedBox(height: 50.0),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                mainAxisAlignment: MainAxisAlignment.end,
                textBaseline: TextBaseline.alphabetic,
                children: <Widget>[
                  Text(
                    '${(_dragPercentage * 100).round()}%', // Display correct percentage
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
