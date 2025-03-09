import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:async';
import 'wave_slider.dart';
import 'target_selector.dart';

// State container for each tab's independent state
class WaveScreenState {
  final Random _random = Random();

  // First wave slider state (Hits)
  double dragPercentage = 0.0;
  double expectedSuccessPercentage = 0.0;
  int numDice = 1;
  int target = 6;
  double expectedSuccesses = 0.0;
  int firstSliderPosition = 0;
  int firstResult = 0;
  bool firstAnimationStarted = false;

  // Second wave slider state (Defence)
  double secondDragPercentage = 0.0;
  double secondExpectedSuccessPercentage = 0.0;
  int secondNumDice = 0;
  double secondExpectedSuccesses = 0.0;
  int secondTarget = 4;
  int secondResult = 0;
  int secondSliderPosition = 0;
  bool secondAnimationStarted = false;

  // Third wave slider state (Resolve)
  double thirdDragPercentage = 0.0;
  double thirdExpectedSuccessPercentage = 0.0;
  int thirdNumDice = 0;
  double thirdExpectedSuccesses = 0.0;
  int thirdTarget = 4;
  int thirdResult = 0;
  int thirdSliderPosition = 0;
  bool thirdAnimationStarted = false;

  // Wounds counter
  int totalWounds = 0;
  double expectedWounds = 0.0;

  // Calculate and update expected values based on current settings
  void updateExpectedValues() {
    // First roll (Clash) expected successes
    expectedSuccesses = calculateExpectedSuccesses(numDice.toDouble(), target);
    expectedSuccessPercentage = numDice > 0 ? expectedSuccesses / numDice : 0;

    // Expected second dice (based on expected first successes)
    double expectedSecondNumDice = expectedSuccesses;

    // Second roll (Defence) expected successes
    secondExpectedSuccesses =
        calculateExpectedSuccesses(expectedSecondNumDice, secondTarget);
    secondExpectedSuccessPercentage = expectedSecondNumDice > 0
        ? secondExpectedSuccesses / expectedSecondNumDice
        : 0;

    // Expected third dice (based on expected second fails)
    double expectedThirdNumDice =
        expectedSecondNumDice - secondExpectedSuccesses;

    // Third roll (Resolve) expected successes
    thirdExpectedSuccesses =
        calculateExpectedSuccesses(expectedThirdNumDice, thirdTarget);
    thirdExpectedSuccessPercentage = expectedThirdNumDice > 0
        ? thirdExpectedSuccesses / expectedThirdNumDice
        : 0;

    // Update expected wounds
    double expectedDefenceFails =
        expectedSecondNumDice - secondExpectedSuccesses;
    double expectedResolveFails = expectedThirdNumDice - thirdExpectedSuccesses;
    expectedWounds = expectedDefenceFails + expectedResolveFails;
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

  // Initialize with default values
  WaveScreenState() {
    updateExpectedValues();
  }
}

// Main container widget
class TabsContainerScreen extends StatefulWidget {
  const TabsContainerScreen({Key? key}) : super(key: key);

  @override
  State<TabsContainerScreen> createState() => _TabsContainerScreenState();
}

class _TabsContainerScreenState extends State<TabsContainerScreen>
    with TickerProviderStateMixin {
  // Tab controller
  late TabController _tabController;

  // Checkbox states
  bool _impactsChecked = false;
  bool _clashChecked = true;

  // Independent state for each tab - the key is persistent for the lifetime of this widget
  final Map<String, WaveScreenState> _tabStates = {
    'Impacts': WaveScreenState(),
    'Clash': WaveScreenState(),
  };

  // List of active tabs
  List<String> _activeTabs = ['Clash'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _activeTabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Update tabs based on checkbox selections while preserving state
  void _updateTabs() {
    setState(() {
      _activeTabs = [];

      if (_impactsChecked) {
        _activeTabs.add('Impacts');
      }

      if (_clashChecked) {
        _activeTabs.add('Clash');
      }

      // If no checkboxes are selected, ensure at least one tab exists
      if (_activeTabs.isEmpty) {
        _activeTabs = ['None Selected'];
      }

      // Create a new tab controller with the updated length
      _tabController = TabController(length: _activeTabs.length, vsync: this);

      // Set to the first tab when tabs change
      _tabController.index = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Top section (25% of screen) with checkboxes
          Container(
            height: MediaQuery.of(context).size.height * 0.25,
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              border: Border(
                bottom: BorderSide(
                  color: Colors.grey.shade300,
                  width: 1,
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Select Types of Rolls:',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Impacts checkbox
                    Row(
                      children: [
                        Checkbox(
                          value: _impactsChecked,
                          onChanged: (bool? value) {
                            setState(() {
                              _impactsChecked = value ?? false;
                              _updateTabs();
                            });
                          },
                          activeColor: Colors.deepPurple,
                        ),
                        Text(
                          'Impacts',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),

                    // Clash checkbox
                    Row(
                      children: [
                        Checkbox(
                          value: _clashChecked,
                          onChanged: (bool? value) {
                            setState(() {
                              _clashChecked = value ?? false;
                              _updateTabs();
                            });
                          },
                          activeColor: Colors.deepPurple,
                        ),
                        Text(
                          'Clash',
                          style: TextStyle(
                            fontSize: 20,
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

          // Tab bar (remaining 75% of screen)
          Expanded(
            child: Column(
              children: [
                // Tab bar
                TabBar(
                  controller: _tabController,
                  tabs:
                      _activeTabs.map((tabName) => Tab(text: tabName)).toList(),
                  labelColor: Colors.deepPurple,
                  unselectedLabelColor: Colors.grey,
                  labelStyle:
                      TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  indicatorColor: Colors.deepPurple,
                  indicatorWeight: 3,
                ),

                // Tab content
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: _activeTabs.map((tabName) {
                      if (tabName == 'None Selected') {
                        return Center(
                          child: Text(
                            'Please select at least one type of roll',
                            style: TextStyle(fontSize: 18),
                          ),
                        );
                      } else {
                        // Use a keyed widget with externalized state
                        return WaveScreen(
                          key: ValueKey(tabName),
                          state: _tabStates[tabName]!,
                        );
                      }
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Modified WaveScreen to take an external state
class WaveScreen extends StatefulWidget {
  final WaveScreenState state;

  const WaveScreen({Key? key, required this.state}) : super(key: key);

  @override
  State<WaveScreen> createState() => _WaveScreenState();
}

class _WaveScreenState extends State<WaveScreen> with TickerProviderStateMixin {
  // Animation controllers
  late AnimationController _controller;
  late AnimationController _secondController;
  late AnimationController _thirdController;

  // Shorthand to access the state
  WaveScreenState get state => widget.state;

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
            if (state.secondNumDice > 0) {
              state.secondAnimationStarted = true;
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
            if (state.thirdNumDice > 0) {
              state.thirdAnimationStarted = true;
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
    if (state.secondNumDice > 0 && state.secondAnimationStarted) {
      double secondSuccessPercentage = state.secondResult / state.secondNumDice;
      _animateWave(
          secondSuccessPercentage, _secondController, _updateSecondWave);
    }
  }

  // Start the third animation
  void _startThirdAnimation() {
    print("Starting third animation"); // Debug
    if (state.thirdNumDice > 0 && state.thirdAnimationStarted) {
      double thirdSuccessPercentage = state.thirdResult / state.thirdNumDice;
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
    setState(() {
      state.dragPercentage = value;
      state.firstSliderPosition =
          (state.numDice * state.dragPercentage).round();
    });
  }

  void _updateSecondWave(double value) {
    setState(() {
      state.secondDragPercentage = value;
      state.secondSliderPosition =
          (state.secondNumDice * state.secondDragPercentage).round();
    });
  }

  void _updateThirdWave(double value) {
    setState(() {
      state.thirdDragPercentage = value;
      state.thirdSliderPosition =
          (state.thirdNumDice * state.thirdDragPercentage).round();
      _updateWoundsCounter();
    });
  }

  // Update the wounds counters (both actual and expected)
  void _updateWoundsCounter() {
    // Calculate actual wounds
    int defenceFails = state.secondNumDice - state.secondSliderPosition;
    int resolveFails = state.thirdNumDice - state.thirdSliderPosition;

    setState(() {
      state.totalWounds = defenceFails + resolveFails;
    });
  }

  // Roll dice action
  void _rollDice() {
    print(
        "Roll dice pressed. NumDice: ${state.numDice}, Target: ${state.target}"); // Debug
    int result = state.rollDice(state.numDice, state.target);
    double expectedSuccesses = state.calculateExpectedSuccesses(
        state.numDice.toDouble(), state.target);

    // Call the original update function with rolled results
    _updateResults(result, state.numDice, expectedSuccesses);
  }

  // Triggered when Roll Dice button is pressed
  void _updateResults(int result, int numDice, double expectedSuccesses) {
    print("Roll dice pressed. Result: $result, NumDice: $numDice"); // Debug

    // Ensure all controllers are reset
    _controller.reset();
    _secondController.reset();
    _thirdController.reset();

    // Store current expected wounds value to preserve it
    double currentExpectedWounds = state.expectedWounds;

    setState(() {
      // Reset animation flags
      state.firstAnimationStarted = true; // First animation starts immediately
      state.secondAnimationStarted = false;
      state.thirdAnimationStarted = false;

      // Store first roll results
      state.numDice = numDice;
      state.expectedSuccesses = expectedSuccesses;
      state.firstResult = result;
      state.expectedSuccessPercentage =
          numDice > 0 ? expectedSuccesses / numDice : 0;

      // Set the second dice number to the result of the first roll (hits)
      state.secondNumDice = result;

      // Calculate expected successes for second roll based on ACTUAL first result
      state.secondExpectedSuccesses = state.calculateExpectedSuccesses(
          state.secondNumDice.toDouble(), state.secondTarget);
      state.secondExpectedSuccessPercentage = state.secondNumDice > 0
          ? state.secondExpectedSuccesses / state.secondNumDice
          : 0;

      // Perform second dice roll (Defence)
      state.secondResult =
          state.rollDice(state.secondNumDice, state.secondTarget);

      // Set the third dice number to the fails from the second roll
      state.thirdNumDice = state.secondNumDice - state.secondResult;

      // Calculate expected successes for third roll based on ACTUAL second result fails
      state.thirdExpectedSuccesses = state.calculateExpectedSuccesses(
          state.thirdNumDice.toDouble(), state.thirdTarget);
      state.thirdExpectedSuccessPercentage = state.thirdNumDice > 0
          ? state.thirdExpectedSuccesses / state.thirdNumDice
          : 0;

      // Perform third dice roll (Resolve)
      state.thirdResult = state.rollDice(state.thirdNumDice, state.thirdTarget);

      // Reset the drag percentages
      state.dragPercentage = 0.0;
      state.secondDragPercentage = 0.0;
      state.thirdDragPercentage = 0.0;

      // Reset positions
      state.firstSliderPosition = 0;
      state.secondSliderPosition = 0;
      state.thirdSliderPosition = 0;

      // Keep the expected wounds value the same as before the roll
      state.expectedWounds = currentExpectedWounds;

      // Initialize actual wounds to 0 instead of expected wounds
      state.totalWounds = 0;
    });

    // Start first animation
    double successPercentage = numDice > 0 ? result / numDice : 0;
    _animateWave(successPercentage, _controller, _updateFirstWave);
  }

  // Target selectors change handlers
  void _onFirstTargetChanged(int value) {
    setState(() {
      state.target = value;
      state.updateExpectedValues();
    });
  }

  void _onSecondTargetChanged(int value) {
    setState(() {
      state.secondTarget = value;
      state.updateExpectedValues();
    });
  }

  void _onThirdTargetChanged(int value) {
    setState(() {
      state.thirdTarget = value;
      state.updateExpectedValues();
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
    return Container(
      padding: EdgeInsets.all(24.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // Dice roller UI
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
                      initialValue: state.numDice,
                      textSize: 20,
                      onChanged: (value) => setState(() {
                        state.numDice = value;
                        state.updateExpectedValues();
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
                      initialValue: state.target,
                      textSize: 20,
                      onChanged: _onFirstTargetChanged,
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 5.0),
            WaveSlider(
              dragPercentage: state.dragPercentage,
              expectedSuccessPercentage: state.expectedSuccessPercentage,
              numDice: state.numDice,
              expectedSuccesses: state.expectedSuccesses,
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
                      initialValue: state.secondTarget,
                      textSize: 20,
                      onChanged: _onSecondTargetChanged,
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 5.0),
            WaveSlider(
              dragPercentage: state.secondDragPercentage,
              expectedSuccessPercentage: state.secondExpectedSuccessPercentage,
              numDice: state.secondNumDice,
              expectedSuccesses: state.secondExpectedSuccesses,
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
                      initialValue: state.thirdTarget,
                      textSize: 20,
                      onChanged: _onThirdTargetChanged,
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 5.0),
            WaveSlider(
              dragPercentage: state.thirdDragPercentage,
              expectedSuccessPercentage: state.thirdExpectedSuccessPercentage,
              numDice: state.thirdNumDice,
              expectedSuccesses: state.thirdExpectedSuccesses,
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
                            '${state.expectedWounds.toStringAsFixed(1)}',
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
                            '${state.totalWounds}',
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
    );
  }
}
