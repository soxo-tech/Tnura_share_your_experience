import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:share_your_experience/features/core/colors.dart';
import 'package:share_your_experience/features/provider/templates_provider.dart';
import 'package:share_your_experience/features/services/navigation_services.dart';
import 'package:share_your_experience/features/view/templates_preview.dart';
import 'package:share_your_experience/features/widgets/app_space.dart';
import 'package:share_your_experience/features/widgets/camera_permission_dialog.dart';
import 'package:share_your_experience/features/widgets/camera_settings_dialog.dart';
import 'package:share_your_experience/features/widgets/refracted_button.dart';
import 'package:share_your_experience/features/widgets/refracted_text.dart';
import 'package:share_your_experience/features/widgets/svg_image.dart';
import 'package:shimmer/shimmer.dart';

/// The main screen of the Share Your Experience module.
///
/// This screen allows users to browse and select from a list of available
/// templates. It handles camera permissions and manages the transition
/// to the [TemplatePreview] screen once a template and image are selected.
class ShareYourExperience extends StatefulWidget {
  /// The name of the package where assets are located, if running as a package.
  final String? packageName;

  /// Whether the module is running as a standalone application.
  /// When true, assets are loaded from the root bundle (packageName is null).
  /// When false, assets are loaded from the package bundle.
  final bool isStandalone;

  const ShareYourExperience({
    super.key,
    this.packageName,
    this.isStandalone = false,
  });

  @override
  State<ShareYourExperience> createState() => _ShareYourExperienceState();
}

/// The state for the [ShareYourExperience] widget.
class _ShareYourExperienceState extends State<ShareYourExperience> {
  /// Global key for the Scaffold to manage the drawer or snackbars.
  final GlobalKey<ScaffoldState> _key = GlobalKey();

  /// Resolves the correct package name based on the [isStandalone] flag.
  String? get _effectivePackageName =>
      widget.packageName ??
      (widget.isStandalone ? null : 'share_your_experience');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _key,
      body: Consumer<TemplateProvider>(
        builder: (context, provider, _) {
          // If the image is ready, navigate to the TemplatePreview screen.
          if (provider.isImageReady) {
            WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
              push(
                context,
                // TemplatePreview is pushed as a new route above the Navigator,
                // so it sits outside this Consumer's provider scope. Forward the
                // existing provider instance so the whole preview subtree can
                // read it.
                ChangeNotifierProvider<TemplateProvider>.value(
                  value: provider,
                  child: TemplatePreview(
                    template: provider.selectedTemplate,
                    isCustom: provider.isCustom,
                    packageName: _effectivePackageName,
                    isStandalone: widget.isStandalone,
                  ),
                ),
              );
              provider.isImageReady = false;
            });
          }

          //Main screen where a user can choose a template from available options
          return Container(
            height: 1.sh,
            decoration: BoxDecoration(gradient: AppColors.blueGradient),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RefractedText(
                            text: 'Choose a template',
                            fontSize: 32,
                            fontWeight: FontWeight.w500,
                            height: 2,
                          ),
                          RefractedText(
                            text:
                                'Pick a template that best captures your Nura experience',
                            fontSize: 18,
                            textColor: Colors.grey,
                            fontWeight: FontWeight.w400,
                            height: 1.25,
                          ),
                        ],
                      ),
                    ),
                    // Display shimmer effect while templates are loading.
                    provider.templatesLoading
                        ? Shimmer.fromColors(
                            baseColor: AppColors.backgroundBlueLight,
                            highlightColor: Colors.white,
                            child: Column(
                              children: [
                                Container(
                                  height: 0.5.sh,
                                  decoration: BoxDecoration(
                                    color: AppColors.backgroundBlueLight,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                setHeight(16),
                                Container(
                                  height: 0.5.sh,
                                  decoration: BoxDecoration(
                                    color: AppColors.backgroundBlueLight,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ],
                            ),
                          )
                        // Show an error message when no templates were supplied.
                        : provider.templates.isEmpty
                        ? Padding(
                            padding: EdgeInsets.symmetric(vertical: 0.3.sh),
                            child: Center(
                              child: RefractedText(
                                text: 'Something went wrong',
                                fontSize: 18,
                                fontWeight: FontWeight.w400,
                                textColor: Colors.grey,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          )
                        //Listview which displays all the available templates
                        : ListView.separated(
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: provider.templates.length,
                            separatorBuilder: (context, index) => setHeight(16),
                            itemBuilder: (context, index) => Column(
                              children: [
                                AspectRatio(
                                  aspectRatio: 1,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: AppColors.buttonBlue,
                                      image: DecorationImage(
                                        image: CachedNetworkImageProvider(
                                          provider.templates[index].bgImage ??
                                              "",
                                        ),
                                        fit: BoxFit.cover,
                                      ),
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(10),
                                        topRight: Radius.circular(10),
                                      ),
                                    ),
                                    child: Stack(
                                      children: [
                                        Align(
                                          alignment: Alignment.bottomCenter,
                                          child: AspectRatio(
                                            aspectRatio: 1.5,
                                            child: Container(
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  begin: Alignment.bottomCenter,
                                                  end: Alignment.topCenter,
                                                  colors: [
                                                    hexToColor(
                                                      provider.templates[index]
                                                              .gradient ??
                                                          "#ffffff",
                                                    ),
                                                    Colors.transparent,
                                                  ],
                                                ),
                                              ),
                                              child: Image.asset(
                                                'assets/images/templates_background.jpeg',
                                                package: _effectivePackageName,
                                                color: hexToColor(
                                                  provider.templates[index]
                                                          .gradient ??
                                                      "#ffffff",
                                                ),
                                                fit: BoxFit.fitHeight,
                                                errorBuilder: (
                                                  context,
                                                  error,
                                                  stackTrace,
                                                ) {
                                                  return const SizedBox
                                                      .shrink();
                                                },
                                              ),
                                            ),
                                          ),
                                        ),
                                        Align(
                                          alignment: Alignment.bottomCenter,
                                          child: Padding(
                                            padding: const EdgeInsets.all(16.0),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.end,
                                              children: [
                                                SvgImage(
                                                  svgPath: 'logo',
                                                  svgWidth: 0.35.sw,
                                                  color: Colors.white,
                                                  packageName:
                                                      _effectivePackageName,
                                                ),
                                                SizedBox(
                                                  height: 140,
                                                  width: 140,
                                                  child: Stack(
                                                    children: [
                                                      SvgPicture.asset(
                                                        'assets/svg/badge.svg',
                                                        package:
                                                            _effectivePackageName,
                                                        height: 140,
                                                        width: 140,
                                                        fit: BoxFit.cover,
                                                      ),
                                                      Center(
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(
                                                            24.0,
                                                          ),
                                                          child:
                                                              Transform.rotate(
                                                            angle:
                                                                -24 * pi / 180,
                                                            child:
                                                                RefractedText(
                                                              text: provider
                                                                      .templates[
                                                                          index]
                                                                      .badgeContent ??
                                                                  "",
                                                              textColor:
                                                                  Colors.white,
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                              fontSize: 16,
                                                              height: 1.2,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Container(
                                  width: double.infinity,
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.only(
                                      bottomLeft: Radius.circular(10),
                                      bottomRight: Radius.circular(10),
                                    ),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              RefractedText(
                                                text: provider.templates[index]
                                                        .title ??
                                                    "",
                                                fontWeight: FontWeight.w500,
                                                fontSize: 20,
                                                textColor:
                                                    AppColors.primaryDark,
                                              ),
                                              RefractedText(
                                                text: provider.templates[index]
                                                        .content ??
                                                    "",
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ],
                                          ),
                                        ),
                                        setWidth(16),
                                        RefractedButton(
                                          label: 'CHOOSE',
                                          textColor: AppColors.buttonBlue,
                                          backGroundColor:
                                              AppColors.buttonBlueLight,
                                          onTap: () async {
                                            final template =
                                                provider.templates[index];

                                            // Only a template built from the
                                            // user's own photo opens the
                                            // camera; the rest are composed
                                            // from the template's background
                                            // image. Asking for camera access
                                            // there would be a prompt we never
                                            // act on.
                                            if (!(template.isCustom ?? false)) {
                                              provider.chooseTemplate(template);
                                              return;
                                            }

                                            var status = await provider
                                                .cameraPermissionStatus();
                                            // Guard against using a stale context
                                            // after the async permission request.
                                            if (!context.mounted) return;

                                            if (status.isGranted) {
                                              provider.chooseTemplate(template);
                                              return;
                                            }

                                            // Refused for good — the OS will
                                            // not prompt again, so the only way
                                            // forward is the app settings.
                                            if (status.isPermanentlyDenied) {
                                              showDialog(
                                                context: context,
                                                builder: (_) =>
                                                    const CameraSettingsDialog(),
                                              );
                                              return;
                                            }

                                            // The explanation is shown once.
                                            // Afterwards go straight to the OS
                                            // prompt: Android still reports a
                                            // plain "denied" after a single
                                            // refusal, and re-showing our own
                                            // dialog on every tap is what made
                                            // the app feel like it asks
                                            // endlessly.
                                            if (provider.cameraExplainerShown) {
                                              status = await provider
                                                  .requestCameraPermission();
                                              if (!context.mounted) return;
                                              if (status.isGranted) {
                                                provider
                                                    .chooseTemplate(template);
                                              } else if (status
                                                  .isPermanentlyDenied) {
                                                showDialog(
                                                  context: context,
                                                  builder: (_) =>
                                                      const CameraSettingsDialog(),
                                                );
                                              }
                                              return;
                                            }

                                            // First time: explain why the
                                            // camera is needed, then let the
                                            // dialog trigger the OS prompt.
                                            provider.markCameraExplainerShown();
                                            showDialog(
                                              context: context,
                                              // Pass the provider instance
                                              // directly; the dialog lives on
                                              // a separate route above the
                                              // Consumer.
                                              builder: (_) =>
                                                  CameraPermissionDialog(
                                                index: index,
                                                provider: provider,
                                              ),
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Converts a hex color string (e.g., "#FFFFFF" or "FFFFFF") to a [Color] object.
///
/// If the code is empty or invalid, it returns [Colors.transparent] or
/// defaults to white respectively.
Color hexToColor(String code) {
  if (code.isEmpty) return Colors.transparent;
  final buffer = StringBuffer();
  if (code.length == 6 || code.length == 7) {
    buffer.write('ff'); // Add full opacity if only RGB is provided
  }
  buffer.write(code.replaceFirst('#', ''));
  final hexInt = int.tryParse(buffer.toString(), radix: 16);
  return Color(hexInt ?? 0xFFFFFFFF); // Default to white if parsing fails
}
