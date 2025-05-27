import 'package:camera_app/features/feedback/presentation/widget/custom_button.dart';
import 'package:camera_app/features/reference/presentation/reference_page.dart';
import 'package:camera_app/features/sign_translation/presentation/pages/camera_page.dart';
import 'package:camera_app/features/theme/presenation/provider/theme_provider.dart';
// Ensure this path correctly points to your ThemeProvider class.
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart'; // Required for platformBrightness
import 'package:provider/provider.dart';

class MainHomePage extends StatelessWidget {
  const MainHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Access ThemeProvider to determine current theme
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    // Determine if dark mode should be active
    bool isDarkMode;
    final currentThemeMode = themeProvider.themeMode;

    if (currentThemeMode == ThemeMode.system) {
      // Listen to platform brightness if theme is system
      final platformBrightness = SchedulerBinding.instance.window.platformBrightness;
      isDarkMode = platformBrightness == Brightness.dark;
    } else {
      isDarkMode = currentThemeMode == ThemeMode.dark;
    }

    // Add this debugPrint to check the value of isDarkMode when this widget builds.
    // Check your debug console when you switch themes.
    debugPrint("MainHomePage build: currentThemeMode = $currentThemeMode, isDarkMode = $isDarkMode");

    // Define colors for light and dark mode
    // Light Mode Colors
    const Color primaryColorLight = Colors.teal;
    const Color accentColorLight = Colors.amber;
    final Color backgroundColorStartLight = Colors.teal.shade50;
    final Color backgroundColorEndLight = Colors.green.shade100;
    const Color appBarTextColorLight = Colors.white;
    const Color bodyTextColorLight = Colors.black87;
    final Color bodySubTextColorLight = Colors.grey.shade700;
    const Color buttonPrimaryTextColorLight = Colors.white;
    const Color buttonAccentTextColorLight = Colors.black87;

    // Dark Mode Colors
    final Color primaryColorDark = Colors.teal.shade700;
    final Color accentColorDark = Colors.amber.shade600;
    final Color backgroundColorStartDark = Colors.grey.shade800; 
    final Color backgroundColorEndDark = Colors.blueGrey.shade900; 
    const Color appBarTextColorDark = Colors.white;
    const Color bodyTextColorDark = Colors.white70;
    final Color bodySubTextColorDark = Colors.grey.shade400;
    const Color buttonPrimaryTextColorDark = Colors.white;
    const Color buttonAccentTextColorDark = Colors.black87;


    // Select colors based on theme
    final Color currentPrimaryColor = isDarkMode ? primaryColorDark : primaryColorLight;
    final Color currentAccentColor = isDarkMode ? accentColorDark : accentColorLight;
    final Color currentBgStart = isDarkMode ? backgroundColorStartDark : backgroundColorStartLight;
    final Color currentBgEnd = isDarkMode ? backgroundColorEndDark : backgroundColorEndLight;
    final Color currentAppBarTextColor = isDarkMode ? appBarTextColorDark : appBarTextColorLight;
    final Color currentBodyTextColor = isDarkMode ? bodyTextColorDark : bodyTextColorLight;
    final Color currentBodySubTextColor = isDarkMode ? bodySubTextColorDark : bodySubTextColorLight;
    final Color currentButtonPrimaryTextColor = isDarkMode ? buttonPrimaryTextColorDark : buttonPrimaryTextColorLight;
    final Color currentButtonAccentTextColor = isDarkMode ? buttonAccentTextColorDark : buttonAccentTextColorLight;


    return Scaffold(
      backgroundColor: isDarkMode ? backgroundColorEndDark : backgroundColorEndLight, 
      appBar: AppBar(
        title: Text(
          'Welcome to Engbaba',
          style: TextStyle(fontWeight: FontWeight.bold, color: currentAppBarTextColor),
        ),
        backgroundColor: currentPrimaryColor,
        elevation: 2, 
        centerTitle: true,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [currentBgStart, currentBgEnd],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Expanded(
                    flex: 3, 
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 20.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(15.0),
                        child: Image.network(
                          'http://googleusercontent.com/image_generation_content/7', 
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              decoration: BoxDecoration(
                                color: isDarkMode ? Colors.grey[700] : Colors.grey[300],
                                borderRadius: BorderRadius.circular(15.0),
                              ),
                              child: Center(
                                child: Icon(
                                  Icons.sign_language,
                                  size: 100,
                                  color: isDarkMode ? Colors.grey.shade400 : Colors.grey,
                                ),
                              ),
                            );
                          },
                          loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                    : null,
                                color: currentPrimaryColor,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                  Text(
                    'Connect & Understand',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: currentBodyTextColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Translate sign language or explore resources to learn more.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: currentBodySubTextColor,
                    ),
                  ),
                  const SizedBox(height: 40), 
                  _buildStyledButton(
                    context: context,
                    icon: Icons.camera_alt_outlined,
                    label: "Translate Sign",
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CameraPage(),
                        ),
                      );
                    },
                    backgroundColor: currentPrimaryColor,
                    textColor: currentButtonPrimaryTextColor,
                  ),
                  const SizedBox(height: 20), 
                  _buildStyledButton(
                    context: context,
                    icon: Icons.menu_book_outlined,
                    label: "Sign Resources",
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ReferencePage(),
                        ),
                      );
                    },
                    backgroundColor: currentAccentColor,
                    textColor: currentButtonAccentTextColor,
                  ),
                  const Spacer(flex: 1), 
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStyledButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required Color backgroundColor,
    required Color textColor,
  }) {
    return SizedBox(
      height: 55, 
      child: ElevatedButton.icon(
        icon: Icon(icon, color: textColor),
        label: Text(
          label,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
        ),
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: textColor, 
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.0), 
          ),
          elevation: 5,
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }
}
