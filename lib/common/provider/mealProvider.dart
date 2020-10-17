import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';

import 'package:flutter/material.dart';

import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class MealStatus with ChangeNotifier {
  Map<dynamic, dynamic> dayList = Map<dynamic, dynamic>();
  String selectedEmoji;
  bool isLoadingFavorite = false;

  String isSaveMenuStorage;


  setIsLoadingFavorite(value){
    isLoadingFavorite = value;
    notifyListeners();
  }


  MealStatus() {
    init();
  }

  init() async{
    var storage = FlutterSecureStorage();
    String favoriteEmoji = await storage.read(key: "favoriteEmoji");
    String _isSaveMenuStorage = await storage.read(key: "isSaveMenuStorage");

    if(favoriteEmoji != null){
      setSelectedEmoji(favoriteEmoji);
    }else{
      setSelectedEmoji("selected");
    }

    if(_isSaveMenuStorage != null){
      isSaveMenuStorage = _isSaveMenuStorage;
      notifyListeners();
    }else{
      isSaveMenuStorage = "true";
      notifyListeners();
      storage.write(key: "isSaveMenuStorage", value : "true");
    }

//    setSelectedEmoji()
  }





  void setDayList(Map m) {
    dayList = m;
    print(dayList);
    print('아이고...');
    print(dayList[0]);
    notifyListeners();
  }

  bool updateSelectedDay(String date, String menu) {
    //true - 추가, false - 삭제
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

  void setSelectedEmoji(String s) async{

    var storage = FlutterSecureStorage();
    storage.write(key: "favoriteEmoji", value: s);

    selectedEmoji = s;
    notifyListeners();
  }


  void setIsSaveMenuStorage(String s) async{

    var storage = FlutterSecureStorage();
    storage.write(key: "isSaveMenuStorage", value: s);
    isSaveMenuStorage = s;
    notifyListeners();
  }



}
