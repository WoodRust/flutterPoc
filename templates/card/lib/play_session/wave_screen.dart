import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:async';
import 'wave_slider.dart';
import 'target_selector.dart';

class WaveScreen extends StatefulWidget {
  const WaveScreen({super.key});

  @override
  State<WaveScreen> createState() => _WaveScreenState();
}

class _WaveScreenState extends State<WaveScreen> with TickerProviderStateMixin {
  final Random _random = Random();

  // First wave slider state (Hits)
  double _dragPercentage = 0.0;
  double _expectedSuccessPercentage = 0.0;
  int numDice = 1;
  int target = 6;
  double expectedSuccesses = 0.0;
  int _firstSliderPosition = 0;
  int firstResult = 0;
  bool firstAnimationStarted = false;

  // Second wave slider state (Defence)
  double _secondDragPercentage = 0.0;
  double _secondExpectedSuccessPercentage = 0.0;
  int secondNumDice = 0;
  double secondExpectedSuccesses = 0.0;
  int secondTarget = 4;
  int secondResult = 0;
  int _secondSliderPosition = 0;
  bool secondAnimationStarted = false;

  // Third wave slider state (Resolve)
  double _thirdDragPercentage = 0.0;
  double _thirdExpectedSuccessPercentage = 0.0;
  int thirdNumDice = 0;
  double thirdExpectedSuccesses = 0.0;
  int thirdTarget = 4;
  int thirdResult = 0;
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

    // Initialize expected values
    _updateExpectedValues();
  }

  // Calculate and update expected values based on current settings
  void _updateExpectedValues() {
    // First roll (Clash) expected successes
    expectedSuccesses = calculateExpectedSuccesses(numDice.toDouble(), target);
    _expectedSuccessPercentage = numDice > 0 ? expectedSuccesses / numDice : 0;

    // Expected second dice (based on expected first successes)
    double expectedSecondNumDice = expectedSuccesses;

    // Second roll (Defence) expected successes
    secondExpectedSuccesses =
        calculateExpectedSuccesses(expectedSecondNumDice, secondTarget);
    _secondExpectedSuccessPercentage = expectedSecondNumDice > 0
        ? secondExpectedSuccesses / expectedSecondNumDice
        : 0;

    // Expected third dice (based on expected second fails)
    double expectedThirdNumDice =
        expectedSecondNumDice - secondExpectedSuccesses;

    // Third roll (Resolve) expected successes
    thirdExpectedSuccesses =
        calculateExpectedSuccesses(expectedThirdNumDice, thirdTarget);
    _thirdExpectedSuccessPercentage = expectedThirdNumDice > 0
        ? thirdExpectedSuccesses / expectedThirdNumDice
        : 0;

    // Update expected wounds
    double expectedDefenceFails =
        expectedSecondNumDice - secondExpectedSuccesses;
    double expectedResolveFails = expectedThirdNumDice - thirdExpectedSuccesses;
    expectedWounds = expectedDefenceFails + expectedResolveFails;
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

    setState(() {
      totalWounds = defenceFails + resolveFails;
    });
  }

  // Function to roll dice
  int rollDice(int numDice, int target) {
    if (numDice <= 0) return 0;

    int count = 0;
    for (int i = 0; i < numDice; i++) {
      int roll = _random.nextInt(6) + 1;
      if (roll <= target) count++;
    }
    return count;
  }

  // Function to calculate expected successes
  double calculateExpectedSuccesses(double numDice, int target) {
    return numDice * (target / 6);
  }

  // Roll dice action (formerly _onPressed in DiceRoller)
  void _rollDice() {
    print("Roll dice pressed. NumDice: $numDice, Target: $target"); // Debug
    int result = rollDice(numDice, target);
    double expectedSuccesses =
        calculateExpectedSuccesses(numDice.toDouble(), target);

    // Call the original update function with rolled results
    _updateResults(result, numDice, expectedSuccesses);
  }

  // Triggered when Roll Dice button is pressed
  void _updateResults(int result, int numDice, double expectedSuccesses) {
    print("Roll dice pressed. Result: $result, NumDice: $numDice"); // Debug

    // Ensure all controllers are reset
    _controller.reset();
    _secondController.reset();
    _thirdController.reset();

    // Store current expected wounds value to preserve it
    double currentExpectedWounds = expectedWounds;

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

      // Calculate expected successes for second roll based on ACTUAL first result
      secondExpectedSuccesses =
          calculateExpectedSuccesses(secondNumDice.toDouble(), secondTarget);
      _secondExpectedSuccessPercentage =
          secondNumDice > 0 ? secondExpectedSuccesses / secondNumDice : 0;

      // Perform second dice roll (Defence)
      secondResult = rollDice(secondNumDice, secondTarget);

      // Set the third dice number to the fails from the second roll
      thirdNumDice = secondNumDice - secondResult;

      // Calculate expected successes for third roll based on ACTUAL second result fails
      thirdExpectedSuccesses =
          calculateExpectedSuccesses(thirdNumDice.toDouble(), thirdTarget);
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

      // Keep the expected wounds value the same as before the roll
      expectedWounds = currentExpectedWounds;

      // Initialize actual wounds to 0 instead of expected wounds
      totalWounds = 0;
    });

    // Start first animation
    double successPercentage = numDice > 0 ? result / numDice : 0;
    _animateWave(successPercentage, _controller, _updateFirstWave);
  }

  // Target selectors change handlers
  void _onFirstTargetChanged(int value) {
    setState(() {
      target = value;
      _updateExpectedValues();
    });
  }

  void _onSecondTargetChanged(int value) {
    setState(() {
      secondTarget = value;
      _updateExpectedValues();
    });
  }

  void _onThirdTargetChanged(int value) {
    setState(() {
      thirdTarget = value;
      _updateExpectedValues();
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
        padding: EdgeInsets.all(24.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // Dice roller UI (replacing DiceRoller widget)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Roll Dice button on the left
                  ElevatedButton(
                    onPressed: _rollDice,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      padding: EdgeInsets.symmetric(
                        horizontal: 48,
                        vertical: 24,
                      ),
                      textStyle: TextStyle(fontSize: 20),
                    ),
                    child: Text(
                      'Roll Dice',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  // Dice number selector
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text('Dice:', style: TextStyle(fontSize: 20)),
                      SizedBox(width: 20),
                      TargetSelector(
                        selectionLimit: 30,
                        initialValue: numDice,
                        textSize: 20,
                        onChanged: (value) => setState(() {
                          numDice = value;
                          _updateExpectedValues();
                        }),
                      ),
                    ],
                  ),
                ],
              ),

              SizedBox(height: 10.0),

              // First wave slider section (Hits) with aligned title and target dropdown
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Hits title on the left
                  Text(
                    'Clash',
                    style:
                        TextStyle(fontSize: 35, fontFamily: 'Permanent Marker'),
                  ),

                  // Hits target selector on the right, aligned with title
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(width: 20),
                      TargetSelector(
                        selectionLimit: 6,
                        initialValue: target,
                        textSize: 20,
                        onChanged: _onFirstTargetChanged,
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 5.0),
              WaveSlider(
                dragPercentage: _dragPercentage,
                expectedSuccessPercentage: _expectedSuccessPercentage,
                numDice: numDice,
                expectedSuccesses: expectedSuccesses,
                onChanged: (double value) {},
              ),

              SizedBox(height: 5.0),

              // Second wave slider section (Defence) with aligned title and target selector
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Defence title on the left
                  Text(
                    'Defence',
                    style:
                        TextStyle(fontSize: 35, fontFamily: 'Permanent Marker'),
                  ),

                  // Defence target selector on the right, aligned with title
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(width: 20),
                      TargetSelector(
                        selectionLimit: 6,
                        initialValue: secondTarget,
                        textSize: 20,
                        onChanged: _onSecondTargetChanged,
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 5.0),
              WaveSlider(
                dragPercentage: _secondDragPercentage,
                expectedSuccessPercentage: _secondExpectedSuccessPercentage,
                numDice: secondNumDice,
                expectedSuccesses: secondExpectedSuccesses,
                onChanged: (double value) {},
              ),

              SizedBox(height: 5.0),

              // Third wave slider section (Resolve) with aligned title and target selector
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Resolve title on the left
                  Text(
                    'Resolve',
                    style:
                        TextStyle(fontSize: 35, fontFamily: 'Permanent Marker'),
                  ),

                  // Resolve target selector on the right, aligned with title
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(width: 20),
                      TargetSelector(
                        selectionLimit: 6,
                        initialValue: thirdTarget,
                        textSize: 20,
                        onChanged: _onThirdTargetChanged,
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 5.0),
              WaveSlider(
                dragPercentage: _thirdDragPercentage,
                expectedSuccessPercentage: _thirdExpectedSuccessPercentage,
                numDice: thirdNumDice,
                expectedSuccesses: thirdExpectedSuccesses,
                onChanged: (double value) {},
              ),

              SizedBox(height: 15.0),

              // Wounds counter
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                width: 270,
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red, width: 1.5),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Title
                    Text(
                      'Wounds',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 2),
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
