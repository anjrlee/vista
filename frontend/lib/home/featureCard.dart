import 'dart:async';
import 'package:flutter/material.dart';

class FeatureCard extends StatefulWidget {
  final List<String> imageUrls;
  final String title;
  final bool isMultiPhoto;
  final bool showLock;
  final VoidCallback? onTap;

  const FeatureCard({
    Key? key,
    required this.imageUrls,
    required this.title,
    this.isMultiPhoto = false,
    this.showLock = true,
    this.onTap,
  }) : super(key: key);

  @override
  State<FeatureCard> createState() => _FeatureCardState();
}

class _FeatureCardState extends State<FeatureCard> {
  int currentPage = 0;
  PageController? _pageController;
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    if (widget.isMultiPhoto && widget.imageUrls.length > 1) {
      _pageController = PageController(initialPage: 0);
      _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
        if (!mounted || _pageController == null) return;
        setState(() {
          currentPage = (currentPage + 1) % widget.imageUrls.length;
          _pageController!.animateToPage(
            currentPage,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        });
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final bool hasMultiplePhotos = widget.isMultiPhoto && widget.imageUrls.length > 1;

    Widget backgroundImage = hasMultiplePhotos && _pageController != null
        ? PageView.builder(
      controller: _pageController,
      itemCount: widget.imageUrls.length,
      itemBuilder: (context, index) {
        return _buildBackground(widget.imageUrls[index]);
      },
    )
        : _buildBackground(widget.imageUrls.first);

    return InkWell(
      onTap: widget.onTap,
      borderRadius: BorderRadius.circular(16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          fit: StackFit.expand,
          children: [
            backgroundImage,
            Container(color: Colors.black.withOpacity(0.4)), // 半透明遮罩
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Spacer(),
                  Text(
                    widget.title,
                    style: theme.textTheme.titleMedium?.copyWith(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  if (widget.showLock)
                    const Icon(Icons.lock, size: 36, color: Colors.white70),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackground(String url) {
    return Image.asset(
      url,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        print('圖片載入失敗：$error'); // ← 打印錯誤訊息
        return Container(color: Colors.grey);
      },

    );
  }
}
