import 'dart:math';
import 'package:flutter/material.dart';
import 'target_selector.dart';

class DiceRoller extends StatefulWidget {
  final void Function(int result, int numDice, double expectedSuccesses)
      onResult;
  final bool hideResults; // Parameter to control visibility of results

  const DiceRoller({
    super.key,
    required this.onResult,
    this.hideResults = false,
  });

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

  double calculateExpectedSuccesses(int numDice, int target) {
    return numDice * (target / 6);
  }

  void _onPressed() {
    setState(() {
      _result = rollDice(numDice, target);
    });
    double expectedSuccesses = calculateExpectedSuccesses(numDice, target);
    widget.onResult(_result, numDice, expectedSuccesses);
  }

  @override
  Widget build(BuildContext context) {
    calculateExpectedSuccesses(numDice, target);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Roll Dice button on the left
        ElevatedButton(
          onPressed: _onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepPurple,
            padding: EdgeInsets.symmetric(
                horizontal: 48, vertical: 24), // 50% larger
            textStyle: TextStyle(fontSize: 20),
          ),
          child: Text('Roll Dice',
              style:
                  TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        ),
        // Selectors on the right
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Padding(
                  padding: EdgeInsets.only(right: 20),
                  child: Text('Dice:', style: TextStyle(fontSize: 20)),
                ),
                TargetSelector(
                  selectionLimit: 30,
                  initialValue: numDice,
                  textSize: 20,
                  onChanged: (value) => setState(() {
                    numDice = value;
                  }),
                ),
              ],
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Padding(
                  padding: EdgeInsets.only(right: 20),
                  child: Text('Target:', style: TextStyle(fontSize: 20)),
                ),
                TargetSelector(
                  selectionLimit: 6,
                  initialValue: target,
                  textSize: 20,
                  onChanged: (value) => setState(() {
                    target = value;
                  }),
                ),
              ],
            ),
          ],
        ),
      ],
    );
    // Display results only if hideResults is false
  }
}
