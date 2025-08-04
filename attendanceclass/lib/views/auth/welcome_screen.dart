import 'package:flutter/material.dart';
import '../onboarding/semester_input_screen.dart';
import '../widgets/custom_button.dart';
import '../../utils/app-styles.dart';
import '../../utils/app_colors.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/images/welcome.png', height: 200),
            const SizedBox(height: 30),
            Text(
              'Welcome to Smart Class Bunk Manager',
              style: AppStyles.headingStyle.copyWith(fontSize: 24),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Text(
              'The more accurate data you provide, the better results we can show. '
              'Remember to cross-check the data after we parse your files. '
              'You can always manually edit any changes later.',
              style: AppStyles.bodyStyle,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            CustomButton(
              text: 'I Understand',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const SemesterInputScreen(),
                  ),
                );
              },
              backgroundColor: AppColors.primaryColor,
            ),
          ],
        ),
      ),
    );
  }
}
