import 'dart:convert';

import 'package:month_picker_dialog/month_picker_dialog.dart';

import "../common/ip.dart";

import 'package:date_format/date_format.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:meal_flutter/UIs/meal_detail.dart';
import 'package:meal_flutter/common/asset_path.dart';
import 'package:meal_flutter/common/color.dart';
import 'package:meal_flutter/common/font.dart';
import 'package:meal_flutter/common/provider/userProvider.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'dart:math'; // 그냥 api 가져오기 전에 이모티콘 다양하게 하려 랜덤쓰려고 함. 나중에 지울 것
import '../common/provider/mealProvider.dart';
import 'package:http/http.dart' as http;
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

FontSize fs;

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
    fs = FontSize(context);
    MealStatus mealStatus = Provider.of<MealStatus>(context);
    initializeDateFormatting('ko_KR', null);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        SizedBox(
          height: 10,
        ),
        TableCalendar(
          calendarController: _controller,
//          locale: "ko_KR",

          onVisibleDaysChanged: (a, b, c) async {
            var oldStartDate = DateTime.parse(mealStatus.startDate);
            var oldEndDate = DateTime.parse(mealStatus.endDate);
            var oldCalendarType = mealStatus.calendarType;


            var focusedDay = _controller.focusedDay;
            var startDate = formatDate(a, ['yyyy', '', 'mm', '', 'dd']);
            var endDate = formatDate(
                DateTime(focusedDay.year, focusedDay.month, 31).isAfter(b)
                    ? b
                    : DateTime(focusedDay.year, focusedDay.month, 31),
                ['yyyy', '', 'mm', '', 'dd']);

            mealStatus.startDate = startDate;
            mealStatus.endDate = endDate;
            mealStatus.calendarType = c;

            if (DateTime.now().difference(b).inDays > 0) {
              mealStatus.setDayList({});
              return;
            }

//            print("startdate");
//            print(startDate);
//            print(endDate);
//            print(oldStartDate);
//            print(oldEndDate);
//            print(a.compareTo(oldStartDate));
//            print(DateTime(focusedDay.year, focusedDay.month, 31).isAfter(b) ? b : DateTime(focusedDay.year, focusedDay.month, 31).compareTo(oldEndDate));
//            if (a.compareTo(oldStartDate) >= 0 && DateTime(focusedDay.year, focusedDay.month, 31).isAfter(b)
//                ? b
//                : DateTime(focusedDay.year, focusedDay.month, 31).compareTo(oldEndDate) <= 0) {
//              print("ssdflkjskldfjskldfjksdajfklsdakfsjdkfsdklfjskld");
//              return;
//            }

//            if(a == oldStartDate && ((c == CalendarFormat.week)|| (c != CalendarFormat.month && oldCalendarType == CalendarFormat.month))){
//              return;
//            }


            mealStatus.setFavoriteListWithRange();
          },

          builders: _calendarBuilders(),

          headerVisible: true,
          onHeaderTapped: (d){
            showMonthPicker(
              context: context,
              firstDate: DateTime(DateTime.now().year - 1, 5),
              lastDate: DateTime(DateTime.now().year + 1, 9),
              initialDate: d,


            ).then((date) {
              if (date != null) {
                _controller.setSelectedDay(date);
              }
            });

          },
          headerStyle: HeaderStyle(
            centerHeaderTitle: true,
            formatButtonVisible: false,
            titleTextStyle: TextStyle(fontSize: fs.s6, color: Colors.white),
            leftChevronIcon: Icon(
              Icons.chevron_left,
              size: fs.s4,
              color: Colors.white,
            ),
            rightChevronIcon: Icon(
              Icons.chevron_right,
              size: fs.s4,
              color: Colors.white,
            ),
            headerMargin: EdgeInsets.only(bottom: 5),
          ),
        )
      ],
    );
  }

  CalendarBuilders _calendarBuilders() {
    MealStatus mealStatus = Provider.of<MealStatus>(context);

    return CalendarBuilders(
      // selectedDayBuilder: (context, date, _) {
      //   return Container(
      //       child: Image.asset(getEmoji(emojiList[randomNum()]), width: 50));
      // },
      todayDayBuilder: (context, date, _) {

        return GestureDetector(
          onTap: () async {
            await Navigator.push(context, MaterialPageRoute(builder: (context) => MealDetailState(date)));
            mealStatus.setFavoriteListWithRange();
          },
          child: Container(
            margin: EdgeInsets.only(bottom: 5, left: 0, right:  0),
            decoration: BoxDecoration(
              color: primaryYellow,
              borderRadius: BorderRadius.all(Radius.circular(5)),
            ),
            child: Column(
              children: <Widget>[
                Text(date.day.toString(), style: TextStyle(color : Colors.white),),
                (!mealStatus.dayList.containsKey(formatDate(date, ['yyyy', '', 'mm', '', 'dd']))
                    ? Image.asset(
                  getEmoji("dishes"),
                  width: 33,
                )
                    : Image.asset(getEmoji(mealStatus.selectedEmoji), width: 33))
              ],
            ),
          ),
        );



        // return GestureDetector(
        //   onTap: () async {
        //     await Navigator.push(context, MaterialPageRoute(builder: (context) => MealDetailState(date)));
        //     mealStatus.setFavoriteListWithRange();
        //   },
        //   child: Container(
        //     child: Column(
        //       children: <Widget>[
        //         Text(date.day.toString()),
        //         ColorFiltered(
        //             colorFilter: ColorFilter.mode(primaryYellow, BlendMode.modulate),
        //             child: Image.asset(getEmoji("dishes"), width: 33))
        //       ],
        //     ),
        //   ),
        // );
      },
      dayBuilder: (_context, date, _) {
        return GestureDetector(
          onTap: () async {
            await Navigator.push(context, MaterialPageRoute(builder: (context) => MealDetailState(date)));
            mealStatus.setFavoriteListWithRange();
          },
          child: Container(

            margin: EdgeInsets.only(bottom: 5, left: 0, right:  0),
            child: Column(
              children: <Widget>[
                Text(date.day.toString()),
                DateTime.now().difference(date).inMilliseconds <= 0
                    ? (!mealStatus.dayList.containsKey(formatDate(date, ['yyyy', '', 'mm', '', 'dd']))
                        ? Image.asset(
                            getEmoji("dishes"),
                            width: 33,
                          )
                        : Image.asset(getEmoji(mealStatus.selectedEmoji), width: 33))
                    : ColorFiltered(
                        colorFilter: ColorFilter.mode(Colors.grey[400], BlendMode.modulate),
                        child: Image.asset(getEmoji("dishes"), width: 33))
              ],
            ),
          ),
        );
      },
      outsideDayBuilder: (context, date, _) {
        return Container(
            child: Center(
          child: Text(
            date.day.toString(),
            style: TextStyle(color: Colors.grey),
          ),
        ));
      },
      outsideWeekendDayBuilder: (context, date, _) {
        return Container(
            child: Center(
          child: Text(
            date.day.toString(),
            style: TextStyle(color: Colors.grey),
          ),
        ));
      },
      dowWeekendBuilder: (context, date) {
        return Center(
          child: Text(
            date.toString(),
            style: TextStyle(color: Colors.white),
          ),
        );
      },
      dowWeekdayBuilder: (context, date) {
        return Center(
          child: Text(
            date.toString(),
            style: TextStyle(color: Colors.white),
          ),
        );
      },
    );
  }

  int randomNum() {
    //api로 이모지 제대로 받으면 사라질 것
    Random rnd = new Random();
    return rnd.nextInt(4);
  }
}
