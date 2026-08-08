import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_your_experience/features/core/colors.dart';
import 'package:share_your_experience/features/model/templates_model.dart';

/// State holder for the Share Your Experience module.
///
/// Responsibilities:
/// * Holds the list of [templates] supplied by the host application via
///   [setTemplates] (see [ShareExperienceLauncher]).
/// * Tracks the currently [selectedTemplate] and drives the camera/crop flow
///   through [chooseTemplate] and [captureImage].
/// * Exposes loading flags ([templatesLoading], [isLoading]) consumed by the
///   UI to render shimmer placeholders and button spinners.
class TemplateProvider extends ChangeNotifier {
  /// The currently selected template.
  TemplatesModel selectedTemplate = TemplatesModel();

  /// The image picked from the gallery or camera.
  XFile? pickedImage;

  /// Indicates if a background process is loading.
  bool isLoading = false;

  /// Indicates if the templates are being loaded.
  bool templatesLoading = true;

  /// Sets the currently selected template and initiates image capture if needed.
  ///
  /// Updates `selectedTemplate` with the given template, sets `isCustom` to the value of
  /// the template's `isCustom` property, and calls `captureImage()` to handle image selection.
  void chooseTemplate(TemplatesModel tm) {
    selectedTemplate = tm;
    isCustom = tm.isCustom ?? false;
    notifyListeners();
    captureImage();
  }

  /// Indicates if the image is ready for use.
  bool isImageReady = false;

  /// Indicates if a custom template is being used.
  bool isCustom = false;

  /// Updates the `isLoading` flag and notifies listeners.
  set toggleLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }

  /// The templates currently available for selection.
  List<TemplatesModel> _templates = [];

  /// The templates currently available for selection.
  ///
  /// Empty when the host application supplied no templates; the UI renders an
  /// error message in that case.
  List<TemplatesModel> get templates => _templates;

  /// Loads the [templates] supplied by the host application.
  ///
  /// The host that embeds this module is the source of truth for templates and
  /// passes them through [ShareExperienceLauncher]. Passing an empty list is
  /// valid and signals the UI to show its "something went wrong" state.
  ///
  /// Marks loading as complete and notifies listeners so the view rebuilds.
  void setTemplates(List<TemplatesModel> templates) {
    _templates = templates;
    templatesLoading = false;
    notifyListeners();
    debugPrint(
      "TemplateProvider: Initialized with ${_templates.length} templates from host.",
    );
  }

  /// Captures an image from the camera or prepares for image handling.
  ///
  /// If `isCustom` is false, sets `isImageReady` to `true` directly. Otherwise, opens the camera
  /// for image capture and then allows the user to crop the image. Updates `pickedImage` and
  /// `isImageReady` accordingly.
  Future<void> captureImage() async {
    if (!isCustom) {
      isImageReady = true;
      notifyListeners();
    } else {
      final XFile? image =
          await ImagePicker().pickImage(source: ImageSource.camera);
      if (image != null) {
        pickedImage = image;
        final croppedFile = await ImageCropper().cropImage(
          sourcePath: pickedImage!.path,
          uiSettings: [
            AndroidUiSettings(
              toolbarTitle: 'Cropper',
              toolbarColor: AppColors.primaryDark,
              toolbarWidgetColor: Colors.white,
              aspectRatioPresets: [CropAspectRatioPreset.square],
              initAspectRatio: CropAspectRatioPreset.square,
              lockAspectRatio: true,
              hideBottomControls: true,
            ),
            IOSUiSettings(
              title: 'Cropper',
              aspectRatioPresets: [CropAspectRatioPreset.square],
              aspectRatioPickerButtonHidden: true,
            ),
          ],
        );
        if (croppedFile != null) {
          pickedImage = XFile(croppedFile.path);
          isImageReady = true;
          notifyListeners();
        }
      }
    }
  }

  /// Checks whether the camera permission is currently granted.
  ///
  /// This only reads the current status; it does not trigger the OS permission
  /// prompt. Requesting the permission is handled by [CameraPermissionDialog]
  /// when the user is not yet granted access, so that the custom dialog acts as
  /// the gate before the native prompt appears.
  /// Returns `true` if the permission is already granted, otherwise `false`.
  Future<bool> checkCameraPermission() async {
    final status = await Permission.camera.status;
    return status.isGranted;
  }

  /// The current camera authorization state.
  ///
  /// Reads only — it never triggers the OS prompt. The caller needs the full
  /// status rather than a boolean, because "not asked yet" and "refused for
  /// good" both report as not-granted but have to be handled differently:
  /// the first deserves an explanation, the second can only be resolved in
  /// the app settings.
  Future<PermissionStatus> cameraPermissionStatus() => Permission.camera.status;

  /// Triggers the OS permission prompt and returns the resulting state.
  Future<PermissionStatus> requestCameraPermission() =>
      Permission.camera.request();

  /// Whether the app's own explanation of why the camera is needed has already
  /// been shown during this session.
  bool _cameraExplainerShown = false;

  /// Whether the explanation has already been shown (see
  /// [markCameraExplainerShown]).
  bool get cameraExplainerShown => _cameraExplainerShown;

  /// Records that the explanation has been shown, so that choosing another
  /// template does not repeat it. The OS prompt itself is still shown when it
  /// is due — the operating system limits how often it appears.
  void markCameraExplainerShown() {
    _cameraExplainerShown = true;
  }
}
