import 'dart:math';
import 'package:flutter/material.dart';
import 'target_selector.dart'; // Ensure this matches your file structure

class DiceRoller extends StatefulWidget {
  final void Function(int result, int numDice) onResult; // Callback function

  const DiceRoller({super.key, required this.onResult});

  @override
  State<DiceRoller> createState() => _DiceRollerState();
}

class _DiceRollerState extends State<DiceRoller> {
  final Random _random = Random();
  int _result = 0;
  int numDice = 1;
  int target = 6;

  int rollDice(int numDice, int target) {
    int count = 0;
    for (int i = 0; i < numDice; i++) {
      int roll = _random.nextInt(6) + 1;
      if (roll <= target) count++;
    }
    return count;
  }

  void _onPressed() {
    setState(() {
      _result = rollDice(numDice, target);
    });
    widget.onResult(_result, numDice); // Pass values to WaveScreen
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(children: [
          Text('# Dice:', style: TextStyle(fontSize: 20)),
          TargetSelector(
            selectionLimit: 30,
            initialValue: numDice,
            onChanged: (value) => setState(() {
              numDice = value;
            }),
          ),
        ]),
        SizedBox(height: 10),
        Row(children: [
          Text('# Target:', style: TextStyle(fontSize: 20)),
          TargetSelector(
            selectionLimit: 6,
            initialValue: target,
            onChanged: (value) => setState(() {
              target = value;
            }),
          ),
        ]),
        SizedBox(height: 20),
        OutlinedButton(
          onPressed: _onPressed,
          child: Text('Roll Dice'),
        ),
        SizedBox(height: 20),
        Text('Successes: $_result', style: TextStyle(fontSize: 20)),
      ],
    );
  }
}
