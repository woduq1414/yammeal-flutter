import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:kakao_flutter_sdk/auth.dart';
import 'package:kakao_flutter_sdk/user.dart';
import 'package:http/http.dart' as http;
import 'package:meal_flutter/common/color.dart';
import 'package:meal_flutter/common/font.dart';
import 'package:meal_flutter/common/widgets/loading.dart';
import 'package:meal_flutter/login_page.dart';
import 'package:meal_flutter/register_page.dart';
import 'package:provider/provider.dart';

import './common/provider/userProvider.dart';
import 'UIs/main_page.dart';
import 'common/route_transition.dart';
import 'kakao_register_page.dart';
import 'common/ip.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class FirstPage extends StatefulWidget {
  @override
  _FirstPageState createState() => _FirstPageState();
}

FontSize fs;

class _FirstPageState extends State<FirstPage> {
  final _idController = TextEditingController();
  final _passwordController = TextEditingController();

  var _isLogined = null;

  void getIsLogined() async {
    var storage = FlutterSecureStorage();
    String token = await getToken();
    int exp;
    print(token);
    try{
      exp = parseJwtPayLoad(token)["exp"];
    }on Exception {
      setState(() {
        _isLogined = false;
        Navigator.push(
          context,
          FadeRoute(page: LoginPage()),
        );
      });
      return;
    }


    int now = (DateTime.now().millisecondsSinceEpoch / 1000).toInt();
    print(exp);
    print(now);

    if (exp >= now) {
      setState(() {
        _isLogined = true;
        Navigator.push(
          context,
          FadeRoute(page: MealState()),
        );
      });
    } else {
      setState(() {
        _isLogined = false;
        Navigator.push(
          context,
          FadeRoute(page: LoginPage()),
        );
      });
    }

//    final res = await http.get(
//      "${currentHost}/auth",
//      headers: {"Content-Type": "application/json", "Authorization" : token},
//    );
//
//
//
//
//    print(res.statusCode);
////    if
//    if(res.statusCode == 200) {
//      setState(() {
//        _isLogined = true;
//        Navigator.push(
//          context,
//          FadeRoute(page: MealState()),
//        );
//      });
//    }else{
//      setState(() {
//        _isLogined = false;
//        Navigator.push(
//          context,
//          FadeRoute(page: LoginPage()),
//        );
//      });
//    }
  }

  @override
  void initState() {
    getIsLogined();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      // add your code here.

      print("!");
    });
  }

  @override
  Widget build(BuildContext context) {
    fs = FontSize(context);

    return Scaffold(
        backgroundColor: primaryYellow,
        body: Center(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              "YAMMEAL",
              style: TextStyle(
                fontSize: fs.s2,
                fontWeight: Font.bold,
                letterSpacing: 8,
              ),
            ),
            SizedBox(
              height: 30,
            ),
            CustomLoading(),
          ],
        )));
  }
}
