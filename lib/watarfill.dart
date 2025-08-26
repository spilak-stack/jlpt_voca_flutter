import 'dart:math';
import 'package:flutter/material.dart';

class WaterFillElevatedButton extends StatefulWidget {
  final double width;
  final double height;
  final double progress;
  final VoidCallback onPressed;
  final String text; // 텍스트 추가

  WaterFillElevatedButton({
    required this.width,
    required this.height,
    required this.progress,
    required this.onPressed,
    required this.text, // 텍스트 추가
  });

  @override
  _WaterFillElevatedButtonState createState() =>
      _WaterFillElevatedButtonState();
}

class _WaterFillElevatedButtonState extends State<WaterFillElevatedButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: widget.onPressed,
      style: ElevatedButton.styleFrom(
        minimumSize: Size(widget.width, widget.height),
        padding: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        elevation: 5,
      ).copyWith(
        overlayColor: MaterialStateProperty.all(Colors.transparent),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Stack(
          // Stack 사용
          children: [
            AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return CustomPaint(
                  size: Size(widget.width, widget.height),
                  painter: WaterFillPainter(
                    progress: widget.progress,
                    waveAnimation: _animationController.value,
                  ),
                );
              },
            ),
            SizedBox(
                width: 200,
                height: 100,
                child: Center(
                  child: Text(
                    widget.text,
                    style:
                        TextStyle(fontSize: 30, fontWeight: FontWeight.normal),
                    // overflow: TextOverflow.ellipsis, // overflow 속성 추가
                  ),
                ))
          ],
        ),
      ),
    );
  }
}

class WaterFillPainter extends CustomPainter {
  final double progress;
  final double waveAnimation;

  WaterFillPainter({required this.progress, required this.waveAnimation});

  @override
  void paint(Canvas canvas, Size size) {
    final wavePaint = Paint()
      ..color = Colors.blue.withOpacity(0.5)
      ..style = PaintingStyle.fill;

    final progressHeight = size.height * (1 - progress);
    final waveHeight = size.height * 0.05;

    final wavePath = Path();
    wavePath.moveTo(
        0, progressHeight + waveHeight * sin(waveAnimation * 2 * pi));
    for (double i = 0; i <= size.width; i++) {
      wavePath.lineTo(
          i,
          progressHeight +
              waveHeight *
                  sin((waveAnimation * 2 * pi) + (i / size.width) * 2 * pi));
    }
    wavePath.lineTo(size.width, size.height);
    wavePath.lineTo(0, size.height);
    wavePath.close();

    canvas.drawPath(wavePath, wavePaint);
  }

  @override
  bool shouldRepaint(WaterFillPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.waveAnimation != waveAnimation;
  }
}
