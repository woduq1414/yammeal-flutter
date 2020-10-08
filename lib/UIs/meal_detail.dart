import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:date_format/date_format.dart';
import 'package:meal_flutter/common/provider/userProvider.dart';
import 'package:speech_bubble/speech_bubble.dart';
import 'package:http/http.dart' as http;

class MealDetailUI extends StatelessWidget {
  DateTime d;
  MealDetailUI(DateTime d) {
    this.d = d;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'meal',
      home: MealDetailState(d),
    );
  }
}

















class MealDetailState extends StatefulWidget {

  DateTime d;
  MealDetailState(DateTime d) {
    this.d = d;
  }

  @override
  MealDetail createState() => MealDetail(d);

}

class MealDetail extends State<MealDetailState> {
  DateTime d;
  MealDetail(DateTime d) {
    this.d = d;
  }

  var _mealList = [];

  @override
  void initState() {
    super.initState();
    getDayMealMenu();
  }

  @override
  Widget build(BuildContext context) {
    print("@@@@");
    return WillPopScope(
      onWillPop: () async{
        print("hello?");
        return true;
      },
      child: Scaffold(
        backgroundColor: Color(0xffFFBB00),
        body: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    return Builder(
      builder: (context) {
        return Container(
          child: Column(
            //crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              SizedBox(height: 70,),
              Center(
                child: Text(formatDate(d, [yyyy, '.', mm, '.', dd]), style: TextStyle(fontSize: 35, color: Colors.white),),
              ),
              SizedBox(height: 15,),
              Column(
                children: _mealList.map<Widget>((menu) {
                  print(_mealList.indexOf(menu));
                  return _buildMenuItem(menu, true);
                }).toList(),
              ),
              // SizedBox(height: 60,),
              // _buildMenuItem('치킨 가라아게 덮밥', true),
              // SizedBox(height: 15,),
              // _buildMenuItem('건새우시래기된장국', false),
              // SizedBox(height: 15,),
              // _buildMenuItem('쫄면아채무침', false),
              // SizedBox(height: 15,),
              // _buildMenuItem('콘치즈버터구이', false),
              // SizedBox(height: 15,),
              // _buildMenuItem('배추김치', false),
              // SizedBox(height: 15,),
              // _buildMenuItem('요구르트', false),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMenuItem(String menu, bool dd) {
    return Column(
      children: <Widget>[
        SizedBox(height: 15,),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
          Container(
            width: 40,
            height: 40,
            child: dd ? Image.asset('assets/meat.png', width: 40,) : Container(),
          ),
          SizedBox(width: 10,),
          Text(menu, style: TextStyle(color: Colors.white, fontSize: 25),),
          SizedBox(width: 15,),
          SpeechBubble(
              width: 50,
              nipLocation: NipLocation.LEFT,
              color: Colors.white,
              borderRadius: 50,
              child: Image.asset('assets/good.png', width: 40,),
            ),
          ],
        ),
      ],
    );
  }

  Future getDayMealMenu() async {
    http.Response res = await http.get('http://meal-backend.herokuapp.com/api/meals/menu?menuDate=${formatDate(d, [yyyy, '', mm, '', dd])}', headers: {
      "Authorization": await getToken(),
    });
    print(res.statusCode);
    if (res.statusCode == 200) {
      print('안녕');
      print(jsonDecode(res.body));
      List<dynamic> jsonBody = jsonDecode(res.body)["data"];
      print("ss");
      print(jsonBody);

      setState(() {
        if (jsonBody != null) {
          _mealList = jsonBody;
        } else {
          _mealList = ['급식 데이터가 없음', '이건 영양사 잘못'];
        }
      });

      return;
    } else {
      return;
    }
  }
}
