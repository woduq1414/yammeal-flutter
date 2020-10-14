import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:meal_flutter/common/font.dart';

class Setting extends StatefulWidget {
  @override
  _SettingState createState() => _SettingState();
}

FontSize fs;

class _SettingState extends State<Setting> {
  @override
  Widget build(BuildContext context) {
    fs = FontSize(context);
    return Container(
      margin: EdgeInsets.only(top: MediaQuery.of(context).size.height*0.55),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text('불쌍한 고딩 개발자들을 위해\n 아래 광고 한번 눌러주십쇼...', style: TextStyle(fontSize: fs.s4),),
          Text('↓', style: TextStyle(fontSize: 200),)
        ],
      ),
    );
  }
}
