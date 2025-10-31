import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import 'profile_page.dart';
import 'settings_page.dart';
import 'spelling_page.dart';
import 'category_words_page.dart';
import 'constants.dart';
// Removed: import 'quiz_page.dart'; // REMOVED: QuizPage import

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  TextEditingController _textController = TextEditingController();

  stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  String _lastWords = ''; // Stores the recognized words

  @override
  void initState() {
    super.initState();
  }

  void _onItemTapped(int index) {
    if (index != _selectedIndex) {
      Widget nextPage;
      switch (index) {
        case 1:
          nextPage = ProfilePage();
          break;
        case 2:
          nextPage = SettingsPage();
          break;
        default:
          nextPage = HomePage();
      }
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => nextPage),
      );
    }
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Error"),
        content: Text(message),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text("OK"))],
      ),
    );
  }

  // Robust _listen function for Speech-to-Text
  void _listen() async {
    if (!_speech.isAvailable) {
      bool hasSpeech = await _speech.initialize(
        onStatus: (status) => print('Speech status: $status'),
        onError: (errorNotification) => print('Speech error: $errorNotification'),
      );
      if (!mounted) return;
      if (!hasSpeech) {
        _showErrorDialog(context, 'Speech recognition not available or permission denied.');
        setState(() {
          _isListening = false;
        });
        return;
      }
    }

    if (_isListening) {
      _speech.stop();
      setState(() {
        _isListening = false;
      });
    } else {
      if (_speech.isAvailable) {
        setState(() {
          _isListening = true;
          _textController.clear();
          _lastWords = '';
        });
        _speech.listen(
          onResult: (result) {
            setState(() {
              _lastWords = result.recognizedWords;
              _textController.text = _lastWords;
            });
            if (result.finalResult) {
              _generateSigns();
              setState(() {
                _isListening = false;
              });
            }
          },
          listenFor: Duration(seconds: 10),
          pauseFor: Duration(seconds: 3),
          // localeId: 'en_US',
        );
      } else {
        _showErrorDialog(context, 'Speech service not ready. Please try again.');
      }
    }
  }

  Future<void> _generateSigns() async {
    final word = _textController.text.trim();
    if (word.isEmpty) {
      _showErrorDialog(context, "No text to generate signs for.");
      return;
    }

    final response = await http.get(
      Uri.parse("$BASE_API_URL/get_letters.php?word=$word"),
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      if (json['success']) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SpellingPage(
              letterVideos: List<String>.from(json['videos']),
              wordLetters: List<String>.from(json['letters']),
              fullSignVideoUrl: null,
            ),
          ),
        );
      } else {
        _showErrorDialog(context, json['message']);
      }
    } else {
      _showErrorDialog(context, 'Server error: ${response.statusCode}');
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    _speech.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/home_bg.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "SignSpell",
                      style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade900),
                    ),
                    Text(
                      "Sign, Aid, Spell",
                      style:
                          TextStyle(fontSize: 14, color: Colors.blueGrey.shade600),
                    ),
                    SizedBox(height: 40),
                    Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 12,
                            spreadRadius: 3,
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Text(
                            "Sign Spell",
                            style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue.shade900),
                          ),
                          Text(
                            "Enter any text to see its finger spelling representation",
                            style: TextStyle(
                                fontSize: 14, color: Colors.grey.shade800),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 20),
                          TextField(
                            controller: _textController,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.grey[100],
                              labelText: "Enter text to spell",
                              labelStyle:
                                  TextStyle(color: Colors.blueGrey.shade700),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.blue.shade600),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 16),
                              hintText: "Type anything...",
                              hintStyle:
                                  TextStyle(color: Colors.blueGrey.shade500),
                              // Microphone icon as suffix
                              suffixIcon: IconButton(
                                icon: Icon(_isListening ? Icons.mic_off : Icons.mic),
                                onPressed: _listen,
                                color: _isListening ? Colors.red : Colors.blue.shade600,
                              ),
                            ),
                          ),
                          SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: _generateSigns,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color.fromARGB(255, 28, 56, 105),
                              minimumSize: Size(double.infinity, 50),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                              elevation: 6,
                              shadowColor: Colors.blue.shade300,
                            ),
                            child: Text(
                              "Generate Signs",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // --- Category selection section ---
                    SizedBox(height: 60),
                    Text(
                      "Or learn by category",
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade900),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 20),
                    Wrap(
                      spacing: 16.0,
                      runSpacing: 16.0,
                      alignment: WrapAlignment.center,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => CategoryWordsPage(category: 'greetings')),
                            );
                          },
                          icon: Icon(Icons.waving_hand),
                          label: Text('Greetings', style: TextStyle(fontSize: 16)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue.shade600,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => CategoryWordsPage(category: 'family')),
                            );
                          },
                          icon: Icon(Icons.family_restroom),
                          label: Text('Family', style: TextStyle(fontSize: 16)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.pink.shade400,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => CategoryWordsPage(category: 'numbers')),
                            );
                          },
                          icon: Icon(Icons.onetwothree),
                          label: Text('Numbers', style: TextStyle(fontSize: 16)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green.shade600,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                        // Removed: Quiz Button
                      ],
                    ),
                    SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container( // Wrap the BottomNavigationBar with a Container
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(          // Add rounded corners to the top
            topRight: Radius.circular(16),
            topLeft: Radius.circular(16),
          ),
          boxShadow: [                         // Add a shadow for the floating effect
            BoxShadow(
              color: Colors.black38,
              spreadRadius: 0,
              blurRadius: 10,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.only(          // Clip the rounded corners
            topRight: Radius.circular(16),
            topLeft: Radius.circular(16),
          ),
          child: BottomNavigationBar(           // The actual BottomNavigationBar
            items: [
              BottomNavigationBarItem(
                  icon: Icon(Icons.translate, size: 28), label: "Generate"),
              BottomNavigationBarItem(
                  icon: Icon(Icons.person, size: 28), label: "Profile"),
              BottomNavigationBarItem(
                  icon: Icon(Icons.settings, size: 28), label: "Settings"),
            ],
            currentIndex: _selectedIndex,
            selectedItemColor: Colors.blue.shade700,
            unselectedItemColor: Colors.blueGrey.shade400,
            selectedLabelStyle: TextStyle(fontWeight: FontWeight.bold),
            unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w500),
            backgroundColor: const Color(0xFFF8F8F8), // Changed to off-white
            elevation: 0,           // Remove the default elevation
            onTap: _onItemTapped,
          ),
        ),
      ),
    );
  }
}