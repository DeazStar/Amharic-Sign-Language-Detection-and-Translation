import 'package:camera_app/features/feedback/presentation/widget/about_section.dart';
import 'package:camera_app/features/feedback/presentation/widget/control_section.dart';
import 'package:camera_app/features/feedback/presentation/widget/support_section.dart';
import 'package:flutter/material.dart';




class SettingPage extends StatelessWidget {
  
  const SettingPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            ControlSection(),
            SizedBox(height: 20),
            SupportSection(), 
            SizedBox(height: 20),
            AboutSection(),
          ],
        ),
      ),
    );
  }
}
