import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:meal_flutter/common/asset_path.dart';
import 'package:meal_flutter/common/color.dart';
import 'package:meal_flutter/common/db.dart';
import 'package:meal_flutter/common/font.dart';
import 'package:meal_flutter/common/provider/mealProvider.dart';
import 'package:meal_flutter/common/provider/userProvider.dart';
import 'package:meal_flutter/common/push.dart';
import 'package:meal_flutter/common/widgets/dialog.dart';
import 'package:meal_flutter/find_all_favorite.dart';
import 'package:meal_flutter/firebase.dart';
import 'package:provider/provider.dart';
import 'package:yaml/yaml.dart';

// import 'package:webview_flutter/webview_flutter.dart';
import 'package:package_info/package_info.dart';
import 'package:url_launcher/url_launcher.dart';
import 'main_page.dart';

import 'dart:io';

import '../login_page.dart';
import '../set_allergy_page.dart';
import "../common/ip.dart";
import 'esteregg.dart';

class Setting extends StatefulWidget {
  @override
  _SettingState createState() => _SettingState();
}

FontSize fs;

class _SettingState extends State<Setting> {
  @override
  Widget build(BuildContext context) {
    fs = FontSize(context);
    UserStatus userStatus = Provider.of<UserStatus>(context);
    MealStatus mealStatus = Provider.of<MealStatus>(context);
    final List emojiList = ['selected', 'pretzel', 'pan', 'icecream'];

    PushManager pm = PushManager();

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        children: <Widget>[
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.035,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                getEmoji("setting"),
                width: 50,
              ),
              SizedBox(width: 5),
              Text('설정',
                  style: TextStyle(fontSize: fs.s3, color: Colors.white, shadows: [
                    Shadow(offset: Offset(0, 4.0), blurRadius: 10.0, color: Colors.black38),
                  ])),
              SizedBox(width: 5),
              Image.asset(
                getEmoji("setting"),
                width: 50,
              ),
            ],
          ),
          SizedBox(
            height: 15,
          ),
          Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
              ),
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    "내 정보",
                    style: TextStyle(fontSize: fs.s5),
                    textAlign: TextAlign.left,
                  ),
                  Divider(),
                  Container(
                    child: Row(
                      children: <Widget>[
                        Icon(
                          Icons.person,
                          size: fs.s5,
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Text(
                          userStatus.userInfo["nickname"],
                          style: TextStyle(fontSize: fs.s6),
                          textAlign: TextAlign.left,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 5),
                  Container(
                    child: Row(
                      children: <Widget>[
                        Icon(
                          Icons.school,
                          size: fs.s5,
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Text(
                          "${userStatus.userInfo["school"]["schoolName"]}",
                          style: TextStyle(fontSize: fs.s6),
                          textAlign: TextAlign.left,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 5),
                  Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        RaisedButton(
                          color: primaryRedDark,
                          onPressed: () {
                            showCustomDialog(
                                context: context,
                                title: "로그아웃 할까요?",
                                content: "다음에 다시 로그인할 수 있어요",
                                cancelButtonText: "취소",
                                confirmButtonText: "로그아웃",
                                cancelButtonAction: () {
                                  Navigator.pop(context);
                                },
                                confirmButtonAction: () {
                                  Navigator.pop(context);
                                  Navigator.popUntil(context, (route) => route.isFirst);
                                  print(Navigator);

                                  Navigator.push(context, MaterialPageRoute(builder: (context) => LoginPage()));
                                  userStatus.logout();

                                  AdManager.hideBanner();

                                  pm.cancelAllScheduledPush();
                                });
                          },
                          child: Text("로그아웃", style: TextStyle(fontSize: fs.s7)),
                        )
                      ],
                    ),
                  )
                ],
              )),
          SizedBox(
            height: 15,
          ),
          Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
              ),
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    "알림 설정",
                    style: TextStyle(fontSize: fs.s5),
                    textAlign: TextAlign.left,
                  ),
                  Divider(),
                  SizedBox(height: 0),
                  Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              "알림 켜기",
                              style: TextStyle(fontSize: fs.s6),
                            ),
                            Text(
                              '푸쉬 알림을 받아보세요',
                              style: TextStyle(fontSize: fs.s7),
                            ),
                          ],
                        ),
                        Switch(
                          value: mealStatus.isReceivePush,
                          onChanged: (value) {
                            mealStatus.setIsReceivePush(value);
                          },
                          activeTrackColor: primaryRed,
                          activeColor: primaryRedDark,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              '즐겨찾기 알림 시간',
                              style: TextStyle(fontSize: fs.s6),
                            ),
                            Text(
                              '${mealStatus.pushHour.toString().padLeft(2, "0")}:${mealStatus.pushMinute.toString().padLeft(2, "0")}에 알림을 보내드려요',
                              style: TextStyle(fontSize: fs.s7),
                            ),
                          ],
                        ),
                        RaisedButton(
                          color: primaryRedDark,
                          onPressed: () async {
                            Future<TimeOfDay> selectedTime = showTimePicker(
                              initialTime: TimeOfDay(hour: mealStatus.pushHour, minute: mealStatus.pushMinute),
                              context: context,
                            );

                            selectedTime.then((timeOfDay) async {
                              if (timeOfDay == null) {
                                return;
                              }

                              print(timeOfDay);

                              var pushList = await pm.getScheduledPush();
                              for (PendingNotificationRequest push in pushList) {
                                DateTime d = DateTime.parse(push.id.toString());
                                print("SDHFksdfjlksdjkf");
                                pm.cancelScheduledPush(push.id);
                                pm.schedulePush(
                                    datetime: DateTime(d.year, d.month, d.day, timeOfDay.hour, timeOfDay.minute, 0),
                                    id: push.id,
                                    title: push.title,
                                    body: push.body,
                                    payload: push.payload);
                              }

                              mealStatus.setPushTime(timeOfDay.hour, timeOfDay.minute);
                              showCustomAlert(
                                context: context,
                                isSuccess: true,
                                title: "설정 완료!",
                                duration: Duration(seconds: 1),
                              );
                              print("PUSHES!!!!!");
                              pm.printScheduledPush();
                            });
                          },
                          child: Text(
                            "설정",
                            style: TextStyle(fontSize: fs.s7),
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              )),
          SizedBox(
            height: 15,
          ),
          Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
              ),
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    "기타 설정",
                    style: TextStyle(fontSize: fs.s5),
                    textAlign: TextAlign.left,
                  ),
                  Divider(),
                  Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          '즐겨찾기 이모지',
                          style: TextStyle(fontSize: fs.s6),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 5),
                  Row(
                    children: emojiList.map((item) {
                      return Padding(
                        padding: EdgeInsets.symmetric(horizontal: 3),
                        child: Material(
                          borderRadius: BorderRadius.all(Radius.circular(1000)),
                          color: mealStatus.selectedEmoji == item
                              ? primaryYellow.withOpacity(0.8)
                              : Colors.white.withOpacity(0.5),
                          child: InkWell(
                            onTap: () {
                              mealStatus.setSelectedEmoji(item);
                            },
                            borderRadius: BorderRadius.all(Radius.circular(1000)),
                            child: Container(
                              padding: EdgeInsets.all(5),
                              width: 50,
                              height: 50,
                              child: Image.asset(
                                getEmoji(item),
                                width: 50,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.all(Radius.circular(1000)),

//                            border: Border.all(color: Colors.black, width: mealStatus.selectedEmoji == item ? 3 : 1),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  SizedBox(height: 15),
                  Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              '즐겨찾기 메뉴 보기',
                              style: TextStyle(fontSize: fs.s6),
                            ),
                          ],
                        ),
                        RaisedButton(
                          color: primaryRedDark,
                          onPressed: () async {

                            AdManager.hideBanner();
                            await Navigator.push(context, MaterialPageRoute(builder: (context) => FindAllFavoritePage()));
                            AdManager.showBanner();
                            
                            mealStatus.setFavoriteListWithRange();

                          },
                          child: Text(
                            '이동',
                            style: TextStyle(fontSize: fs.s7),
                          ),
                        )
                      ],
                    ),
                  ),

                  SizedBox(height: 10),
                  Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              '즐겨찾기 메뉴 초기화',
                              style: TextStyle(fontSize: fs.s6),
                            ),
                          ],
                        ),
                        RaisedButton(
                          color: primaryRedDark,
                          onPressed: () async {
                            showCustomDialog(
                                context: context,
                                title: "초기화 할까요?",
                                content: "다시 되돌릴 수 없어요.",
                                cancelButtonText: "취소",
                                confirmButtonText: "초기화",
                                cancelButtonAction: () {
                                  Navigator.pop(context);
                                },
                                confirmButtonAction: () async {
                                  Navigator.pop(context);
                                  mealStatus.setIsLoading(true);
                                  var deleteResult = await deleteWithToken('$currentHost/meals/rating/favorite-all');
                                  mealStatus.setIsLoading(false);
                                  if (deleteResult.statusCode == 200) {
                                    mealStatus.setDayList({});
                                    showCustomAlert(
                                      context: context,
                                      isSuccess: true,
                                      title: "초기화 완료!",
                                      duration: Duration(seconds: 1),
                                    );
                                  }

                                  pm.cancelAllScheduledPush();
                                });
                          },
                          child: Text(
                            "초기화",
                            style: TextStyle(fontSize: fs.s7),
                          ),
                        )
                      ],
                    ),
                  ),
//                  SizedBox(height: 5),
                  SizedBox(height: 15),
                  Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              '알레르기 정보',
                              style: TextStyle(fontSize: fs.s6),
                            ),
                          ],
                        ),
                        RaisedButton(
                          color: primaryRedDark,
                          onPressed: () async {
                            AdManager.hideBanner();
                            await Navigator.push(context, MaterialPageRoute(builder: (context) => SetAllergyPage()));
                            AdManager.showBanner();
                          },
                          child: Text(
                            "설정",
                            style: TextStyle(fontSize: fs.s7),
                          ),
                        )
                      ],
                    ),
                  ),

                  SizedBox(height: 15),
                  Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              '급식 메뉴 앱에 저장',
                              style: TextStyle(fontSize: fs.s6),
                            ),
                            Text(
                              '데이터 소모를 줄일 수 있어요',
                              style: TextStyle(fontSize: fs.s7),
                            ),
                          ],
                        ),
                        Switch(
                          value: mealStatus.isSaveMenuStorage == "true" ? true : false,
                          onChanged: (value) {
                            mealStatus.setIsSaveMenuStorage(value ? "true" : "false");
                          },
                          activeTrackColor: primaryRed,
                          activeColor: primaryRedDark,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 10),
                  Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              '앱에 저장된 메뉴 초기화',
                              style: TextStyle(fontSize: fs.s6),
                            ),
                          ],
                        ),
                        RaisedButton(
                          color: primaryRedDark,
                          onPressed: () async {
                            showCustomDialog(
                                context: context,
                                title: "초기화 할까요?",
                                content: "다시 되돌릴 수 없어요.",
                                cancelButtonText: "취소",
                                confirmButtonText: "초기화",
                                cancelButtonAction: () {
                                  Navigator.pop(context);
                                },
                                confirmButtonAction: () async {
                                  Navigator.pop(context);
                                  bool deleteResult = await DBHelper.delete("meals", "");
                                  if (deleteResult == true) {
                                    showCustomAlert(
                                      context: context,
                                      isSuccess: true,
                                      title: "초기화 완료!",
                                      duration: Duration(seconds: 1),
                                    );
                                  }
                                });
                          },
                          child: Text(
                            "초기화",
                            style: TextStyle(fontSize: fs.s7),
                          ),
                        )
                      ],
                    ),
                  ),
                  SizedBox(height: 5),
                ],
              )),
          SizedBox(
            height: 15,
          ),
          Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
              ),
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    "앱 정보",
                    style: TextStyle(fontSize: fs.s5),
                    textAlign: TextAlign.left,
                  ),
                  Divider(),
                  Container(
                    child: Row(
                      children: <Widget>[
                        FutureBuilder(
                            future: rootBundle.loadString("pubspec.yaml"),
                            builder: (context, snapshot) {
                              String version = "Unknown";
                              if (snapshot.hasData) {
                                var yaml = loadYaml(snapshot.data);
                                version = yaml["version"];
                              }

                              return GestureDetector(
                                onLongPressEnd: (x) {
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => EasterEgg()));
                                },
                                child: Container(
                                  child: Text(
                                    '앱 버전: $version',
                                    style: TextStyle(fontSize: fs.s7),
                                  ),
                                ),
                              );
                            }),
                      ],
                    ),
                  ),
                  SizedBox(height: 5),
                  Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        RaisedButton(
                          padding: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                          color: primaryRedDark,
                          onPressed: () async {
                            launchURL() async {
                              const url =
                                  'https://docs.google.com/forms/d/e/1FAIpQLSfTMdFKFo1riLfdOlLv8AhTUL47sa8KjJxo5whE4iyzUsbgFg/viewform';
                              if (await canLaunch(url)) {
                                await launch(
                                  url,
                                  forceSafariVC: true,
                                  enableJavaScript: true,
                                );
                              } else {
                                throw 'Could not launch $url';
                              }
                            }

                            launchURL();
                          },
                          child: Text(
                            '건의 / 오류 신고',
                            style: TextStyle(fontSize: fs.s7),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 5),
                ],
              ))
        ],
      ),
    );

//    return Container(
//      margin: EdgeInsets.only(top: MediaQuery.of(context).size.height*0.55),
//      child: Column(
//        mainAxisAlignment: MainAxisAlignment.center,
//        children: <Widget>[
//          Text('불쌍한 정재엽을 위해\n 아래 광고 한번 눌러주십쇼...', style: TextStyle(fontSize: fs.s4),),
//          Text('↓', style: TextStyle(fontSize: 200),)
//        ],
//      ),
//    );
  }
}
