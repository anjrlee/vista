// camera_controls_widget.dart
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

class CameraControlsWidget extends StatefulWidget {
  final Future<void> Function() onTakePicture;
  final VoidCallback? onSwitchToAlbum;
  final VoidCallback onShowFilter;
  final VoidCallback onShowAction;
  final VoidCallback onShowComposition;

  const CameraControlsWidget({
    super.key,
    required this.onTakePicture,
    this.onSwitchToAlbum,
    required this.onShowFilter,
    required this.onShowAction,
    required this.onShowComposition,
  });

  @override
  State<CameraControlsWidget> createState() => _CameraControlsWidgetState();
}

class _CameraControlsWidgetState extends State<CameraControlsWidget> {
  Uint8List? latestThumbnail;

  @override
  void initState() {
    super.initState();
    _loadLatestThumbnail();
  }

  Future<void> _loadLatestThumbnail() async {
    final permission = await PhotoManager.requestPermissionExtend();
    if (!permission.isAuth) return;

    final albums = await PhotoManager.getAssetPathList(onlyAll: true);
    if (albums.isEmpty) return;

    final recentAssets = await albums[0].getAssetListPaged(page: 0, size: 1);
    if (recentAssets.isEmpty) return;

    final thumb = await recentAssets[0].thumbnailDataWithSize(const ThumbnailSize(100, 100));

    if (mounted) {
      setState(() {
        latestThumbnail = thumb;
      });
    }
  }

  Future<void> _handleTakePicture() async {
    await widget.onTakePicture();
    await Future.delayed(const Duration(milliseconds: 500));
    await _loadLatestThumbnail();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 30,
      left: 0,
      right: 0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _AlbumButton(
            thumbnail: latestThumbnail,
            onPressed: widget.onSwitchToAlbum,
          ),
          _ControlButton(
            icon: Icons.tonality,
            onPressed: widget.onShowFilter,
          ),
          _CaptureButton(onPressed: _handleTakePicture),
          _ControlButton(
            icon: Icons.accessibility_new,
            onPressed: widget.onShowAction,
          ),
          _ControlButton(
            icon: Icons.grid_on,
            onPressed: widget.onShowComposition,
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