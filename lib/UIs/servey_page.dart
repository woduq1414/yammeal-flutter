import 'dart:convert';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:meal_flutter/common/asset_path.dart';
import 'package:meal_flutter/common/color.dart';
import 'package:meal_flutter/common/font.dart';
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

class MealSurvey extends StatefulWidget {
  int menuSeq;
  String meal;

  MealSurvey(int index, String meal) {
    this.menuSeq = index;
    this.meal = meal;
  }

  @override
  _MealSurveyState createState() => _MealSurveyState(menuSeq, meal);
}

class _MealSurveyState extends State<MealSurvey> {
  int menuSeq;
  String meal;

  _MealSurveyState(int menuSeq, String meal) {
    this.menuSeq = menuSeq;
    this.meal = meal;
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
  var _questions = {};
  var _nowQuestions = [];
  var _transferData = [];

  bool _isGetAvgRating = false;

  bool _postIsEnd = false;

  bool _isQuestionAnswered = false;

  @override
  void initState() {
    super.initState();
    _postIsEnd = false;
    _avgRatings = [];

    getIsQuestionAnswered();

    getMenuAvgRatings();

    print(_questions);
  }

  getIsQuestionAnswered() async {
    http.Response res = await getWithToken('$currentHost/meals/rating/answer/my?menuDate=${formatDate(DateTime.now(), [
      yyyy,
      '',
      mm,
      '',
      dd
    ])}&menuSeq=${menuSeq}');

    if (res.statusCode == 200) {
      Map<String, dynamic> jsonBody = jsonDecode(res.body)["data"];
      print(jsonBody);
      setState(() {
        _isQuestionAnswered = true;
        _questions = jsonBody;
      });
    } else {
      setState(() {
        _isQuestionAnswered = false;
      });
      btnController.animateToPage(1, duration: Duration(milliseconds: 500), curve: Curves.ease);
      setState(() {
        _selectedTabIndex = 1;
      });
      await getQuestion();
    }
  }

  @override
  Widget build(BuildContext context) {
    fs = FontSize(context);

    return LoadingMealModal(
      child: Scaffold(
        backgroundColor: Color(0xffFFBB00),
        body: Column(mainAxisAlignment: MainAxisAlignment.start, children: [
          SizedBox(height: fs.getHeightRatioSize(0.07)),
          Text(
            meal,
            style: TextStyle(fontSize: fs.s2),
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
                      print("@!#!@#");
                      if (_isGetAvgRating == false) {
                        getMenuAvgRatings();
                      }
                    }
                    setState(() {
                      _selectedTabIndex = index;
                    });
                  }),
              items: <Widget>[
                SingleChildScrollView(
                  child: Column(
                    children: <Widget>[
                      SizedBox(
                        height: fs.getHeightRatioSize(0.02),
                      ),
                      SizedBox(
                        height: fs.getHeightRatioSize(0.02),
                      ),
                      _bulidMenuInfo()
                    ],
                  ),
                ),
                Align(
//                  alignment: Alignment.center,
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
                                  children: _questions["answers"] != null ? _questions["answers"].map<Widget>((item) {

                                    return _buildQuestionItem(item, defaultVal: item["answer"]);
                                  }).toList()
                                            : <Widget>[
                                         Center(child: CustomLoading(),)
                                        ],
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 35,),
                                ],
                              )
                          ),
                          Positioned(
                            bottom: 10,
                            right: 15,
                            left: 15,
                            child: RaisedButton(
                              color: Colors.grey[400],
                              textColor: Colors.black,

                              child: Text("이미 평가 했어요!", style: TextStyle(fontSize: fs.s6),),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(50),
                              ),
                              onPressed: () async {
                               
                              },
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
                                              Center(
                                                child: CustomLoading()
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 35,),
                                    ],
                                  )
                                ),
                                Positioned(
                                  bottom: 10,
                                  right: 15,
                                  left: 15,
                                  child: RaisedButton(
                                    color: primaryRedDark,
                                    textColor: Colors.white,

                                    child: Text("평가 제출하기", style: TextStyle(fontSize: fs.s6),),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(50),
                                    ),
                                    onPressed: () async {
                                      var temp = [];
                                      print("길이 ${_nowQuestions.length}");
                                      for (int i = 0; i < _nowQuestions.length; i++) print(_nowQuestions[i]);
                                      for (int j = 0; j < _nowQuestions.length; j++) {
                                        temp.add({
                                          "questionSeq": _nowQuestions[j],
                                          "answer": _currentValue[(_nowQuestions[j]).toString()].round()
                                        });
                                      }
                                      setState(() {
                                        _transferData = temp;
                                      });
                                      print("dkdkdkdk");
                                      print(_transferData);
                                      if (await postAnswer(context) == true) {

                                        setState(() {
                                          _questions["answers"] = _questions["questions"];
                                          for(int i = 0; i < _questions["answers"].length; i++){
                                            _questions["answers"][i]["answer"] = _transferData[i]["answer"];
                                          }
                                        });

                                        showCustomAlert(
                                          context: context,
                                          isSuccess: true,
                                          title: "평가 완료!",
                                          duration: Duration(seconds: 1),
                                        );

                                        btnController.animateToPage(0, duration: Duration(milliseconds: 500), curve: Curves.ease);
                                        setState(() {
                                          _selectedTabIndex = 0;
                                        });

                                      } else {
                                        showCustomAlert(
                                          context: context,
                                          isSuccess: false,
                                          title: "오류",
                                          duration: Duration(seconds: 1),
                                        );
                                      }
                                    },
                                  ),
                                )
                              ],
                            )),
                )
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
                icon: Icon(Icons.dvr),
                title: Text('메뉴 상세 정보'),
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.edit),
                title: Text('메뉴 평가'),
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
    );
  }

  Widget  _buildQuestionItem(item, {int defaultVal}) {
    return Column(
      children: <Widget>[
//        SizedBox(
//          height: fs.getHeightRatioSize(0.1),
//        ),
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
    //String menuName = '';
    double avgStar = -1;

    //if (_isCalled) {
    for (int i = 0; i < _avgRatings.length; i++) {
      if (_avgRatings[i]["menuSeq"] == menuSeq) {
        // menuName = _avgRatings[i]["menuName"];
        avgStar = _avgRatings[i]["averageStar"].toDouble();
        break;
      }
    }
    //}
    return Container(
      width: fs.getWidthRatioSize(0.9),
      height: fs.getHeightRatioSize(0.6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.3),
      ),
      padding: EdgeInsets.only(left: 20, top: 20, right: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _isGetAvgRating ?
          Text(
            avgStar != -1 ? '학생들의 평균 별점: $avgStar' : '별점(이모지)를 평가하고 볼 수 있습니다ㅋㅋㅋㅋ ',
            style: TextStyle(fontSize: avgStar != -1 ? fs.s5 : fs.s6),
          ) : CustomLoading(),
          Text('주저리주저리종속저리종속저리...')
        ],
      ),
    );
  }

  //api 가져오기
  Future getQuestion() async {
    var menuQ = {};

    http.Response res = await getWithToken(
        '$currentHost/meals/rating/question?menuDate=${formatDate(DateTime.now(), [yyyy, '', mm, '', dd])}');
    print(res.statusCode);
    if (res.statusCode == 200) {
      //print(jsonDecode(res.body));
      List<dynamic> jsonBody = jsonDecode(res.body)["data"];
      print(jsonBody);
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
            print(menuQ);
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

  Future getMenuAvgRatings() async {
    http.Response res =
        await getWithToken('$currentHost/meals/rating/star?menuDate=${formatDate(DateTime.now(), [yyyy, '', mm, '', dd])}');
    print(res.statusCode);
    print(10000000000000000 + res.statusCode);
    if (res.statusCode == 200) {
      List<dynamic> jsonBody = jsonDecode(res.body)["data"];
      print(jsonBody);
      setState(() {
        if (jsonBody != null) {
          setState(() {
            _avgRatings = jsonBody;
            print(_avgRatings);
          });
        } else {}
      });
    } else {
      setState(() {
        _avgRatings = [];
      });
    }
    setState(() {
      _isGetAvgRating = true;
    });
  }

  Future postAnswer(context) async {
    MealStatus mealStatus = Provider.of<MealStatus>(context);
    mealStatus.setIsLoading(true);

    print('여기 들어오긴 오냐');
    http.Response res = await postWithToken('$currentHost/meals/rating/answer', body: {
      "menuDate": formatDate(DateTime.now(), [yyyy, '', mm, '', dd]),
      "menu": {"menuSeq": menuSeq, "questions": _transferData}
    });
    print('포스트');
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
}
