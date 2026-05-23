import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:share_your_experience/firebase_options.dart';
import 'package:share_your_experience/share_experience_launcher.dart';

/// The entry point of the application.
///
/// Ensures that plugin services are initialized before running the app.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const ShareYourExperienceApp());
}

/// The root widget of the Share Your Experience application.
class ShareYourExperienceApp extends StatelessWidget {
  /// Creates a [ShareYourExperienceApp] instance.
  const ShareYourExperienceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ShareExperienceLauncher(isStandalone: true),
    );
  }
}
