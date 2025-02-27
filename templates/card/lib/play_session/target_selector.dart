import 'package:flutter/material.dart';

class TargetSelector extends StatelessWidget {
  final int selectionLimit;
  final int initialValue;
  final ValueChanged<int> onChanged;

  const TargetSelector({
    super.key,
    required this.selectionLimit,
    required this.initialValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButton<int>(
      value: initialValue,
      icon: const Icon(Icons.arrow_downward),
      elevation: 16,
      style: const TextStyle(color: Colors.deepPurple),
      underline: Container(height: 2, color: Colors.deepPurpleAccent),
      onChanged: (int? newValue) {
        if (newValue != null) {
          onChanged(newValue);
        }
      },
      items: List.generate(selectionLimit, (index) => index + 1)
          .map<DropdownMenuItem<int>>((int value) {
        return DropdownMenuItem<int>(
          value: value,
          child: Text(value.toString()),
        );
      }).toList(),
    );
  }
}
