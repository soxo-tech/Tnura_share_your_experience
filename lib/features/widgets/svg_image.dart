
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SvgImage extends StatelessWidget {
  final String svgPath;
  final double? svgWidth;
  final Color? color;
  final BoxFit? fit;
  final String? packageName;

  const SvgImage({
    super.key,
    required this.svgPath,
    this.svgWidth,
    this.color,
        this.fit,
        this.packageName

  });

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      'assets/svg/$svgPath.svg',
      package: packageName,
      fit: fit ?? BoxFit.cover,
      width: svgWidth,
      colorFilter: color != null
          ? ColorFilter.mode(color!, BlendMode.srcIn)
          : null,
    );
  }
}