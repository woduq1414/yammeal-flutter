import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:kakao_flutter_sdk/auth.dart';
import 'package:kakao_flutter_sdk/user.dart';
import 'package:http/http.dart' as http;
import 'package:meal_flutter/common/widgets/loading.dart';
import 'package:meal_flutter/register_page.dart';
import 'package:provider/provider.dart';

import './common/provider/userProvider.dart';
import 'common/route_transition.dart';
import 'kakao_register_page.dart';


class FirstPage extends StatefulWidget {
  @override
  _FirstPageState createState() => _FirstPageState();
}

class _FirstPageState extends State<FirstPage> {

  final _idController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    UserStatus userStatus = Provider.of<UserStatus>(context);


    isKakaoTalkInstalled();

    return LoadingModal(
      child: Scaffold(
        appBar: AppBar(
          title: Text("Kakao Flutter SDK Login"),
          actions: [],
        ),
        body: Center(
          child: Column(
            children: <Widget>[
              TextField(
                autofocus: true,
                onChanged: (value) {
                },
                controller: _idController,
                style: TextStyle(
                  fontSize: 25,
                ),
                decoration: InputDecoration(
//                        border: InputBorder.none,
                  hintText: "아이디",
                  contentPadding: EdgeInsets.fromLTRB(0, 10.0, 0, 8.0),

                  hintStyle: TextStyle(
                    fontSize: 25,
                  ),
                ),
              ),
              TextField(
                autofocus: true,
                onChanged: (value) {

                },
                controller: _passwordController,
                style: TextStyle(
                  fontSize: 25,
                ),
                decoration: InputDecoration(
//                        border: InputBorder.none,
                  hintText: "비밀번호",
                  contentPadding: EdgeInsets.fromLTRB(0, 10.0, 0, 8.0),

                  hintStyle: TextStyle(
                    fontSize: 25,
                  ),
                ),
              ),

              RaisedButton(
                  child: Text("그냥 로그인"),
                  onPressed: () async {
                    UserStatus userStatus = Provider.of<UserStatus>(context);
                    bool loginREsult = await userStatus.loginDefault(_idController.text, _passwordController.text);

                  }
              ),


              RaisedButton(
                  child: Text("그냥 회원가입"),
                  onPressed: () async {
                    UserStatus userStatus = Provider.of<UserStatus>(context);
                    userStatus.setIsKakao(false);
//                  goKakaoRegisterPage();

                    goRegisterPage();

                  }
              ),


              RaisedButton(
                  child: Text("카카오톡으로 로그인"),
                  onPressed: () async {
                    UserStatus userStatus = Provider.of<UserStatus>(context);
                    userStatus.setIsKakao(true);
//                  goKakaoRegisterPage();
                    userStatus.setIsLoading(true);
                    bool loginResult = await userStatus.loginWithKakao();

                    print("login 성공");

                    userStatus.setIsLoading(false);
                    if(loginResult == true){
//                      userStatus.loginWithKakao();
                      print("login 성공");
                    }else{
                      goKakaoRegisterPage();
                    }

                  }
              ),
              RaisedButton(
                  child: Text("Logout"),
                  onPressed: () {
                    userStatus.logout();
                  }
              ),
              RaisedButton(
                child: Text("UnLink"),
                onPressed: () {
                  userStatus.unlinkTalk();
                },
              ),

              RaisedButton(
                child: Text("이미지 테스트"),
                onPressed: () {

                },
              ),

              Text(userStatus.userInfo["nickname"] + "님 ㅎㅇ"),
            ],
          ),
        ),
      ),
    );


  }




  void goKakaoRegisterPage() {
    Navigator.push(
      context,
      FadeRoute(page: RegisterPage(isKakao: true,)),
    );
  }


  void goRegisterPage() {
    Navigator.push(
      context,
      FadeRoute(page: RegisterPage(isKakao: false,)),
    );
  }
}
