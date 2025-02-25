import 'package:card/play_session/wave_slider.dart';
import 'package:flutter/material.dart';

class WaveScreen extends StatefulWidget {
  const WaveScreen({super.key});

  @override
  State<WaveScreen> createState() => _WaveScreenState();
}

class _WaveScreenState extends State<WaveScreen> {
  int _hits = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
            padding: EdgeInsets.all(32.0),
            child: Center(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                  Text(
                    'Hits',
                    style: TextStyle(
                      fontSize: 45,
                      fontFamily: 'Permanent Marker',
                    ),
                  ),
                  WaveSlider(),
                  SizedBox(
                    height: 50.0,
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: <Widget>[
                      Text(
                        _hits.toString(),
                        style: TextStyle(fontSize: 45),
                      ),
                      SizedBox(
                        width: 15,
                      ),
                      Text(
                        'Hits',
                        style: TextStyle(fontSize: 20, fontFamily: 'TextMeOne'),
                      )
                    ],
                  )
                ]))));
  }
}
