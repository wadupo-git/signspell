import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter/services.dart';

import 'profile_page.dart';
import 'settings_page.dart';
import 'api_service.dart'; // Import the service to save the word

import 'constants.dart';


class SpellingPage extends StatefulWidget {
  final List<String> letterVideos;
  final List<String> wordLetters;
  final String? fullSignVideoUrl; // NEW: Optional URL for the full word sign

  const SpellingPage({
    required this.letterVideos,
    required this.wordLetters,
    this.fullSignVideoUrl, // NEW: Added to the constructor
    Key? key,
  }) : super(key: key);

  @override
  State<SpellingPage> createState() => _SpellingPageState();
}

class _SpellingPageState extends State<SpellingPage> with TickerProviderStateMixin {
  late List<String> _videoSequence;
  late List<String> _letterSequence;
  late VideoPlayerController _controller;
  int _currentIndex = 0;
  int _previousIndex = 0;
  bool _isInitialized = false;
  bool _videoEnded = false;
  double _playbackSpeed = 1.0;
  late AnimationController _fadeController;
  late AnimationController _cardSlideController;
  int _selectedIndex = 0;

  bool _isInitialPlaybackComplete = false; // To track if initial sequence is done
  bool _isFullSignPlaying = false; // NEW: To track if we are playing the full sign video

  @override
  void initState() {
    super.initState();
    _videoSequence = widget.letterVideos;
    _letterSequence = widget.wordLetters;
    _fadeController = AnimationController(vsync: this, duration: Duration(milliseconds: 500));
    _cardSlideController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _cardSlideController.forward();
    
    // --- UPDATED LOGIC: Play full sign first if available ---
    if (widget.fullSignVideoUrl != null && widget.fullSignVideoUrl!.isNotEmpty) {
      _isFullSignPlaying = true;
      _initController(videoUrl: widget.fullSignVideoUrl);
    } else {
      // If no full sign, start fingerspelling the first letter directly
      _initController();
    }
    
    // Log the word to the user's history as soon as the page is initialized
    final fullWord = _letterSequence.join();
    saveSpelledWord(fullWord);
  }

  void _initController({String? videoUrl}) {
    // Dispose of the previous controller if it exists
    if (_isInitialized && _controller.value.isInitialized) {
      _controller.removeListener(_videoListener); // Remove old listener first
      _controller.dispose();
      _isInitialized = false; // Reset initialization status
    }

    final url = videoUrl ?? "$BASE_API_URL/video/${_videoSequence[_currentIndex]}";
    
    _controller = VideoPlayerController.networkUrl(Uri.parse(url))
      ..initialize().then((_) {
        _controller.setPlaybackSpeed(_playbackSpeed);
        if (mounted) {
          setState(() {
            _isInitialized = true;
            _videoEnded = false;
          });
        }
        _controller.play();
        _fadeController.forward(from: 0);
        
        // --- UPDATED: Use a different listener based on the mode ---
        if (_isFullSignPlaying) {
          _controller.addListener(_fullSignListener);
        } else {
          _controller.addListener(_videoListener);
        }
      }).catchError((error) {
        print("Error initializing video: $error");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to load video. Please check your connection."),
            duration: Duration(seconds: 5),
          ),
        );
        if (mounted) {
          setState(() {
            _isInitialized = true;
            _videoEnded = true;
            if (!_isInitialPlaybackComplete) {
              _advanceInitialPlayback();
            }
          });
        }
      });
  }

  // NEW: Listener for the full sign video
  void _fullSignListener() {
    if (_controller.value.position >= _controller.value.duration && !_controller.value.isPlaying) {
      _controller.removeListener(_fullSignListener); // Remove this listener
      _controller.dispose(); // Dispose of the full sign video
      
      // Now, start playing the fingerspelling sequence
      if (mounted) {
        setState(() {
          _isFullSignPlaying = false;
          _currentIndex = 0; // Reset index to start from the first letter
        });
        _initController(); // Initialize with the first letter video
      }
    }
  }

  // Listener for the fingerspelling sequence
  void _videoListener() {
    if (_controller.value.position >= _controller.value.duration && !_controller.value.isPlaying) {
      if (mounted) {
        setState(() => _videoEnded = true);
      }
      if (!_isInitialPlaybackComplete) {
        _advanceInitialPlayback(); // Advance to the next video in the initial sequence
      }
    }
  }

  void _advanceInitialPlayback() {
    if (_currentIndex < _videoSequence.length - 1) {
      _changeLetter(1); // Advance to the next letter
    } else {
      // All videos in the initial sequence have played
      if (mounted) {
        setState(() {
          _isInitialPlaybackComplete = true;
          _currentIndex = 0; // Reset to 0 to allow user to start navigating from the first letter
        });
      }
      _initController(); // Reinitialize with the first letter for navigation
    }
  }

  void _changeLetter(int offset) {
    if (!_isInitialPlaybackComplete && offset != 1) return; // Only allow forward movement during initial playback

    final newIndex = _currentIndex + offset;
    if (newIndex < 0 || newIndex >= _videoSequence.length) return;

    _controller.pause();
    _controller.removeListener(_videoListener); // Remove listener before disposing
    _controller.dispose();

    if (mounted) {
      setState(() {
        _previousIndex = _currentIndex;
        _currentIndex = newIndex;
        _isInitialized = false;
        _videoEnded = false;
      });
    }

    _initController();
  }

  void _replayCurrent() {
    _controller.seekTo(Duration.zero);
    _controller.play();
    if (mounted) {
      setState(() => _videoEnded = false);
    }
  }

  void _onItemTapped(int index) {
    if (index != _selectedIndex) {
      if (mounted) {
        setState(() {
          _selectedIndex = index;
        });
      }
      Widget nextPage;
      switch (index) {
        case 1:
          nextPage = ProfilePage();
          break;
        case 2:
          nextPage = SettingsPage();
          break;
        default:
          return;
      }
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => nextPage),
      );
    }
  }

  @override
  void dispose() {
    if (_controller.value.isInitialized) {
      _controller.removeListener(_videoListener);
      _controller.removeListener(_fullSignListener);
      _controller.dispose();
    }
    _fadeController.dispose();
    _cardSlideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );

    final currentLetter = _letterSequence[_currentIndex];
    final allLetters = _letterSequence;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade50, Colors.white], // Changed from shade200 to a softer shade50
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              AppBar(
                title: Padding(
                  padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "SignSpell",
                        style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade900),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        "Sign, Aid, Spell",
                        style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                centerTitle: true,
                backgroundColor: Colors.transparent,
                elevation: 0,
                foregroundColor: Colors.black,
                automaticallyImplyLeading: false,
              ),
              SizedBox(height: 8),
              Text(
                _isFullSignPlaying
                    ? "Playing sign for the word..."
                    : (_isInitialPlaybackComplete ? "Tap the letters below to navigate." : "Playing word sequence..."),
                style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8),
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SlideTransition(
                        position: Tween<Offset>(
                                begin: const Offset(0.0, 0.1), end: Offset.zero)
                            .animate(CurvedAnimation(
                                parent: _cardSlideController,
                                curve: Curves.easeInOut)),
                        child: AnimatedBuilder(
                          animation: _cardSlideController,
                          builder: (context, child) {
                            return Opacity(
                              opacity: _cardSlideController.value,
                              child: Card(
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                                elevation: 8,
                                color: const Color(0xFFC2E8F4), // UPDATED: Softer card color
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text("Current Letter: $currentLetter",
                                              style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600)),
                                          const Text("View: Front",
                                              style: TextStyle(fontSize: 14)),
                                        ],
                                      ),
                                      const SizedBox(height: 16),
                                      AspectRatio(
                                        aspectRatio: 1.5,
                                        child: AnimatedSwitcher(
                                          duration:
                                              const Duration(milliseconds: 300),
                                          transitionBuilder: (Widget child,
                                              Animation<double> animation) {
                                            return SlideTransition(
                                              position: Tween<Offset>(
                                                begin: _currentIndex <
                                                        _previousIndex
                                                    ? const Offset(-1.0, 0.0)
                                                    : const Offset(1.0, 0.0),
                                                end: Offset.zero,
                                              ).animate(CurvedAnimation(
                                                  parent: animation,
                                                  curve: Curves.easeInOut)),
                                              child: child,
                                            );
                                          },
                                          child: AspectRatio(
                                            aspectRatio: _controller
                                                    .value.isInitialized
                                                ? _controller.value.aspectRatio
                                                : 1.0,
                                            key: ValueKey<String>(
                                                _videoSequence[_currentIndex]),
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(12.0),
                                              child: _isInitialized
                                                  ? FadeTransition(
                                                      opacity: _fadeController.drive(
                                                          CurveTween(
                                                              curve: Curves
                                                                  .easeIn)),
                                                      child: VideoPlayer(_controller),
                                                    )
                                                  : const Center(
                                                      child:
                                                          CircularProgressIndicator()),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 20),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          // Disable previous button during initial playback
                                          IconButton(
                                            onPressed: _isInitialPlaybackComplete
                                                ? () => _changeLetter(-1)
                                                : null, // Disable
                                            icon: const Icon(Icons.arrow_left,
                                                size: 30),
                                            tooltip: "Previous Letter",
                                          ),
                                          Expanded(
                                            child: SingleChildScrollView(
                                              scrollDirection: Axis.horizontal,
                                              child: Center(
                                                child: Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    ...List.generate(allLetters.length, (index) {
                                                      final letter = allLetters[index];
                                                      final isCurrent = index == _currentIndex;
                                                      return Padding(
                                                        padding:
                                                            const EdgeInsets.symmetric(
                                                                horizontal: 10.5),
                                                        // NEW: Make the letter circles tappable
                                                        child: GestureDetector(
                                                          onTap: _isInitialPlaybackComplete
                                                              ? () => _changeLetter(index - _currentIndex)
                                                              : null, // Only tappable after initial playback
                                                          child: Semantics(
                                                            label: "Letter $letter",
                                                            child: AnimatedScale(
                                                              duration: const Duration(
                                                                  milliseconds: 200),
                                                              scale: isCurrent ? 1.3 : 1.0,
                                                              child: CircleAvatar(
                                                                radius: 20,
                                                                backgroundColor: isCurrent
                                                                    ? Colors.blue.shade900
                                                                    : Colors.grey.shade300,
                                                                child: Text(
                                                                  letter,
                                                                  style: TextStyle(
                                                                    color: isCurrent
                                                                        ? Colors.white
                                                                        : Colors.black,
                                                                    fontWeight: FontWeight.bold,
                                                                    fontSize: 16,
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      );
                                                    }),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                          // Disable next button during initial playback unless it's the last letter
                                          IconButton(
                                            onPressed: _isInitialPlaybackComplete || (_currentIndex < _videoSequence.length -1 && !_isInitialPlaybackComplete)
                                                ? () => _changeLetter(1)
                                                : null, // Disable
                                            icon: const Icon(Icons.arrow_right,
                                                size: 30),
                                            tooltip: "Next Letter",
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 8),
                      SlideTransition(
                        position: Tween<Offset>(
                                begin: const Offset(0.0, 0.15),
                                end: Offset.zero)
                            .animate(CurvedAnimation(
                                parent: _cardSlideController,
                                curve: Curves.easeInOut)),
                        child: AnimatedBuilder(
                          animation: _cardSlideController,
                          builder: (context, child) {
                            return Opacity(
                              opacity: _cardSlideController.value,
                              child: Card(
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                                elevation: 4,
                                color: const Color(0xFFC2E8F4), // UPDATED: Softer card color
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            bottom: 16.0),
                                        child: Column(
                                          children: [
                                            Row(
                                              children: [
                                                const Text("Animation Speed",
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w600)),
                                                const Spacer(),
                                                Text(
                                                    "${(_playbackSpeed * 1000).round()}ms per letter"),
                                              ],
                                            ),
                                            Slider(
                                              value: _playbackSpeed,
                                              min: 0.5,
                                              max: 2.0,
                                              divisions: 6,
                                              label:
                                                  "${_playbackSpeed.toStringAsFixed(1)}x",
                                              onChanged: (value) {
                                                setState(() {
                                                  _playbackSpeed = value;
                                                });
                                                _controller
                                                    .setPlaybackSpeed(
                                                        _playbackSpeed);
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Semantics(
                                            label: _controller.value.isPlaying
                                                ? "Pause Animation"
                                                : "Play Animation",
                                            child: AnimatedScale(
                                              duration: const Duration(
                                                  milliseconds: 200),
                                              scale: _controller.value.isPlaying
                                                  ? 1.0
                                                  : 1.2,
                                              child: GestureDetector(
                                                onTap: () {
                                                  setState(() {
                                                    _controller.value.isPlaying
                                                        ? _controller.pause()
                                                        : _controller.play();
                                                  });
                                                },
                                                child: Container(
                                                  padding:
                                                      const EdgeInsets.all(12),
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color:
                                                        Colors.blue.shade700,
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Colors
                                                            .blue.shade900
                                                            .withOpacity(0.5),
                                                        spreadRadius: 2,
                                                        blurRadius: 10,
                                                        offset: const Offset(
                                                            0, 4),
                                                      ),
                                                    ],
                                                  ),
                                                  child: Icon(
                                                    _controller
                                                            .value.isPlaying
                                                        ? Icons.pause
                                                        : Icons.play_arrow,
                                                    size: 36,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(
                                              width:
                                                  24),
                                          Semantics(
                                            label: "Replay Animation",
                                            child: AnimatedScale(
                                              duration: const Duration(
                                                  milliseconds: 200),
                                              scale: 1.2,
                                              child: GestureDetector(
                                                onTap: _replayCurrent,
                                                child: Container(
                                                  padding:
                                                      const EdgeInsets.all(12),
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color:
                                                        Colors.blue.shade700,
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Colors
                                                            .blue.shade900
                                                            .withOpacity(0.5),
                                                        spreadRadius: 2,
                                                        blurRadius: 10,
                                                        offset: const Offset(
                                                            0, 4),
                                                      ),
                                                    ],
                                                  ),
                                                  child: const Icon(
                                                    Icons.replay,
                                                    size: 36,
                                                    color: Colors.white,
                                                  ),
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
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              BottomNavigationBar(
                items: [
                  BottomNavigationBarItem(
                      icon: const Icon(Icons.translate, size: 28),
                      label: "Generate"),
                  BottomNavigationBarItem(
                      icon: const Icon(Icons.person, size: 28), label: "Profile"),
                  BottomNavigationBarItem(
                      icon: const Icon(Icons.settings, size: 28),
                      label: "Settings"),
                ],
                currentIndex: _selectedIndex,
                selectedItemColor: Colors.blue.shade700,
                unselectedItemColor: Colors.blueGrey.shade400,
                selectedLabelStyle:
                    const TextStyle(fontWeight: FontWeight.bold),
                unselectedLabelStyle:
                    const TextStyle(fontWeight: FontWeight.w500),
                backgroundColor: Colors.transparent,
                elevation: 0,
                onTap: _onItemTapped,
              ),
            ],
          ),
        ),
      ),
    );
  }
}