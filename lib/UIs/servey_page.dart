import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:meal_flutter/common/asset_path.dart';
import 'package:meal_flutter/common/color.dart';
import 'package:meal_flutter/common/font.dart';


class MealSurvey extends StatefulWidget {
  @override
  _MealSurveyState createState() => _MealSurveyState();
}

class _MealSurveyState extends State<MealSurvey> {

  FontSize fs;
  int _selectedTabIndex = 0;
  CarouselController btnController = CarouselController();
  Map<String, double> _currentValue = {"salt": 50, "spice": 50, "sexy": 50};

  @override
  Widget build(BuildContext context) {
    fs = FontSize(context);

    return Scaffold(
      backgroundColor: Color(0xffFFBB00),
      body: Column(
        children: [
          CarouselSlider(
            carouselController: btnController,
            options: CarouselOptions(
              enableInfiniteScroll: false,
              autoPlay: false,
              height: MediaQuery.of(context).size.height-100,
              viewportFraction: 1,
                onPageChanged: (index, CarouselPageChangedReason c) {
                  setState(() {
                    _selectedTabIndex = index;
                  });
                }
            ),
            items: <Widget>[
              Column(
                children: <Widget>[
                  SizedBox(height: 50,),
                  Text('급식의 정보', style: TextStyle(fontSize: fs.s2),)
                ],
              ),
              Column(
                children: <Widget>[
                  SizedBox(height: fs.getHeightRatioSize(0.1),),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text('음식의 간은 어땠나요?', style: TextStyle(fontSize: fs.s4),),
                      Image.asset(getEmoji("question"), width: fs.s1,),
                    ],
                  ),
                  SizedBox(height: fs.getHeightRatioSize(0.06),),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Image.asset(getEmoji("cup"), width: 50,),
                      _buildSilder("salt"),
                      Image.asset(getEmoji("salty"), width: 50,)
                    ],
                  ),
                  //질문1
                  SizedBox(height: fs.getHeightRatioSize(0.1),),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text('음식의 맵기는 어땠나요?', style: TextStyle(fontSize: fs.s4),),
                      Image.asset(getEmoji("question"), width: fs.s1,),
                    ],
                  ),
                  SizedBox(height: fs.getHeightRatioSize(0.06),),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Image.asset(getEmoji("cup"), width: 50,),
                      _buildSilder("spice"),
                      Image.asset(getEmoji("spice"), width: 50,)
                    ],
                  ),
                  //질문2
                  SizedBox(height: fs.getHeightRatioSize(0.1),),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text('음식의 섹시함은 어땠나요?', style: TextStyle(fontSize: fs.s4),),
                      Image.asset(getEmoji("question"), width: fs.s1,),
                    ],
                  ),
                  SizedBox(height: fs.getHeightRatioSize(0.06),),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Image.asset(getEmoji("soso"), width: 50,),
                      _buildSilder("sexy"),
                      Image.asset(getEmoji("good"), width: 50,)
                    ],
                  )
                ],
              )
            ],
          ),
        ]
      ),
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          canvasColor: primaryYellowDark,
          primaryColor: primaryRed,
          textTheme: Theme.of(context)
              .textTheme
              .copyWith(caption: TextStyle(color: Colors.black)),
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
            btnController.jumpToPage(index);
            setState(() {
              _selectedTabIndex = index;
            });
          },
        ),
      ),
    );
  }

  Widget _buildSilder(String val) {
    return Container(
      width: fs.getWidthRatioSize(0.7),
      child: Slider(
        value: _currentValue[val],
        min: 0,
        max: 100,
        divisions: 4,
        label: _currentValue[val].round().toString(),
        activeColor: Color(0xffff4600),
        onChanged: (double value) {
          setState(() {
            _currentValue[val] = value;
          });
        },
      ),
    );
  }
}
