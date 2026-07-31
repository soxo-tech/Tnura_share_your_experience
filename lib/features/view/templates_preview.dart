import 'dart:io';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:share_your_experience/features/core/colors.dart';
import 'package:share_your_experience/features/model/templates_model.dart';
import 'package:share_your_experience/features/provider/templates_provider.dart';
import 'package:share_your_experience/features/services/navigation_services.dart';
import 'package:share_your_experience/features/widgets/refracted_button.dart';
import 'package:share_your_experience/features/widgets/refracted_text.dart';
import 'package:share_your_experience/features/widgets/svg_image.dart';
import 'package:widgets_to_image/widgets_to_image.dart';

/// A StatefulWidget that previews a template for sharing experience.
///
/// This widget displays a template preview which can be either custom or predefined.
/// The preview is wrapped with functionality to capture the widget as an image
/// and log an analytics event when the template is created.
class TemplatePreview extends StatefulWidget {
  /// The template model to be previewed.
  final TemplatesModel template;

  /// A flag to indicate whether the template is custom or predefined.
  final bool isCustom;

  /// The name of the package where the assets are located.
  final String? packageName;

  /// Whether the module is running as a standalone application.
  final bool isStandalone;

  /// Constructs a TemplatePreview widget.
  ///
  /// Takes a [template] of type `TemplatesModel` and a boolean [isCustom]
  /// to determine if the template is custom or not.
  const TemplatePreview({
    super.key,
    required this.template,
    required this.isCustom,
    this.packageName,
    this.isStandalone = false,
  });

  @override
  State<TemplatePreview> createState() => _TemplatePreviewState();
}

/// The state for the [TemplatePreview] widget.
class _TemplatePreviewState extends State<TemplatePreview> {
  /// Controller to capture the widget as an image.
  WidgetsToImageController controller = WidgetsToImageController();

  /// Resolves the correct package name based on the [isStandalone] flag.
  String? get _effectivePackageName =>
      widget.packageName ??
      (widget.isStandalone ? null : 'share_your_experience');

  /// Global key for managing the state of the Scaffold.
  final GlobalKey<ScaffoldState> _key = GlobalKey();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // Accesses the TemplateProvider instance to manage the template data and loading state.
    TemplateProvider templateProvider = Provider.of<TemplateProvider>(context);

    return Scaffold(
      key: _key, // Unique key for the Scaffold to manage its state
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: AppColors.blueDark,
          ),
          onPressed: () async {
            Navigator.of(context).pop();
          },
        ),
      ),
      // Main content of the screen.
      body: Container(
        decoration: BoxDecoration(
          gradient: AppColors.blueGradient,
        ), // Background gradient for the container.
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Heading text that informs the user they are ready to share.
                RefractedText(
                  text: 'Ready to share!',
                  fontSize: 32,
                  fontWeight: FontWeight.w500,
                  height: 2,
                ),
                // Subheading text that gives more context to the user.
                RefractedText(
                  text: 'Your picture is ready to share online!',
                  fontSize: 18,
                  textColor: Colors.grey,
                  fontWeight: FontWeight.w400,
                  height: 1.25,
                ),
              ],
            ),
            SizedBox(
              height: 25,
            ),
            // Display area for the picture that the user is going to share.
            AspectRatio(
              aspectRatio: 0.9,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: WidgetsToImage(
                  controller:
                      controller, // Controller to capture the widget as an image.
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.buttonBlue,
                      image: !widget.isCustom
                          ? DecorationImage(
                              image: CachedNetworkImageProvider(
                                widget.template.bgImage ?? "",
                              ),
                              fit: BoxFit.cover,
                            )
                          : DecorationImage(
                              image: FileImage(
                                File(templateProvider.pickedImage!.path),
                              ),
                              fit: BoxFit.cover,
                            ),
                    ),
                    child: Stack(
                      children: [
                        // Gradient overlay at the bottom of the image.
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: AspectRatio(
                            aspectRatio: 1.8,
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                  colors: [
                                    TemplatesModel.hexToColor(
                                      widget.template.gradient ?? "#ffffff",
                                    ),
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                              child: SvgImage(
                                svgPath: 'gradient',
                                color: TemplatesModel.hexToColor(
                                  widget.template.gradient ?? "#ffffff",
                                ),
                                fit: BoxFit.fill,
                                packageName: _effectivePackageName,
                              ),
                            ),
                          ),
                        ),

                        // Bottom bar with the logo and badge content.
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                // Nura logo.
                                SvgImage(
                                  svgPath: 'logo',
                                  svgWidth: 0.30.sw,
                                  color: Colors.white,
                                  packageName: _effectivePackageName,
                                ),
                                // Badge with custom content rotated by 24 degrees.
                                SizedBox(
                                  height: 130,
                                  width: 130,
                                  child: Stack(
                                    children: [
                                      SvgPicture.asset(
                                        'assets/svg/badge.svg',
                                        package: _effectivePackageName,
                                        height: 130,
                                        width: 130,
                                        fit: BoxFit.cover,
                                      ),
                                      Center(
                                        child: Padding(
                                          padding: const EdgeInsets.all(24.0),
                                          child: Transform.rotate(
                                            angle: -24 * pi / 180,
                                            child: RefractedText(
                                              text: widget
                                                      .template.badgeContent ??
                                                  "",
                                              textColor: Colors.white,
                                              textAlign: TextAlign.center,
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
              ),
            ),
            SizedBox(
              height: 25,
            ),
            // Row containing a share button that captures the widget as an image and shares it.
            Row(
              children: [
                Expanded(
                  child: Builder(
                    builder: (buttonContext) => RefractedButton(
                      label: 'SHARE',
                      isLoading: templateProvider.isLoading,
                      onTap: () async {
                        templateProvider.toggleLoading = true;
                        try {
                          // Capture the widget as an image and save it to the device.
                          await Future.delayed(
                              const Duration(milliseconds: 100));
                          final bytes = await controller.capture(pixelRatio: 3);
                          if (bytes == null) {
                            if (buttonContext.mounted) {
                              showSnackBar(buttonContext,
                                  'Could not prepare the image. Please try again.');
                            }
                            return;
                          }

                          final directory =
                              await getApplicationDocumentsDirectory();
                          final file =
                              File('${directory.path}/My_Experience.jpg');
                          await file.writeAsBytes(bytes.toList());

                          // The share sheet is a popover on iPad/macOS and must be
                          // anchored to a rect, otherwise it fails to present.
                          if (!buttonContext.mounted) return;
                          final box =
                              buttonContext.findRenderObject() as RenderBox?;
                          final origin = box != null && box.hasSize
                              ? box.localToGlobal(Offset.zero) & box.size
                              : null;

                          // Share the image using the platform share sheet.
                          final result = await Share.shareXFiles(
                            [XFile(file.path)],
                            subject: 'I just got screened!',
                            text:
                                Platform.isIOS ? null : 'I just got screened!',
                            sharePositionOrigin: origin,
                          );

                          // Bail out if the widget was disposed during the await.
                          if (!buttonContext.mounted) return;
                          if (result.status == ShareResultStatus.success) {
                            pop(buttonContext);
                          }
                        } catch (e) {
                          if (buttonContext.mounted) {
                            showSnackBar(buttonContext,
                                'Unable to share. Please try again.');
                          }
                        } finally {
                          templateProvider.toggleLoading = false;
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
