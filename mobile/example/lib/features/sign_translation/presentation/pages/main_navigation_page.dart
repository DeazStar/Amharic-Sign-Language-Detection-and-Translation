// lib/features/main_navigation/presentation/pages/main_navigation_page.dart

import 'package:camera_app/features/sign_translation/presentation/pages/main_home_page.dart';
import 'package:flutter/material.dart';
// Import your new Home and Settings pages/views
// import '../pages/home_page.dart';
import '../../../../features/feedback/presentation/page/setting_page.dart';

class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({super.key});

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  int _selectedIndex = 0;


  static final List<Widget> _widgetOptions = <Widget>[
    MainHomePage(),
   const SettingPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:  Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home), // Changed to camera icon for home
            label: 'home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        // Optional: Add styling for selected/unselected items
        // selectedItemColor: Colors.amber[800],
        // unselectedItemColor: Colors.grey,
      ),
    );
  }
}


