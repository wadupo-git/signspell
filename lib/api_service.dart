import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import 'constants.dart'; // NEW: Import the constants file for BASE_API_URL

// This function will save a word to the user's history in the database.
Future<void> saveSpelledWord(String word) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? userEmail = prefs.getString('email');

  if (userEmail == null) {
    print("User not logged in, cannot save word.");
    return;
  }

  try {
    // MODIFIED: Using BASE_API_URL from constants.dart
    final response = await http.post(
      Uri.parse('$BASE_API_URL/save_spelled_word.php'),
      headers: {"Content-Type": "application/x-www-form-urlencoded"},
      body: {
        "email": userEmail,
        "word": word,
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body.trim());
      if (data['success']) {
        print("Word '$word' saved successfully to history.");
      } else {
        print("Failed to save word: ${data['message']}");
      }
    } else {
      print("Server error: ${response.statusCode}");
    }
  } catch (e) {
    print("Error saving word: $e");
  }
}