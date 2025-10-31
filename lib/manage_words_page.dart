// manage_words_page.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:video_player/video_player.dart';

import 'constants.dart'; // Import BASE_API_URL

class ManageWordsPage extends StatefulWidget {
  const ManageWordsPage({super.key});

  @override
  State<ManageWordsPage> createState() => _ManageWordsPageState();
}

class _ManageWordsPageState extends State<ManageWordsPage> {
  List<Map<String, dynamic>> _words = []; // Original flat list of words
  Map<String, List<Map<String, dynamic>>> _groupedWords = {}; // NEW: Words grouped by category
  bool _isLoading = true;
  String? _errorMessage;

  VideoPlayerController? _currentVideoPreviewController;

  final List<String> _categories = ['greetings', 'family', 'numbers']; // Match your ENUM values

  @override
  void initState() {
    super.initState();
    _fetchWords();
  }

  @override
  void dispose() {
    _currentVideoPreviewController?.dispose();
    super.dispose();
  }

  void showMessage(String message, {bool isError = true}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.only(bottom: 20, left: 20, right: 20),
      ),
    );
  }

  Future<void> _fetchWords() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      var url = Uri.parse("$BASE_API_URL/fetch_all_words.php");
      var response = await http.get(url);

      if (!mounted) return;

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        if (data["success"] == true) {
          List<Map<String, dynamic>> fetchedWords = List<Map<String, dynamic>>.from(data["words"]);
          Map<String, List<Map<String, dynamic>>> tempGroupedWords = {};

          // Initialize grouped words map with all defined categories
          for (var category in _categories) {
            tempGroupedWords[category] = [];
          }

          // Group fetched words by category
          for (var word in fetchedWords) {
            String category = word['category']?.toString() ?? 'unknown';
            if (tempGroupedWords.containsKey(category)) {
              tempGroupedWords[category]!.add(word);
            } else {
              // Handle words with categories not in _categories list (optional)
              print("Warning: Word '${word['word']}' has unrecognized category: '$category'");
            }
          }

          setState(() {
            _words = fetchedWords; // Keep the flat list if needed elsewhere
            _groupedWords = tempGroupedWords; // Update the grouped list
          });
        } else {
          setState(() {
            _errorMessage = data["message"];
          });
        }
      } else {
        setState(() {
          _errorMessage = "Server error: ${response.statusCode}";
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = "Failed to connect to the server: $e";
      });
      print("Error fetching words: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _addWord(String word, String category, String? videoUrl) async {
    try {
      var url = Uri.parse("$BASE_API_URL/add_word.php");
      var response = await http.post(
        url,
        headers: {"Content-Type": "application/x-www-form-urlencoded"},
        body: {"word": word, "category": category, "video_url": videoUrl ?? ''},
      );
      if (!mounted) return; var data = jsonDecode(response.body);
      if (data["success"] == true) { showMessage(data["message"], isError: false); _fetchWords(); } else { showMessage(data["message"]); }
    } catch (e) { if (!mounted) return; showMessage("Failed to add word: $e"); print("Error adding word: $e"); }
  }

  Future<void> _updateWord(String id, String word, String category, String? videoUrl) async {
    try {
      var url = Uri.parse("$BASE_API_URL/update_word.php");
      var response = await http.post(
        url,
        headers: {"Content-Type": "application/x-www-form-urlencoded"},
        body: {"id": id, "word": word, "category": category, "video_url": videoUrl ?? ''},
      );
      if (!mounted) return; var data = jsonDecode(response.body);
      if (data["success"] == true) { showMessage(data["message"], isError: false); _fetchWords(); } else { showMessage(data["message"]); }
    } catch (e) { if (!mounted) return; showMessage("Failed to update word: $e"); print("Error updating word: $e"); }
  }

  Future<void> _deleteWord(String id, String word) async {
    final bool confirm = await showDialog( context: context, builder: (BuildContext context) { return AlertDialog( title: const Text("Confirm Delete"), content: Text("Are you sure you want to delete the word '$word'? This action cannot be undone."), actions: <Widget>[ TextButton( onPressed: () => Navigator.of(context).pop(false), child: const Text("Cancel"), ), ElevatedButton( onPressed: () => Navigator.of(context).pop(true), style: ElevatedButton.styleFrom(backgroundColor: Colors.red), child: const Text("Delete", style: TextStyle(color: Colors.white)), ), ], ); }, ) ?? false;
    if (!confirm) return; setState(() { _isLoading = true; });
    try {
      var url = Uri.parse("$BASE_API_URL/delete_word.php");
      var response = await http.post( url, headers: {"Content-Type": "application/x-www-form-urlencoded"}, body: {"id": id}, );
      if (!mounted) return; var data = jsonDecode(response.body);
      if (data["success"] == true) { showMessage(data["message"], isError: false); _fetchWords(); } else { showMessage(data["message"]); }
    } catch (e) { if (!mounted) return; showMessage("Failed to delete word: $e"); print("Error deleting word: $e"); } finally { if (mounted) { setState(() { _isLoading = false; }); } }
  }

  Future<void> _showAddWordDialog() async {
    final TextEditingController wordController = TextEditingController();
    final TextEditingController videoUrlController = TextEditingController();
    String? selectedCategory = _categories.first;
    final _formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Add New Word"),
          content: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: wordController,
                    decoration: const InputDecoration(labelText: "Word"),
                    textCapitalization: TextCapitalization.words,
                    validator: (value) { if (value == null || value.isEmpty) { return 'Please enter a word.'; } return null; },
                  ),
                  DropdownButtonFormField<String>(
                    value: selectedCategory,
                    decoration: const InputDecoration(labelText: "Category"),
                    items: _categories.map((String category) { return DropdownMenuItem<String>( value: category, child: Text(_capitalize(category)), ); }).toList(),
                    onChanged: (String? newValue) { if (newValue != null) { selectedCategory = newValue; } },
                    validator: (value) { if (value == null || value.isEmpty) { return 'Please select a category.'; } return null; },
                  ),
                  TextFormField(
                    controller: videoUrlController,
                    decoration: const InputDecoration(labelText: "Video Filename (Optional, e.g., hello.mp4)"),
                    keyboardType: TextInputType.url,
                    validator: (value) {
                      if (value != null && value.isNotEmpty && !value.endsWith('.mp4') && !value.endsWith('.MP4')) { return 'Video URL should be empty or end with .mp4'; }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            TextButton( onPressed: () => Navigator.of(context).pop(), child: const Text("Cancel"), ),
            ElevatedButton( onPressed: () { if (_formKey.currentState?.validate() ?? false) { _addWord(wordController.text.trim().toLowerCase(), selectedCategory!, videoUrlController.text.trim().isEmpty ? null : videoUrlController.text.trim()); Navigator.of(context).pop(); } }, style: ElevatedButton.styleFrom(backgroundColor: const Color.fromARGB(255, 28, 56, 105)), child: const Text("Add", style: TextStyle(color: Colors.white)), ),
          ],
        );
      },
    );
  }

  Future<void> _showUpdateWordDialog(Map<String, dynamic> wordData) async {
    final TextEditingController wordController = TextEditingController(text: wordData['word']);
    final TextEditingController videoUrlController = TextEditingController(text: wordData['video_url']);
    String? selectedCategory = wordData['category'];
    final _formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Update Word"),
          content: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: wordController,
                    decoration: const InputDecoration(labelText: "Word"),
                    textCapitalization: TextCapitalization.words,
                    validator: (value) { if (value == null || value.isEmpty) { return 'Please enter a word.'; } return null; },
                  ),
                  DropdownButtonFormField<String>(
                    value: selectedCategory,
                    decoration: const InputDecoration(labelText: "Category"),
                    items: _categories.map((String category) { return DropdownMenuItem<String>( value: category, child: Text(_capitalize(category)), ); }).toList(),
                    onChanged: (String? newValue) { if (newValue != null) { selectedCategory = newValue; } },
                    validator: (value) { if (value == null || value.isEmpty) { return 'Please select a category.'; } return null; },
                  ),
                  TextFormField(
                    controller: videoUrlController,
                    decoration: const InputDecoration(labelText: "Video Filename (Optional)"),
                    keyboardType: TextInputType.url,
                    validator: (value) { if (value != null && value.isNotEmpty && !value.endsWith('.mp4') && !value.endsWith('.MP4')) { return 'Video URL should be empty or end with .mp4'; } return null; },
                  ),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            TextButton( onPressed: () => Navigator.of(context).pop(), child: const Text("Cancel"), ),
            ElevatedButton( onPressed: () { if (_formKey.currentState?.validate() ?? false) { _updateWord( wordData['id'].toString(), wordController.text.trim().toLowerCase(), selectedCategory!, videoUrlController.text.trim().isEmpty ? null : videoUrlController.text.trim(), ); Navigator.of(context).pop(); } }, style: ElevatedButton.styleFrom(backgroundColor: const Color.fromARGB(255, 28, 56, 105)), child: const Text("Update", style: TextStyle(color: Colors.white)), ),
          ],
        );
      },
    );
  }

  String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1);
  }

  // --- UPDATED _playContentVideoPreview FUNCTION ---
  Future<void> _playContentVideoPreview(String videoUrl) async {
    _currentVideoPreviewController?.dispose(); // Dispose previous if any
    _currentVideoPreviewController = null; // Clear reference

    final fullVideoUrl = "$BASE_API_URL/video/$videoUrl";
    print("Attempting to play video from: $fullVideoUrl"); // Debugging

    // Initialize controller. This returns a Future<void>.
    // We do NOT await it here so that we can pass this Future to FutureBuilder.
    _currentVideoPreviewController = VideoPlayerController.networkUrl(Uri.parse(fullVideoUrl));
    final Future<void> initializeVideoFuture = _currentVideoPreviewController!.initialize();

    await showDialog(
      context: context,
      builder: (BuildContext dialogContext) { // Use dialogContext to avoid conflicts
        return AlertDialog(
          title: const Text("Video Preview"),
          content: FutureBuilder( // Use FutureBuilder to react to initialization state
            future: initializeVideoFuture,
            builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                // The future has completed (either successfully or with an error)
                if (snapshot.hasError) {
                  // Video initialization failed
                  print("Video initialization error in dialog: ${snapshot.error}");
                  return const SizedBox(
                    height: 200, // Consistent size for content
                    width: 300,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error_outline, color: Colors.red, size: 40),
                          SizedBox(height: 10),
                          Text("Failed to load video.", textAlign: TextAlign.center),
                          Text("Check URL and file existence.", style: TextStyle(fontSize: 12, color: Colors.grey), textAlign: TextAlign.center),
                        ],
                      ),
                    ),
                  );
                } else {
                  // Video initialized successfully, play it
                  _currentVideoPreviewController!.play();
                  return AspectRatio(
                    aspectRatio: _currentVideoPreviewController!.value.aspectRatio,
                    child: VideoPlayer(_currentVideoPreviewController!),
                  );
                }
              } else {
                // Video is still loading
                return const SizedBox(
                  height: 200, // Consistent size for content
                  width: 300,
                  child: Center(child: CircularProgressIndicator()),
                );
              }
            },
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Dismiss the dialog
                // Dispose controller when the dialog is explicitly closed by the user
                _currentVideoPreviewController?.pause();
                _currentVideoPreviewController?.dispose();
                _currentVideoPreviewController = null; // Clear the reference
              },
              child: const Text("Close"),
            ),
          ],
        );
      },
    );

    // After the dialog has been dismissed, ensure the controller is disposed as a safeguard.
    _currentVideoPreviewController?.pause();
    _currentVideoPreviewController?.dispose();
    _currentVideoPreviewController = null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Manage Words"),
        backgroundColor: const Color.fromARGB(255, 28, 56, 105),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchWords,
            tooltip: "Refresh Content",
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade50, Colors.white],
          ),
        ),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _errorMessage != null
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error_outline, color: Colors.red, size: 50),
                            const SizedBox(height: 10),
                            Text(
                              "Error: $_errorMessage",
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.red, fontSize: 16),
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: _fetchWords,
                              child: const Text("Retry"),
                            ),
                          ],
                        ),
                      ),
                    )
                  : _words.isEmpty
                      ? const Center(
                          child: Text(
                            "No words found. Click '+' to add new content.",
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          itemCount: _categories.length, // Build a section for each category
                          itemBuilder: (context, categoryIndex) {
                            final categoryName = _categories[categoryIndex];
                            final wordsInCategory = _groupedWords[categoryName] ?? [];

                            return Card(
                              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              elevation: 5,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                              child: ExpansionTile( // ExpansionTile for categories
                                title: Text(
                                  _capitalize(categoryName),
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.black87),
                                ),
                                trailing: Text(
                                  '${wordsInCategory.length} words',
                                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                                ),
                                children: [
                                  Divider(height: 1, thickness: 1, color: Colors.grey[200]),
                                  if (wordsInCategory.isEmpty)
                                    Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                                      child: Text(
                                        "No words in this category yet.",
                                        style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey[600]),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ...wordsInCategory.map((word) {
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                                      child: Card( // Inner card for each word
                                        elevation: 2,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                        child: InkWell(
                                          onTap: () { /* Optional: Details for individual word */ },
                                          borderRadius: BorderRadius.circular(10),
                                          child: Padding(
                                            padding: const EdgeInsets.all(12.0),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    CircleAvatar(
                                                      radius: 20,
                                                      backgroundColor: word['video_url'] != null && word['video_url'].isNotEmpty ? Colors.deepOrange : Colors.grey,
                                                      child: Text(
                                                        word['word'].toString()[0].toUpperCase(),
                                                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 12),
                                                    Expanded(
                                                      child: Text(
                                                        word['word'] ?? 'N/A',
                                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 8),
                                                Text(
                                                  word['video_url'] != null && word['video_url'].isNotEmpty ? 'Full Sign Available' : 'Fingerspelling Only',
                                                  style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: Colors.grey[600]),
                                                ),
                                                Align(
                                                  alignment: Alignment.bottomRight,
                                                  child: Row(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      if (word['video_url'] != null && word['video_url'].isNotEmpty)
                                                        IconButton(
                                                          icon: const Icon(Icons.play_circle_fill, color: Colors.purple),
                                                          onPressed: () => _playContentVideoPreview(word['video_url']),
                                                          tooltip: "Play Video",
                                                        ),
                                                      IconButton(
                                                        icon: const Icon(Icons.edit, color: Colors.blue),
                                                        onPressed: () => _showUpdateWordDialog(word),
                                                        tooltip: "Edit Word",
                                                      ),
                                                      IconButton(
                                                        icon: const Icon(Icons.delete, color: Colors.red),
                                                        onPressed: () => _deleteWord(word['id'].toString(), word['word']),
                                                        tooltip: "Delete Word",
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ],
                              ),
                            );
                          },
                        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddWordDialog, // FAB for adding words
        backgroundColor: const Color.fromARGB(255, 28, 56, 105),
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
        tooltip: "Add New Word",
      ),
    );
  }
}