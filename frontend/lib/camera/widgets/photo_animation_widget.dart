// widgets/photo_animation_widget.dart
import 'dart:typed_data';
import 'package:flutter/material.dart';

class PhotoAnimationWidget extends StatelessWidget {
  final Uint8List capturedBytes;
  final double imageSize;
  final double left;
  final double top;

  const PhotoAnimationWidget({
    super.key,
    required this.capturedBytes,
    required this.imageSize,
    required this.left,
    required this.top,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOut,
      left: left,
      top: top,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 600),
        width: imageSize,
        height: imageSize,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: MemoryImage(capturedBytes),
            fit: BoxFit.cover,
          ),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: const [
            BoxShadow(
              color: Colors.black38,
              blurRadius: 8,
              offset: Offset(2, 2),
            ),
          ],
        ),
      ),
    );
  }
}