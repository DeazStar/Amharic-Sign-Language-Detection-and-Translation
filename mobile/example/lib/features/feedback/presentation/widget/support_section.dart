import 'package:camera_app/features/feedback/presentation/page/about_us_page.dart';
import 'package:camera_app/features/feedback/presentation/page/contact_us_page.dart';
import 'package:camera_app/features/feedback/presentation/page/faq_page.dart';
import 'package:camera_app/features/feedback/presentation/page/feed_back_page.dart';
import 'package:camera_app/features/feedback/presentation/page/setting_page.dart';
import 'package:flutter/material.dart';

class SupportSection extends StatelessWidget {

  const SupportSection({ Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('SUPPORT', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        ListTile(
          leading: Icon(Icons.help_outline),
          title: Text('FQA'),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => FaqPage(onBack: () {
                  Navigator.of(context).pop();
                },),
              ),
            );
          },
        ),
        ListTile(
          leading: Icon(Icons.contact_mail),
          title: Text('Contact Us'),
          onTap: (){
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ContactUsPage(),
              ),
            );
           
          },
        ),
        ListTile(
          leading: Icon(Icons.feedback),
          title: Text('FeedBack'),
         onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => FeedbackPage(
                onBack: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
          );
        },

        ),
      ],
    );
  }
}
