import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'features/provider/templates_provider.dart';
import 'features/view/share_your_experience.dart';

/// A launcher widget that serves as the entry point for the Share Your Experience module.
///
/// This widget initializes necessary utilities like [ScreenUtil] and provides
/// the [TemplateProvider] to the widget tree. It configures the environment
/// (standalone vs package) and sets up the primary [ShareYourExperience] view.
class ShareExperienceLauncher extends StatelessWidget {
  /// Indicates if the application is running in standalone mode.
  final bool isStandalone;

  /// The name of the package where assets are stored when running as a dependency.
  final String? packageName;

  const ShareExperienceLauncher({
    super.key,
    this.isStandalone = false,
    this.packageName,
  });

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return ChangeNotifierProvider(
          create: (_) => TemplateProvider()..loadHardcodedTemplates(),
          child: ShareYourExperience(
            isStandalone: isStandalone,
            packageName: packageName,
          ),
        );
      },
    );
  }
}
