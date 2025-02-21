import 'package:card/play_session/wave_slider.dart';
import 'package:flutter/material.dart';

class WaveScreen extends StatefulWidget {
  const WaveScreen({super.key});

  @override
  State<WaveScreen> createState() => _WaveScreenState();
}

class _WaveScreenState extends State<WaveScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Wave Slider'),
        ),
        body: Container(
            padding: EdgeInsets.all(32.0),
            child: Center(
              child: WaveSlider(),
            )));
  }
}
