import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'onboarding_page.dart';
import 'home_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isLoading = true;
  bool _isNewUser = true;

  @override
  void initState() {
    super.initState();
    _checkNewUser();
  }

  Future<void> _checkNewUser() async {
    final prefs = await SharedPreferences.getInstance();
    final routineJson = prefs.getString('routine');
    setState(() {
      _isNewUser = routineJson == null;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Attendance Tracker',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: _isLoading
          ? const AnimatedLoaderScreen()
          : _isNewUser
          ? const OnboardingPage()
          : const HomePage(),
    );
  }
}

class AnimatedLoaderScreen extends StatelessWidget {
  const AnimatedLoaderScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 20),
            Text('Loading...'),
          ],
        ),
      ),
    );
  }
}
