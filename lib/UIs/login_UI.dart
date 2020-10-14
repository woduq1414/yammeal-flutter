import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'main_page.dart';
import 'login_UI.dart';
import 'dart:math' as Math;
import "../common/color.dart";
void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HELP ME',
      theme: ThemeData(
        primaryColor: Colors.red,
        fontFamily: 'GmarketSans'
      ),
      home: MainPage(),
    );
  }
}

class MainPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        resizeToAvoidBottomInset: false,
        resizeToAvoidBottomPadding: false,
        body: SingleChildScrollView(
          child: Stack(
            children: [
              _buildUpperCurvePainter(),
              //SizedBox(height: 100,),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                //crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: EdgeInsets.only(top: 165),
                    child: Text(
                      '오늘 뭐먹지?',
                      style: TextStyle(
                        fontSize: 30,
                      ),
                    ),
                  ),
                  Container(
                    //margin: EdgeInsets.only(bottom: 120),
                    child: Image.asset(
                      'assets/yam_logo.jpg',
                      width: 150,
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Container(
                    child: _buildTextFields(context),
                  )
                ],
              )
            ],
          ),
        )
    );
  }

  Widget _buildTextFields(context) {
    return Builder(
      builder: (context) {
        return Container(
            margin: EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              children: <Widget>[
                TextField(
                  maxLines: 1,
                  maxLength: 30,
                  decoration: InputDecoration(
                    hintText: '아이디',
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                    contentPadding: EdgeInsets.fromLTRB(20, 0, 0, 0),
                  ),
                ),
                TextField(
                  maxLines: 1,
                  maxLength: 30,
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: '비밀번호',
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                    contentPadding: EdgeInsets.fromLTRB(20, 0, 0, 0),
                  ),
                ),
                SizedBox(height: 20,),
                ButtonTheme(
                  minWidth: 320,
                  height: 40,
                  child: RaisedButton(
                    color: Colors.red,
                    child: Text(
                      '로그인', style: TextStyle(fontSize: 20),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                    onPressed: () {
                      Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => MealMainUI()) // 여기선 걍 로그인 누르면 메인 화면으로 넘어가게 함
                      );
                    },
                  ),
                ),
                _buildDivisionLine(),
                ButtonTheme(
                  minWidth: 320,
                  height: 40,
                  child: RaisedButton(
                    color: Colors.blueAccent,
                    child: Text(
                      'Facebook', style: TextStyle(fontSize: 20, color: Colors.white),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                    onPressed: () {},
                  ),
                ),
                ButtonTheme(
                  minWidth: 320,
                  height: 40,
                  child: RaisedButton(
                    color: Colors.lightGreen,
                    child: Text(
                      'Naver', style: TextStyle(fontSize: 20, color: Colors.white),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                    onPressed: () {
                      print("pressed");
                    },
                  ),
                ),
                SizedBox(height: 30,),
                ButtonTheme(
                  minWidth: 100,
                  height: 40,
                  child: RaisedButton(
                    color: Colors.white,
                    child: Text(
                      '회원가입', style: TextStyle(fontSize: 20, color: Colors.grey),
                    ),
                    onPressed: () {},
                  ),
                ),
              ],

            ));
      },
    );
  }

  Widget _buildDivisionLine() {
    return Container(
      margin: EdgeInsets.fromLTRB(10, 30, 10, 30),
      child: Row(
        children: <Widget>[
          Container(
            width: 142,
            height: 2,
            color: Colors.black,
          ),
          Text(
            ' OR ',
            style: TextStyle(color: Colors.black),
          ),
          Container(
            width: 142,
            height: 2,
            color: Colors.black,
          ),
        ],
      ),
    );

  }

  Widget _buildUpperCurvePainter() {
    return Builder(
      builder: (context) {
        return Stack(
          children: <Widget>[
            CustomPaint(
              size: MediaQuery.of(context).size,
              painter: Painter2(),
            ),
            Opacity(
              opacity: 0.7,
              child: CustomPaint(
                size: MediaQuery.of(context).size,
                painter: Painter1(),
              ),
            ),
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
      ..color = Color(0xffFF7039)
      ..style = PaintingStyle.fill
      ..strokeWidth = 8.0;

    Path path = new Path();
    path.moveTo(-50, 0);
    path.lineTo(-50, size.height * 0.27);
    path.cubicTo(size.width * 0.2, size.height * 0.15, size.width * 0.45,
        size.height * 0.08, size.width * 0.6, size.height * 0.12);
    path.cubicTo(size.width, size.height * 0.25, size.width, size.height * 0.25,
        size.width * 1.05, size.height * 0.02);
    path.lineTo(size.width, 0);
    path.lineTo(0, 0);
    canvas.drawPath(path, paint);
  }

  num degToRad(num deg) => deg * (Math.pi / 180.0);

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

class Painter2 extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = new Paint()
      ..color = primaryRed
      ..style = PaintingStyle.fill
      ..strokeWidth = 8.0;

    Path path = new Path();
    path.moveTo(-50, 0);
    path.lineTo(-50, size.height * 0.2);
    path.cubicTo(-20, size.height * 0.2, size.width * 0.15, size.height * 0.05,
        size.width * 0.51, size.height * 0.2);
    path.cubicTo(size.width * 0.65, size.height * 0.25, size.width * 0.85,
        size.height * 0.25, size.width, size.height * 0.16);
    path.lineTo(size.width, 0);
    path.lineTo(0, 0);
    canvas.drawPath(path, paint);
  }

  num degToRad(num deg) => deg * (Math.pi / 180.0);

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}