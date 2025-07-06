import 'package:flutter/material.dart';

class PhotoScore extends StatelessWidget {
  const PhotoScore({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('照片評分'),

      ),
      body: const Center(
        child: Text(
          'Hello',
          style: TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
