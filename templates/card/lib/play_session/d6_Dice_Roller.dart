// import 'dart:math';
// import 'package:flutter/material.dart';
// import 'target_selector.dart';

// class DiceRoller extends StatefulWidget {
//   final void Function(int result, int numDice, double expectedSuccesses)
//       onResult;
//   final bool hideResults;
//   final int target; // Now we receive target as a prop from parent

//   const DiceRoller({
//     super.key,
//     required this.onResult,
//     required this.target, // Required prop
//     this.hideResults = false,
//   });

//   @override
//   State<DiceRoller> createState() => _DiceRollerState();
// }

// class _DiceRollerState extends State<DiceRoller> {
//   final Random _random = Random();
//   int _result = 0;
//   int numDice = 1;
//   // Target is now a prop from parent, not maintained here

//   int rollDice(int numDice, int target) {
//     int count = 0;
//     for (int i = 0; i < numDice; i++) {
//       int roll = _random.nextInt(6) + 1;
//       if (roll <= target) count++;
//     }
//     return count;
//   }

//   double calculateExpectedSuccesses(int numDice, int target) {
//     return numDice * (target / 6);
//   }

//   void _onPressed() {
//     // Use the target passed as a prop
//     setState(() {
//       _result = rollDice(numDice, widget.target);
//     });
//     double expectedSuccesses =
//         calculateExpectedSuccesses(numDice, widget.target);
//     widget.onResult(_result, numDice, expectedSuccesses);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       crossAxisAlignment: CrossAxisAlignment.center,
//       children: [
//         // Roll Dice button on the left
//         ElevatedButton(
//           onPressed: _onPressed,
//           style: ElevatedButton.styleFrom(
//             backgroundColor: Colors.deepPurple,
//             padding: EdgeInsets.symmetric(
//                 horizontal: 48, vertical: 24), // 50% larger
//             textStyle: TextStyle(fontSize: 20),
//           ),
//           child: Text('Roll Dice',
//               style:
//                   TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
//         ),

//         // Only the Dice number selector, no Target selector
//         Row(
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             Text('Dice:', style: TextStyle(fontSize: 20)),
//             SizedBox(width: 20),
//             TargetSelector(
//               selectionLimit: 30,
//               initialValue: numDice,
//               textSize: 20,
//               onChanged: (value) => setState(() {
//                 numDice = value;
//               }),
//             ),
//           ],
//         ),
//       ],
//     );
//   }
// }
