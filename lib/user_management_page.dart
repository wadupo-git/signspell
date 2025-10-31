import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import 'user_detail_page.dart';
import 'constants.dart';

class UserManagementPage extends StatefulWidget {
  const UserManagementPage({super.key});

  @override
  State<UserManagementPage> createState() => _UserManagementPageState();
}

class _UserManagementPageState extends State<UserManagementPage> {
  List<Map<String, dynamic>> _users = []; // Stores all fetched users
  List<Map<String, dynamic>> _filteredUsers = []; // Stores users after applying search filter
  bool _isLoading = true; // Tracks if data is being loaded
  String? _errorMessage; // Stores any error messages

  final TextEditingController _searchController = TextEditingController(); // Controller for the search input

  @override
  void initState() {
    super.initState();
    _fetchUsers(); // Fetch users when the page initializes
    _searchController.addListener(_filterUsers); // Listen for changes in the search input
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterUsers); // Remove listener to prevent memory leaks
    _searchController.dispose(); // Dispose the text editing controller
    super.dispose();
  }

  // Helper function to show snackbar messages
  void showMessage(String message, {bool isError = true}) {
    if (!mounted) return; // Ensure the widget is still mounted before showing SnackBar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating, // Makes the SnackBar float above the content
        duration: const Duration(seconds: 3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.only(bottom: 20, left: 20, right: 20),
      ),
    );
  }

  // Fetches all users from the backend API
  Future<void> _fetchUsers() async {
    setState(() {
      _isLoading = true; // Set loading state to true
      _errorMessage = null; // Clear any previous error messages
    });

    try {
      var url = Uri.parse("$BASE_API_URL/fetch_users.php"); // Construct the API URL
      var response = await http.get(url); // Make the HTTP GET request

      if (!mounted) return; // Check if the widget is still in the widget tree

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body); // Decode the JSON response
        if (data["success"] == true) {
          setState(() {
            _users = List<Map<String, dynamic>>.from(data["users"]); // Update the main users list
            _filterUsers(); // Apply the current search filter to the new data
          });
        } else {
          setState(() {
            _errorMessage = data["message"]; // Set error message if API returns failure
          });
        }
      } else {
        setState(() {
          _errorMessage = "Server error: ${response.statusCode}"; // Set error for non-200 status codes
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = "Failed to connect to the server: $e"; // Set error for network/parsing issues
      });
      print("Error fetching users: $e"); // Log the detailed error
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false; // Set loading state to false regardless of success or failure
        });
      }
    }
  }

  // Filters the user list based on the search query
  void _filterUsers() {
    final query = _searchController.text.toLowerCase(); // Get the search query in lowercase
    setState(() {
      _filteredUsers = _users.where((user) {
        final name = user['name']?.toLowerCase() ?? ''; // Get user name (safe from null)
        final email = user['email']?.toLowerCase() ?? ''; // Get user email (safe from null)
        return name.contains(query) || email.contains(query); // Check if name or email contains the query
      }).toList(); // Convert the iterable to a list
    });
  }

  // Handles deleting a user after confirmation
  Future<void> _deleteUser(String userId) async {
    // Show a confirmation dialog
    final bool confirm = await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Confirm Delete"),
              content: const Text("Are you sure you want to delete this user? This action cannot be undone."),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false), // Dismiss dialog, return false
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true), // Dismiss dialog, return true
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: const Text("Delete", style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        ) ??
        false; // If dialog is dismissed, result is null, so default to false

    if (!confirm) return; // If user cancels, do nothing

    setState(() {
      _isLoading = true; // Show loading indicator
    });

    try {
      var url = Uri.parse("$BASE_API_URL/delete_user.php"); // API endpoint for deleting user
      var response = await http.post(
        url,
        headers: {"Content-Type": "application/x-www-form-urlencoded"},
        body: {"id": userId}, // Pass user ID to delete
      );

      if (!mounted) return;

      var data = jsonDecode(response.body);

      if (data["success"] == true) {
        showMessage("User deleted successfully!", isError: false);
        _fetchUsers(); // Refresh the user list after deletion
      } else {
        showMessage(data["message"]);
      }
    } catch (e) {
      if (!mounted) return;
      showMessage("Failed to delete user: $e");
      print("Error deleting user: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false; // Hide loading indicator
        });
      }
    }
  }

  // Shows a dialog to add a new user
  Future<void> _showAddUserDialog() async {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();

    final bool? result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Add New User"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: "Name"),
                ),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: "Email"),
                  keyboardType: TextInputType.emailAddress,
                ),
                TextField(
                  controller: passwordController,
                  decoration: const InputDecoration(labelText: "Password"),
                  obscureText: true, // Hide password input
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                await _createUser(
                  nameController.text,
                  emailController.text,
                  passwordController.text,
                );
                if (mounted) {
                  Navigator.of(context).pop(true);
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color.fromARGB(255, 28, 56, 105)),
              child: const Text("Add User", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );

    if (result == true) {
      _fetchUsers(); // Refresh list after adding a user
    }
  }

  // Creates a new user via API
  Future<void> _createUser(String name, String email, String password) async {
    try {
      var url = Uri.parse("$BASE_API_URL/create_user.php"); // API endpoint for creating user
      var response = await http.post(
        url,
        headers: {"Content-Type": "application/x-www-form-urlencoded"},
        body: {
          "name": name,
          "email": email,
          "password": password,
        },
      );

      if (!mounted) return;

      var data = jsonDecode(response.body);

      if (data["success"] == true) {
        showMessage("User added successfully!", isError: false);
      } else {
        showMessage(data["message"]);
      }
    } catch (e) {
      if (!mounted) return;
      showMessage("Failed to add user: $e");
      print("Error adding user: $e");
    }
  }

  // Shows a dialog to update an existing user's details
  Future<void> _showUpdateUserDialog(Map<String, dynamic> user) async {
    final TextEditingController nameController = TextEditingController(text: user['name']);
    final TextEditingController emailController = TextEditingController(text: user['email']);

    final bool? result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Update User"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: "Name"),
                ),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: "Email"),
                  keyboardType: TextInputType.emailAddress,
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                await _updateUser(
                  user['id'].toString(),
                  nameController.text,
                  emailController.text,
                );
                if (mounted) {
                  Navigator.of(context).pop(true);
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color.fromARGB(255, 28, 56, 105)),
              child: const Text("Update", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );

    if (result == true) {
      _fetchUsers(); // Refresh list after update
    }
  }

  // Updates an existing user via API
  Future<void> _updateUser(String userId, String name, String email) async {
    try {
      var url = Uri.parse("$BASE_API_URL/update_user.php"); // API endpoint for updating user
      var response = await http.post(
        url,
        headers: {"Content-Type": "application/x-www-form-urlencoded"},
        body: {
          "id": userId,
          "name": name,
          "email": email,
        },
      );

      if (!mounted) return;

      var data = jsonDecode(response.body);

      if (data["success"] == true) {
        showMessage("User updated successfully!", isError: false);
      } else {
        showMessage(data["message"]);
      }
    } catch (e) {
      if (!mounted) return;
      showMessage("Failed to update user: $e");
      print("Error updating user: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("User Management"),
        backgroundColor: const Color.fromARGB(255, 28, 56, 105),
        foregroundColor: Colors.white,
        actions: [
          // Refresh button
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchUsers,
            tooltip: "Refresh Users",
          ),
          // Search bar moved to AppBar.bottom
        ],
        bottom: PreferredSize( // Search bar moved to the bottom of the AppBar
          preferredSize: const Size.fromHeight(kToolbarHeight + 10), // Adjust height as needed
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by name or email...',
                hintStyle: TextStyle(color: Colors.blue.shade100),
                prefixIcon: Icon(Icons.search, color: Colors.blue.shade100),
                filled: true,
                fillColor: const Color.fromARGB(20, 255, 255, 255), // Very light transparent white
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
              ),
              style: TextStyle(color: Colors.white),
              cursorColor: Colors.white,
            ),
          ),
        ),
      ),
      body: Container( // Main body with gradient background
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
                              onPressed: _fetchUsers,
                              child: const Text("Retry"),
                            ),
                          ],
                        ),
                      ),
                    )
                  : _filteredUsers.isEmpty && _searchController.text.isNotEmpty
                      ? const Center(
                          child: Text(
                            "No matching users found.",
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                        )
                      : _filteredUsers.isEmpty
                          ? const Center(
                              child: Text(
                                "No users found.",
                                style: TextStyle(fontSize: 18, color: Colors.grey),
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                              itemCount: _filteredUsers.length,
                              itemBuilder: (context, index) {
                                final user = _filteredUsers[index];
                                return Card(
                                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  elevation: 5,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                  child: InkWell( // Added InkWell for ripple effect on tap
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => UserDetailPage(userId: user['id'].toString()),
                                        ),
                                      );
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
                                                radius: 30, // Larger avatar
                                                backgroundColor: const Color.fromARGB(255, 28, 56, 105),
                                                backgroundImage: user['profile_picture'] != null && user['profile_picture'].isNotEmpty
                                                  ? NetworkImage("$BASE_API_URL/${user['profile_picture']}") // <--- MODIFIED LINE
                                                  : null,
                                                child: user['profile_picture'] == null || user['profile_picture'].isEmpty
                                                  ? Text(
                                                      user['name'] != null && user['name'].isNotEmpty ? user['name'][0].toUpperCase() : '?',
                                                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 24),
                                                    )
                                                  : null,
                                              ),
                                              const SizedBox(width: 16),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      user['name'] ?? 'N/A',
                                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black87),
                                                    ),
                                                    const SizedBox(height: 4),
                                                    Text(
                                                      user['email'] ?? 'N/A',
                                                      style: TextStyle(fontSize: 14, color: Colors.grey[700]),
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
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              // Display Joined Date
                                              if (user['created_at'] != null)
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        'Joined:',
                                                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                                      ),
                                                      Text(
                                                        DateFormat.yMMMd().format(DateTime.parse(user['created_at'])),
                                                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              // Display Total Words Spelled (from PHP update)
                                              if (user['total_words_spelled'] != null)
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        'Words Spelled:',
                                                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                                      ),
                                                      Text(
                                                        user['total_words_spelled'].toString(),
                                                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              Row( // Action Buttons
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  IconButton(
                                                    icon: const Icon(Icons.edit, color: Colors.blue),
                                                    onPressed: () => _showUpdateUserDialog(user),
                                                    tooltip: "Edit User",
                                                  ),
                                                  IconButton(
                                                    icon: const Icon(Icons.delete, color: Colors.red),
                                                    onPressed: () => _deleteUser(user['id'].toString()),
                                                    tooltip: "Delete User",
                                                  ),
                                                ],
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
        onPressed: _showAddUserDialog,
        backgroundColor: const Color.fromARGB(255, 28, 56, 105),
        child: const Icon(Icons.person_add, color: Colors.white),
        tooltip: 'Add New User',
      ),
    );
  }
}