import 'package:flutter/material.dart';

class FaqPage extends StatelessWidget {
  final VoidCallback onBack;
  const FaqPage({super.key, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('FAQ'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: onBack,
        ),
      ),
      body: Center(
      child: Text('FAQ Page', style: TextStyle(fontSize: 24)),
    )
    );
  }
}