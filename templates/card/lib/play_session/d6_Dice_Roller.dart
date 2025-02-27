import 'dart:math';
import 'package:flutter/material.dart';
import 'target_selector.dart'; // Ensure this matches your file structure

class DiceRoller extends StatefulWidget {
  const DiceRoller({super.key});

  @override
  State<DiceRoller> createState() => _DiceRollerState();
}

class _DiceRollerState extends State<DiceRoller> {
  final Random _random = Random();
  int _result = 0;
  int numDice = 1; // Default to 1 dice
  int target = 6; // Default target number is 6

  /// Rolls the given number of dice and counts successes (<= target number).
  int rollDice(int numDice, int target) {
    int count = 0;
    for (int i = 0; i < numDice; i++) {
      int roll = _random.nextInt(6) + 1; // Rolls between 1 and 6
      if (roll <= target) count++;
    }
    return count;
  }

  void _onPressed() {
    setState(() {
      _result = rollDice(numDice, target);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(children: [
          Text('# Dice:', style: const TextStyle(fontSize: 20)),
          _gap,
          _gap,
          TargetSelector(
            selectionLimit: 30, // Example: Allow up to 10 dice
            initialValue: numDice,
            onChanged: (value) => setState(() => numDice = value),
          ),
        ]),
        const SizedBox(height: 10),
        Row(children: [
          Text('# Target:', style: const TextStyle(fontSize: 20)),
          _gap,
          TargetSelector(
            selectionLimit: 6, // Target numbers range from 1 to 6
            initialValue: target,
            onChanged: (value) => setState(() => target = value),
          ),
        ]),
        const SizedBox(height: 20),
        OutlinedButton(
          onPressed: _onPressed,
          child: const Text('Roll Dice'),
        ),
        const SizedBox(height: 20),
        Text('Successes: $_result', style: const TextStyle(fontSize: 20)),
      ],
    );
  }

  static const _gap = SizedBox(width: 20);
}
