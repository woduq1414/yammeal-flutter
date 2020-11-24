import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:carousel_slider/carousel_slider.dart';
import 'package:date_format/date_format.dart';
import 'package:firebase_admob/firebase_admob.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:meal_flutter/UIs/servey_page.dart';
import 'package:meal_flutter/UIs/setting.dart';
import 'package:meal_flutter/common/asset_path.dart';
import 'package:meal_flutter/common/db.dart';
import "package:meal_flutter/common/font.dart";
import 'package:meal_flutter/common/ip.dart';
import 'package:meal_flutter/common/provider/mealProvider.dart';
import 'package:meal_flutter/common/provider/userProvider.dart';
import 'package:meal_flutter/common/push.dart';
import 'package:meal_flutter/common/widgets/dialog.dart';
import 'package:meal_flutter/common/widgets/loading.dart';
import 'package:provider/provider.dart';
import 'package:speech_bubble/speech_bubble.dart';

import "../common/color.dart";
import '../firebase.dart';
import 'meal_calendar.dart';
import 'meal_detail.dart';

GlobalKey _containerKey = GlobalKey();
FontSize fs;

class CustomStack extends Stack {
  CustomStack({children}) : super(children: children);

  @override
  CustomRenderStack createRenderObject(BuildContext context) {
    return CustomRenderStack(
      alignment: alignment,
      textDirection: textDirection ?? Directionality.of(context),
      fit: fit,
      overflow: overflow,
    );
  }
}

class CustomRenderStack extends RenderStack {
  CustomRenderStack({alignment, textDirection, fit, overflow})
      : super(alignment: alignment, textDirection: textDirection, fit: fit);

  @override
  bool hitTestChildren(BoxHitTestResult result, {Offset position}) {
    var stackHit = false;
    final children = getChildrenAsList();
    for (var child in children) {
      final StackParentData childParentData = child.parentData;
      final childHit = result.addWithPaintOffset(
        offset: childParentData.offset,
        position: position,
        hitTest: (BoxHitTestResult result, Offset transformed) {
          assert(transformed == position - childParentData.offset);
          return child.hitTest(result, position: transformed);
        },
      );
      if (childHit) stackHit = true;
    }
    return stackHit;
  }
}

class MealMainUI extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'meal',
      home: MealState(),
    );
  }
}

class MealState extends StatefulWidget {
  @override
  MealUI createState() => MealUI();
}

Offset getWidgetPos(GlobalKey key) {
  RenderBox b = key.currentContext.findRenderObject();
  return b.localToGlobal(Offset.zero);
}

Size getWidgetSize(GlobalKey key) {
  final RenderBox renderBoxRed = key.currentContext.findRenderObject();
  final size = renderBoxRed.size;
  return size;
}

BannerAd bannerAd;

class MealUI extends State<MealState> {
  int _selectedIndex = 0;
  double _selectedTop = 0;
  bool _openInfo = false;
  int _nowTab = 0;
  var _mealList = [];
  bool _getMealDataSuccess = false;
  var dayList = {};
  bool _iscalled = false;
  AdManager AdM = AdManager();
  CarouselController btnController = CarouselController();
  bool _bubbleOpened = false;
  bool _getNowMealFail = false;

  String _menuTime;

  String tmp;

  var tabList = ["soup", "calendar", "setting"];

  var ratingEmojiList = ["spice", "cold", "soso", "good", "love"];

  int _count = 1;

  PushManager pm;

  List<int> _ratingStarList = [
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0
  ];

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
    pm = PushManager();
    AdManager.showBanner();
    super.initState();
    getAlgFromStorage();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      MealStatus mealStatus = Provider.of<MealStatus>(context);

      List menuTimeList = mealStatus.menuTimeList;
      DateTime now = DateTime.now();
      DateTime morningEnd = DateTime(now.year, now.month, now.day, 9, 0, 0);
      DateTime lunchEnd = DateTime(now.year, now.month, now.day, 14, 30, 0);

      String menuTime;

      if (menuTimeList.contains("조식") && now.isBefore(morningEnd)) {
        menuTime = "조식";
      } else if (menuTimeList.contains("석식") && now.isAfter(lunchEnd)) {
        menuTime = "석식";
      } else if (menuTimeList.contains("중식")){
        menuTime = "중식";
      }

      setState(() {
        _menuTime = menuTime;
      });

      getNowMealMenu();
      mealStatus.getMyRatedStar(_menuTime);
    });
  }

  Future getMyRatedStar() async {
    http.Response res = await getWithToken('${currentHost}/meals/rating/star/my?menuDate=${formatDate(DateTime.now(), [
      yyyy,
      '',
      mm,
      '',
      dd
    ])}&menuTime=${_menuTime}');
    print(res.statusCode);
    if (res.statusCode == 200) {
      var jsonBody = jsonDecode(res.body)["data"];
      for (var rating in jsonBody) {
        setState(() {
          _ratingStarList[rating["menuSeq"]] = rating["star"];
        });
      }
      return;
    } else {
      return;
    }
  }

  Future rateStar(int menuSeq, int star) async {
    http.Response res = await postWithToken('${currentHost}/meals/rating/star', body: {
      "menuTime": _menuTime,
      "menuDate": formatDate(DateTime.now(), [yyyy, '', mm, '', dd]),
      "menus": [
        {"menuSeq": menuSeq, "star": star}
      ]
    });
    print(res.statusCode);
    if (res.statusCode == 200) {
      print('포스트 성공');

      return true;
    } else {
      return false;
    }
  }

  @override
  void dispose() {
    try {
      bannerAd?.dispose();
    } on Exception {}

    super.dispose();
  }

  double degreeToRadian(double f) {
    return f * math.pi / 180;
  }

  @override
  Widget build(BuildContext context) {
    fs = FontSize(context);
    MealStatus mealStatus = Provider.of<MealStatus>(context);
    return WillPopScope(
      onWillPop: () async {
        showCustomDialog(
            context: context,
            title: "앱을 종료할까요?",
            cancelButtonText: "취소",
            confirmButtonText: "나가기",
            cancelButtonAction: () {
              Navigator.pop(context);
              Future.delayed(Duration(milliseconds: 500), () {
                if (bannerAd != null) bannerAd.dispose();
                bannerAd = null;
              });
            },
            confirmButtonAction: () {
              Navigator.pop(context);
              exit(1);
            });

        return true;
      },
      child: LoadingMealModal(
        child: Scaffold(
          backgroundColor: primaryRed,
          body: SafeArea(
              child: CustomStack(
            children: <Widget>[
              Container(
                color: Colors.transparent,
                child: Stack(
                  children: <Widget>[
                    CustomPaint(painter: CurvePainter1(), size: MediaQuery.of(context).size),
                    CustomPaint(
                      painter: CurvePainter2(),
                      size: MediaQuery.of(context).size,
                    )
                  ],
                ),
              ),
              Container(
//            key: _underMenuKey,
                child: CustomStack(
                  children: <Widget>[
                        Container(
                          child: CustomPaint(
                            painter: HalfCirclePainter(),
                            size: MediaQuery.of(context).size,
                          ),
                        ),
                        Container(
                          child: CustomPaint(
                            painter: InnerHalfCirclePainter(),
                            size: MediaQuery.of(context).size,
                          ),
                        ),
                        Container(
                          child: CustomPaint(
                            painter: BuchaePainter(),
                            size: MediaQuery.of(context).size,
                          ),
                        )
                      ] +
                      tabList.map<Widget>((tab) {
                        var t = 90 + (_nowTab - tabList.indexOf(tab)) * 40.0;
                        var s = _nowTab == tabList.indexOf(tab) ? 70.0 : 50.0;

                        double halfCircleVerticalRadius = MediaQuery.of(context).size.height * 0.15 / 1.4;
                        double halfCircleHorizontalRadius = MediaQuery.of(context).size.width * 0.3 / 1.4;
                        return AnimatedPositioned(
                          child: GestureDetector(
                            behavior: HitTestBehavior.translucent,
                            onTap: () {
                              btnController.animateToPage(tabList.indexOf(tab),
                                  duration: Duration(milliseconds: 500), curve: Curves.ease);
                            },
                            child: Container(
                              child: Image.asset(
                                getEmoji(tab),
                              ),
                            ),
                          ),
                          top: MediaQuery.of(context).size.height * 1 -
                              math.sin(degreeToRadian(t)) * halfCircleVerticalRadius -
                              s -
                              10,
                          left: (MediaQuery.of(context).size.width / 2) +
                              math.cos(degreeToRadian(t)) * halfCircleHorizontalRadius -
                              s / 2,
                          width: s,
                          height: s,
                          duration: Duration(milliseconds: 400),
                          curve: Curves.ease,
                        );
                      }).toList(),
                ),
              ),
              CarouselSlider(
                carouselController: btnController,
                options: CarouselOptions(
                    enableInfiniteScroll: false,
                    autoPlay: false,
                    height: MediaQuery.of(context).size.height,
                    viewportFraction: 1,
                    onPageChanged: (index, CarouselPageChangedReason c) {
                      MealStatus mealStatus = Provider.of<MealStatus>(context);
                      setState(() {
                        _nowTab = index;
                        if (_nowTab == 1 && !_iscalled) {
                          mealStatus.setFavoriteListWithRange();
                          setState(() {
                            _iscalled = true;
                          });
                        }
                      });
                    }),
                items: <Widget>[
                  FractionallySizedBox(
                    alignment: Alignment.topCenter,
                    heightFactor: 0.8,
                    child: SingleChildScrollView(
                      physics: BouncingScrollPhysics(),
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        child: Column(
                          children: <Widget>[
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.035,
                            ),
                            Container(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Image.asset(
                                        getEmoji("soup"),
                                        width: 50,
                                      ),
                                      SizedBox(width: 5),
                                      GestureDetector(
                                        onDoubleTap: () {},
                                        child: Text('오늘의 메뉴',
                                            style: TextStyle(fontSize: fs.s3, color: Colors.white, shadows: [
                                              Shadow(offset: Offset(0, 4.0), blurRadius: 10.0, color: Colors.black38),
                                            ])),
                                      ),
                                      SizedBox(width: 5),
                                      Image.asset(
                                        getEmoji("soup"),
                                        width: 50,
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 8),
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        List<String> menuTimeList = mealStatus.menuTimeList;
                                        _menuTime = menuTimeList[
                                            (menuTimeList.indexOf(_menuTime) + 1 + menuTimeList.length) %
                                                menuTimeList.length];
                                        _getMealDataSuccess = false;

                                        _iscalled = false;

                                        getNowMealMenu();
                                        mealStatus.getMyRatedStar(_menuTime);
                                      });
                                    },
                                    child: Text(_menuTime == "조식" ? "아침" : (_menuTime == "중식" ? "점심" : "저녁"),
                                        style: TextStyle(fontSize: fs.s5, color: Colors.white, fontWeight: Font.normal)),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                      formatDate(DateTime.now(), [yyyy, '.', mm, '.', dd]) +
                                          " (" +
                                          ["월", "화", "수", "목", "금", "토", "일"][DateTime.now().weekday - 1] +
                                          ")",
                                      style: TextStyle(fontSize: fs.s7, color: Colors.white)),
                                ],
                              ),
                            ),
                            Container(
                              key: _containerKey,
                              width: MediaQuery.of(context).size.width,
                              child: Stack(
                                alignment: Alignment.topCenter,
                                children: <Widget>[
                                  _getMealDataSuccess
                                      ? _mealList != null
                                          ? Column(
                                              children: <Widget>[
                                                    SizedBox(
                                                      height: fs.getWidthRatioSize(0.15),
                                                    )
                                                  ] +
                                                  (_mealList).map<Widget>((menuData) {
                                                    String menuName = menuData["menu_name"];
                                                    return _buildMealItem(
                                                        menuData["menu_name"], menuData["alg"], _mealList.indexOf(menuData));
                                                  }).toList() +
                                                  <Widget>[
                                                    SizedBox(
                                                      height: fs.getWidthRatioSize(0.15),
                                                    )
                                                  ],
                                            )
                                          : Container(
                                              margin: EdgeInsets.only(top: fs.getHeightRatioSize(0.07)),
                                              child: Text(
                                                '급식 정보가 없습니다.',
                                                style: TextStyle(color: Colors.white, fontSize: fs.s5),
                                              ))
                                      : Container(margin: EdgeInsets.all(40), child: CustomLoading()),
                                  _bubbleOpened
                                      ? GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              _bubbleOpened = false;
                                              _openInfo = false;
                                            });
                                          },
                                          child: Container(
                                            width: fs.getWidthRatioSize(1),
                                            height: fs.getHeightRatioSize(0.6),
                                            decoration: BoxDecoration(color: Colors.transparent),
                                          ),
                                        )
                                      : Container(
                                          width: 0,
                                          height: 0,
                                        ),
                                  Positioned(
                                    child: _buildBelowItemInfo(_selectedIndex),
                                    top: _selectedTop + 5,
                                  ),
                                  Positioned(
                                    child: _buildUpperItemInfo(_selectedIndex),
                                    top: _selectedTop - 90,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Container(
                    child: FractionallySizedBox(
                      heightFactor: 0.8,
                      alignment: Alignment.topCenter,
                      child: SingleChildScrollView(
                        physics: BouncingScrollPhysics(),
                        child: Container(
                            width: MediaQuery.of(context).size.width,
                            child: Column(
                              children: <Widget>[
                                SizedBox(
                                  height: MediaQuery.of(context).size.height * 0.035,
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Image.asset(
                                      getEmoji("calendar"),
                                      width: 50,
                                    ),
                                    SizedBox(width: 5),
                                    Text('내 급식표',
                                        style: TextStyle(fontSize: fs.s3, color: Colors.white, shadows: [
                                          Shadow(offset: Offset(0, 4.0), blurRadius: 10.0, color: Colors.black38),
                                        ])),
                                    SizedBox(width: 5),
                                    Image.asset(
                                      getEmoji("calendar"),
                                      width: 50,
                                    ),
                                  ],
                                ),
                                MealCalState(),
                                !mealStatus.isLoadingFavorite ? _buildDDayList() : CustomLoading()
                              ],
                            )),
                      ),
                    ),
                  ),
                  Container(
                      child: Container(
                    child: FractionallySizedBox(
                      heightFactor: 0.8,
                      alignment: Alignment.topCenter,
                      child: SingleChildScrollView(
                        physics: BouncingScrollPhysics(),
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          child: Setting(),
                        ),
                      ),
                    ),
                  ))
                ],
              ),
            ],
          )),
        ),
      ),
    );
  }

  Widget _buildMealItem(String mealName, List<dynamic> menuAlgList, int index) {
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

    GlobalKey _key = GlobalKey();
    return Container(
        key: _key,
        //height: 40,
        child: Column(
          children: <Widget>[
            SizedBox(
              height: fs.s7,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                myAlgList.length > 0
                    ? Row(
                        children: [
                          Icon(
                              Icons.assignment_late,
                              color: primaryYellow
                          ),
                          SizedBox(
                            width: 3,
                          )
                        ],
                      )
                    : Container(),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _openInfo = true;
                      _selectedTop = getWidgetPos(_key).dy - getWidgetPos(_containerKey).dy + 47;
                      _selectedIndex = index;
                      _bubbleOpened = true;
                    });
                  },
                  onTapUp: (TapUpDetails t) {
                    setState(() {
                      _openInfo = false;
                    });
                  },
                  child: Text(mealName, style: TextStyle(fontSize: fs.s5, color: Colors.white)),
                )
              ],
            ),
            SizedBox(
              height: 7,
            ),
          ],
        ));
  }

  Widget _buildBelowItemInfo(int index) {
    return AnimatedOpacity(
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        height: _openInfo ? MediaQuery.of(context).size.height * 0.06 : 0,
        decoration: BoxDecoration(color: Colors.grey, borderRadius: BorderRadius.circular(50), boxShadow: [
          new BoxShadow(
            color: Colors.black.withOpacity(0.2),
            offset: Offset(1, 3),
            blurRadius: 2,
            spreadRadius: 0.5,
          )
        ]),
        child: SpeechBubble(
            height: _openInfo ? MediaQuery.of(context).size.height * 0.06 : 0,
            nipLocation: NipLocation.TOP,
            color: primaryYellow,
            borderRadius: 50,
            child: FlatButton(
              child: Text(
                '자세히',
                style: TextStyle(fontSize: 15),
              ),
              color: primaryYellow,
              onPressed: () {
                Navigator.push(
                    context, MaterialPageRoute(builder: (context) => MealSurvey(DateTime.now(), index, _mealList[index])));
              },
            )),
      ),
      opacity: _openInfo ? 1.0 : 0.0,
      duration: Duration(milliseconds: 300),
    );
  }

  Widget _buildUpperItemInfo(int index) {
    MealStatus mealStatus = Provider.of<MealStatus>(context);
    return AnimatedOpacity(
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        height: _openInfo ? MediaQuery.of(context).size.height * 0.06 : 0,
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(50), boxShadow: [
          new BoxShadow(
            color: Colors.black.withOpacity(0.2),
            offset: Offset(1, 3),
            blurRadius: 2,
            spreadRadius: 0.5,
          )
        ]),
        child: SpeechBubble(
          height: _openInfo ? MediaQuery.of(context).size.height * 0.06 : 0,
          nipLocation: NipLocation.BOTTOM,
          color: Colors.white,
          borderRadius: 50,
          child: Row(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.center, children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return SizeTransition(
                  sizeFactor: animation,
                  child: child,
                  axisAlignment: 1,
                  axis: Axis.horizontal,
                );
              },
              child: mealStatus.ratingStarList[index] == 0
                  ? Row(
                      key: ValueKey<List>(mealStatus.ratingStarList),
                      children: ratingEmojiList.map((x) {
                        return Material(
                          borderRadius: BorderRadius.all(Radius.circular(100)),
                          child: InkWell(
                            borderRadius: BorderRadius.all(Radius.circular(100)),
                            onTap: () async {
                              int star = ratingEmojiList.indexOf(x) + 1;
                              setState(() {
                                mealStatus.setRatingStarList(index, star);
                              });

                              Future.delayed(Duration(milliseconds: 600), () {
                                setState(() {
                                  _bubbleOpened = false;
                                  _openInfo = false;
                                });
                              });

                              var rateResult = await rateStar(index, star);
                            },
                            child: Container(
                              padding: EdgeInsets.all(2),
                              child: Image.asset(
                                getEmoji(x),
                                width: 35,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    )
                  : Container(
                      key: ValueKey<List>(mealStatus.ratingStarList),
                      child: Material(
                        borderRadius: BorderRadius.all(Radius.circular(100)),
                        child: InkWell(
                          borderRadius: BorderRadius.all(Radius.circular(100)),
                          onTap: () {
                          },
                          child: Container(
                            padding: EdgeInsets.all(2),
                            child: Image.asset(
                              getEmoji(ratingEmojiList[mealStatus.ratingStarList[index] - 1]),
                              width: 35,
                            ),
                          ),
                        ),
                      ),
                    ),
            ),
          ]),
        ),
      ),
      opacity: _openInfo ? 1.0 : 0.0,
      duration: Duration(milliseconds: 300),
    );
  }

  Widget _buildDDayList() {
    MealStatus mealStatus = Provider.of<MealStatus>(context);
    var keys = mealStatus.dayList.keys.toList();
    int i = 0;

    keys.sort();
    var now = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    return Column(
        children: keys
            .where((x) {
              DateTime dParsed = DateTime.parse(x);
              var dday = dParsed.difference(now).inDays;
              return dday >= 0;
            })
            .toList()
            .map((x) {
              var menuSet = Set();
              for (var time in mealStatus.dayList[x].keys) {
                menuSet.addAll(mealStatus.dayList[x][time]);
              }
              return _buildDDayListItem(x, menuSet.toList(), i++);
            })
            .toList());
  }

  Widget _buildDDayListItem(String date, List menus, index) {
    DateTime dParsed = DateTime.parse(date);
    var now = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    int dday = dParsed.difference(now).inDays;
    if (dday < 0)
      return Container(
        width: 0,
        height: 0,
      ); // 개선 여지 매우 큼.
    return Builder(
      builder: (context) {
        MealStatus mealStatus = Provider.of<MealStatus>(context);
        return GestureDetector(
          onTap: () async {
            await Navigator.push(context, MaterialPageRoute(builder: (context) => MealDetailState(dParsed)));
            mealStatus.setFavoriteListWithRange();
          },
          child: Container(
            margin: EdgeInsets.symmetric(vertical: 2),
            decoration: BoxDecoration(
              color: primaryRed,
              boxShadow: index % 2 == 0
                  ? <BoxShadow>[
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        spreadRadius: 0.1,
                        blurRadius: 0.5,
                        offset: Offset(0, 2), // changes position of shadow
                      ),
                    ]
                  : [],
            ),
            child: Row(
              children: <Widget>[
                Container(
                  width: MediaQuery.of(context).size.width * 0.2,
                  height: MediaQuery.of(context).size.width * 0.1,
                  child: Center(
                    child: Text(
                      'D-${dday == 0 ? 'Day' : dday}',
                      style: TextStyle(fontSize: fs.s6, color: Colors.white),
                    ),
                  ),
                  decoration: BoxDecoration(
                    color: index % 2 == 0 ? Color(0xffFFBB00) : primaryRed,
                  ),
                ),
                Flexible(
                  child: Container(
                      margin: EdgeInsets.only(left: fs.s7),
                      child: Text(menus.join(", "), style: TextStyle(fontSize: fs.s6, color: Colors.white), softWrap: true)),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  // api 가져오는 지역
  Future getNowMealMenu() async {
    Timer(const Duration(milliseconds: 7000), () {
      if (!_getMealDataSuccess) {
        setState(() {
          _getNowMealFail = true;
        });
      } else {
        _getNowMealFail = false;
      }
    });

    http.Response res = await getWithToken(
      '${currentHost}/meals/v2/menu?menuDate=${formatDate(DateTime.now(), [yyyy, '', mm, '', dd])}&menuTime=${_menuTime}',
    );
    print(res.statusCode);
    if (res.statusCode == 200) {
      List<dynamic> jsonBody = jsonDecode(res.body)["data"];
      setState(() {
        if (jsonBody != null) {
          _getMealDataSuccess = true;
          _mealList = jsonBody;
        } else {
          _getMealDataSuccess = true;
          _mealList = null;
        }
      });

      return;
    } else {
      return;
    }
  }

  Future getDayMealMenu() async {
    var storage = FlutterSecureStorage();
    var isSaveMenuStorage = await storage.read(key: "isSaveMenuStorage");
    if (!_getMealDataSuccess) {
      setState(() {
        _getNowMealFail = true;
      });
    } else {
      _getNowMealFail = false;
    }

    var schoolId = (await getUserInfo())["school"]["schoolId"];
    var formattedDate = formatDate(DateTime.now(), [yyyy, '', mm, '', dd]);

    var sqlRes;
    if (isSaveMenuStorage == "true") {
      sqlRes = await DBHelper.select(
          "meals", "WHERE schoolID= $schoolId and menuDate ='$formattedDate' and menuTime ='$_menuTime'");
    }

    if (sqlRes == null || sqlRes.length == 0) {
      http.Response res = await getWithToken(
          '${currentHost}/meals/v2/menu?menuDate=${formatDate(DateTime.now(), [yyyy, '', mm, '', dd])}&menuTime=$_menuTime');
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
                  "meals", {"schoolId": schoolId, "menuDate": formattedDate, "menus": menu_str, "menuTime": _menuTime});
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

    setState(() {
      _getMealDataSuccess = true;
    });
  }

  Future getSelectedMealMenu(year, month) async {
    http.Response res = await getWithToken('${currentHost}/meals/rating/favorite?year=${year}&month=${month}');
    print(res.statusCode);
    if (res.statusCode == 200) {
      Map<dynamic, dynamic> jsonBody = jsonDecode(res.body)["data"];
      setState(() {
        if (jsonBody != null) {
          setState(() {
            dayList = jsonBody;
          });
        } else {}
      });
      return;
    } else {
      setState(() {
        dayList = {};
      });
    }
  }
}

// CustompPainter 지역

class HalfCirclePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = new Paint()
      ..color = primaryYellow
      ..style = PaintingStyle.fill
      ..strokeWidth = 8.0;

    final x = size.width;
    final y = size.height;
    Path path = new Path();
    path.arcTo(Rect.fromLTWH(x * 0.2, y * 0.85, x * 0.6, y * 0.3), degToRad(0), degToRad(-180), true);
    canvas.drawPath(path, paint);
  }

  num degToRad(num deg) => deg * (math.pi / 180.0);

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}

class BuchaePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = new Paint()
      ..color = primaryRed
      ..style = PaintingStyle.stroke
      ..strokeWidth = 50.0;

    final x = size.width;
    final y = size.height;
    Path path = new Path();
    path.arcTo(Rect.fromLTWH(x * 0.34, y * 0.87, x * 0.33, y * 0.2), degToRad(-60), degToRad(-60), true);
    canvas.drawPath(path, paint);
  }

  num degToRad(num deg) => deg * (math.pi / 180.0);

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}

class InnerHalfCirclePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = new Paint()
      ..color = primaryRed
      ..style = PaintingStyle.fill
      ..strokeWidth = 8.0;

    final x = size.width;
    final y = size.height;
    Path path = new Path();
    path.arcTo(Rect.fromLTWH(x * 0.37, y * 0.93, x * 0.275, y * 0.15), degToRad(0), degToRad(-180), true);
    canvas.drawPath(path, paint);
  }

  num degToRad(num deg) => deg * (math.pi / 180.0);

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}

class CurvePainter1 extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = new Paint()
      ..color = Color(0xffFF4600)
      ..style = PaintingStyle.fill
      ..strokeWidth = 8.0;

    final x = size.width;
    final y = size.height;
    Path path = new Path();
    path.moveTo(-50, 0);
    path.lineTo(-50, y * 0.15);
    path.cubicTo(x * 0.15, y * 0.1, x * 0.25, y * 0.1, x * 0.45, y * 0.2);
    path.cubicTo(x * 0.7, y * 0.17, x * 0.8, y * 0.17, x, y * 0.1);
    path.lineTo(x, 0);
    path.lineTo(-50, 0);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}

class CurvePainter2 extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = new Paint()
      ..color = Color(0xffFFBB00)
      ..style = PaintingStyle.fill
      ..strokeWidth = 8.0;

    final x = size.width;
    final y = size.height;
    Path path = new Path();
    path.moveTo(-50, 0);
    path.lineTo(-50, y * 0.23);
    path.cubicTo(x * 0.15, y * 0.08, x * 0.4, y * 0.05, x * 0.6, y * 0.12);
    path.cubicTo(x * 0.75, y * 0.23, x * 0.92, y * 0.23, x, y * 0.1);
    path.lineTo(x, 0);
    path.lineTo(-50, 0);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
