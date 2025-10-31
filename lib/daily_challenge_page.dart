import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:video_player/video_player.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Used for fetching user email

import 'constants.dart'; // Import the constants file for BASE_API_URL

class DailyChallengePage extends StatefulWidget {
  final int userId; // NEW: Receive userId from ProfilePage

  const DailyChallengePage({Key? key, required this.userId}) : super(key: key);

  @override
  State<DailyChallengePage> createState() => _DailyChallengePageState();
}

class _DailyChallengePageState extends State<DailyChallengePage> {
  String challengeWord = "Loading...";
  late VideoPlayerController _videoController;
  Future<void>? _initializeVideoPlayerFuture;

  // NEW: Store all letters for smart selection
  List<Map<String, dynamic>> _allLetters = [];

  @override
  void initState() {
    super.initState();
    _videoController = VideoPlayerController.networkUrl(Uri.parse(''));
    _fetchChallengeWord(); // Fetch the smart challenge
  }
  
  @override
  void dispose() {
    _videoController.dispose();
    super.dispose();
  }

  // UPDATED: Function to fetch a smart daily challenge letter
  Future<void> _fetchChallengeWord() async {
    try {
      // 1. Fetch all available letters
      final allLettersResponse = await http.get(
        Uri.parse('$BASE_API_URL/get_all_letters.php'), // Use new endpoint
      );
      if (allLettersResponse.statusCode != 200) {
        throw Exception('Failed to load all letters: ${allLettersResponse.statusCode}');
      }
      final allLettersData = json.decode(allLettersResponse.body);
      if (allLettersData['success']) {
        _allLetters = List<Map<String, dynamic>>.from(allLettersData['letters']);
      } else {
        throw Exception(allLettersData['message'] ?? 'Failed to load all letters from API');
      }

      // 2. Fetch user's spelling history
      final historyResponse = await http.get(
        // Assuming get_user_details_and_history.php also provides history for a user ID
        Uri.parse('$BASE_API_URL/get_user_details_and_history.php?id=${widget.userId}'),
      );
      if (historyResponse.statusCode != 200) {
        throw Exception('Failed to load user history: ${historyResponse.statusCode}');
      }
      final historyData = json.decode(historyResponse.body);
      List<Map<String, dynamic>> userHistory = [];
      if (historyData['success'] && historyData['spelling_history'] != null) {
        userHistory = List<Map<String, dynamic>>.from(historyData['spelling_history']);
      }

      // 3. Implement "Smart" Selection Logic (Client-Side AI)
      Map<String, int> letterFrequency = {};
      // Initialize all letters to 0 frequency
      for (var letterMap in _allLetters) {
        letterFrequency[letterMap['letter'].toUpperCase()] = 0;
      }

      // Count frequency of each letter in user's spelled words
      for (var historyItem in userHistory) {
        String word = historyItem['word']?.toUpperCase() ?? '';
        for (int i = 0; i < word.length; i++) {
          String char = word[i];
          if (letterFrequency.containsKey(char)) {
            letterFrequency[char] = (letterFrequency[char] ?? 0) + 1;
          }
        }
      }

      // Find the least frequently practiced letter
      String? leastPracticedLetter;
      int minFrequency = 999999999; // A very high number

      // Convert map to list of entries to sort
      List<MapEntry<String, int>> sortedFrequencies = letterFrequency.entries.toList();
      sortedFrequencies.sort((a, b) => a.value.compareTo(b.value)); // Sort by frequency ascending

      // Pick the first one (least practiced)
      if (sortedFrequencies.isNotEmpty) {
        leastPracticedLetter = sortedFrequencies.first.key;
        minFrequency = sortedFrequencies.first.value;
      }

      // Fallback to a truly random letter if no distinct least practiced is found
      // (e.g., all have 0 frequency or if sorting logic is too simple)
      if (leastPracticedLetter == null || minFrequency > 0) { // If all practiced or no history
        // Pick from all letters randomly if no specific "least practiced"
        leastPracticedLetter = _allLetters[(DateTime.now().millisecond % _allLetters.length)]['letter'].toUpperCase();
      }

      // Find the video URL for the selected smart letter
      Map<String, dynamic>? selectedLetterData = _allLetters.firstWhere(
        (element) => element['letter'].toUpperCase() == leastPracticedLetter,
        orElse: () => _allLetters.first, // Fallback to first letter if somehow not found
      );

      if (mounted) {
        setState(() {
          challengeWord = selectedLetterData!['letter'];
          _initializeVideoPlayer('$BASE_API_URL/video/${selectedLetterData['video_url']}');
        });
      }

    } catch (e) {
      print("Error fetching smart challenge: $e");
      if (mounted) {
        setState(() {
          challengeWord = "Failed to load smart challenge";
          _initializeVideoPlayerFuture = Future.error('Failed to load video');
        });
      }
    }
  }

  void _initializeVideoPlayer(String videoUrl) {
    if (_videoController.value.isInitialized) {
      _videoController.pause();
      _videoController.dispose();
    }

    _videoController = VideoPlayerController.networkUrl(Uri.parse(videoUrl))
      ..initialize().then((_) {
        if (mounted) {
          setState(() {});
          _videoController.play();
          _videoController.setLooping(true);
        }
      }).catchError((error) {
        print("Error initializing video player: $error");
        if (mounted) {
          setState(() {
            _initializeVideoPlayerFuture = Future.error('Failed to load video');
          });
        }
      });
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color primaryColor = isDark ? Colors.blue.shade200 : Colors.blue.shade600;
    final Color textColor = isDark ? Colors.white : Colors.black87;
    final Color secondaryTextColor = isDark ? Colors.white70 : Colors.grey.shade700;
    final Color cardColor = isDark ? Colors.grey.shade800 : Colors.white;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Daily Challenge",
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(
          color: textColor,
        ),
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [Colors.black, Colors.grey.shade900]
                : [Colors.blue.shade900, Colors.white],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: 60),
                  Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    elevation: 8,
                    shadowColor: Colors.black.withOpacity(0.1),
                    color: cardColor,
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'Can you spell the letter?',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                          SizedBox(height: 16),
                          FutureBuilder(
                            future: _initializeVideoPlayerFuture,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.done && _videoController.value.isInitialized) {
                                return AspectRatio(
                                  aspectRatio: _videoController.value.aspectRatio,
                                  child: VideoPlayer(_videoController),
                                );
                              } else if (snapshot.connectionState == ConnectionState.waiting) {
                                return SizedBox(
                                  height: 200,
                                  child: Center(child: CircularProgressIndicator(color: primaryColor)),
                                );
                              } else {
                                return SizedBox(
                                  height: 200,
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.error_outline, size: 80, color: Colors.red),
                                        SizedBox(height: 8),
                                        Text("Failed to load video", style: TextStyle(color: secondaryTextColor)),
                                      ],
                                    ),
                                  ),
                                );
                              }
                            },
                          ),
                          SizedBox(height: 20),
                          Text(
                            challengeWord,
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2,
                              color: primaryColor,
                            ),
                          ),
                          SizedBox(height: 20),
                          ElevatedButton.icon(
                            onPressed: _fetchChallengeWord,
                            icon: Icon(Icons.refresh_rounded, size: 20),
                            label: Text('Get a new challenge', style: TextStyle(fontSize: 16)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              foregroundColor: isDark ? Colors.black : Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}