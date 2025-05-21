import 'package:camera_app/features/feedback/presentation/page/about_us_page.dart';
import 'package:camera_app/features/feedback/presentation/page/terms_and_conditions_page.dart';
import 'package:flutter/material.dart';

class AboutSection extends StatelessWidget {
  const AboutSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('ABOUT', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        ListTile(
          leading: Icon(Icons.description),
          title: Text('Terms and Conditions'),
          onTap: () {
            Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TermsAndConditionsPage(
                
              ),
            ),
          );
          },
        ),
        ListTile(
          leading: Icon(Icons.info_outline),
          title: Text('About us'),
          onTap: () {
             Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AboutUsPage(),
              ),
            );
          },
        ),
      ],
    );
  }
}
