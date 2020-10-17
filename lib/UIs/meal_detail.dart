import 'dart:convert';
//import 'dart:html';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:date_format/date_format.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:meal_flutter/common/asset_path.dart';
import 'package:meal_flutter/common/color.dart';
import 'package:meal_flutter/common/provider/userProvider.dart';
import 'package:meal_flutter/common/widgets/appbar.dart';
import 'package:meal_flutter/common/widgets/loading.dart';
import 'package:speech_bubble/speech_bubble.dart';
import 'package:http/http.dart' as http;
import '../common/provider/mealProvider.dart';
import '../common/font.dart';

import 'package:provider/provider.dart';

import "../common/db.dart";

FontSize fs;

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

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    getDayMealMenu();
  }

  @override
  Widget build(BuildContext context) {
    fs = FontSize(context);

    print("@@@@");
    return WillPopScope(
      onWillPop: () async {
        print("hello?");
        return true;
      },
      child: Scaffold(
        appBar: DefaultAppBar(
          backgroundColor: primaryYellowDark,
          title: "급식표",
        ),
        backgroundColor: Color(0xffFFBB00),
        body: Column(children: [Flexible(child: _buildBody(d)),
          Container(width: MediaQuery.of(context).size.width, height: 60, margin: EdgeInsets.only(bottom: 0,))

        ]),
      ),
    );
  }

  Widget _buildBody(DateTime date) {
    DateTime d = date;

    return Builder(
      builder: (context) {
        MealStatus mealStatus = Provider.of<MealStatus>(context);
        return SingleChildScrollView(
          child: Column(
            //crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                height: 30,
              ),
              Center(
                child: Text(
                  formatDate(d, [yyyy, '.', mm, '.', dd]),
                  style: TextStyle(fontSize: fs.s2, color: Colors.white),
                ),
              ),
              SizedBox(
                height: 15,
              ),
              if (!_isLoading)
                _mealList != null
                    ? Column(
                        children: _mealList.map<Widget>((menu) {
                        return _buildMenuItem(
                            menu,
                            mealStatus.dayList.containsKey(formatDate(d, [yyyy, '', mm, '', dd])) &&
                                mealStatus.dayList[formatDate(d, [yyyy, '', mm, '', dd])].contains(menu),
                            d,
                            _mealList.indexOf(menu));
                      }).toList())
                    : Container(
                        child: Text(
                          "급식 정보가 없습니다.",
                          style: TextStyle(
                            fontSize: fs.s5,
                            color: Colors.white,
                          ),
                        ),
                      )
              else
                Container(margin: EdgeInsets.only(top: 10), child: CustomLoading()),

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

        void toggleFavorite() {
          if (mealStatus.updateSelectedDay(formatDate(d, ['yyyy', '', 'mm', '', 'dd']), menu)) {
            postSelectedDay(formatDate(d, ['yyyy', '', 'mm', '', 'dd']), index);
          } else {
            print('딜리딜리딜리트');
            deleteSelectedDay(formatDate(d, ['yyyy', '', 'mm', '', 'dd']), index);
          }
        }

        return Column(
          children: <Widget>[
            SizedBox(
              height: fs.getHeightRatioSize(0.02),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                GestureDetector(
                  onTap: () {
                    toggleFavorite();
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    child: dd
                        ? Image.asset(
                            getEmoji("meat"),
                            width: 40,
                          )
                        : ColorFiltered(
                            colorFilter: ColorFilter.mode(Colors.grey[600], BlendMode.modulate),
                            child: Image.asset(
                              getEmoji("meat"),
                              width: 40,
                            )),
                  ),
                ),
                SizedBox(width: 10),
                Flexible(
                  child: GestureDetector(
                    onTap: () {
                      toggleFavorite();
                    },
                    child: Text(
                      menu,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: fs.s5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
//                SizedBox(width: 50,),

                SizedBox(
                  width: 15,
                ),
                SpeechBubble(
                  width: 50,
                  nipLocation: NipLocation.LEFT,
                  color: Colors.white,
                  borderRadius: 50,
                  child: Image.asset(
                    getEmoji("good"),
                    width: 40,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Future getDayMealMenu() async {
    var storage = FlutterSecureStorage();
    var isSaveMenuStorage = await storage.read(key: "isSaveMenuStorage");




    setState(() {
      _isLoading = true;
    });
    print((await getUserInfo()));

    var schoolId = (await getUserInfo())["school"]["schoolId"];
    var formattedDate = formatDate(d, [yyyy, '', mm, '', dd]);

    var sqlRes;
    if (isSaveMenuStorage == "true"){
      sqlRes = await DBHelper.select("meals", "WHERE schoolID= $schoolId and menuDate = $formattedDate");
      print(sqlRes);
    }

    if(sqlRes == null || sqlRes.length == 0){
      http.Response res = await http
          .get('http://meal-backend.herokuapp.com/api/meals/menu?menuDate=${formatDate(d, [yyyy, '', mm, '', dd])}', headers: {
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

            if(isSaveMenuStorage == "true"){
              DBHelper.insert("meals", {"schoolId": schoolId, "menuDate": formattedDate, "menus": _mealList.join("~")});
            }

          } else {
            _mealList = null;
          }
        });




      } else {}
    }else{
      setState(() {
        _mealList = sqlRes[0]["menus"].split("~");
      });
    }





//    DBHelper.insert("meals", {
//      "schoolId": schoolId,
//      "menuDate": formattedDate,
//      "menus" : "aa/ss/sssdf"
//    });





    setState(() {
      _isLoading = false;
    });
  }

  Future postSelectedDay(String date, int menuSeq) async {
    print(date);
    http.Response res = await http.post('http://meal-backend.herokuapp.com/api/meals/rating/favorite',
        body: jsonEncode(
          {"menuDate": date, "menuSeq": menuSeq},
        ),
        headers: {"Authorization": await getToken(), "Content-Type": "application/json "});
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
    http.Response res = await http.delete(
        'http://meal-backend.herokuapp.com/api/meals/rating/favorite?menuDate=${date}&menuSeq=${menuSeq}',
        headers: {"Authorization": await getToken(), "Content-Type": "application/json "});
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
