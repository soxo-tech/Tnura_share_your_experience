import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_your_experience/features/core/colors.dart';
import 'package:share_your_experience/features/model/templates_model.dart';

/// Manages the application templates and image handling functionalities.
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

  /// Updates the `isCustom` flag and notifies listeners.
  set customTemplate(bool value) {
    isCustom = value;
    notifyListeners();
  }

  /// Updates the `isLoading` flag and notifies listeners.
  set toggleLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }

  List<TemplatesModel> _templates = [];
  List<TemplatesModel> get templates => _templates;

  /// Parses the JSON string from Remote Config and updates the template list.
  void initializeWithJson(String jsonString) {
    if (jsonString.isEmpty) {
      debugPrint("TemplateProvider: Received empty JSON string.");
      templatesLoading = false;
      notifyListeners();
      return;
    }

    try {
      final decodedData = jsonDecode(jsonString);

      if (decodedData is List) {
        _templates = decodedData
            .map(
              (item) => TemplatesModel.fromJson(item as Map<String, dynamic>),
            )
            .toList();
      } else if (decodedData is Map && decodedData.containsKey('templates')) {
        final List<dynamic> templateList = decodedData['templates'];
        _templates = templateList
            .map(
              (item) => TemplatesModel.fromJson(item as Map<String, dynamic>),
            )
            .toList();
      }

      templatesLoading = false;
      notifyListeners();
      debugPrint(
        "TemplateProvider: Successfully initialized with ${_templates.length} templates.",
      );
    } catch (e) {
      templatesLoading = false;
      notifyListeners();
      debugPrint("TemplateProvider: Error parsing templates JSON: $e");
    }
  }

  void loadHardcodedTemplates() {
    final List<Map<String, dynamic>> data = [
      {
        "gradient": "",
        "title": "",
        "content": "",
        "bgImage":
            "",
        "badgeContent": "",
        "isCustom": bool,
      },
    ];

    _templates = data.map((e) => TemplatesModel.fromJson(e)).toList();

    templatesLoading = false;
    notifyListeners();
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

  /// Checks if the camera permission has been granted.
  ///
  /// Requests and verifies the camera permission status.
  /// Returns `true` if the permission is granted, otherwise `false`.
  Future<bool> checkCameraPermission() async {
  var status = await Permission.camera.status;
  if (status.isDenied) {
    status = await Permission.camera.request();
  }
  return status.isGranted;
}
}
