import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:typed_data';

class AlbumPage extends StatefulWidget {
  const AlbumPage({super.key});

  @override
  AlbumPageState createState() => AlbumPageState();
}

class AlbumPageState extends State<AlbumPage> {
  List<AssetEntity> photos = [];
  Set<AssetEntity> selectedPhotos = {};
  bool isLoading = true;
  bool selectionMode = false;

  @override
  void initState() {
    super.initState();
    fetchPhotos();
  }

  Future<void> fetchPhotos() async {
    setState(() => isLoading = true);

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
      List<AssetEntity> media =
      await albums[0].getAssetListPaged(page: 0, size: 100);
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

  void toggleSelection(AssetEntity photo) {
    setState(() {
      if (selectedPhotos.contains(photo)) {
        selectedPhotos.remove(photo);
      } else {
        selectedPhotos.add(photo);
      }
    });
  }

  void cancelSelection() {
    setState(() {
      selectedPhotos.clear();
      selectionMode = false;
    });
  }

  Future<void> filterSelectedPhotos() async {
    if (selectedPhotos.length > 30) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('一次最多 30 張照片')),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('確認過濾?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('確認'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final baseUrl = dotenv.env['API_BASE_URL'];
    if (baseUrl == null) return;

    final List<String> ids = selectedPhotos.map((e) => e.id).toList();

    try {


      final response = await http.post(
        Uri.parse('$baseUrl/filterAlbum'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'photo_ids': ids}),
      );

      if (response.statusCode == 200) {
        final List<bool> results = List<bool>.from(jsonDecode(response.body));
        List<AssetEntity> toKeep = [];
        int index = 0;
        for (var photo in selectedPhotos) {
          if (results[index]) {
            toKeep.add(photo);
          } else {
            await PhotoManager.editor.deleteWithIds([photo.id]);

          }
          index++;
        }

        setState(() {
          selectedPhotos.clear();
          selectionMode = false;
        });

        await fetchPhotos(); // 重新刷新照片

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('已完成過濾')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('伺服器錯誤：${response.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('發送失敗：$e')),
      );
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
      appBar: AppBar(
        title: selectionMode
            ? Text('已選取 ${selectedPhotos.length} 張')
            : const Text('相簿'),
        leading: selectionMode
            ? TextButton(
          onPressed: cancelSelection,
          child: const Text('取消'),
        )
            : null,
        actions: [
          if (!selectionMode)
            TextButton(
              onPressed: () {
                setState(() {
                  selectionMode = true;
                });
              },
              child:
              const Text('選取'),
            ),
          if (selectionMode)
            TextButton(
              onPressed: filterSelectedPhotos,
              child:
              const Text('篩選'),
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GridView.builder(
          itemCount: photos.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 4,
            mainAxisSpacing: 4,
          ),
          itemBuilder: (context, index) {
            final photo = photos[index];
            final isSelected = selectedPhotos.contains(photo);

            return GestureDetector(
              onTap: selectionMode ? () => toggleSelection(photo) : null,
              child: Stack(
                children: [
                  FutureBuilder<Uint8List?>(
                    future: photo.thumbnailDataWithSize(
                        const ThumbnailSize(200, 200)),
                    builder: (context, snapshot) {
                      final bytes = snapshot.data;
                      if (snapshot.connectionState ==
                          ConnectionState.done &&
                          bytes != null) {
                        return Positioned.fill(
                          child: Image.memory(bytes, fit: BoxFit.cover),
                        );
                      }
                      return Container(color: Colors.grey[300]);
                    },
                  ),
                  if (selectionMode)
                    Positioned(
                      top: 4,
                      right: 4,
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.blue : Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.black),
                        ),
                        padding: const EdgeInsets.all(4),
                        child: Icon(
                          isSelected
                              ? Icons.check
                              : Icons.check_box_outline_blank,
                          color: isSelected ? Colors.white : Colors.black,
                          size: 18,
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
