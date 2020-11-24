import 'dart:convert';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:meal_flutter/common/asset_path.dart';
import 'package:meal_flutter/common/color.dart';
import 'package:meal_flutter/common/font.dart';
import 'package:meal_flutter/common/func.dart';
import 'package:meal_flutter/common/ip.dart';
import 'package:meal_flutter/common/provider/mealProvider.dart';
import 'package:meal_flutter/common/provider/userProvider.dart';
import 'package:http/http.dart' as http;
import 'package:date_format/date_format.dart';
import 'package:meal_flutter/common/widgets/dialog.dart';
import 'package:meal_flutter/common/widgets/loading.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';
import 'main_page.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class MealSurvey extends StatefulWidget {
  DateTime date;
  int menuSeq;
  String meal;
  String menuTime;

  MealSurvey(DateTime date, int index, String meal, {String menuTime}) {
    this.date = date;
    this.menuSeq = index;
    this.meal = meal;
    if (menuTime == null) {
      this.menuTime = "중식";
    } else {
      this.menuTime = menuTime;
    }
  }

  @override
  _MealSurveyState createState() => _MealSurveyState(date, menuSeq, meal, menuTime);
}

class _MealSurveyState extends State<MealSurvey> {
  int menuSeq;
  String meal;
  DateTime date;
  bool isToday;
  String menuTime;

  _MealSurveyState(DateTime date, int menuSeq, String meal, String menuTime) {
    this.date = date;
    this.menuSeq = menuSeq;
    this.meal = meal;
    this.menuTime = menuTime;

    if (DateTime.now().year == date.year && DateTime.now().month == date.month && DateTime.now().day == date.day) {
      isToday = true;
    } else {
      isToday = false;
    }
  }

  FontSize fs;
  int _selectedTabIndex = 0;
  CarouselController btnController = CarouselController();
  Map<String, double> _currentValue = {
    "1": 1,
    "2": 1,
    "3": 1,
    "4": 1,
    "5": 1,
    "6": 1,
    "7": 1,
    "8": 1,
    "9": 1,
    "10": 1,
    "11": 1
  };
  var _avgRatings;

  var _avgAnswers = [];

  var _questions = {};
  var _nowQuestions = [];
  var _transferData = [];

  bool _isGetAvgStar = false;
  bool _isGetAvgAnswer = false;
  bool _postIsEnd = false;
  int changedStar;
  bool _isQuestionAnswered = false;

  @override
  void initState() {
    super.initState();
    _postIsEnd = false;
    _avgRatings = [];

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      getIsQuestionAnswered();

      getMenuAvgStar(context);
      getMenuAvgAnswer();
    });
  }

  getIsQuestionAnswered() async {
    http.Response res = await getWithToken(
        '$currentHost/meals/rating/answer/my?menuDate=${formatDate(date, [yyyy, '', mm, '', dd])}&menuSeq=${menuSeq}&menuTime=${menuTime}');

    if (res.statusCode == 200) {
      Map<String, dynamic> jsonBody = jsonDecode(res.body)["data"];
      setState(() {
        _isQuestionAnswered = true;
        _questions = jsonBody;
      });
      btnController.animateToPage(1, duration: Duration(milliseconds: 500), curve: Curves.ease);
      setState(() {
        _selectedTabIndex = 1;
      });
    } else {
      setState(() {
        _isQuestionAnswered = false;
      });
      if (!isSameDate(date, DateTime.now())) {
        btnController.animateToPage(1, duration: Duration(milliseconds: 500), curve: Curves.ease);
      }
      await getQuestion();
    }
  }

  @override
  Widget build(BuildContext context) {
    fs = FontSize(context);

    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pop({"menuSeq" : menuSeq, "changedStar" : changedStar});
        return true;
      }
      ,
      child: LoadingMealModal(
        child: Scaffold(
          backgroundColor: Color(0xffFFBB00),
          body: Column(mainAxisAlignment: MainAxisAlignment.start, children: [
            SizedBox(height: fs.getHeightRatioSize(0.07)),
            Text(
              meal,
              style: TextStyle(fontSize: fs.s2),
            ),
            Center(
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
            Expanded(
              child: CarouselSlider(
                carouselController: btnController,
                options: CarouselOptions(
                    enableInfiniteScroll: false,
                    autoPlay: false,
                    height: MediaQuery.of(context).size.height,
                    viewportFraction: 1,
                    onPageChanged: (index, CarouselPageChangedReason c) {
                      if (index == 0) {
                        if (_isGetAvgStar == false) {
                          getMenuAvgStar(context);
                        }
                      }
                      setState(() {
                        _selectedTabIndex = index;
                      });
                    }),
                items: <Widget>[
                  Align(
                    child: Container(
                        child: _isQuestionAnswered
                            ? Stack(
                                children: <Widget>[
                                  Center(
                                      child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Expanded(
                                        child: Center(
                                          child: ListView(
                                            shrinkWrap: true,
                                            children: _questions["answers"] != null
                                                ? _questions["answers"].map<Widget>((item) {
                                                    return _buildQuestionItem(item, defaultVal: item["answer"]);
                                                  }).toList()
                                                : <Widget>[
                                                    Center(
                                                      child: CustomLoading(),
                                                    )
                                                  ],
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 35,
                                      ),
                                    ],
                                  )),
                                  Positioned(
                                    bottom: 10,
                                    right: 15,
                                    left: 15,
                                    child: RaisedButton(
                                      color: Colors.grey[400],
                                      textColor: Colors.black,
                                      child: Text(
                                        "이미 평가 했어요!",
                                        style: TextStyle(fontSize: fs.s6),
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(50),
                                      ),
                                      onPressed: () async {},
                                    ),
                                  )
                                ],
                              )
                            : Stack(
                                children: <Widget>[
                                  Center(
                                      child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Expanded(
                                        child: Center(
                                          child: ListView(
                                            shrinkWrap: true,
                                            children: _questions["questions"] != null
                                                ? _questions["questions"].map<Widget>((item) {
                                                    if (!_nowQuestions.contains(item["questionSeq"]))
                                                      _nowQuestions.add(item["questionSeq"]);
                                                    return _buildQuestionItem(item);
                                                  }).toList()
                                                : <Widget>[
                                                    Center(child: CustomLoading()),
                                                  ],
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 35,
                                      ),
                                    ],
                                  )),
                                  _questions.length > 0
                                      ? isToday
                                          ? Positioned(
                                              bottom: 10,
                                              right: 15,
                                              left: 15,
                                              child: RaisedButton(
                                                color: primaryRedDark,
                                                textColor: Colors.white,
                                                child: Text(
                                                  "평가 제출하기",
                                                  style: TextStyle(fontSize: fs.s6),
                                                ),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(50),
                                                ),
                                                onPressed: () async {
                                                  MealStatus mealStatus = Provider.of<MealStatus>(context);
                                                  double avgStar = -1;
                                                  for (int i = 0; i < _avgRatings.length; i++) {
                                                    if (_avgRatings[i]["menuSeq"] == menuSeq) {
                                                      // menuName = _avgRatings[i]["menuName"];
                                                      avgStar = _avgRatings[i]["averageStar"].toDouble();
                                                      break;
                                                    }
                                                  }
                                                  if (avgStar == -1) {
                                                    showRateStarSheet(context, false);
                                                  } else {
                                                    submitAnswer(context);
                                                  }
                                                },
                                              ),
                                            )
                                          : Positioned(
                                              bottom: 10,
                                              right: 15,
                                              left: 15,
                                              child: RaisedButton(
                                                color: Colors.grey[400],
                                                textColor: Colors.white,
                                                child: Text(
                                                  "당일에만 평가할 수 있어요!",
                                                  style: TextStyle(fontSize: fs.s6),
                                                ),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(50),
                                                ),
                                                onPressed: () async {},
                                              ),
                                            )
                                      : Container(),
                                ],
                              )),
                  ),
                  Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Expanded(
                      child: ListView(
                        children: <Widget>[
                          SizedBox(
                            height: fs.getHeightRatioSize(0.02),
                          ),
                          _bulidMenuInfo(),
                        ],
                      ),
                    ),
                  ]),
                ],
              ),
            ),
          ]),
          bottomNavigationBar: Theme(
            data: Theme.of(context).copyWith(
              canvasColor: primaryYellowDark,
              primaryColor: primaryRed,
              textTheme: Theme.of(context).textTheme.copyWith(caption: TextStyle(color: Colors.black)),
            ),
            child: BottomNavigationBar(
              items: <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                  icon: Icon(Icons.edit),
                  title: Text('메뉴 평가'),
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.dvr),
                  title: Text('메뉴 상세 정보'),
                ),
              ],
              currentIndex: _selectedTabIndex,
              onTap: (index) {
                btnController.animateToPage(index, duration: Duration(milliseconds: 500), curve: Curves.ease);
                setState(() {
                  _selectedTabIndex = index;
                });
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuestionItem(item, {int defaultVal}) {
    return Column(
      children: <Widget>[
        SizedBox(
          height: fs.getHeightRatioSize(0.0),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              item["content"],
              style: TextStyle(fontSize: fs.s4),
            ),
            Image.asset(
              getEmoji("question"),
              width: fs.s1,
            ),
          ],
        ),
        SizedBox(
          height: fs.getHeightRatioSize(0.015),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset(
              getEmoji("cup"),
              width: 50,
            ),
            _buildSilder(item["questionSeq"].toString(), item["options"], defaultVal: defaultVal),
            Image.asset(
              getEmoji("salty"),
              width: 50,
            )
          ],
        ),
        SizedBox(
          height: fs.getHeightRatioSize(0.04),
        )
      ],
    );
  }

  Widget _buildSilder(String val, List ops, {int defaultVal}) {
    return Container(
      width: fs.getWidthRatioSize(0.7),
      child: Slider(
          value: defaultVal == null ? _currentValue[val] : defaultVal.toDouble(),
          min: 1,
          max: ops.length.toDouble(),
          divisions: ops.length - 1,
          label: ops[(_currentValue[val] - 1).round()],
          activeColor: Color(0xffff4600),
          onChanged: !_isQuestionAnswered
              ? (double value) {
                  setState(() {
                    _currentValue[val] = value;
                  });
                }
              : null),
    );
  }

  Widget _bulidMenuInfo() {
    double avgStar = -1;
    for (int i = 0; i < _avgRatings.length; i++) {
      if (_avgRatings[i]["menuSeq"] == menuSeq) {
        avgStar = _avgRatings[i]["averageStar"].toDouble();
        break;
      }
    }
    return Container(
      width: fs.getWidthRatioSize(0.9),
      // height: fs.getHeightRatioSize(0.6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.3),
      ),
      padding: EdgeInsets.only(left: 20, top: 20, right: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _isGetAvgStar
              ? avgStar != -1
                  ? Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            "별점(이모지) 점수 : ",
                            style: TextStyle(fontSize: fs.s6),
                          ),
                          Center(
                            child: RatingBarIndicator(
                              rating: avgStar,
                              itemBuilder: (context, index) => Icon(Icons.star, color: primaryRed),
                              itemCount: 5,
                              itemSize: fs.getWidthRatioSize(0.12),
                              unratedColor: Colors.amber.withAlpha(50),
                              direction: Axis.horizontal,
                            ),
                          ),
                        ],
                      ),
                    )
                  : isToday ? Text(
                      '별점(이모지)를 평가하고 별점 결과를 볼 수 있습니다!',
                      style: TextStyle(fontSize: avgStar != -1 ? fs.s5 : fs.s6),
                    )  : Text(
            '별점(이모지) 평과 결과가 없습니다.',
            style: TextStyle(fontSize: avgStar != -1 ? fs.s5 : fs.s6),
          )
              : CustomLoading(),
          SizedBox(
            height: 25,
          ),
          _isGetAvgAnswer
              ? _avgAnswers.length != 0
                  ? Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                              Text(
                                "질문 평가 결과 : ",
                                style: TextStyle(fontSize: fs.s6),
                              ),
                              SizedBox(
                                height: 10,
                              )
                            ] +
                            _avgAnswers.map((answer) {
                              return Column(
                                children: <Widget>[
                                  Text(
                                    '<${answer["content"]}>',
                                    style: TextStyle(fontSize: fs.s6),
                                  ),
                                  Center(
                                    child: Slider(
                                      value: answer["answerMean"],
                                      min: 1,
                                      max: answer["options"].length.toDouble(),
                                      divisions: 100,
                                      label: answer["options"][answer["answerMean"].round() - 1],
                                      activeColor: Color(0xffff4600),
                                      inactiveColor: Color(0xffff4600),
                                      onChanged: (d) {},
                                      // onChanged: null
                                    ),
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Text(
                                        answer["options"][0],
                                        style: TextStyle(fontSize: fs.s6, color: primaryRed),
                                      ),
                                      Text(
                                        answer["options"][answer["options"].length - 1],
                                        style: TextStyle(fontSize: fs.s6, color: primaryRed),
                                      )
                                    ],
                                  ),
                                  SizedBox(
                                    height: 10,
                                  )
                                ],
                              );
                            }).toList(),
                      ),
                    )
                  : isToday
                      ? Text(
                          '급식 질문에 대해 평가하고 질문 평가 결과를 볼 수 있습니다!',
                          style: TextStyle(fontSize: fs.s6),
                        )
                      : Text(
                          '질문 평가 결과가 없습니다.',
                          style: TextStyle(fontSize: fs.s6),
                        )
              : CustomLoading(),
          SizedBox(
            height: 20,
          )
        ],
      ),
    );
  }

  //api 가져오기
  Future getQuestion() async {
    var menuQ = {};

    http.Response res =
        await getWithToken('$currentHost/meals/rating/question?menuDate=${formatDate(date, [yyyy, '', mm, '', dd])}&menuTime=${menuTime}');
    print(res.statusCode);
    if (res.statusCode == 200) {
      List<dynamic> jsonBody = jsonDecode(res.body)["data"];
      setState(() {
        if (jsonBody != null) {
          for (int i = 0; i < jsonBody.length; i++) {
            if (jsonBody[i]["menuSeq"] == menuSeq) {
              menuQ = jsonBody[i];
              break;
            }
          }
          setState(() {
            _questions = menuQ;
          });
        } else {}
      });
      return;
    } else {
      setState(() {
        _questions = {};
      });
    }
  }

  Future getMenuAvgStar(context) async {
    http.Response res =
        await getWithToken('$currentHost/meals/rating/star?menuDate=${formatDate(date, [yyyy, '', mm, '', dd])}&menuTime=${menuTime}');
    print(res.statusCode);
    if (res.statusCode == 200) {
      List<dynamic> jsonBody = jsonDecode(res.body)["data"];
      setState(() {
        if (jsonBody != null) {
          setState(() {
            _avgRatings = jsonBody;
            double avgStar = -1;
            for (int i = 0; i < _avgRatings.length; i++) {
              if (_avgRatings[i]["menuSeq"] == menuSeq) {
                avgStar = _avgRatings[i]["averageStar"].toDouble();
                break;
              }
            }
          });
        } else {}
      });
    } else {
      setState(() {
        _avgRatings = [];
      });
    }
    setState(() {
      _isGetAvgStar = true;
    });
  }

  Future getMenuAvgAnswer() async {
    http.Response res = await getWithToken(
        '$currentHost/meals/rating/answer?menuDate=${formatDate(date, [yyyy, '', mm, '', dd])}&menuSeq=${menuSeq}&menuTime=${menuTime}');
    print(res.statusCode);

    if (res.statusCode == 200) {
      List<dynamic> jsonBody = jsonDecode(res.body)["data"]["answers"];
      setState(() {
        if (jsonBody != null) {
          setState(() {
            _avgAnswers = jsonBody;
          });
        } else {}
      });
    } else {
      setState(() {
        _avgAnswers = [];
      });
    }
    setState(() {
      _isGetAvgAnswer = true;
    });
  }

  Future postAnswer(context) async {
    MealStatus mealStatus = Provider.of<MealStatus>(context);
    mealStatus.setIsLoading(true);
    http.Response res = await postWithToken('$currentHost/meals/rating/answer', body: {
      "menuDate": formatDate(date, [yyyy, '', mm, '', dd]), "menuTime" : menuTime,
      "menu": {"menuSeq": menuSeq, "questions": _transferData}
    });
    print(res.statusCode);

    mealStatus.setIsLoading(false);

    if (res.statusCode == 200) {
      print('포스트 성공');
      setState(() {
        _postIsEnd = true;
        _isQuestionAnswered = true;
      });
      return true;
    } else {
      return false;
    }
  }

  submitAnswer(context) async {
    var temp = [];
    for (int j = 0; j < _nowQuestions.length; j++) {
      temp.add({"questionSeq": _nowQuestions[j], "answer": _currentValue[(_nowQuestions[j]).toString()].round()});
    }
    setState(() {
      _transferData = temp;
    });

    if (await postAnswer(context) == true) {
      setState(() {
        _questions["answers"] = _questions["questions"];
        for (int i = 0; i < _questions["answers"].length; i++) {
          _questions["answers"][i]["answer"] = _transferData[i]["answer"];
        }
      });

      showCustomAlert(
        context: context,
        isSuccess: true,
        title: "평가 완료!",
        duration: Duration(seconds: 1),
      );
      getMenuAvgAnswer();

      btnController.animateToPage(1, duration: Duration(milliseconds: 500), curve: Curves.ease);
      setState(() {
        _selectedTabIndex = 1;
      });
    } else {
      showCustomAlert(
        context: context,
        isSuccess: false,
        title: "ERROR!",
        duration: Duration(seconds: 1),
      );
    }
  }

  showRateStarSheet(context, isAnswerCompleted) {
    MealStatus mealStatus = Provider.of<MealStatus>(context);
    var ratingEmojiList = ["spice", "cold", "soso", "good", "love"];
    showModalBottomSheet(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
        ),
        context: context,
        builder: (BuildContext bc) {
          return StatefulBuilder(builder: (BuildContext bc, StateSetter state) {
            return Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(15)),
              ),
              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
              child: new Wrap(
                children: <Widget>[
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        "전체적인 메뉴의 만족도는 어땠나요?",
                        style: TextStyle(fontSize: fs.s6),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: ratingEmojiList.map((x) {
                          return Material(
                            borderRadius: BorderRadius.all(Radius.circular(100)),
                            child: InkWell(
                              borderRadius: BorderRadius.all(Radius.circular(100)),
                              onTap: () async {
                                int star = ratingEmojiList.indexOf(x) + 1;
                                Future rateStar(int menuSeq, int star) async {
                                  http.Response res = await postWithToken('${currentHost}/meals/rating/star', body: {
                                    "menuTime" : menuTime,
                                    "menuDate": formatDate(date, [yyyy, '', mm, '', dd]),
                                    "menus": [
                                      {"menuSeq": menuSeq, "star": star}
                                    ]
                                  });
                                  print(res.statusCode);
                                  if (res.statusCode == 200) {
                                    print('포스트 성공');
                                    mealStatus.setRatingStarList(menuSeq, star);
                                    return true;
                                  } else {
                                    return false;
                                  }
                                }

                                mealStatus.setIsLoading(true);
                                Navigator.pop(context);
                                bool rateResult = await rateStar(menuSeq, star);

                                mealStatus.setIsLoading(false);




                                if (rateResult == true) {

                                  setState(() {
                                    changedStar = star;
                                  });
                                  getMenuAvgStar(context);
                                  if (!isAnswerCompleted) {
                                    submitAnswer(context);
                                  }
                                }else{
                                  showCustomAlert(
                                    context: context,
                                    isSuccess: false,
                                    title: "ERROR!",
                                    duration: Duration(seconds: 1),
                                  );
                                }
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.all(Radius.circular(100)),
                                ),
                                padding: EdgeInsets.all(2),
                                margin: EdgeInsets.symmetric(horizontal: 3),
                                child: Image.asset(
                                  getEmoji(x),
                                  width: 40,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      SizedBox(
                        height: 30,
                      )
                    ],
                  )
                ],
              ),
            );
          });
        });
  }
}
