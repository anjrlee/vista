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
    Future.delayed(const Duration(milliseconds: 200), () {
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
        onSwitchToAlbum: switchToAlbum, // 傳callback
      ),
      const ProfilePage(),
    ];

    return Scaffold(
      bottomNavigationBar: Container(
        margin: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.15), // 半透明淡灰背景
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: NavigationBar(
          height: 60,
          backgroundColor: Colors.transparent,
          elevation: 0,
          indicatorColor: Colors.black.withOpacity(0.05), // 柔和粉色透明指示器
          animationDuration: const Duration(milliseconds: 250),
          labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
          selectedIndex: currentPageIndex,
          onDestinationSelected: (int index) {
            setState(() {
              currentPageIndex = index;
            });

            if (index == 1) {
              Future.delayed(const Duration(milliseconds: 100), () {
                albumPageKey.currentState?.fetchPhotos();
              });
            }
          },
          destinations: [
            _buildNavDestination(
              icon: Icons.home_outlined,
              selectedIcon: Icons.home,
              selected: currentPageIndex == 0,
            ),
            _buildNavDestination(
              icon: Icons.photo_outlined,
              selectedIcon: Icons.photo,
              selected: currentPageIndex == 1,
            ),
            _buildNavDestination(
              icon: Icons.camera_alt_outlined,
              selectedIcon: Icons.camera_alt,
              selected: currentPageIndex == 2,
            ),
            NavigationDestination(
              icon: Badge(
                isLabelVisible: false,
                child: Icon(
                  Icons.person_outline,
                  color: currentPageIndex == 3
                      ? Colors.pink.shade400
                      : Colors.grey.shade600,
                  size: 26,
                ),
              ),
              selectedIcon: Badge(
                isLabelVisible: false,
                child: Icon(
                  Icons.person,
                  color: Colors.pink.shade600,
                  size: 28,
                ),
              ),
              label: '',
            ),
          ],
        ),
      ),
      body: pages[currentPageIndex],
    );
  }

  NavigationDestination _buildNavDestination({
    required IconData icon,
    required IconData selectedIcon,
    required bool selected,
  }) {
    return NavigationDestination(
      icon: AnimatedScale(
        scale: selected ? 1.2 : 1.0,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        child: Icon(
          icon,
          color: Colors.grey.shade600,
          size: 26,
        ),
      ),
      selectedIcon: AnimatedScale(
        scale: selected ? 1.2 : 1.0,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        child: Icon(
          selectedIcon,
          color: Colors.blue.shade300,
          size: 28,
        ),
      ),
      label: '',
    );
  }
}
