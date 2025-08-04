import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import './views/auth/welcome_screen.dart';
import './services/local_storage.dart';
import './utils/app_colors.dart';
import './utils/app-styles.dart';
import './views/widgets/animated_loader.dart';
import './views/home/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalStorage.init();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]).then((
    _,
  ) {
    runApp(const MyApp());
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Class Bunk Manager',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        fontFamily: 'Inter',
      ),
      home: const AnimatedLoaderScreen(),
    );
  }
}

class AnimatedLoaderScreen extends StatefulWidget {
  const AnimatedLoaderScreen({super.key});

  @override
  State<AnimatedLoaderScreen> createState() => _AnimatedLoaderScreenState();
}

class _AnimatedLoaderScreenState extends State<AnimatedLoaderScreen> {
  @override
  void initState() {
    super.initState();
    _checkFirstLaunch();
  }

  Future<void> _checkFirstLaunch() async {
    await Future.delayed(const Duration(seconds: 3)); // Simulate loading
    final isFirstLaunch = await LocalStorage.isFirstLaunch();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) =>
            isFirstLaunch ? const WelcomeScreen() : const HomeScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const AnimatedLoader(),
            const SizedBox(height: 30),
            Text(
              'Smart Class Bunk Manager',
              style: AppStyles.headingStyle.copyWith(color: Colors.white),
            ),
            const SizedBox(height: 10),
            Text(
              'Managing your attendance made easy',
              style: AppStyles.subtitleStyle.copyWith(color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }
}
