import 'package:flutter/material.dart';

class TermsAndConditionsPage extends StatelessWidget {
  const TermsAndConditionsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Terms and Conditions"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: const [
            Text(
              "Welcome to Our App!",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              "By using this application, you agree to the following terms and conditions. "
              "Please read them carefully.",
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Text(
              "1. Acceptance of Terms",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              "By accessing or using the app, you agree to be bound by these terms.",
            ),
            SizedBox(height: 8),
            Text(
              "2. Privacy",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              "Your privacy is important to us. We do not share your data with third parties.",
            ),
            SizedBox(height: 8),
            Text(
              "3. User Responsibilities",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              "You are responsible for the content you share through the app.",
            ),
            SizedBox(height: 8),
            Text(
              "4. Changes to Terms",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              "We reserve the right to modify these terms at any time.",
            ),
            SizedBox(height: 8),
            Text(
              "5. Contact Us",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              "If you have any questions about these terms, please contact our support team.",
            ),
          ],
        ),
      ),
    );
  }
}
