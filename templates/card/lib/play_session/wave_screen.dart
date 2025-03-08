import 'package:card/play_session/target_selector.dart';
import 'package:flutter/material.dart';
import 'd6_Dice_Roller.dart';
import 'wave_slider.dart';
import 'dart:math';

class WaveScreen extends StatefulWidget {
  const WaveScreen({super.key});

  @override
  State<WaveScreen> createState() => _WaveScreenState();
}

class _WaveScreenState extends State<WaveScreen> with TickerProviderStateMixin {
  // First wave slider state
  double _dragPercentage = 0.0;
  double _expectedSuccessPercentage = 0.0;
  int numDice = 1;
  double expectedSuccesses = 0.0;
  int _firstSliderPosition = 0;

  // Second wave slider state
  double _secondDragPercentage = 0.0;
  double _secondExpectedSuccessPercentage = 0.0;
  int secondNumDice = 0; // Will be set from first roll's successes
  double secondExpectedSuccesses = 0.0;
  int secondTarget = 4; // Default second target value
  int secondResult = 0; // To store second roll result
  int _secondSliderPosition = 0;

  // Animation controllers
  late AnimationController _controller;
  late AnimationController _secondController;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1500),
    );

    _secondController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1500),
    );
  }

  void _animateWave(double successRate, AnimationController controller,
      Function(double) updateState) {
    controller.reset();

    final up1 = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
          parent: controller,
          curve: Interval(0.0, 0.33, curve: Curves.easeInOut)),
    );
    final down = Tween<double>(begin: 1, end: 0).animate(
      CurvedAnimation(
          parent: controller,
          curve: Interval(0.33, 0.66, curve: Curves.easeInOut)),
    );
    final up2 = Tween<double>(begin: 0, end: successRate).animate(
      CurvedAnimation(
          parent: controller,
          curve: Interval(0.66, 1.0, curve: Curves.easeInOut)),
    );

    controller.addListener(() {
      setState(() {
        if (controller.value <= 0.33) {
          updateState(up1.value);
        } else if (controller.value <= 0.66) {
          updateState(down.value);
        } else {
          updateState(up2.value);
        }
      });
    });

    controller.forward();
  }

  void _updateFirstWave(double value) {
    _dragPercentage = value;
    // Update the actual successes value based on the current animation state
    _firstSliderPosition = (numDice * _dragPercentage).round();
  }

  void _updateSecondWave(double value) {
    _secondDragPercentage = value;
    // Update the actual successes value based on the current animation state
    _secondSliderPosition = (secondNumDice * _secondDragPercentage).round();
  }

  void _updateResults(int result, int numDice, double expectedSuccesses) {
    setState(() {
      this.numDice = numDice; // Store the number of dice
      this.expectedSuccesses = expectedSuccesses; // Store expected successes
      _expectedSuccessPercentage =
          numDice > 0 ? expectedSuccesses / numDice : 0;

      // Set the second dice number to the result of the first roll
      secondNumDice = result;

      // Calculate expected successes for second roll
      secondExpectedSuccesses =
          calculateExpectedSuccesses(secondNumDice, secondTarget);
      _secondExpectedSuccessPercentage =
          secondNumDice > 0 ? secondExpectedSuccesses / secondNumDice : 0;

      // Perform second dice roll
      secondResult = rollDice(secondNumDice, secondTarget);
    });

    // Animate first wave
    double successPercentage = numDice > 0 ? result / numDice : 0;
    _animateWave(successPercentage, _controller, _updateFirstWave);

    // Animate second wave
    double secondSuccessPercentage =
        secondNumDice > 0 ? secondResult / secondNumDice : 0;

    // Slight delay for the second animation to create a cascade effect
    Future.delayed(Duration(milliseconds: 300), () {
      _animateWave(
          secondSuccessPercentage, _secondController, _updateSecondWave);
    });
  }

  // Moved these functions from DiceRoller to be accessible here for the second roll
  int rollDice(int numDice, int target) {
    int count = 0;
    final random = Random();
    for (int i = 0; i < numDice; i++) {
      int roll = random.nextInt(6) + 1;
      if (roll <= target) count++;
    }
    return count;
  }

  double calculateExpectedSuccesses(int numDice, int target) {
    return numDice * (target / 6);
  }

  // Update the second target value when changed
  void _onSecondTargetChanged(int value) {
    setState(() {
      secondTarget = value;
      secondExpectedSuccesses =
          calculateExpectedSuccesses(secondNumDice, secondTarget);
      _secondExpectedSuccessPercentage =
          secondNumDice > 0 ? secondExpectedSuccesses / secondNumDice : 0;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _secondController.dispose();
    super.dispose();
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
              // Primary dice roller
              DiceRoller(
                onResult: _updateResults,
                hideResults: true, // New parameter to hide results display
              ),
              SizedBox(height: 20.0),

              // First wave slider section
              Text(
                'Hits',
                style: TextStyle(fontSize: 35, fontFamily: 'Permanent Marker'),
              ),
              Stack(
                alignment: Alignment.center,
                children: [
                  WaveSlider(
                    dragPercentage: _dragPercentage,
                    expectedSuccessPercentage: _expectedSuccessPercentage,
                    numDice: numDice,
                    expectedSuccesses: expectedSuccesses,
                    onChanged: (double value) {},
                  ),
                  Positioned(
                    left: 350 *
                        _dragPercentage, // Assuming width 350 from WaveSlider default
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Text(
                        '$_firstSliderPosition',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 40.0),

              // Second roll target selector
              Row(
                children: [
                  Text('Defence Target:', style: TextStyle(fontSize: 20)),
                  TargetSelector(
                    selectionLimit: 6,
                    initialValue: secondTarget,
                    onChanged: _onSecondTargetChanged,
                  ),
                ],
              ),

              SizedBox(height: 20.0),

              // Second wave slider section
              Text(
                'Defence',
                style: TextStyle(fontSize: 35, fontFamily: 'Permanent Marker'),
              ),
              Stack(
                alignment: Alignment.center,
                children: [
                  WaveSlider(
                    dragPercentage: _secondDragPercentage,
                    expectedSuccessPercentage: _secondExpectedSuccessPercentage,
                    numDice: secondNumDice,
                    expectedSuccesses: secondExpectedSuccesses,
                    onChanged: (double value) {},
                  ),
                  Positioned(
                    left: 350 *
                        _secondDragPercentage, // Assuming width 350 from WaveSlider default
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Text(
                        '$_secondSliderPosition',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
