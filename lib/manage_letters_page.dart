// manage_letters_page.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:video_player/video_player.dart';

import 'constants.dart'; // Import BASE_API_URL

class ManageLettersPage extends StatefulWidget {
  const ManageLettersPage({super.key});

  @override
  State<ManageLettersPage> createState() => _ManageLettersPageState();
}

class _ManageLettersPageState extends State<ManageLettersPage> {
  List<Map<String, dynamic>> _letters = [];
  bool _isLoading = true;
  String? _errorMessage;

  VideoPlayerController? _currentVideoPreviewController; // Controller for in-app video preview

  @override
  void initState() {
    super.initState();
    _fetchLetters();
  }

  @override
  void dispose() {
    _currentVideoPreviewController?.dispose(); // Dispose video controller
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

  Future<void> _fetchLetters() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      var url = Uri.parse("$BASE_API_URL/fetch_letters.php"); // Use BASE_API_URL
      var response = await http.get(url);

      if (!mounted) return;

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        if (data["success"] == true) {
          setState(() {
            _letters = List<Map<String, dynamic>>.from(data["letters"]);
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
      print("Error fetching letters: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _addLetter(String letter, String videoUrl, String? description) async {
    try {
      var url = Uri.parse("$BASE_API_URL/add_letter.php"); // Use BASE_API_URL
      var response = await http.post(
        url,
        headers: {"Content-Type": "application/x-www-form-urlencoded"},
        body: {
          "letter": letter, 
          "video_url": videoUrl,
          "description": description ?? '', // Pass description
        },
      );

      if (!mounted) return;
      var data = jsonDecode(response.body);
      if (data["success"] == true) {
        showMessage(data["message"], isError: false);
        _fetchLetters();
      } else {
        showMessage(data["message"]);
      }
    } catch (e) {
      if (!mounted) return; showMessage("Failed to add letter: $e"); print("Error adding letter: $e");
    }
  }

  Future<void> _updateLetter(String id, String letter, String videoUrl, String? description) async {
    try {
      var url = Uri.parse("$BASE_API_URL/update_letter.php"); // Use BASE_API_URL
      var response = await http.post(
        url,
        headers: {"Content-Type": "application/x-www-form-urlencoded"},
        body: {
          "id": id, 
          "letter": letter, 
          "video_url": videoUrl,
          "description": description ?? '', // Pass description
        },
      );
      if (!mounted) return; var data = jsonDecode(response.body);
      if (data["success"] == true) { showMessage(data["message"], isError: false); _fetchLetters(); } else { showMessage(data["message"]); }
    } catch (e) { if (!mounted) return; showMessage("Failed to update letter: $e"); print("Error updating letter: $e"); }
  }

  Future<void> _deleteLetter(String id, String letter) async {
    final bool confirm = await showDialog( context: context, builder: (BuildContext context) { return AlertDialog( title: const Text("Confirm Delete"), content: Text("Are you sure you want to delete the letter '$letter'? This action cannot be undone."), actions: <Widget>[ TextButton( onPressed: () => Navigator.of(context).pop(false), child: const Text("Cancel"), ), ElevatedButton( onPressed: () => Navigator.of(context).pop(true), style: ElevatedButton.styleFrom(backgroundColor: Colors.red), child: const Text("Delete", style: TextStyle(color: Colors.white)), ), ], ); }, ) ?? false;
    if (!confirm) return; setState(() { _isLoading = true; });
    try {
      var url = Uri.parse("$BASE_API_URL/delete_letter.php");
      var response = await http.post( url, headers: {"Content-Type": "application/x-www-form-urlencoded"}, body: {"id": id}, );
      if (!mounted) return; var data = jsonDecode(response.body);
      if (data["success"] == true) { showMessage(data["message"], isError: false); _fetchLetters(); } else { showMessage(data["message"]); }
    } catch (e) { if (!mounted) return; showMessage("Failed to delete letter: $e"); print("Error deleting letter: $e"); } finally { if (mounted) { setState(() { _isLoading = false; }); } }
  }

  Future<void> _showAddLetterDialog() async {
    final TextEditingController letterController = TextEditingController();
    final TextEditingController videoUrlController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();
    final _formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Add New Letter"),
          content: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: letterController,
                    decoration: const InputDecoration(labelText: "Letter (e.g., A, B, C)"),
                    textCapitalization: TextCapitalization.characters,
                    maxLength: 1,
                    validator: (value) {
                      if (value == null || value.isEmpty) { return 'Please enter a letter.'; }
                      if (value.length != 1 || !value.contains(RegExp(r'^[a-zA-Z0-9]$'))) { return 'Please enter a single letter or digit (A-Z, 0-9).'; }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: videoUrlController,
                    decoration: const InputDecoration(labelText: "Video Filename (e.g., Hand_A.mp4)"),
                    keyboardType: TextInputType.url,
                    validator: (value) {
                      if (value == null || value.isEmpty) { return 'Please enter a video filename.'; }
                      if (!value.endsWith('.mp4') && !value.endsWith('.MP4')) { return 'Video URL should end with .mp4'; }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: descriptionController,
                    decoration: const InputDecoration(labelText: "Description (Optional)"),
                    maxLines: 2,
                    keyboardType: TextInputType.multiline,
                  ),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            TextButton( onPressed: () => Navigator.of(context).pop(), child: const Text("Cancel"), ),
            ElevatedButton( onPressed: () { if (_formKey.currentState?.validate() ?? false) { _addLetter(letterController.text.trim().toUpperCase(), videoUrlController.text.trim(), descriptionController.text.trim().isEmpty ? null : descriptionController.text.trim()); Navigator.of(context).pop(); } }, style: ElevatedButton.styleFrom(backgroundColor: const Color.fromARGB(255, 28, 56, 105)), child: const Text("Add", style: TextStyle(color: Colors.white)), ),
          ],
        );
      },
    );
  }

  Future<void> _showUpdateLetterDialog(Map<String, dynamic> letterData) async {
    final TextEditingController letterController = TextEditingController(text: letterData['letter']);
    final TextEditingController videoUrlController = TextEditingController(text: letterData['video_url']);
    final TextEditingController descriptionController = TextEditingController(text: letterData['description']);
    final _formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Update Letter"),
          content: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField( controller: letterController, decoration: const InputDecoration(labelText: "Letter (e.g., A, B, C)"), textCapitalization: TextCapitalization.characters, maxLength: 1, validator: (value) { if (value == null || value.isEmpty) { return 'Please enter a letter.'; } if (value.length != 1 || !value.contains(RegExp(r'^[a-zA-Z0-9]$'))) { return 'Please enter a single letter or digit (A-Z, 0-9).'; } return null; }, ),
                  TextFormField( controller: videoUrlController, decoration: const InputDecoration(labelText: "Video URL"), keyboardType: TextInputType.url, validator: (value) { if (value == null || value.isEmpty) { return 'Please enter a video URL.'; } if (!value.endsWith('.mp4') && !value.endsWith('.MP4')) { return 'Video URL should end with .mp4'; } return null; }, ),
                  TextFormField( controller: descriptionController, decoration: const InputDecoration(labelText: "Description (Optional)"), maxLines: 2, keyboardType: TextInputType.multiline, ),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            TextButton( onPressed: () => Navigator.of(context).pop(), child: const Text("Cancel"), ),
            ElevatedButton( onPressed: () { if (_formKey.currentState?.validate() ?? false) { _updateLetter( letterData['id'].toString(), letterController.text.trim().toUpperCase(), videoUrlController.text.trim(), descriptionController.text.trim().isEmpty ? null : descriptionController.text.trim(), ); Navigator.of(context).pop(); } }, style: ElevatedButton.styleFrom(backgroundColor: const Color.fromARGB(255, 28, 56, 105)), child: const Text("Update", style: TextStyle(color: Colors.white)), ),
          ],
        );
      },
    );
  }

  // Function to play video preview
  Future<void> _playContentVideoPreview(String videoUrl) async {
    // 1. Dispose any existing controller to prevent resource leaks and conflicts
    _currentVideoPreviewController?.dispose();
    _currentVideoPreviewController = null; // Ensure the reference is cleared

    final fullVideoUrl = "$BASE_API_URL/video/$videoUrl";
    print("Attempting to play video from: $fullVideoUrl"); // Good for debugging

    // 2. Initialize the controller. This returns a Future<void>.
    //    We do NOT await it here so that we can pass this Future to FutureBuilder.
    _currentVideoPreviewController = VideoPlayerController.networkUrl(Uri.parse(fullVideoUrl));
    final Future<void> initializeVideoFuture = _currentVideoPreviewController!.initialize();

    // 3. Show the dialog, using FutureBuilder for its content.
    await showDialog(
      context: context,
      builder: (BuildContext dialogContext) { // Use dialogContext to avoid conflicts
        return AlertDialog(
          title: const Text("Video Preview"),
          content: FutureBuilder( // This widget builds based on the state of initializeVideoFuture
            future: initializeVideoFuture,
            builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                // The future has completed (either successfully or with an error)
                if (snapshot.hasError) {
                  // Video initialization failed
                  print("Video initialization error in dialog: ${snapshot.error}");
                  // You can also show an error message using showMessage here if desired,
                  // but for now, we'll display it within the dialog.
                  return const SizedBox(
                    height: 200, // Give it a consistent size
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
                // Video is still loading (connectionState is not done yet)
                return const SizedBox(
                  height: 200,
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

    // After the dialog has been dismissed (due to user pressing close or navigation),
    // ensure the controller is disposed if it wasn't already. This is a safeguard.
    // The `onPressed` of the TextButton already handles it, but this is for cases
    // where the dialog might be dismissed by other means (e.g., swiping down, back button).
    _currentVideoPreviewController?.pause();
    _currentVideoPreviewController?.dispose();
    _currentVideoPreviewController = null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Manage Letters"), // Title changed to reflect content
        backgroundColor: const Color.fromARGB(255, 28, 56, 105),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchLetters,
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
                              onPressed: _fetchLetters,
                              child: const Text("Retry"),
                            ),
                          ],
                        ),
                      ),
                    )
                  : _letters.isEmpty
                      ? const Center(
                          child: Text(
                            "No letters found. Click '+' to add new content.",
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          itemCount: _letters.length,
                          itemBuilder: (context, index) {
                            final letter = _letters[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              elevation: 5,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                              child: InkWell(
                                onTap: () {
                                  // Optional: Show more details or navigate to a dedicated detail page for letter
                                },
                                borderRadius: BorderRadius.circular(15),
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          CircleAvatar(
                                            radius: 30,
                                            backgroundColor: const Color.fromARGB(255, 28, 56, 105),
                                            child: Text(
                                              letter['letter'].toString().toUpperCase(),
                                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 24),
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  "Letter: ${letter['letter'] ?? 'N/A'}",
                                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black87),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  "Description: ${letter['description'] ?? 'No description'}",
                                                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                                                  maxLines: 2,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      Divider(height: 1, color: Colors.grey[300]),
                                      const SizedBox(height: 12),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.play_circle_fill, color: Colors.purple),
                                            onPressed: () => _playContentVideoPreview(letter['video_url']),
                                            tooltip: "Play Video",
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.edit, color: Colors.blue),
                                            onPressed: () => _showUpdateLetterDialog(letter),
                                            tooltip: "Edit Content",
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.delete, color: Colors.red),
                                            onPressed: () => _deleteLetter(letter['id'].toString(), letter['letter']),
                                            tooltip: "Delete Content",
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
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddLetterDialog, // FAB now only for adding letters on this page
        backgroundColor: const Color.fromARGB(255, 28, 56, 105),
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
        tooltip: "Add New Letter",
      ),
    );
  }
}