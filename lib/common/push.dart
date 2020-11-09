import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart';

class PushManager{
  var _flutterLocalNotificationsPlugin;

  var initializationSettingsAndroid =
  AndroidInitializationSettings('@mipmap/ic_launcher');
  var initializationSettingsIOS = IOSInitializationSettings();

  PushManager(){
    var initializationSettings = InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);

    _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    _flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: onSelectNotification);
  }


  Future<void> onSelectNotification(String payload) async {
    debugPrint("$payload");
//    showDialog(
//        context: context,
//        builder: (_) => AlertDialog(
//          title: Text('Notification Payload'),
//          content: Text('Payload: $payload'),
//        ));
  }


  Future<void> showNotification() async {
    print("pushpush babe");
    var android = AndroidNotificationDetails(
        'your channel id', 'your channel name', 'your channel description',
        importance: Importance.Max, priority: Priority.High);

    var ios = IOSNotificationDetails();
    var detail = NotificationDetails(android, ios);

    await _flutterLocalNotificationsPlugin.show(
      0,
      '단일 Notification',
      '단일 Notification 내용',
      detail,
      payload: 'Hello Flutter',
    );
  }

  Future<void> NotificationAt() async {

    tz.initializeTimeZones();

    final detroit = getLocation('America/Detroit');


//    var detroit = getLocation('Asia/Seoul');
    var time = TZDateTime(detroit, 2020, 11,09,22,32,25);
    var android = AndroidNotificationDetails(
        'your channel id', 'your channel name', 'your channel description',
        importance: Importance.Max, priority: Priority.High);

    var ios = IOSNotificationDetails();
    var detail = NotificationDetails(android, ios);

    print(time);


    await _flutterLocalNotificationsPlugin.zonedSchedule(
      0,
      '오늘의 급식은?',
      '뭘까요',
      time,
      detail,
      payload: 'Hello Flutter',
    );
  }



  Future<void> dailyAtTimeNotification() async {
    var time = Time(21, 50, 30);
    var android = AndroidNotificationDetails(
        'your channel id', 'your channel name', 'your channel description',
        importance: Importance.Max, priority: Priority.High);

    var ios = IOSNotificationDetails();
    var detail = NotificationDetails(android, ios);

    await _flutterLocalNotificationsPlugin.showDailyAtTime(
      0,
      '매일 똑같은 시간의 Notification',
      '매일 똑같은 시간의 Notification 내용',
      time,
      detail,
      payload: 'Hello Flutter',
    );
  }

  Future<void> repeatNotification() async {
    var android = AndroidNotificationDetails(
        'your channel id', 'your channel name', 'your channel description',
        importance: Importance.Max, priority: Priority.High);

    var ios = IOSNotificationDetails();
    var detail = NotificationDetails(android, ios);

    await _flutterLocalNotificationsPlugin.periodicallyShow(
      0,
      '반복 Notification',
      '반복 Notification 내용',
      RepeatInterval.EveryMinute,
      detail,
      payload: 'Hello Flutter',
    );
  }


}


