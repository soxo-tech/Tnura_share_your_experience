import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_your_experience/features/core/colors.dart';
import 'package:share_your_experience/features/services/navigation_services.dart';
import 'package:share_your_experience/features/widgets/app_space.dart';
import 'package:share_your_experience/features/widgets/refracted_button.dart';
import 'package:share_your_experience/features/widgets/refracted_text.dart';

/// A dialog shown when the camera access has been refused for good.
///
/// Once the user has refused permanently, the operating system no longer shows
/// its own request, so [CameraPermissionDialog] would be a dead end — its
/// "ENABLE" button could not produce a prompt. This dialog instead sends the
/// user to the app settings, which is the only place the access can still be
/// granted.
class CameraSettingsDialog extends StatelessWidget {
  const CameraSettingsDialog({super.key});

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
            /// Title text explaining that the access is currently turned off.
            RefractedText(
              text: 'Camera access is turned off.',
              fontSize: 22,
              fontWeight: FontWeight.w500,
              textAlign: TextAlign.center,
            ),

            /// Informative text pointing the user to the app settings.
            RefractedText(
              text:
                  'To take a photo for your experience, allow camera access for the Nura App in your device settings.',
              fontSize: 14,
              fontWeight: FontWeight.w400,
              textAlign: TextAlign.center,
            ),
            setHeight(16),

            /// Row containing two buttons: "GO BACK" and "OPEN SETTINGS".
            Row(
              children: [
                Expanded(
                  /// Button to dismiss the dialog and stay on the template list.
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
                  /// Button to open the settings screen of the application,
                  /// where the camera access can be granted manually.
                  child: RefractedButton(
                    fontSize: 12,
                    label: 'OPEN SETTINGS',
                    onTap: () {
                      pop(context);
                      openAppSettings();
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
