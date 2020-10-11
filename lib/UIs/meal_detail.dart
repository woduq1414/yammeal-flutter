import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:date_format/date_format.dart';
import 'package:meal_flutter/common/asset_path.dart';
import 'package:meal_flutter/common/provider/userProvider.dart';
import 'package:speech_bubble/speech_bubble.dart';
import 'package:http/http.dart' as http;
import '../common/provider/mealProvider.dart';
import 'package:provider/provider.dart';
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
        body: _buildBody(d),
      ),
    );
  }

  Widget _buildBody(DateTime date) {
    DateTime d = date;

    return Builder(
      builder: (context) {
        MealStatus mealStatus = Provider.of<MealStatus>(context);
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
                  return _buildMenuItem(menu, mealStatus.dayList.containsKey(formatDate(d, [yyyy, '', mm, '', dd])) && mealStatus.dayList[formatDate(d, [yyyy, '', mm, '', dd])].contains(menu), d, _mealList.indexOf(menu));
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMenuItem(String menu, bool dd, DateTime d, int index) {
    return Builder(
      builder: (context) {
        MealStatus mealStatus = Provider.of<MealStatus>(context);
        return Column(
          children: <Widget>[
            SizedBox(height: 15,),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  width: 40,
                  height: 40,
                  child: dd ? Image.asset(getEmoji("meat"), width: 40,) : Container(),
                ),
                SizedBox(width: 10,),
                GestureDetector(
                  onTap: () {
                    if (mealStatus.updateSelectedDay(formatDate(d, ['yyyy', '', 'mm', '', 'dd']), menu)) {
                      postSelectedDay(formatDate(d, ['yyyy', '', 'mm', '', 'dd']), index);
                    } else {
                      print('딜리딜리딜리트');
                      deleteSelectedDay(formatDate(d, ['yyyy', '', 'mm', '', 'dd']), index);
                    }
                  },
                  child: Text(menu, style: TextStyle(color: Colors.white, fontSize: 25),),
                ),
                SizedBox(width: 15,),
                SpeechBubble(
                  width: 50,
                  nipLocation: NipLocation.LEFT,
                  color: Colors.white,
                  borderRadius: 50,
                  child: Image.asset(getEmoji("good"), width: 40,),
                ),
              ],
            ),
          ],
        );
      },
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

  Future postSelectedDay(String date, int menuSeq) async {
    print(date);
    http.Response res = await http.post('http://meal-backend.herokuapp.com/api/meals/rating/favorite',
      body: jsonEncode({
        "menuDate": date,
        "menuSeq": menuSeq
      }, ), headers: {
          "Authorization": await getToken(),
          "Content-Type": "application/json "
        }
    );
    print('포스트');
    print(res.statusCode);
    if (res.statusCode == 200) {
      print('포스트 성공');

      return;
    } else {
      return;
    }
  }

  Future deleteSelectedDay(String date, int menuSeq) async {
    print(date);
    print(menuSeq);
    http.Response res = await http.delete('http://meal-backend.herokuapp.com/api/meals/rating/favorite?menuDate=${date}&menuSeq=${menuSeq}', headers: {
          "Authorization": await getToken(),
          "Content-Type": "application/json "
        }
    );
    print('딜리트');
    print(res.statusCode);
    if (res.statusCode == 200) {
      print('딜리트 성공');

      return;
    } else {
      return;
    }
  }
}
