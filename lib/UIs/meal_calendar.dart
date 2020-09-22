import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'dart:math'; // 그냥 api 가져오기 전에 이모티콘 다양하게 하려 랜덤쓰려고 함. 나중에 지울 것

class MealCalState extends StatefulWidget {
  @override
  MealCalendar createState() => MealCalendar();

}

class MealCalendar extends State<MealCalState> {

  CalendarController _controller;

  final List<String> emojiList = ['cold', 'good', 'spice', 'umji', 'love']; // 랜덤 돌리려 만들어둔거, 삭제될 예정.
  @override
  void initState() {
    super.initState();
    _controller = CalendarController();
  }

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
        dayBuilder: (context, date, _) {
          return Container(
            child: Column(
              children: <Widget>[
                Text(date.day.toString()),
                Image.asset('assets/${emojiList[randomNum()]}.png', width: 35,)
              ],
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