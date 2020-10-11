import 'dart:convert';

import 'package:date_format/date_format.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:meal_flutter/UIs/meal_detail.dart';
import 'package:meal_flutter/common/provider/userProvider.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'dart:math'; // 그냥 api 가져오기 전에 이모티콘 다양하게 하려 랜덤쓰려고 함. 나중에 지울 것
import '../common/provider/mealProvider.dart';
import 'package:http/http.dart' as http;

class MealCalState extends StatefulWidget {
  @override
  MealCalendar createState() => MealCalendar();

}

class MealCalendar extends State<MealCalState> {

  CalendarController _controller;

  final List<String> emojiList = ['cold', 'good', 'spice', 'umji', 'love']; // 랜덤 돌리려 만들어둔거, 삭제될 예정.
  var dayList = {};

  @override
  void initState() {
    super.initState();
    _controller = CalendarController();
  }

  // @override
  // void didChangeDependencies() {
  //   super.didChangeDependencies();
  //   MealStatus mealStatus = Provider.of<MealStatus>(context);
  //   mealStatus.setDayList(dayList);
  // }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TableCalendar(
      calendarController: _controller,
      builders: _calendarBuilders(),
    );
  }

  CalendarBuilders _calendarBuilders() {
    MealStatus mealStatus = Provider.of<MealStatus>(context);

    return CalendarBuilders(
        selectedDayBuilder: (context, date, _) {
          return Container(
              child: Image.asset('assets/${emojiList[randomNum()]}.png', width: 50)
          );
        },
        todayDayBuilder: (context, date, _) {
          return Container(
            child: Stack(
              children: <Widget>[
                Image.asset('assets/${emojiList[randomNum()]}.png', width: 50)
              ],
            ),
            decoration: BoxDecoration(
              color: Colors.red,
            ),
          );
        },
        dayBuilder: (_context, date, _) {
          return GestureDetector(
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => MealDetailState(date))
              );
            },
            child: Container(
              child: Column(
                children: <Widget>[
                  Text(date.day.toString()),
                  Image.asset(DateTime.now().difference(date).inMilliseconds <= 0 ? (!mealStatus.dayList.containsKey(formatDate(date, ['yyyy', '', 'mm', '', 'dd'])) ? 'assets/dishes.png' : 'assets/selected.png') : 'assets/${emojiList[randomNum()]}.png', width: 35,),
                ],
              ),
            ),
          );
        },
        outsideDayBuilder: (context, date, _) {
          return Container(
              child: Center(
                child: Text(date.day.toString(), style: TextStyle(color: Colors.grey),),
              )
          );
        },
        outsideWeekendDayBuilder: (context, date, _) {
          return Container(
              child: Center(
                child: Text(date.day.toString(), style: TextStyle(color: Colors.grey),),
              )
          );
        },
        dowWeekendBuilder: (context, date) {
          return Center(
            child: Text(date.toString(), style: TextStyle(color: Colors.yellow),),
          );
        }
    );
  }

  int randomNum() {//api로 이모지 제대로 받으면 사라질 것
    Random rnd = new Random();
    return rnd.nextInt(4);
  }
}



