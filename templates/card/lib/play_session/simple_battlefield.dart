import 'package:flutter/material.dart';

class SimpleBattlefieldScreen extends StatefulWidget {
  const SimpleBattlefieldScreen({super.key});
  @override
  State<SimpleBattlefieldScreen> createState() =>
      _SimpleBattlefieldScreenState();
}

class _SimpleBattlefieldScreenState extends State<SimpleBattlefieldScreen> {
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text("Battlefield")),
        body: InteractiveViewer(
          child: Image.asset('assets/images/battlefield.jpg'),
        ),
      );
}
