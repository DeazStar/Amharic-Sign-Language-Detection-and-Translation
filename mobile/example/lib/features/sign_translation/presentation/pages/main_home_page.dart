import 'package:camera_app/features/feedback/presentation/widget/custom_button.dart';
import 'package:flutter/material.dart';
import '../pages/home_page.dart';

class MainHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Page'),
      ),
      body: Center(
        child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.7,
          height: 50,
          child: CustomButton(label: "Camera", onPressed: () {
            // Navigate to the camera page
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>const HomePage(), // Replace with your camera page
              ),
            );
          }),
        ),
      ),
    );
  }
}