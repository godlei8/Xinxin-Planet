import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';

class PetModelView extends StatelessWidget {
  const PetModelView({
    super.key,
    required this.modelAsset,
    required this.alt,
    this.autoRotate = true,
    this.cameraControls = false,
    this.backgroundColor = Colors.transparent,
  });

  final String modelAsset;
  final String alt;
  final bool autoRotate;
  final bool cameraControls;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: backgroundColor,
      child: ModelViewer(
        src: modelAsset,
        alt: alt,
        ar: false,
        autoRotate: autoRotate,
        cameraControls: cameraControls,
      ),
    );
  }
}
