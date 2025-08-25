import 'package:flutter/material.dart';

class AIButton extends StatelessWidget {
  final VoidCallback onPressed;

  const AIButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: const Offset(8, -12), // 右に8px、上に8px移動
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          clipBehavior: Clip.antiAlias,
          decoration: ShapeDecoration(
            color: const Color(0xFFEADDFF) /* Schemes-Primary-Container */,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            shadows: [
              BoxShadow(
                color: Color(0x4C000000),
                blurRadius: 3,
                offset: Offset(0, 1),
                spreadRadius: 0,
              ),
              BoxShadow(
                color: Color(0x26000000),
                blurRadius: 6,
                offset: Offset(0, 4),
                spreadRadius: 1,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  spacing: 8,
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(),
                      child: Image.asset('assets/icons/calendar-ai.png'),
                    ),
                    Text(
                      'AI絵日記を見てみる',
                      style: TextStyle(
                        color: const Color(
                          0xFF4F378A,
                        ) /* Schemes-On-Primary-Container */,
                        fontSize: 16,
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w500,
                        height: 1.50,
                        letterSpacing: 0.15,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ), // Transform.translateの閉じ括弧
    );
  }
}
