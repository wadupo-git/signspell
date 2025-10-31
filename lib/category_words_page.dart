import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'spelling_page.dart'; // Import your spelling page
import 'api_service.dart'; // To get the base URL if needed (though not directly used after constants)
import 'constants.dart'; // NEW: Import the constants file for BASE_API_URL

class CategoryWordsPage extends StatefulWidget {
  final String category;

  const CategoryWordsPage({Key? key, required this.category}) : super(key: key);

  @override
  _CategoryWordsPageState createState() => _CategoryWordsPageState();
}

class _CategoryWordsPageState extends State<CategoryWordsPage> {
  List<Map<String, dynamic>> _words = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchWordsByCategory();
  }

  // This function fetches words from the backend based on the category
  Future<void> _fetchWordsByCategory() async {
    try {
      // MODIFIED: Using BASE_API_URL from constants.dart
      final response = await http.get(
        Uri.parse('$BASE_API_URL/get_words_by_category.php?category=${widget.category}'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body.trim());
        if (data['success']) {
          if (mounted) {
            setState(() {
              // Cast the list to a list of maps
              _words = List<Map<String, dynamic>>.from(data['words']);
              _isLoading = false;
            });
          }
        } else {
          if (mounted) {
            setState(() {
              _isLoading = false;
              _errorMessage = data['message'] ?? 'Failed to load history.';
            });
          }
        }
      } else {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _errorMessage = 'Server error: ${response.statusCode}';
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Network error: $e';
        });
      }
    }
  }

  // This function navigates to the spelling page, passing either the video URL or the letters
  void _navigateToSpellingPage(String word, String? videoUrl) async {
    // A list of letters to fingerspell the word
    final List<String> letters = word.toUpperCase().split('');
    
    // Check if the word has a full sign video
    if (videoUrl != null && videoUrl.isNotEmpty) {
      // Navigate, providing both the fingerspelling sequence and the full sign video
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SpellingPage(
            wordLetters: letters,
            // Maps the letters (e.g., 'H', 'E', 'L', 'L', 'O') to their video filenames from the fingerspelling_letters table
            letterVideos: letters.map((l) => 'Hand_${l}.mp4').toList(), 
            // MODIFIED: Using BASE_API_URL from constants.dart
            fullSignVideoUrl: '$BASE_API_URL/video/$videoUrl', // Pass the full sign video URL
          ),
        ),
      );
    } else {
      // If no full sign video, just fingerspell the word
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SpellingPage(
            wordLetters: letters,
            letterVideos: letters.map((l) => 'Hand_${l}.mp4').toList(),
            fullSignVideoUrl: null, // Explicitly pass null
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.category.toUpperCase()}'),
        backgroundColor: Colors.blue.shade800,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(child: Text(_errorMessage))
              : ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: _words.length,
                  itemBuilder: (context, index) {
                    final word = _words[index]['word'];
                    final videoUrl = _words[index]['video_url'];
                    
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      elevation: 4,
                      child: ListTile(
                        leading: Icon(Icons.sign_language),
                        title: Text(word, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        subtitle: Text(
                          videoUrl != null ? 'Full Sign Available' : 'Fingerspelling only',
                          style: TextStyle(fontStyle: FontStyle.italic),
                        ),
                        trailing: Icon(Icons.arrow_forward_ios),
                        onTap: () => _navigateToSpellingPage(word, videoUrl),
                      ),
                    );
                  },
                ),
    );
  }
}