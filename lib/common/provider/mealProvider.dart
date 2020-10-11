import 'dart:io';

import 'package:flutter/cupertino.dart';
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

  void addSelectedDay(String date, String menu) {
    if (!dayList.containsKey(date)) {
      List<String> menuList = [];
      menuList.add(menu);
      dayList[date] = menuList;
      notifyListeners();
    } else {
      print("어머나 이거 어떡하지");
      dayList[date].add(menu);
      notifyListeners();
    }
    for (int i = 0; i < dayList.length; i++) {
      print(dayList);
    }
  }
}
