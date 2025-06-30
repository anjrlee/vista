import 'package:flutter/material.dart';

class CameraHintText extends StatefulWidget {
  final bool hasButton;
  final bool hasText;
  final String buttonText;
  final String textText;
  final void Function(String)? onButtonTap;

  const CameraHintText({
    super.key,
    this.hasButton = false,
    this.hasText = false,
    this.buttonText = '知道了',
    this.textText = '請上下左右移動相機調整構圖',
    this.onButtonTap,
  });

  @override
  State<CameraHintText> createState() => _CameraHintTextState();
}

class _CameraHintTextState extends State<CameraHintText> {
  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 60,
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.black54,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.hasText)
                Text(
                  widget.textText,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              if (widget.hasButton)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: GestureDetector(
                    onTap: () {
                      if (widget.onButtonTap != null) {
                        widget.onButtonTap!(widget.buttonText);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.white.withOpacity(0.6), width: 1),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            offset: const Offset(0, 2),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: Text(
                        widget.buttonText,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ),


                ),
            ],
          ),
        ),
      ),
    );
  }
}
