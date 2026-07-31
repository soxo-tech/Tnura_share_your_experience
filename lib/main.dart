import 'package:flutter/material.dart';
import 'package:share_your_experience/features/model/templates_model.dart';
import 'package:share_your_experience/share_experience_launcher.dart';

/// The entry point of the application.
///
/// Ensures that plugin services are initialized before running the app.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ShareYourExperienceApp());
}

/// The root widget of the Share Your Experience application.
///
/// This standalone wrapper plays the role of a "host" application: it owns the
/// templates and hands them to [ShareExperienceLauncher]. When embedded as a
/// package, the real host application supplies its own templates the same way.
class ShareYourExperienceApp extends StatelessWidget {
  /// Creates a [ShareYourExperienceApp] instance.
  const ShareYourExperienceApp({super.key});

  /// Sample templates used to demonstrate the module in standalone mode.
  ///
  /// In a real deployment the host application provides these instead.
  static final List<TemplatesModel> _sampleTemplates = [
    TemplatesModel(
      gradient: "",
      title: "",
      content: "",
      bgImage:
          "",
      badgeContent: "",
      isCustom: false,
    ),
    TemplatesModel(
      gradient: "",
      title: "",
      content: "",
      bgImage:
          "",
      badgeContent: "",
      isCustom: false,
    ),
    TemplatesModel(
      gradient: "",
      title: "",
      content:
          "",
      bgImage:
          "",
      badgeContent: "",
      isCustom: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ShareExperienceLauncher(
        isStandalone: true,
        templates: _sampleTemplates,
      ),
    );
  }
}
