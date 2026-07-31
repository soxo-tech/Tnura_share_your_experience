import 'package:flutter_test/flutter_test.dart';
import 'package:share_your_experience/features/model/templates_model.dart';
import 'package:share_your_experience/features/provider/templates_provider.dart';

/// Unit tests for [TemplateProvider].
///
/// These focus on the host-driven template flow ([TemplateProvider.setTemplates])
/// that backs the launcher integration. The camera/crop methods are not covered
/// here because they depend on platform plugins (image_picker, image_cropper,
/// permission_handler) that require a device.
void main() {
  group('TemplateProvider.setTemplates', () {
    late TemplateProvider provider;

    setUp(() {
      provider = TemplateProvider();
    });

    test('starts in a loading state with no templates', () {
      expect(provider.templatesLoading, isTrue);
      expect(provider.templates, isEmpty);
    });

    test('stores the templates supplied by the host', () {
      final templates = [
        TemplatesModel(title: 'Template A'),
        TemplatesModel(title: 'Template B'),
      ];

      provider.setTemplates(templates);

      expect(provider.templates, hasLength(2));
      expect(provider.templates.first.title, 'Template A');
    });

    test('clears the loading flag once templates are set', () {
      provider.setTemplates([TemplatesModel(title: 'Template A')]);

      expect(provider.templatesLoading, isFalse);
    });

    test('accepts an empty list and clears loading (error state)', () {
      provider.setTemplates([]);

      expect(provider.templates, isEmpty);
      expect(provider.templatesLoading, isFalse);
    });

    test('notifies listeners when templates are set', () {
      var notifications = 0;
      provider.addListener(() => notifications++);

      provider.setTemplates([TemplatesModel(title: 'Template A')]);

      expect(notifications, 1);
    });

    test('replaces previously set templates', () {
      provider.setTemplates([TemplatesModel(title: 'Old')]);
      provider.setTemplates([
        TemplatesModel(title: 'New 1'),
        TemplatesModel(title: 'New 2'),
      ]);

      expect(provider.templates.map((t) => t.title), ['New 1', 'New 2']);
    });
  });

  group('TemplatesModel.hexToColor', () {
    test('parses a valid hex string into an opaque colour', () {
      final color = TemplatesModel.hexToColor('#FFB198');

      expect(color.toARGB32(), 0xFFFFB198);
    });

    test('falls back to white for null or malformed input', () {
      expect(TemplatesModel.hexToColor(null).toARGB32(), 0xFFFFFFFF);
      expect(TemplatesModel.hexToColor('').toARGB32(), 0xFFFFFFFF);
      expect(TemplatesModel.hexToColor('FFB198').toARGB32(), 0xFFFFFFFF);
    });
  });
}
