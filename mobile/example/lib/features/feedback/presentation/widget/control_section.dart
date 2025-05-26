// lib/features/settings/presentation/components/control_section.dart
// Or any other appropriate path like lib/features/theme/presentation/components/

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http; // For API calls
import 'dart:convert'; // For jsonEncode/Decode

// Assuming ThemeProvider is in this path, adjust if necessary
import '../../../theme/presenation/provider/theme_provider.dart';
// Assuming FeedbackListPage is in this path, adjust if necessary
import '../../../feedback/presentation/page/feedback_list_page.dart';


class ControlSection extends StatefulWidget {
  const ControlSection({super.key});

  @override
  State<ControlSection> createState() => _ControlSectionState();
}

class _ControlSectionState extends State<ControlSection> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isAdminLoggingIn = false;

  // TODO: Replace with your actual admin login endpoint
  final String _adminLoginUrl = "http://18.188.141.168:8000/admin/login"; // Placeholder
  static const String _accessTokenKey = 'admin_access_token';


  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleAdminLogin(BuildContext dialogContext) async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter email and password.'), backgroundColor: Colors.orangeAccent),
      );
      return;
    }

    // This setState is for the dialog's StatefulBuilder to show loading
    // It's passed as a parameter to the dialog builder
    // For the main page loading state, use the _isAdminLoggingIn instance variable
    (dialogContext as Element).markNeedsBuild(); // Force dialog to rebuild if using StatefulBuilder for loading

    setState(() { _isAdminLoggingIn = true; });


    try {
      // TODO: Replace MOCK with actual API call
      final response = await http.post(
        Uri.parse(_adminLoginUrl),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'username' : _emailController.text,
          'password': _passwordController.text,
        });
      //
      bool loginSuccess = response.statusCode == 200;
      String? accessToken;
      String message;
      if (loginSuccess) {
        accessToken = jsonDecode(response.body)['access_token'];
        message = 'Login Successful!';
      } else {
        print("Login failed with status code: ${response.statusCode}" );
        print("Response body: ${response.body}");
        message = jsonDecode(response.body)['detail'] ?? 'Login Failed. Status: ${response.statusCode}';
      }

      // // --- MOCK ---
      // await Future.delayed(const Duration(seconds: 1)); // Simulate network delay
      // bool loginSuccess = _emailController.text == "admin@example.com" && _passwordController.text == "password";
      // String? accessToken = loginSuccess ? "mock_access_token_for_shared_prefs_123" : null;
      // String message = loginSuccess ? "Login Successful!" : "Invalid credentials (mocked)";
      // // --- END MOCK ---

      if (loginSuccess && accessToken != null && mounted) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString(_accessTokenKey, accessToken);
        
        String access = accessToken;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: Colors.green),
        );
        Navigator.of(dialogContext).pop(); // Close the dialog
        Navigator.of(context).push(MaterialPageRoute( // Use context from ControlSection
          builder: (_) => FeedbackListPage(accessToken: access,), // No longer pass token directly
        ));
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: Colors.redAccent),
        );
      }
    } catch (e) {
      debugPrint("Admin login error: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An error occurred during login: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() { _isAdminLoggingIn = false; });
        // Also ensure dialog's loading state is reset if it's still visible
         (dialogContext as Element).markNeedsBuild();
      }
    }
  }

  void _showAdminLoginDialog() {
    _emailController.clear();
    _passwordController.clear();
    // Reset _isAdminLoggingIn state before showing dialog, in case it was stuck from a previous attempt
    // This is important if the dialog can be dismissed without completing login
    if (_isAdminLoggingIn) {
      setState(() {
        _isAdminLoggingIn = false;
      });
    }

    showDialog(
      context: context,
      barrierDismissible: !_isAdminLoggingIn,
      builder: (BuildContext dialogContext) {
        // Use StatefulBuilder to manage the dialog's own state for the loading indicator on the button
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Admin Login'),
              content: SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    TextField(
                      controller: _emailController,
                      decoration: const InputDecoration(hintText: "Username", icon: Icon(Icons.verified_user)),
                      keyboardType: TextInputType.emailAddress,
                      enabled: !_isAdminLoggingIn,
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _passwordController,
                      decoration: const InputDecoration(hintText: "Password", icon: Icon(Icons.lock)),
                      obscureText: true,
                      enabled: !_isAdminLoggingIn,
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: _isAdminLoggingIn ? null : () {
                    Navigator.of(dialogContext).pop();
                  },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: _isAdminLoggingIn ? null : () async {
                     // Update dialog's local state for loading indicator on button
                    setDialogState(() {
                      // _isAdminLoggingIn is already true from the parent state,
                      // but this ensures the button itself reflects it if needed.
                    });
                    await _handleAdminLogin(dialogContext); // Pass dialogContext
                    // Reset dialog's local state after attempt, if dialog is still visible
                    if (Navigator.canPop(dialogContext)) {
                        setDialogState(() {
                           // _isAdminLoggingIn will be reset by _handleAdminLogin's finally block
                           // which will trigger a rebuild of the parent, and thus the dialog.
                        });
                    }
                  },
                  child: _isAdminLoggingIn
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Login'),
                ),
              ],
            );
          }
        );
      },
    ).then((_){
        // This 'then' block executes after the dialog is popped.
        // Ensure the main page's loading state is reset if the dialog was dismissed
        // by tapping outside or pressing the back button, and an async operation was ongoing.
        if (mounted && _isAdminLoggingIn) {
            setState(() {
                _isAdminLoggingIn = false;
            });
        }
    });
  }


  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final systemBrightness = MediaQuery.platformBrightnessOf(context);
    final isUsingSystem = themeProvider.themeMode == ThemeMode.system;

    final isDark = isUsingSystem
        ? systemBrightness == Brightness.dark
        : themeProvider.themeMode == ThemeMode.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text('CONTROLS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        ),
        const SizedBox(height: 10),
        ListTile(
          leading: const Icon(Icons.brightness_6), // Changed icon for theme
          title: const Text('Dark Mode'),
          trailing: Switch(
            value: isDark,
            onChanged: (value) {
              themeProvider.toggle(value); // Assuming toggleTheme(bool isDark)
            },
          ),
        ),
        Padding( // Added padding for better layout
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            children: [
              const Icon(Icons.format_size), // Changed icon for font size
              const SizedBox(width: 16),
              const Text('Font Size'),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.remove_circle_outline), // Changed icon
                onPressed: () {
                  themeProvider.setFontSize(
                      (themeProvider.fontSize - 1).clamp(12.0, 24.0));
                },
                tooltip: "Decrease font size",
              ),
              Text(themeProvider.fontSize.toInt().toString(), style: const TextStyle(fontSize: 16)),
              IconButton(
                icon: const Icon(Icons.add_circle_outline), // Changed icon
                onPressed: () {
                  themeProvider.setFontSize(
                      (themeProvider.fontSize + 1).clamp(12.0, 24.0));
                },
                tooltip: "Increase font size",
              ),
            ],
          ),
        ),
        ListTile(
          leading: const Icon(Icons.admin_panel_settings),
          title: const Text('Admin Login'),
          onTap: _showAdminLoginDialog, // Call the dialog display method
        ),
      ],
    );
  }
}
