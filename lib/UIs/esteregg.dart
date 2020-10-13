import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class EasterEgg extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Image.asset('assets/easter.jpg', height: 500,),
              Text('개발진 - \n디자인 - 박건형\n백엔드 개발 - 정재엽, 손호진, 윤진혁, 이희태, 천준민\n앱 개발 - 정재엽, 안유성', textAlign: TextAlign.center,),
              SizedBox(height: 50,)
            ],
          ),
        ),
      ),
    );
  }
}