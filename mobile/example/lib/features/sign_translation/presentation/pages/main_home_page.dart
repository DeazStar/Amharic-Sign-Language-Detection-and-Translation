import 'package:camera_app/features/feedback/presentation/widget/custom_button.dart';
import 'package:camera_app/features/reference/presentation/reference_page.dart';
import 'package:camera_app/features/sign_translation/presentation/pages/camera_page.dart';
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
        child: Column(
          children: [
            SizedBox(
                width: MediaQuery.of(context).size.width * 0.7,
              height: 50,
              child: CustomButton(label: "Camera", onPressed: () {
                // Navigate to the camera page
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>const CameraPage(), // Replace with your camera page
                  ),
                );
              }),
            ),
            SizedBox(
                width: MediaQuery.of(context).size.width * 0.7,
              height: 50,
              child: CustomButton(label: "Reference", onPressed: () {
                // Navigate to the camera page
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>const ReferencePage(), // Replace with your camera page
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}