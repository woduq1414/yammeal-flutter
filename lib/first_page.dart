import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:kakao_flutter_sdk/auth.dart';
import 'package:kakao_flutter_sdk/user.dart';
import 'package:http/http.dart' as http;
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

class _FirstPageState extends State<FirstPage> {

  final _idController = TextEditingController();
  final _passwordController = TextEditingController();

  var _isLogined = null;


  void getIsLogined() async {
    var storage = FlutterSecureStorage();
    String token = await getToken();
    print(token);
    final res = await http.get(
      "${Host.address}/auth",
      headers: {"Content-Type": "application/json", "Authorization" : token},
    );
    print(res.statusCode);
//    if
    if(res.statusCode == 200) {
      setState(() {
        _isLogined = true;
        Navigator.push(
          context,
          FadeRoute(page: MealState()),
        );
      });
    }else{
      setState(() {
        _isLogined = false;
        Navigator.push(
          context,
          FadeRoute(page: LoginPage()),
        );
      });
    }

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




    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      )
    );


  }


}
