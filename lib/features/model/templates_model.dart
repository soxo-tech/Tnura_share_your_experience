// To parse this JSON data, do
//
//     final templatesModel = templatesModelFromJson(jsonString?);

import 'package:flutter/material.dart';
import 'dart:convert';

List<TemplatesModel> templatesModelFromJson(String? str) =>
    List<TemplatesModel>.from(
        json.decode(str!).map((x) => TemplatesModel.fromJson(x)),);

String? templatesModelToJson(List<TemplatesModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class TemplatesModel {
  String? gradient;
  String? title;
  String? content;
  String? bgImage;
  String? badgeContent;
  bool? isCustom;

  TemplatesModel({
    this.gradient,
    this.title,
    this.content,
    this.bgImage,
    this.badgeContent,
    this.isCustom,
  });

  factory TemplatesModel.fromJson(Map<String, dynamic> json) => TemplatesModel(
        gradient: json["gradient"],
        title: json["title"],
        content: json["content"],
        bgImage: json["bgImage"],
        badgeContent: json["badgeContent"],
        isCustom: json["isCustom"],
      );

  Map<String?, dynamic> toJson() => {
        "gradient": gradient,
        "title": title,
        "content": content,
        "bgImage": bgImage,
        "badgeContent": badgeContent,
        "isCustom": isCustom,
      };

  /// Converts a hex color string (e.g., "#FFFFFF") to a Flutter [Color].
  static Color hexToColor(String? code) {
    if (code == null || code.isEmpty || !code.startsWith('#') || code.length < 7) {
      return Colors.white;
    }
    return Color(int.parse(code.substring(1, 7), radix: 16) + 0xFF000000);
  }
}
