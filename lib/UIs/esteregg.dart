import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import 'package:meal_flutter/common/widgets/dialog.dart';
import 'package:shake/shake.dart';

class EasterEgg extends StatefulWidget {
  @override
  _EasterEggState createState() => _EasterEggState();
}

class _EasterEggState extends State<EasterEgg>  with SingleTickerProviderStateMixin{
  int _counter = 0;
  int _shakeCounter = 0;
  AnimationController _controller;
  void initState() {
    _controller = AnimationController(vsync: this, duration: Duration(seconds: 2))..repeat();
    super.initState();

    ShakeDetector detector = ShakeDetector.autoStart(onPhoneShake: () {
      setState(() {
        _counter = _counter + 70;
        _shakeCounter = _shakeCounter + 1;
      });

    });

    // To close: detector.stopListening();
    // ShakeDetector.waitForStart() waits for user to call detector.startListening();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              if (_shakeCounter < 10) Column(
                      children: <Widget>[
                        RotationTransition(
                          turns: new AlwaysStoppedAnimation((_counter % 360) / 360),
                          child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _counter = _counter + 10;
                                  print((sin(_counter) * 50 + 400));
                                });
                              },
                              child: Image.asset(
                                'assets/easter.jpg',
                                height: (sin(_counter / 100) * 50 + 400).toDouble(),
                                color: Color.lerp(Colors.yellow, Colors.blue, ((_counter % 100) / 100).toDouble()),
                                colorBlendMode: _counter % 20 == 0 ? BlendMode.softLight : BlendMode.modulate,
                              )),
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        Text(
                          "당신은 행운의 고양이를 \n 차잤씁니다!!!!1",
                          style: TextStyle(fontSize: 25),
                          textAlign: TextAlign.center,
                        )
                      ],
                    ) else Column(
                children: <Widget>[
                  AnimatedBuilder(
                    animation: _controller,
                    builder: (_, child) {
                      return Transform.rotate(
                        angle: _controller.value * 2 * pi,
                        child: child,
                      );
                    },
                    child: Image.asset(
                      'assets/carrot.png',
                      height: 250
                    ),
                  ),
                  SizedBox(
                    height: 50,
                  ),
                  Text(
                    "살...려..ㅈ...ㅝ",
                    style: TextStyle(fontSize: 18),
                    textAlign: TextAlign.center,
                  )
                ],
              ),
              SizedBox(
                height: 15,
              ),
              Text(
                '개발진 - \n디자인 - 박건형, 손호진\n백엔드 개발 - 정재엽, 손호진, 윤진혁, 이희태, 천준민\n앱 개발 - 정재엽, 안유성',
                textAlign: TextAlign.center,
              ),
              SizedBox(
                height: 50,
              )
            ],
          ),
        ),
      ),
    );
  }
}
