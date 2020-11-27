import 'dart:convert';

import 'package:date_format/date_format.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:meal_flutter/UIs/servey_page.dart';
import 'package:meal_flutter/common/asset_path.dart';
import 'package:meal_flutter/common/color.dart';
import 'package:meal_flutter/common/func.dart';
import 'package:meal_flutter/common/ip.dart';
import 'package:meal_flutter/common/provider/userProvider.dart';
import 'package:meal_flutter/common/push.dart';
import 'package:meal_flutter/common/routes.dart';
import 'package:meal_flutter/common/widgets/appbar.dart';
import 'package:meal_flutter/common/widgets/dialog.dart';
import 'package:meal_flutter/common/widgets/loading.dart';
import 'package:provider/provider.dart';
import 'package:speech_bubble/speech_bubble.dart';
import 'package:swipedetector/swipedetector.dart';

import "../common/db.dart";
import '../common/font.dart';
import '../common/provider/mealProvider.dart';
import 'package:confetti/confetti.dart';
import 'package:vibration/vibration.dart';
// import '../common/routes.dart'rovider/provider.dart';

import "../common/db.dart";

FontSize fs;

class MealDetailState extends StatefulWidget {
  DateTime d;
  String menuTime;

  MealDetailState(DateTime d, {String menuTime}) {
    this.d = d;
    if (menuTime == null) {
      this.menuTime = "중식";
    } else {
      this.menuTime = menuTime;
    }
  }

  @override
  MealDetail createState() => MealDetail(d, menuTime);
}

class MealDetail extends State<MealDetailState> {
  DateTime d;
  String menuTime;
  PushManager pm = PushManager();
  var ratingEmojiList = ["spice", "cold", "soso", "good", "love"];
  var _ratedStarList = [-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1];

  MealDetail(DateTime d, String menuTime) {
    this.d = d;
    this.menuTime = menuTime;
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

  getRatedStarList() async {
    http.Response res = await getWithToken(
        '${currentHost}/meals/rating/star/my?menuDate=${formatDate(d, [yyyy, '', mm, '', dd])}&menuTime=${menuTime}');
    print(res.statusCode);
    if (res.statusCode == 200) {
      List<dynamic> jsonBody = jsonDecode(res.body)["data"];
      for (var menu in jsonBody) {
        setState(() {
          _ratedStarList[menu["menuSeq"]] = menu["star"];
        });
      }
    }
  }

  ConfettiController _controllerCenter = ConfettiController(
    duration: const Duration(seconds: 5),
  );

  @override
  void initState() {
    super.initState();
    // _controllerCenter = ConfettiController(duration: const Duration(seconds: 10));

    getAlgFromStorage();

    getDayMealMenu();
  }

  //
  // @override
  // void dispose() {
  //   _controllerCenter.dispose();
  //   super.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    List<String> menuTimeList = ["조식", "중식", "석식"];

    fs = FontSize(context);
    MealStatus mealStatus = Provider.of<MealStatus>(context);
    return WillPopScope(
      onWillPop: () async {
        return true;
      },
      child: SwipeDetector(
        onSwipeUp: () {
          Navigator.of(context).pushReplacement(SlideUpRoute(
              page: MealDetailState(
            d,
            menuTime: menuTimeList[(menuTimeList.indexOf(menuTime) + 1) % menuTimeList.length],
          )));
        },
        onSwipeDown: () {
          Navigator.of(context).pushReplacement(SlideDownRoute(
              page: MealDetailState(
            d,
            menuTime: menuTimeList[(menuTimeList.indexOf(menuTime) - 1 + menuTimeList.length) % menuTimeList.length],
          )));
        },
        onSwipeRight: () {
          DateTime moveDate = widget.d.add(Duration(days: -1));
          Navigator.of(context).pushReplacement(SlideRightRoute(page: MealDetailState(moveDate)));
        },
        onSwipeLeft: () {
          DateTime moveDate = widget.d.add(Duration(days: 1));
          Navigator.of(context).pushReplacement(SlideLeftRoute(page: MealDetailState(moveDate)));
        },
        child: LoadingMealModal(
          child: Scaffold(
            backgroundColor: Color(0xffFFBB00),
            body: Stack(
              children: [
                Column(children: [
                  Flexible(child: _buildBody(d)),
                  Container(
                      width: MediaQuery.of(context).size.width,
                      height: 60,
                      margin: EdgeInsets.only(
                        bottom: 0,
                      )),
                ]),
                Center(
                  child: ConfettiWidget(
                    blastDirectionality: BlastDirectionality.explosive,
                    confettiController: _controllerCenter,
                    particleDrag: 0.05,
                    emissionFrequency: 0.05,
                    numberOfParticles: 10,
                    gravity: 0.05,
                    shouldLoop: false,
                    colors: [
                      Colors.green,
                      Colors.red,
                      Colors.yellow,
                      Colors.blue,
                    ],
                  ),
                ),

                // ConfettiWidget(
                //     confettiController: _controllerCenter,
                //     blastDirectionality: BlastDirectionality.explosive, // don't specify a direction, blast randomly
                //     shouldLoop: true, // start again as soon as the animation is finished
                //     colors: const [
                //       Colors.green,
                //       Colors.blue,
                //       Colors.pink,
                //       Colors.orange,
                //       Colors.purple
                //     ],
                //     maxBlastForce: 5, // set a lower max blast force
                //     minBlastForce: 2, // set a lower min blast force
                //     emissionFrequency: 0.05,
                //     numberOfParticles: 50, // a lot of particles at once
                //     gravity: 1// manually specify the colors to be used
                // ),
                // GestureDetector(
                //     onTap: (){
                //
                //       print("SDF");
                //       _controllerCenter.play();},
                //     child: Text("SDSDFsdfSDFsdfSDFsdfSDFsdfSDFsdfSDFsdfSDFsdfSDFsdfSDFsdfSDFsdfSDFsdfSDFsdfSDFsdfSDFsdfSDFsdfSDFsdfSDFsdfSDFsdfSDFsdfSDFsdfSDFsdfSDFsdfSDFsdfSDFsdfSDFsdfSDFsdfSDFsdfSDFsdfSDFsdfSDFsdfSDFsdfSDFsdfSDFsdfSDFsdfSDFsdfSDFsdfSDFsdfSDFsdfSDFsdfSDFsdfSDFsdfSDFsdfSDFsdfSDFsdfSDFsdfSDFsdfSDFsdfSDFsdfSDFsdfSDFsdfSDFsdfSDFsdfSDFsdfSDFsdfSDFsdfSDFsdfSDFsdfSDFsdfSDFsdfSDFsdfFsdf")),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(DateTime date) {
    DateTime d = date;
    MealStatus mealStatus = Provider.of<MealStatus>(context);
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          SizedBox(
            height: fs.getHeightRatioSize(0.08),
          ),
          Center(
            child: InkWell(
                onLongPress: () {
                  if (d.month == 12 && d.day == 19) {
                    print("DFSD");
                    _controllerCenter.play();
                    Vibration.vibrate(duration: 1000);
                    showCustomAlert(
                      width: 1000,
                      context: context,
                      isSuccess: false,
                      title: "저의 생일을 축하해주셔서\n감사합니다 🎉",
                      duration: Duration(seconds: 1),
                    );

                  }
                },

                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                  decoration: BoxDecoration(
                    color: primaryYellowDark,
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                  child: Text(
                    formatDate(d, [yyyy, '.', mm, '.', dd]) +
                        " (" +
                        ["월", "화", "수", "목", "금", "토", "일"][d.weekday - 1] +
                        ")",
                    style: TextStyle(fontSize: fs.s3, color: Colors.white),
                  ),
                )),
          ),
          SizedBox(
            height: 5,
          ),
          Center(
            child: GestureDetector(
              onTap: () {
                List<String> menuTimeList = ["조식", "중식", "석식"];
                Navigator.of(context).pushReplacement(SlideUpRoute(
                    page: MealDetailState(
                  d,
                  menuTime: menuTimeList[(menuTimeList.indexOf(menuTime) + 1) % menuTimeList.length],
                )));
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: primaryRed,
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
                child: Text(
                  menuTime,
                  style: TextStyle(fontSize: fs.s6, color: Colors.white),
                ),
              ),
            ),
          ),
          SizedBox(
            height: 5,
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
                            mealStatus.dayList[formatDate(d, [yyyy, '', mm, '', dd])].containsKey(menuTime) &&
                            mealStatus.dayList[formatDate(d, [yyyy, '', mm, '', dd])][menuTime].contains(menuName),
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
  }

  Widget _buildMenuItem(String menu, List<dynamic> menuAlgList, bool dd, DateTime d, int index) {
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
    for (int algId in menuAlgList) {
      if (algId == null || !(1 <= algId && algId <= allAlgList.length)) {
        continue;
      }

      if (checkedAlg[algId] == true) {
        myAlgList.add(allAlgList[algId - 1]);
      }
    }

    return Builder(
      builder: (context) {
        MealStatus mealStatus = Provider.of<MealStatus>(context);

        void toggleFavorite() async {
          mealStatus.setIsLoading(true);

          int PUSH_HOUR = mealStatus.pushHour;
          int PUSH_MINUTE = mealStatus.pushMinute;

          if (mealStatus.updateSelectedDay(formatDate(d, ['yyyy', '', 'mm', '', 'dd']), menu, menuTime)) {
            if (mealStatus.isReceivePush == true) {
              var pushList = await pm.getScheduledPush();
              bool isExist = false;
              String formattedDate = formatDate(d, ['yyyy', '', 'mm', '', 'dd']);
              for (var push in pushList) {
                if (push.payload == formattedDate) {
                  var randomMenu = getRandomElement(push.payload.split("%")[1].split(","));

                  pm.schedulePush(
                      id: int.parse(formatDate(d, ['yyyy', '', 'mm', '', 'dd'])),
                      datetime: DateTime(d.year, d.month, d.day, PUSH_HOUR, PUSH_MINUTE, 0),
                      title: getRandomPushTitle(),
                      body: "오늘은 ${randomMenu} 나오는 날~",
                      payload: push.payload + "," + menu);

                  isExist = true;
                }
              }
              if (isExist == false) {
                pm.schedulePush(
                    id: int.parse(formatDate(d, ['yyyy', '', 'mm', '', 'dd'])),
                    datetime: DateTime(d.year, d.month, d.day, PUSH_HOUR, PUSH_MINUTE, 0),
                    title: getRandomPushTitle(),
                    body: "오늘은 ${menu} 나오는 날~",
                    payload: formatDate(d, ['yyyy', '', 'mm', '', 'dd']) + "%" + menu);
              }
            }

            await postSelectedDay(formatDate(d, ['yyyy', '', 'mm', '', 'dd']), index);
          } else {
            if (mealStatus.isReceivePush == true) {
              var pushList = await pm.getScheduledPush();
              bool isExist = false;
              String formattedDate = formatDate(d, ['yyyy', '', 'mm', '', 'dd']);
              for (var push in pushList) {
                if (push.payload == formattedDate) {
                  pm.cancelScheduledPush(push.id);

                  var tmp = push.payload.split("%").split(",");
                  String newMenu = tmp.where((x) => x != menu).toList().join(",");

                  if (newMenu.split(",").length == 0) {
                  } else {
                    String randomMenu = getRandomElement(newMenu.split(","));
                    pm.schedulePush(
                        id: int.parse(formatDate(d, ['yyyy', '', 'mm', '', 'dd'])),
                        datetime: DateTime(d.year, d.month, d.day, PUSH_HOUR, PUSH_MINUTE, 0),
                        title: getRandomPushTitle(),
                        body: "오늘은 ${randomMenu} 나오는 날~",
                        payload: formatDate(d, ['yyyy', '', 'mm', '', 'dd']) + "%" + newMenu);
                  }
                  isExist = true;
                }
              }
            }
            await deleteSelectedDay(formatDate(d, ['yyyy', '', 'mm', '', 'dd']), index);
          }
          mealStatus.setIsLoading(false);
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
                            getEmoji(mealStatus.selectedEmoji == "selected" ? "meat" : mealStatus.selectedEmoji),
                            width: 40,
                          )
                        : ColorFiltered(
                            colorFilter: ColorFilter.mode(Colors.grey[600], BlendMode.modulate),
                            child: Image.asset(
                              getEmoji(mealStatus.selectedEmoji == "selected" ? "meat" : mealStatus.selectedEmoji),
                              width: 40,
                            )),
                  ),
                ),
                SizedBox(width: 10),
                Flexible(
                  child: GestureDetector(
                    onTap: () async {
                      var popResult = await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => MealSurvey(
                                    d,
                                    index,
                                    _mealList[index]["menu_name"],
                                    menuTime: menuTime,
                                  )));
                      if (popResult["changedStar"] != null) {
                        setState(() {
                          _ratedStarList[index] = popResult["changedStar"];
                        });
                      }
                    },
                    child: myAlgList.length > 0
                        ? StrikeThroughWidget(
                            child: Text(
                              menu,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: fs.s5,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          )
                        : Text(
                            menu,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: fs.s5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                  ),
                ),
                SizedBox(
                  width: 15,
                ),
                _ratedStarList[index] != -1
                    ? SpeechBubble(
                        width: 50,
                        nipLocation: NipLocation.LEFT,
                        color: Colors.white,
                        borderRadius: 50,
                        child: Image.asset(
                          getEmoji(ratingEmojiList[_ratedStarList[index] - 1]),
                          width: 40,
                        ),
                      )
                    : Container(
                        width: 0,
                      ),
              ],
            ),
            myAlgList.length > 0
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        "ㄴ",
                        style: TextStyle(fontSize: fs.s7, color: primaryRedDark),
                      ),
                      Text(
                        myAlgList.join(", "),
                        style: TextStyle(fontSize: fs.s7, color: primaryRedDark),
                      ),
                    ],
                  )
                : Container(),
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

    var schoolId = (await getUserInfo())["school"]["schoolId"];
    var formattedDate = formatDate(d, [yyyy, '', mm, '', dd]);

    var sqlRes;
    if (isSaveMenuStorage == "true") {
      sqlRes = await DBHelper.select(
          "meals", "WHERE schoolID= $schoolId and menuDate ='$formattedDate' and menuTime ='$menuTime'");
    }

    if (sqlRes == null || sqlRes.length == 0) {
      http.Response res = await getWithToken(
          '${currentHost}/meals/v2/menu?menuDate=${formatDate(d, [yyyy, '', mm, '', dd])}&menuTime=$menuTime');
      print(res.statusCode);
      if (res.statusCode == 200) {
        List<dynamic> jsonBody = jsonDecode(res.body)["data"];
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

              DBHelper.insert(
                  "meals", {"schoolId": schoolId, "menuDate": formattedDate, "menus": menu_str, "menuTime": menuTime});
            }
          } else {
            _mealList = null;
          }
        });
      } else {}
    } else {
      setState(() {
        String menus_data = sqlRes[0]["menus"];

        for (var menu_data in menus_data.split("~")) {
          String menuName = menu_data.split(";")[0];
          List<int> menuAlgList = [];
          if (menu_data.split(";").length >= 2) {
            menuAlgList = menu_data.split(";")[1].split("^").map((x) {
              if (x != "") {
                return int.parse(x);
              } else {
                return null;
              }
            }).toList();
          }

          setState(() {
            _mealList.add({"menu_name": menuName, "alg": menuAlgList});
          });
        }
      });
    }
    getRatedStarList();
    setState(() {
      _isLoading = false;
    });
  }

  Future postSelectedDay(String date, int menuSeq) async {
    http.Response res = await postWithToken(
      '$currentHost/meals/v2/rating/favorite',
      body: {"menuDate": date, "menuSeq": menuSeq, "menuTime": menuTime},
    );
    print(res.statusCode);
    if (res.statusCode == 200) {
      print('포스트 성공');
      return;
    } else {
      return;
    }
  }

  Future deleteSelectedDay(String date, int menuSeq) async {
    http.Response res = await deleteWithToken(
      '$currentHost/meals/v2/rating/favorite?menuDate=$date&menuSeq=$menuSeq&menuTime=$menuTime',
    );
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
