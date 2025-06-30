import 'dart:typed_data';
import 'package:flutter/material.dart';

class CameraControlsWidget extends StatelessWidget {
  final Uint8List? latestThumbnail;
  final VoidCallback onTakePicture;
  final VoidCallback? onSwitchToAlbum;
  final VoidCallback onShowFilter;
  final VoidCallback onShowAction;
  final VoidCallback onShowComposition;

  const CameraControlsWidget({
    super.key,
    this.latestThumbnail,
    required this.onTakePicture,
    this.onSwitchToAlbum,
    required this.onShowFilter,
    required this.onShowAction,
    required this.onShowComposition,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 30,
      left: 0,
      right: 0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // 相簿按鈕
          _AlbumButton(
            thumbnail: latestThumbnail,
            onPressed: onSwitchToAlbum,
          ),

          // 濾鏡按鈕
          _ControlButton(
            icon: Icons.tonality,
            onPressed: onShowFilter,
          ),

          // 拍照按鈕
          _CaptureButton(onPressed: onTakePicture),

          // 動作按鈕
          _ControlButton(
            icon: Icons.accessibility_new,
            onPressed: onShowAction,
          ),

          // 構圖按鈕
          _ControlButton(
            icon: Icons.grid_on,
            onPressed: onShowComposition,

          ),
        ],
      ),
    );
  }
}

class _AlbumButton extends StatelessWidget {
  final Uint8List? thumbnail;
  final VoidCallback? onPressed;

  const _AlbumButton({
    this.thumbnail,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      iconSize: 40,
      icon: thumbnail != null
          ? ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: Image.memory(
          thumbnail!,
          width: 40,
          height: 40,
          fit: BoxFit.cover,
        ),
      )
          : const Icon(Icons.photo_library, size: 30, color: Colors.white),
      onPressed: onPressed,
    );
  }
}

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _ControlButton({
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon, size: 30, color: Colors.white),
      onPressed: onPressed,
    );
  }
}

class _CaptureButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _CaptureButton({
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 4),
          color: Colors.white70,
        ),
      ),
    );
  }
}