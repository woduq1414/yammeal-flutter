import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:kakao_flutter_sdk/auth.dart';
import 'package:kakao_flutter_sdk/user.dart';
import 'package:http/http.dart' as http;
import 'package:meal_flutter/common/provider/mealProvider.dart';
import "package:meal_flutter/common/font.dart";

import 'package:modal_progress_hud/modal_progress_hud.dart';

import 'package:provider/provider.dart';

import './common/provider/userProvider.dart';
import 'UIs/main_page.dart';
import 'common/route_transition.dart';

import 'login_page.dart';
import 'first_page.dart';
import 'kakao_register_page.dart';




void main() => runApp(KakaoLoginTest());

class KakaoLoginTest extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {

//    fs = FontSize(context);


    KakaoContext.clientId = '39d6c43a0a346cca6ebc7b2dbb8e4353';

//    var storage = FlutterSecureStorage();
//    String token = await storage.read(key: "token");


    return MultiProvider(


        providers: [
          ChangeNotifierProvider<UserStatus>(create: (_) => UserStatus()),
          ChangeNotifierProvider<MealStatus>(create: (_) => MealStatus()),
        ],
        child: MaterialApp(
          title: 'Flutter Demo',
          routes: <String, WidgetBuilder>{
            '/FirstPage': (BuildContext context) => new FirstPage(),
          },
          theme: ThemeData(
            fontFamily: "GmarketSans",

            // This is the theme of your application.
            //
            // Try running your application with "flutter run". You'll see the
            // application has a blue toolbar. Then, without quitting the app, try
            // changing the primarySwatch below to Colors.green and then invoke
            // "hot reload" (press "r" in the console where you ran "flutter run",
            // or simply save your changes to "hot reload" in a Flutter IDE).
            // Notice that the counter didn't reset back to zero; the application
            // is not restarted.

          ),
          home: FirstPage(),

        ));
  }
}

//
//class LoginDone extends StatelessWidget {
//  Future<bool> _getUser() async {
//    try {
//      User user = await UserApi.instance.me();
//      print(user.toString());
//    } on KakaoAuthException catch (e) {
//    } catch (e) {
//    }
//  }
//
//  @override
//  Widget build(BuildContext context) {
//    _getUser();
//
//    return Scaffold(
//      body: SafeArea(
//        child: Center(
//          child: Text('Login Success!'),
//        ),
//      ),
//    );
//  }
//}

