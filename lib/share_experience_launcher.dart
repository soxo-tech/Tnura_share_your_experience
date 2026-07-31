import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'features/model/templates_model.dart';
import 'features/provider/templates_provider.dart';
import 'features/view/share_your_experience.dart';

/// Entry point widget for the Share Your Experience module.
///
/// This is the single public surface a host application embeds. It:
/// * initializes [ScreenUtil] for responsive sizing,
/// * provides a [TemplateProvider] seeded with the host-supplied [templates],
/// * configures asset resolution (standalone vs. package), and
/// * renders the primary [ShareYourExperience] view.
///
/// The host application owns the templates and passes them in. When [templates]
/// is `null` or empty, the view shows a "something went wrong" message instead
/// of a template list.
///
/// Example — embedding from a host app:
/// ```dart
/// ShareExperienceLauncher(
///   templates: [
///     TemplatesModel(
///       gradient: '#ADDFDE',
///       title: 'I just got screened',
///       content: 'Choose Nura for screening',
///       bgImage: 'https://example.com/template.jpg',
///       badgeContent: 'My Badge for Screening',
///       isCustom: false,
///     ),
///   ],
/// )
/// ```
class ShareExperienceLauncher extends StatelessWidget {
  /// Whether the module runs as a standalone app (`true`) or embedded inside a
  /// host application as a package (`false`).
  ///
  /// Controls how bundled assets are resolved. See [packageName].
  final bool isStandalone;

  /// The package name used to resolve bundled assets when embedded.
  ///
  /// When `null` and not [isStandalone], assets resolve from the
  /// `share_your_experience` package bundle.
  final String? packageName;

  /// The templates supplied by the host application.
  ///
  /// These are the source of truth for what the user can choose from. When
  /// `null` or empty, the view renders its error state rather than a list.
  final List<TemplatesModel>? templates;

  const ShareExperienceLauncher({
    super.key,
    this.isStandalone = false,
    this.packageName,
    this.templates,
  });

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return ChangeNotifierProvider(
          create: (_) =>
              TemplateProvider()..setTemplates(templates ?? const []),
          child: ShareYourExperience(
            isStandalone: isStandalone,
            packageName: packageName,
          ),
        );
      },
    );
  }
}
