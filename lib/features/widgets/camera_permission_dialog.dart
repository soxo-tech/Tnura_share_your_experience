import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_your_experience/features/core/colors.dart';
import 'package:share_your_experience/features/provider/templates_provider.dart';
import 'package:share_your_experience/features/services/navigation_services.dart';
import 'package:share_your_experience/features/widgets/app_space.dart';
import 'package:share_your_experience/features/widgets/refracted_button.dart';
import 'package:share_your_experience/features/widgets/refracted_text.dart';

/// A dialog that prompts the user to enable camera and photo access for the app.
/// This dialog is used when the user attempts to share their experience and the
/// app requires camera or gallery access.
///
/// The dialog provides options to either go back or enable the necessary permissions.
/// If the permissions are granted, the selected template is processed further.
class CameraPermissionDialog extends StatelessWidget {
  /// Index of the template the user chose, used to resume template selection
  /// once camera permission is granted.
  final int index;

  /// The provider that drives template selection. Passed in directly so the
  /// dialog does not depend on being under the provider in the widget tree
  /// (it is shown on a separate dialog route).
  final TemplateProvider provider;

  /// Constructs a [CameraPermissionDialog] for the template at [index].
  const CameraPermissionDialog({
    super.key,
    required this.index,
    required this.provider,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 32,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            /// Title text prompting the user to enable camera and photo access.
            RefractedText(
              text: 'Enable access to camera and photos.',
              fontSize: 22,
              fontWeight: FontWeight.w500,
              textAlign: TextAlign.center,
            ),

            /// Informative text explaining why the app needs access to the camera and gallery.
            RefractedText(
              text:
                  'Allow Nura App to use camera and access gallery to share your experience'
                      ,
              fontSize: 14,
              fontWeight: FontWeight.w400,
              textAlign: TextAlign.center,
            ),
            setHeight(16),

            /// Row containing two buttons: "GO BACK" and "ENABLE".
            Row(
              children: [
                Expanded(
                  /// Button to go back without enabling the permission.
                  child: RefractedButton(
                    fontSize: 12,
                    label: 'GO BACK',
                    textColor: AppColors.buttonBlue,
                    backGroundColor: AppColors.buttonBlueLight,
                    onTap: () {
                      pop(context);
                    },
                  ),
                ),
                setWidth(16),
                Expanded(
                  /// Button to request camera permission.
                  /// If the permission is permanently denied, it prompts the user to open the app settings.
                  /// Otherwise, it proceeds with selecting the template.
                  child: RefractedButton(
                    fontSize: 12,
                    label: 'ENABLE',
                    onTap: () {
                      pop(context);
                      Permission.camera.request().then((value) {
                        if (value.isGranted) {
                          // Permission granted: take a photo (for custom
                          // templates) and continue to the preview/share flow.
                          provider.chooseTemplate(
                            provider.templates[index],
                          );
                        } else if (value.isPermanentlyDenied) {
                          // The OS will no longer show the prompt, so send the
                          // user to the app settings to enable it manually.
                          openAppSettings();
                        }
                      });
                    },
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
