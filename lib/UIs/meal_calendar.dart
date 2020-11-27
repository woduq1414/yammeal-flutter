import 'dart:math';

import 'package:date_format/date_format.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:meal_flutter/UIs/meal_detail.dart';
import 'package:meal_flutter/common/asset_path.dart';
import 'package:meal_flutter/common/color.dart';
import 'package:meal_flutter/common/font.dart';
import 'package:meal_flutter/common/provider/mealProvider.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

// import '../common/provider/mealProviderkage:intl/date_symbol_data_local.dart';
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
          rowHeight: fs.getHeightRatioSize(0.073),
          calendarController: _controller,
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
                  width: fs.getWidthRatioSize(0.08),
                )
                    : Image.asset(getEmoji(mealStatus.selectedEmoji), width: fs.getWidthRatioSize(0.08),))
              ],
            ),
          ),
        );
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
                            width: fs.getWidthRatioSize(0.08),
                          )
                        : Image.asset(getEmoji(mealStatus.selectedEmoji), width: fs.getWidthRatioSize(0.08),))
                    : ColorFiltered(
                        colorFilter: ColorFilter.mode(Colors.grey[400], BlendMode.modulate),
                        child: Image.asset(getEmoji("dishes"), width: fs.getWidthRatioSize(0.08),))
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
