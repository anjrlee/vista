import 'package:flutter/material.dart';
import 'home/home.dart';
import 'camera/camera.dart';
import 'profile/profile.dart';
import 'album/album.dart';
import 'package:camera/camera.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:io';

late List<CameraDescription> _cameras;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  print("hello");
  print('Current working dir: ${Directory.current.path}');
  await dotenv.load(fileName: '.env');
  print('API_BASE_URL: ${dotenv.env['API_BASE_URL']}');
  _cameras = await availableCameras(); // 初始化相機
  runApp(NavigationBarApp(cameras: _cameras)); // 傳給App
}

class NavigationBarApp extends StatelessWidget {
  final List<CameraDescription> cameras;

  const NavigationBarApp({super.key, required this.cameras});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: NavigationExample(cameras: cameras),
    );
  }
}

class NavigationExample extends StatefulWidget {
  final List<CameraDescription> cameras;

  const NavigationExample({super.key, required this.cameras});

  @override
  State<NavigationExample> createState() => _NavigationExampleState();
}

class _NavigationExampleState extends State<NavigationExample> {
  int currentPageIndex = 0;

  // 建立 GlobalKey 用於控制 AlbumPage
  final GlobalKey<AlbumPageState> albumPageKey = GlobalKey<AlbumPageState>();

  void switchToAlbum() {
    setState(() {
      currentPageIndex = 1; // 切到相簿頁
    });
    // 延遲呼叫刷新照片，確保頁面已建立
    Future.delayed(const Duration(milliseconds: 100), () {
      albumPageKey.currentState?.fetchPhotos();
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      const HomePage(),
      AlbumPage(key: albumPageKey),
      CameraPage(
        cameras: widget.cameras,
        onSwitchToAlbum: switchToAlbum,  // 傳callback
      ),
      const ProfilePage(),
    ];

    return Scaffold(
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
          setState(() {
            currentPageIndex = index;
          });

          // 每次切換到相簿頁時刷新照片
          if (index == 1) {
            Future.delayed(const Duration(milliseconds: 100), () {
              albumPageKey.currentState?.fetchPhotos();
            });
          }
        },
        indicatorColor: Colors.amber,
        selectedIndex: currentPageIndex,
        destinations: const <Widget>[
          NavigationDestination(
            selectedIcon: Icon(Icons.home),
            icon: Icon(Icons.home_outlined),
            label: '',
          ),
          NavigationDestination(
            icon: Icon(Icons.photo),
            label: '',
          ),
          NavigationDestination(
            icon: Icon(Icons.camera_alt),
            label: '',
          ),
          NavigationDestination(
            icon: Badge(
              isLabelVisible: false,
              child: Icon(Icons.person),
            ),
            label: '',
          ),
        ],
      ),
      body: pages[currentPageIndex],
    );
  }
}
