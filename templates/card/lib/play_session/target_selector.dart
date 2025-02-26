import 'package:flutter/material.dart';

class TargetSelector extends StatefulWidget {
  final int selectionLimit;
  final int initialvalue;

  const TargetSelector(
      {super.key, required this.selectionLimit, required this.initialvalue});

  @override
  State<TargetSelector> createState() => _TargetSelectorState();
}

class _TargetSelectorState extends State<TargetSelector> {
  late int dropdownValue;

  @override
  void initState() {
    super.initState();
    dropdownValue = widget.initialvalue;
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButton<int>(
      value: dropdownValue,
      icon: const Icon(Icons.arrow_downward),
      elevation: 16,
      style: const TextStyle(color: Colors.deepPurple),
      underline: Container(height: 2, color: Colors.deepPurpleAccent),
      onChanged: (int? value) {
        // This is called when the user selects an item.
        setState(() {
          dropdownValue = value!;
        });
      },
      items: List.generate(widget.selectionLimit, (index) => index + 1)
          .map<DropdownMenuItem<int>>((int value) {
        return DropdownMenuItem<int>(
            value: value, child: Text(value.toString()));
      }).toList(),
    );
  }
}
