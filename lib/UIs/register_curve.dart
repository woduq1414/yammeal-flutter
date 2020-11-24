import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import "../common/color.dart";
class RegisterPageUI extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'register',
      home: RegisterUI(),
    );
  }
}

class RegisterUI extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _buildCurveBottom(),
    );
  }

  Widget _buildCurveBottom() {
    return Builder(
      builder: (context) {
        return Stack(
          children: <Widget>[
            CustomPaint(
              size: MediaQuery.of(context).size,
              painter: Painter1(),
            ),
            Opacity(
              opacity: 0.7,
              child: CustomPaint(
                size: MediaQuery.of(context).size,
                painter: Painter2(),
              ),
            )
          ],
        );
      },
    );
  }

}

class Painter1 extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = new Paint()
      ..color = primaryRed
      ..style = PaintingStyle.fill;

    final h = size.height;
    final w = size.width;

    Path path = new Path();
    path.moveTo(0, h);
    path.lineTo(0, h * 0.81);
    path.cubicTo(w * 0.5, h * 0.7, w*0.9, h*0.85, w, h * 0.9);
    path.lineTo(w, h);
    path.lineTo(0, h);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

class Painter2 extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = new Paint()
      ..color = Color(0xffFF7039)
      ..style = PaintingStyle.fill;

    final h = size.height;
    final w = size.width;

    Path path = new Path();
    path.moveTo(-20, h);
    path.lineTo(-20, h * 0.8);
    path.cubicTo(0, h*0.75, w * 0.2, h * 0.8, w * 0.3, h * 0.8);
    path.quadraticBezierTo(w * 0.65, h * 0.85, w, h * 0.75);
    path.lineTo(w, h);
    path.lineTo(0, h);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}