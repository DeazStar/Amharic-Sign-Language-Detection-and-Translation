import 'package:camera_app/features/sign_translation/presentation/pages/main_home_page.dart';
import 'package:camera_app/features/sign_translation/presentation/pages/main_navigation_page.dart';
import 'package:flutter/material.dart';
// Adjust the import path according to your project structure for MainHomePage

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Define colors - you can use your ThemeProvider here if you have one set up globally
    // For simplicity, I'm defining some example colors.
    // These should ideally adapt to light/dark mode using Theme.of(context) or your ThemeProvider
    final Brightness currentBrightness = MediaQuery.platformBrightnessOf(context);
    final bool isDarkMode = currentBrightness == Brightness.dark;

    final Color backgroundColor = isDarkMode ? Colors.grey.shade900 : Colors.teal.shade50;
    final Color primaryTextColor = isDarkMode ? Colors.white : Colors.black87;
    final Color secondaryTextColor = isDarkMode ? Colors.grey.shade400 : Colors.grey.shade700;
    final Color buttonColor = isDarkMode ? const Color.fromRGBO(77, 182, 172, 1) : Colors.teal;
    final Color buttonTextColor = isDarkMode ? Colors.black : Colors.white;


    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const Spacer(flex: 2),
              // Welcome Image
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.35, // Adjust size as needed
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15.0),
                  child: Image( // TODO: Replace with your local asset image
                    image: AssetImage('assets/images/onboarding.png'), // Placeholder URL
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        decoration: BoxDecoration(
                          color: isDarkMode ? Colors.grey[800] : Colors.grey[300],
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        child: Center(
                          child: Icon(
                            Icons.people_alt_outlined, // A generic icon if image fails
                            size: 100,
                            color: isDarkMode ? Colors.grey.shade500 : Colors.grey.shade600,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 40),

              // Title "እንግባባ"
              Text(
                'Engbaba', // "Let's Understand Each Other" / "Let's Communicate"
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: primaryTextColor,
                  fontFamily: 'NotoSerifEthiopic', // Ensure you have this font or similar
                ),
              ),
              const SizedBox(height: 16),

              // Description
              Text(
                'Translate Amharic Sign Language to text.', // "Translate Amharic Sign Language to text. የአማርኛ ምልክት ቋንቋን ወደ ጽሑፍ ይተርጉሙ።"
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  color: secondaryTextColor,
                  // fontFamily: 'NotoSansEthiopic', // Ensure you have this font or similar
                  height: 1.5, // Line height for better readability
                ),
              ),
              const Spacer(flex: 3),

              // Get Started Button
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: buttonColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  elevation: 5,
                ),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MainNavigationPage(), // Navigate to your main home page
                    ),
                  );
                },
                child: Text(
                  'Get Started', // "Get Started" or ጀምር"Start"
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: buttonTextColor,
                    fontFamily: 'NotoSansEthiopic',
                  ),
                ),
              ),
              const Spacer(flex: 1),
            ],
          ),
        ),
      ),
    );
  }
}
