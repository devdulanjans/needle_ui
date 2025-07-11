import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../controller/config/image_path_setter.dart';

class StoryDetailsPage extends StatefulWidget {
  final List<Map<String, dynamic>> stories;
  final int initialIndex;

  StoryDetailsPage({
    required List<Map<String, dynamic>> stories,
    required int initialIndex,
  })  : stories = stories.where((story) => story['id'] != "0").toList(),
        initialIndex = (initialIndex >= 0 && initialIndex < stories.length)
            ? initialIndex
            : 0; // Ensure the index is valid

  @override
  _StoryDetailsPageState createState() => _StoryDetailsPageState();
}

class _StoryDetailsPageState extends State<StoryDetailsPage> {
  late PageController _pageController;
  late int _currentIndex;
  Timer? _timer;
  double _progressValue = 0.0;
  Timer? _progressTimer;
  bool _isPaused = false;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex; // Start with the validated index
    _pageController = PageController(initialPage: _currentIndex);
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel(); // Cancel any existing timer
    _progressTimer?.cancel(); // Cancel any existing progress timer

    _timer = Timer.periodic(Duration(seconds: 10), (timer) {
      if (!_isPaused) { // Check if the timer is paused
        setState(() {
          _progressValue = 1.0; // Reset progress when timer restarts
        });
        if (_currentIndex < widget.stories.length - 1) {
          _currentIndex++;
          _pageController.animateToPage(
            _currentIndex,
            duration: Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        } else {
          _timer?.cancel();
          Navigator.pop(context);
        }
      }
    });

    // Start a new timer to update the progress bar
    _progressTimer = Timer.periodic(Duration(milliseconds: 100), (timer) {
      if (!_isPaused) { // Check if the progress timer is paused
        if (_progressValue < 1.0) {
          setState(() {
            _progressValue += 0.01; // Increment progress by 1% every 100ms
          });
        } else {
          timer.cancel(); // Stop this timer when progress reaches 100%
        }
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _progressTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _pauseTimer() {
    setState(() {
      _isPaused = true;
    });
  }

  void _resumeTimer() {
    setState(() {
      _isPaused = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: PageView.builder(
        physics: NeverScrollableScrollPhysics(), // Disable swiping
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _progressValue = 0.0; // Reset progress on page change
            _currentIndex = index;
          });
          _startTimer();
        },
        itemCount: widget.stories.length,
        itemBuilder: (context, index) {
          final story = widget.stories[index];
          return GestureDetector(
            onTapDown: (_) => _pauseTimer(), // Pause timer on single tap
            onTapUp: (_) => _resumeTimer(), // Resume timer after untap
            onTapCancel: () => _resumeTimer(), // Resume timer if tap is canceled
            onLongPressStart: (_) => _pauseTimer(), // Pause timer on long press
            onLongPressEnd: (_) => _resumeTimer(), // Resume timer after long press ends
            child: Stack(
              children: [
                Container(
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    image: DecorationImage(
                      image: story['contentMediaUrl'] != null &&
                              story['contentMediaUrl'].isNotEmpty
                          ? CachedNetworkImageProvider(
                              imagePathSetter(
                                imageName: story['contentMediaUrl'],
                                imageSize: "THUMBNAIL",
                                requestingImageType: "STORY",
                                setUserId: story['userId']?.toString() ?? "0",
                              ),
                            )
                          : AssetImage("assets/profile_images.png")
                              as ImageProvider,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                Positioned(
                  top: 40,
                  left: 16,
                  right: 16,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: Icon(Icons.close, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  top: 20, // Adjust position as needed
                  left: 16,
                  right: 16,
                  child: LinearProgressIndicator(
                    value: _progressValue,
                    backgroundColor: Colors.grey[700],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Colors.purpleAccent,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
