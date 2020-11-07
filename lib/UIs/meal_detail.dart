import 'dart:convert';

//import 'dart:html';

import 'package:swipedetector/swipedetector.dart';

import 'package:meal_flutter/common/ip.dart';
import 'package:swipeable_page_route/swipeable_page_route.dart';

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

import '../common/routes.dart';

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

  List<bool> checkedAlg = List.generate(20, (_) => false);

  getAlgFromStorage() async {
    var storage = FlutterSecureStorage();
    var saved_list = await storage.read(key: "algList");
    if (saved_list == null) {
      return;
    }
    for (var i in saved_list.split(",")) {
      setState(() {
        checkedAlg[int.parse(i)] = true;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getAlgFromStorage();

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
      child: SwipeDetector(
        onSwipeRight: () {
          DateTime moveDate = widget.d.add(Duration(days: -1));
          Navigator.of(context).pushReplacement(SlideRightRoute(
              page : MealDetailState(moveDate)
          ));




        },
        onSwipeLeft: () {
          DateTime moveDate = widget.d.add(Duration(days: 1));

//          Na

          Navigator.of(context).pushReplacement(SlideLeftRoute(
              page : MealDetailState(moveDate)
          ));


        },
        child: Scaffold(
          appBar: DefaultAppBar(
            backgroundColor: primaryYellowDark,
            title: "급식표",
          ),
          backgroundColor: Color(0xffFFBB00),
          body: Column(children: [
            Flexible(child: _buildBody(d)),
            Container(
                width: MediaQuery.of(context).size.width,
                height: 60,
                margin: EdgeInsets.only(
                  bottom: 0,
                ))
          ]),
        ),
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
                        children: _mealList.map<Widget>((menuData) {
                        String menuName = menuData["menu_name"];

                        return _buildMenuItem(
                            menuName,
                            menuData["alg"],
                            mealStatus.dayList.containsKey(formatDate(d, [yyyy, '', mm, '', dd])) &&
                                mealStatus.dayList[formatDate(d, [yyyy, '', mm, '', dd])].contains(menuName),
                            d,
                            _mealList.indexOf(menuData));
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

  Widget _buildMenuItem(String menu, List<dynamic> menuAlgList,   bool dd, DateTime d, int index) {

//    print(checkedAlg);
    List<String> allAlgList = [
      "난류(가금류)",
      "우유",
      "메밀",
      "땅콩",
      "대두",
      "밀",
      "고등어",
      "게",
      "새우",
      "돼지고기",
      "복숭아",
      "토마토",
      "아황산염",
      "호두",
      "닭고기",
      "쇠고기",
      "오징어",
      "조개류"
    ];


    List<String> myAlgList = [];
    for(int algId in menuAlgList){

      if(algId == null){
        continue;
      }

      if(checkedAlg[algId]== true){
        myAlgList.add(allAlgList[algId - 1]);
      }
    }



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
                    child: myAlgList.length > 0?
                    StrikeThroughWidget(
                      child: Text(
                        menu,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: fs.s5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ) : Text(
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

            myAlgList.length > 0?

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[

                Text("ㄴ", style: TextStyle(fontSize: fs.s7, color: primaryRedDark),),
                Text(myAlgList.join(", "), style: TextStyle(fontSize: fs.s7, color: primaryRedDark),),

              ],
            ): Container(),

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
    if (isSaveMenuStorage == "true") {
      sqlRes = await DBHelper.select("meals", "WHERE schoolID= $schoolId and menuDate = $formattedDate");
      print(sqlRes);
    }

    if (sqlRes == null || sqlRes.length == 0) {
      http.Response res =
          await getWithToken('${currentHost}/meals/v2/menu?menuDate=${formatDate(d, [yyyy, '', mm, '', dd])}');
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

            if (isSaveMenuStorage == "true") {
              String menu_str = "";
              for (var menu in _mealList) {
                menu_str += menu["menu_name"];
                menu_str += ";";
                menu_str += menu["alg"].join("^");

                if (menu != _mealList[_mealList.length - 1]) {
                  menu_str += "~";
                }
              }

              DBHelper.insert("meals", {"schoolId": schoolId, "menuDate": formattedDate, "menus": menu_str});
            }
          } else {
            _mealList = null;
          }
        });
      } else {}
    } else {
      setState(() {
        String menus_data = sqlRes[0]["menus"];

        for(var menu_data in menus_data.split("~")){
          String menuName = menu_data.split(";")[0];
          List<int> menuAlgList = [];
          if (menu_data.split(";").length >= 2) {
            menuAlgList = menu_data.split(";")[1].split("^").map((x) {
              if(x != ""){
                return int.parse(x);
              }else{
                return null;
              }
            }).toList();
          }

          setState(() {
            _mealList.add({"menu_name": menuName, "alg": menuAlgList});
          });

          print(menuAlgList);
        }



//        _mealList = sqlRes[0]["menus"].split("~");
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
    http.Response res = await postWithToken(
      '${currentHost}/meals/rating/favorite',
      body: {"menuDate": date, "menuSeq": menuSeq},
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
    http.Response res = await deleteWithToken(
      '${currentHost}/meals/rating/favorite?menuDate=${date}&menuSeq=${menuSeq}',
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


class StrikeThroughWidget extends StatelessWidget {
  final Widget _child;

  StrikeThroughWidget({Key key, @required Widget child})
      : this._child = child,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: _child,
      padding: EdgeInsets.symmetric(horizontal: 8), // this line is optional to make strikethrough effect outside a text
      decoration: BoxDecoration(
        image: DecorationImage(image: AssetImage('./assets/graphics/strikethrough.png'), fit: BoxFit.fitWidth),
      ),
    );
  }
}

