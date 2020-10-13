import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';

import 'package:flutter/material.dart';

import 'dart:convert';

class MealStatus with ChangeNotifier {
  Map<dynamic, dynamic> dayList = Map<dynamic, dynamic>();

  void setDayList(Map m) {
    dayList = m;
    print(dayList);
    print('아이고...');
    print(dayList[0]);
    notifyListeners();
  }

  // void sortMapITem(Map m) {
  //   for (int i = 0; i < m.length; i++) {
  //     if (m)
  //   }
  // }

  bool updateSelectedDay(String date, String menu) { //true - 추가, false - 삭제
    if (!dayList.containsKey(date)) {
      List<String> menuList = [];
      menuList.add(menu);
      dayList[date] = menuList;
      notifyListeners();
      return true;
    } else {
      if (dayList[date].contains(menu)) {
        dayList[date].remove(menu);
        if (dayList[date].length == 0) {
          dayList.remove(date);
        }
        notifyListeners();
        return false;
      } else {
        dayList[date].add(menu);
        notifyListeners();
        return true;
      }
    }
  }
}
