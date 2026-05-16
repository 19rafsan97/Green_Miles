import 'package:flutter/material.dart';
import 'package:green_miles_app/core/app_assets.dart';
import 'package:green_miles_app/core/app_strings.dart';

class BrandLogo extends StatelessWidget {
  const BrandLogo({
    super.key,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
  });

  final double? width;
  final double? height;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      AppAssets.appLogo,
      width: width,
      height: height,
      fit: fit,
      semanticLabel: AppStrings.appName,
    );
  }
}

