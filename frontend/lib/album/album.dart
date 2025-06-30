// album.dart
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'dart:typed_data';

class AlbumPage extends StatefulWidget {
  const AlbumPage({super.key});

  @override
  AlbumPageState createState() => AlbumPageState();
}

class AlbumPageState extends State<AlbumPage> {
  List<AssetEntity> photos = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchPhotos();
  }

  Future<void> fetchPhotos() async {
    setState(() {
      isLoading = true;
    });

    final permitted = await PhotoManager.requestPermissionExtend();
    if (!permitted.isAuth) {
      setState(() {
        isLoading = false;
        photos = [];
      });
      return;
    }

    List<AssetPathEntity> albums = await PhotoManager.getAssetPathList(
      onlyAll: true,
      type: RequestType.image,
    );

    if (albums.isNotEmpty) {
      List<AssetEntity> media = await albums[0].getAssetListPaged(page: 0, size: 100);
      setState(() {
        photos = media;
        isLoading = false;
      });
    } else {
      setState(() {
        photos = [];
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (photos.isEmpty) {
      return const Scaffold(
        body: Center(child: Text('沒有找到照片')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('相簿')),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GridView.builder(
          itemCount: photos.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3, crossAxisSpacing: 4, mainAxisSpacing: 4),
          itemBuilder: (context, index) {
            final photo = photos[index];
            return FutureBuilder<Uint8List?>(
              future: photo.thumbnailDataWithSize(const ThumbnailSize(200, 200)),
              builder: (context, snapshot) {
                final bytes = snapshot.data;
                if (snapshot.connectionState == ConnectionState.done && bytes != null) {
                  return Image.memory(bytes, fit: BoxFit.cover);
                }
                return Container(color: Colors.grey[300]);
              },
            );
          },
        ),
      ),
    );
  }
}
