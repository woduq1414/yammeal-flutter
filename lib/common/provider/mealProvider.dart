import 'dart:io';
import 'package:date_format/date_format.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';

import 'package:flutter/material.dart';

import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:meal_flutter/common/provider/userProvider.dart';
import 'package:table_calendar/table_calendar.dart';

import "../../common/ip.dart";
import '../func.dart';

import "../../common/push.dart";

import 'package:http/http.dart' as http;

import '../ip.dart';

class MealStatus with ChangeNotifier {
  bool isLoading = false;

  String test = "hello";

  Map<dynamic, dynamic> dayList = Map<dynamic, dynamic>();
  String selectedEmoji;
  bool isLoadingFavorite = false;

  String isSaveMenuStorage;
  bool isReceivePush;
  int pushHour;
  int pushMinute;

  List<String> menuTimeList = [];

  var startDate = formatDate(DateTime(DateTime.now().year, DateTime.now().month, 01), ['yyyy', '', 'mm', '', 'dd']);
  var endDate = formatDate(DateTime(DateTime.now().year, DateTime.now().month, 32), ['yyyy', '', 'mm', '', 'dd']);
  var calendarType = CalendarFormat.month;

  List<int> ratingStarList = [
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0
  ];

  getMyRatedStar(String menuTime) async {
    ratingStarList = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
    http.Response res = await getWithToken('${currentHost}/meals/rating/star/my?menuDate=${formatDate(DateTime.now(), [
      yyyy,
      '',
      mm,
      '',
      dd
    ])}&menuTime=${menuTime}');
    print(res.statusCode);
    if (res.statusCode == 200) {
//      print(jsonDecode(res.body));
      var jsonBody = jsonDecode(res.body)["data"];
      for (var rating in jsonBody) {
        ratingStarList[rating["menuSeq"]] = rating["star"];
      }
      print(ratingStarList);
      notifyListeners();
      return;
    } else {
      return;
    }
  }

  setRatingStarList(index, value) {
    ratingStarList[index] = value;
    notifyListeners();
  }

  refreshFavoritePush(jsonBody) async {
    int PUSH_HOUR = pushHour;
    int PUSH_MINUTE = pushMinute;

    PushManager pm = PushManager();
    var pushList = await pm.getScheduledPush();
    for (String dateString in jsonBody.keys) {
      DateTime d = DateTime.parse(dateString);
      DateTime now = DateTime.now();
      if (d.difference(DateTime.now()) <= Duration(days: 7)) {
        print("abc" + dateString);
        // pm.cancelScheduledPush(int.parse(formatDate(d, ['yyyy', '', 'mm', '', 'dd'])));
        pm.schedulePush(
            id: int.parse(formatDate(d, ['yyyy', '', 'mm', '', 'dd'])),
            datetime: DateTime(d.year, d.month, d.day, PUSH_HOUR, PUSH_MINUTE, 0),
            title: getRandomPushTitle(),
            body: "오늘은 ${getRandomElement(jsonBody[dateString])} 나오는 날~",
            payload: formatDate(d, ['yyyy', '', 'mm', '', 'dd']) + "%" + jsonBody[dateString].join(","));
        print(formatDate(d, ['yyyy', '', 'mm', '', 'dd']) + "%" + jsonBody[dateString].join(","));
      }
    }
    pm.printScheduledPush();
  }

  setFavoriteListWithRange() async {
    print(startDate);
    print("start");
    setIsLoadingFavorite(true);
    notifyListeners();

    var res = await getWithToken(
      '${currentHost}/meals/v2/rating/favorite?startDate=${startDate}&endDate=${endDate}',
    );
    print(res.statusCode);
    if (res.statusCode == 200) {
      print(jsonDecode(res.body));
      Map<dynamic, dynamic> jsonBody = jsonDecode(res.body)["data"];
      if (jsonBody != null) {
        setDayList(jsonBody);

        if (isReceivePush && true) {
          int PUSH_HOUR = pushHour;
          int PUSH_MINUTE = pushMinute;

          PushManager pm = PushManager();
          var pushList = await pm.getScheduledPush();
          for (String dateString in jsonBody.keys) {
            DateTime d = DateTime.parse(dateString);
            DateTime now = DateTime.now();
            if (d.difference(DateTime.now()) <= Duration(days: 7)) {
              print(dateString);
              pm.cancelScheduledPush(int.parse(formatDate(d, ['yyyy', '', 'mm', '', 'dd'])));

              var menuSet = Set();
              for (var time in dayList[dateString].keys) {
                menuSet.addAll(dayList[dateString][time]);
              }

              pm.schedulePush(
                  id: int.parse(formatDate(d, ['yyyy', '', 'mm', '', 'dd'])),
                  datetime: DateTime(d.year, d.month, d.day, PUSH_HOUR, PUSH_MINUTE, 0),
                  title: getRandomPushTitle(),
                  body: "오늘은 ${getRandomElement(menuSet.toList())} 나오는 날~",
                  payload: formatDate(d, ['yyyy', '', 'mm', '', 'dd']) + "%" + menuSet.toList().join(","));
            }
          }
          print(await pm.getScheduledPush());
        }
      } else {}
    } else {
      setDayList({});
    }

    setIsLoadingFavorite(false);
    notifyListeners();
  }

  setIsLoadingFavorite(value) {
    isLoadingFavorite = value;
    notifyListeners();
  }

  MealStatus() {
    init();
  }

  init() async {
    var storage = FlutterSecureStorage();
    String favoriteEmoji = await storage.read(key: "favoriteEmoji");
    String _isSaveMenuStorage = await storage.read(key: "isSaveMenuStorage");
    String _isReceivePush = await storage.read(key: "isReceivePush");
    String _pushHour = await storage.read(key: "pushHour");
    String _pushMinute = await storage.read(key: "pushMinute");
    String _menuTimeList = await storage.read(key: "menuTimeList");

    if (favoriteEmoji != null) {
      setSelectedEmoji(favoriteEmoji);
    } else {
      setSelectedEmoji("selected");
    }

    if (_isSaveMenuStorage != null) {
      isSaveMenuStorage = _isSaveMenuStorage;
      notifyListeners();
    } else {
      isSaveMenuStorage = "true";
      notifyListeners();
      storage.write(key: "isSaveMenuStorage", value: "true");
    }

    if (_isReceivePush != null) {
      isReceivePush = _isReceivePush == "true" ? true : false;
      notifyListeners();
    } else {
      isReceivePush = true;
      notifyListeners();
      storage.write(key: "isSaveMenuStorage", value: "true");
    }

    if (_pushHour != null) {
      pushHour = int.parse(_pushHour);
      notifyListeners();
    } else {
      pushHour = 7;
      notifyListeners();
      storage.write(key: "pushHour", value: "7");
    }

    if (_pushMinute != null) {
      pushMinute = int.parse(_pushMinute);
      notifyListeners();
    } else {
      pushMinute = 0;
      notifyListeners();
      storage.write(key: "pushMinute", value: "0");
    }

    if (_menuTimeList != null) {
      menuTimeList = _menuTimeList.split("/");
      notifyListeners();
    } else {
      menuTimeList = ["조식", "중식", "석식"];
      notifyListeners();
      storage.write(key: "menuTimeList", value: "조식/중식/석식");
    }

//    setSelectedEmoji()
  }

  void setIsLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }

  void setDayList(Map m) {
    dayList = m;

    print(dayList);
    print('아이고...');
    print(dayList[0]);
    notifyListeners();
  }

  bool updateSelectedDay(String date, String menu, String menuTime) {
    //true - 추가, false - 삭제

    // if (!dayList.containsKey(date)) {
    //   List<String> menuList = [];
    //   menuList.add(menu);
    //   dayList[date] = menuList;
    //   notifyListeners();
    //   return true;
    // } else {
    //   if (dayList[date].contains(menu)) {
    //     dayList[date].remove(menu);
    //     if (dayList[date].length == 0) {
    //       dayList.remove(date);
    //     }
    //     notifyListeners();
    //     return false;
    //   } else {
    //     dayList[date].add(menu);
    //     notifyListeners();
    //     return true;
    //   }
    // }

    if (!dayList.containsKey(date)) {
      dayList[date] = {};
      dayList[date][menuTime] = [menu];

      notifyListeners();
      return true;
    } else {
      if (dayList[date].containsKey(menuTime)) {
        if (dayList[date][menuTime].contains(menu)) {
          dayList[date][menuTime].remove(menu);
          if (dayList[date][menuTime].length == 0) {
            // dayList.remove(date);
          }
          notifyListeners();
          return false;
        } else {
          dayList[date][menuTime].add(menu);
          notifyListeners();
          return true;
        }
      } else {
        dayList[date][menuTime] = [menu];
        notifyListeners();
        return true;
      }
    }
  }

  void setSelectedEmoji(String s) async {
    var storage = FlutterSecureStorage();
    storage.write(key: "favoriteEmoji", value: s);

    selectedEmoji = s;
    notifyListeners();
  }

  void setIsSaveMenuStorage(String s) async {
    var storage = FlutterSecureStorage();
    storage.write(key: "isSaveMenuStorage", value: s);
    isSaveMenuStorage = s;
    notifyListeners();
  }

  void setMenuTimeList(String s) async {
    var storage = FlutterSecureStorage();
    storage.write(key: "menuTimeList", value: s);
    menuTimeList = s.split("/");
    notifyListeners();
  }




  void setIsReceivePush(bool s) async {
    var storage = FlutterSecureStorage();
    storage.write(key: "isReceivePush", value: s == true ? "true" : "false");
    isReceivePush = s;

    if (s == false) {
      PushManager pm = PushManager();
      pm.cancelAllScheduledPush();
    } else {
      PushManager pm = PushManager();

      pm.pushNow(id: 0, title: "알림 받는 것을 허용했어요!", body: "알림을 이제 받을 수 있어요.");

      refreshFavoritePush(dayList);
    }

    notifyListeners();
  }

  void setPushTime(int hour, int minute) async {
    var storage = FlutterSecureStorage();
    storage.write(key: "pushHour", value: hour.toString());
    storage.write(key: "pushMinute", value: minute.toString());

    pushHour = hour;
    pushMinute = minute;

    notifyListeners();
  }
}
