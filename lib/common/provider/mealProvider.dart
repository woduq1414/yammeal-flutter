import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../ip.dart';
import 'package:http/http.dart' as http;

import 'package:kakao_flutter_sdk/auth.dart';
import 'package:kakao_flutter_sdk/user.dart';

import 'dart:convert';

class MealStatus with ChangeNotifier {
  Map<dynamic, dynamic> dayList = {};

  void setDayList(Map m) {
    dayList = m;
    print(dayList);
    notifyListeners();
  }

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
