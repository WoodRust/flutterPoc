import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:async';
import 'd6_Dice_Roller.dart';
import 'wave_slider.dart';
import 'target_selector.dart';

class WaveScreen extends StatefulWidget {
  const WaveScreen({super.key});

  @override
  State<WaveScreen> createState() => _WaveScreenState();
}

class _WaveScreenState extends State<WaveScreen> with TickerProviderStateMixin {
  // First wave slider state (Hits)
  double _dragPercentage = 0.0;
  double _expectedSuccessPercentage = 0.0;
  int numDice = 1;
  double expectedSuccesses = 0.0;
  int _firstSliderPosition = 0;
  int firstResult = 0;
  bool firstAnimationStarted = false;

  // Second wave slider state (Defence)
  double _secondDragPercentage = 0.0;
  double _secondExpectedSuccessPercentage = 0.0;
  int secondNumDice = 0; // Will be set from first roll's successes
  double secondExpectedSuccesses = 0.0;
  int secondTarget = 4; // Default second target value
  int secondResult = 0; // To store second roll result
  int _secondSliderPosition = 0;
  bool secondAnimationStarted = false;

  // Third wave slider state (Resolve)
  double _thirdDragPercentage = 0.0;
  double _thirdExpectedSuccessPercentage = 0.0;
  int thirdNumDice = 0; // Will be set from second roll's fails
  double thirdExpectedSuccesses = 0.0;
  int thirdTarget = 4; // Default third target value
  int thirdResult = 0; // To store third roll result
  int _thirdSliderPosition = 0;
  bool thirdAnimationStarted = false;

  // Wounds counter
  int totalWounds = 0;
  double expectedWounds = 0.0;

  // Animation controllers
  late AnimationController _controller;
  late AnimationController _secondController;
  late AnimationController _thirdController;

  @override
  void initState() {
    super.initState();

    // Setup first animation controller with completion listener
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1500),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          print("First animation completed"); // Debug
          setState(() {
            if (secondNumDice > 0) {
              secondAnimationStarted = true;
              // Start second animation with delay
              Future.delayed(Duration(milliseconds: 300), () {
                _startSecondAnimation();
              });
            }
          });
        }
      });

    // Setup second animation controller with completion listener
    _secondController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1500),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          print("Second animation completed"); // Debug
          setState(() {
            if (thirdNumDice > 0) {
              thirdAnimationStarted = true;
              // Start third animation with delay
              Future.delayed(Duration(milliseconds: 300), () {
                _startThirdAnimation();
              });
            }
          });
        }
      });

    // Setup third animation controller
    _thirdController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1500),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          print("Third animation completed"); // Debug
        }
      });
  }

  // Start the second animation
  void _startSecondAnimation() {
    print("Starting second animation"); // Debug
    if (secondNumDice > 0 && secondAnimationStarted) {
      double secondSuccessPercentage = secondResult / secondNumDice;
      _animateWave(
          secondSuccessPercentage, _secondController, _updateSecondWave);
    }
  }

  // Start the third animation
  void _startThirdAnimation() {
    print("Starting third animation"); // Debug
    if (thirdNumDice > 0 && thirdAnimationStarted) {
      double thirdSuccessPercentage = thirdResult / thirdNumDice;
      _animateWave(thirdSuccessPercentage, _thirdController, _updateThirdWave);
    }
  }

  // Common animation function
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

  // Update functions for each wave
  void _updateFirstWave(double value) {
    _dragPercentage = value;
    _firstSliderPosition = (numDice * _dragPercentage).round();
  }

  void _updateSecondWave(double value) {
    _secondDragPercentage = value;
    _secondSliderPosition = (secondNumDice * _secondDragPercentage).round();
  }

  void _updateThirdWave(double value) {
    _thirdDragPercentage = value;
    _thirdSliderPosition = (thirdNumDice * _thirdDragPercentage).round();
    _updateWoundsCounter();
  }

  // Update the wounds counters (both actual and expected)
  void _updateWoundsCounter() {
    // Calculate actual wounds
    int defenceFails = secondNumDice - _secondSliderPosition;
    int resolveFails = thirdNumDice - _thirdSliderPosition;

    // Calculate expected wounds
    double expectedDefenceFails = secondNumDice - secondExpectedSuccesses;
    double expectedResolveFails = thirdNumDice - thirdExpectedSuccesses;

    setState(() {
      totalWounds = defenceFails + resolveFails;
      expectedWounds = expectedDefenceFails + expectedResolveFails;
    });
  }

  // Triggered when Roll Dice button is pressed
  void _updateResults(int result, int numDice, double expectedSuccesses) {
    print("Roll dice pressed. Result: $result, NumDice: $numDice"); // Debug

    // Ensure all controllers are reset
    _controller.reset();
    _secondController.reset();
    _thirdController.reset();

    setState(() {
      // Reset animation flags
      firstAnimationStarted = true; // First animation starts immediately
      secondAnimationStarted = false;
      thirdAnimationStarted = false;

      // Store first roll results
      this.numDice = numDice;
      this.expectedSuccesses = expectedSuccesses;
      this.firstResult = result;
      _expectedSuccessPercentage =
          numDice > 0 ? expectedSuccesses / numDice : 0;

      // Set the second dice number to the result of the first roll (hits)
      secondNumDice = result;

      // Calculate expected successes for second roll (Defence)
      secondExpectedSuccesses =
          calculateExpectedSuccesses(secondNumDice, secondTarget);
      _secondExpectedSuccessPercentage =
          secondNumDice > 0 ? secondExpectedSuccesses / secondNumDice : 0;

      // Perform second dice roll (Defence)
      secondResult = rollDice(secondNumDice, secondTarget);

      // Set the third dice number to the fails from the second roll
      thirdNumDice = secondNumDice - secondResult;

      // Calculate expected successes for third roll (Resolve)
      thirdExpectedSuccesses =
          calculateExpectedSuccesses(thirdNumDice, thirdTarget);
      _thirdExpectedSuccessPercentage =
          thirdNumDice > 0 ? thirdExpectedSuccesses / thirdNumDice : 0;

      // Perform third dice roll (Resolve)
      thirdResult = rollDice(thirdNumDice, thirdTarget);

      // Reset the drag percentages
      _dragPercentage = 0.0;
      _secondDragPercentage = 0.0;
      _thirdDragPercentage = 0.0;

      // Reset positions
      _firstSliderPosition = 0;
      _secondSliderPosition = 0;
      _thirdSliderPosition = 0;

      // Calculate expected wounds
      double expectedDefenceFails = secondNumDice - secondExpectedSuccesses;
      double expectedResolveFails = thirdNumDice - thirdExpectedSuccesses;
      expectedWounds = expectedDefenceFails + expectedResolveFails;

      // Initially set actual wounds to match expected wounds
      totalWounds = expectedWounds.round();
    });

    // Start first animation
    double successPercentage = numDice > 0 ? result / numDice : 0;
    _animateWave(successPercentage, _controller, _updateFirstWave);
  }

  // Helper functions
  int rollDice(int numDice, int target) {
    if (numDice <= 0) return 0;

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

  // Target selectors change handlers
  void _onSecondTargetChanged(int value) {
    setState(() {
      secondTarget = value;

      // Only update expected values, not actual dice rolls
      secondExpectedSuccesses =
          calculateExpectedSuccesses(secondNumDice, secondTarget);
      _secondExpectedSuccessPercentage =
          secondNumDice > 0 ? secondExpectedSuccesses / secondNumDice : 0;

      // Update expected wounds
      double expectedDefenceFails = secondNumDice - secondExpectedSuccesses;
      double expectedResolveFails = thirdNumDice - thirdExpectedSuccesses;
      expectedWounds = expectedDefenceFails + expectedResolveFails;
    });
  }

  void _onThirdTargetChanged(int value) {
    setState(() {
      thirdTarget = value;

      // Only update expected values, not actual dice rolls
      thirdExpectedSuccesses =
          calculateExpectedSuccesses(thirdNumDice, thirdTarget);
      _thirdExpectedSuccessPercentage =
          thirdNumDice > 0 ? thirdExpectedSuccesses / thirdNumDice : 0;

      // Update expected wounds
      double expectedDefenceFails = secondNumDice - secondExpectedSuccesses;
      double expectedResolveFails = thirdNumDice - thirdExpectedSuccesses;
      expectedWounds = expectedDefenceFails + expectedResolveFails;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _secondController.dispose();
    _thirdController.dispose();
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
                hideResults: true, // Hide results display
              ),
              SizedBox(height: 30.0),

              // First wave slider section (Hits)
              Text(
                'Hits',
                style: TextStyle(fontSize: 35, fontFamily: 'Permanent Marker'),
              ),
              SizedBox(height: 10.0),
              Stack(
                children: [
                  WaveSlider(
                    dragPercentage: _dragPercentage,
                    expectedSuccessPercentage: _expectedSuccessPercentage,
                    numDice: numDice,
                    expectedSuccesses: expectedSuccesses,
                    onChanged: (double value) {},
                  ),
                  // Show "X" before animation starts or if not started
                  if (!firstAnimationStarted)
                    Positioned(
                      left: 165, // Center of slider (assuming 350px width)
                      top: 15,
                      child: Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          'X',
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

              // Second roll target selector (Defence)
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Padding(
                    padding: EdgeInsets.only(right: 20),
                    child:
                        Text('Defence Target:', style: TextStyle(fontSize: 20)),
                  ),
                  TargetSelector(
                    selectionLimit: 6,
                    initialValue: secondTarget,
                    textSize: 20,
                    onChanged: _onSecondTargetChanged,
                  ),
                ],
              ),

              SizedBox(height: 20.0),

              // Second wave slider section (Defence)
              Text(
                'Defence',
                style: TextStyle(fontSize: 35, fontFamily: 'Permanent Marker'),
              ),
              SizedBox(height: 10.0),
              Stack(
                children: [
                  WaveSlider(
                    dragPercentage: _secondDragPercentage,
                    expectedSuccessPercentage: _secondExpectedSuccessPercentage,
                    numDice: secondNumDice,
                    expectedSuccesses: secondExpectedSuccesses,
                    onChanged: (double value) {},
                  ),
                  // Show "X" before animation starts
                  if (!secondAnimationStarted)
                    Positioned(
                      left: 165, // Center of slider
                      top: 15,
                      child: Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          'X',
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

              // Third roll target selector (Resolve)
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Padding(
                    padding: EdgeInsets.only(right: 20),
                    child:
                        Text('Resolve Target:', style: TextStyle(fontSize: 20)),
                  ),
                  TargetSelector(
                    selectionLimit: 6,
                    initialValue: thirdTarget,
                    textSize: 20,
                    onChanged: _onThirdTargetChanged,
                  ),
                ],
              ),

              SizedBox(height: 20.0),

              // Third wave slider section (Resolve)
              Text(
                'Resolve',
                style: TextStyle(fontSize: 35, fontFamily: 'Permanent Marker'),
              ),
              SizedBox(height: 10.0),
              Stack(
                children: [
                  WaveSlider(
                    dragPercentage: _thirdDragPercentage,
                    expectedSuccessPercentage: _thirdExpectedSuccessPercentage,
                    numDice: thirdNumDice,
                    expectedSuccesses: thirdExpectedSuccesses,
                    onChanged: (double value) {},
                  ),
                  // Show "X" before animation starts
                  if (!thirdAnimationStarted)
                    Positioned(
                      left: 165, // Center of slider
                      top: 15,
                      child: Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          'X',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),

              SizedBox(height: 35.0), // Reduced from 40.0

              // Wounds counter
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                width: 270, // Make the box slightly narrower
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: Colors.red, width: 1.5), // Thinner border
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min, // Take minimum space needed
                  children: [
                    // Title
                    Text(
                      'Wounds',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 2), // Reduced spacing
                    // Values row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Expected wounds on the left
                        Row(
                          children: [
                            Text(
                              '${expectedWounds.toStringAsFixed(1)}',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.deepPurple,
                              ),
                            ),
                            Text(
                              ' xW',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),

                        // Actual wounds on the right
                        Row(
                          children: [
                            Text(
                              '$totalWounds',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                              ),
                            ),
                            Text(
                              ' W',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
