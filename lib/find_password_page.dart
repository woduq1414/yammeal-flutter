import 'package:date_format/date_format.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:meal_flutter/UIs/login_UI.dart';
import 'package:meal_flutter/UIs/main_page.dart';

import 'common/provider/userProvider.dart';

import './common/widgets/appbar.dart';
import './common/color.dart';
import './common/ip.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:provider/provider.dart';

import './common/provider/userProvider.dart';
import 'common/widgets/appbar.dart';
import 'common/widgets/dialog.dart';
import 'common/widgets/loading.dart';

final scaffoldKey = GlobalKey<ScaffoldState>();
final scaffoldKey2 = GlobalKey<ScaffoldState>();
final scaffoldKey3 = GlobalKey<ScaffoldState>();

class FindPasswordPage extends StatefulWidget {
//  bool isKakao;
//
//  FindPasswordPage({this.isKakao});

  @override
  _FindPasswordPageState createState() => _FindPasswordPageState();
}

class _FindPasswordPageState extends State<FindPasswordPage> {
//  bool isKakao;
//
//  _FindPasswordPageState(bool _isKakao) {
//    isKakao = _isKakao;
//  }

  @override
  Widget build(BuildContext context) {
    return IdInputPage();
  }
}

class IdInputPage extends StatelessWidget {
  final _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    UserStatus userStatus = Provider.of<UserStatus>(context);

    return LoadingModal(
      child: Scaffold(
          key: scaffoldKey,
          appBar: DefaultAppBar(),
          body: Container(
              padding: EdgeInsets.all(15),
              child: Stack(children: [
                Column(
                  children: <Widget>[
                    SizedBox(
                      height: 20,
                    ),
                    Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "가입했던 이메일을 입력하세요",
                          style: TextStyle(fontSize: 25),
                        )),
                    TextField(
                      keyboardType: TextInputType.emailAddress,
                      autofocus: true,
                      onChanged: (value) {
                        userStatus.setInputData("id", value);
                      },
                      controller: _controller,
                      style: TextStyle(
                        fontSize: 25,
                      ),
                      decoration: InputDecoration(
//                        border: InputBorder.none,
                        hintText: "example@abc.com",
                        contentPadding: EdgeInsets.fromLTRB(0, 10.0, 0, 8.0),

                        helperText: "비밀번호 찾기에 이용돼요",

                        hintStyle: TextStyle(
                          fontSize: 25,
                        ),
                      ),
                    ),
                  ],
                ),
                Positioned(
                    child: NextButton(
                        text: "인증 메일 전송",
                        onTap: () async {
                          userStatus.inputData["id"] = _controller.text;

                          bool mailResult = await userStatus.verifyMail();
                          if (mailResult) {
                            print("OK");
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => VerifyCodeInputPage()),
                            );
                          } else {
                            scaffoldKey.currentState.showSnackBar(SnackBar(
                                content: Text(
                              "이메일을 찾을 수 없습니다.",
                            )));
                          }
                        },
                        textColor: Colors.white,
                        primeColor: primaryRedDark,
                        disabled: () {
                          return !RegExp(
                                  r'^(([^<>()\[\]\.,;:\s@\"]+(\.[^<>()\[\]\.,;:\s@\"]+)*)|(\".+\"))@(([^<>()[\]\.,;:\s@\"]+\.)+[^<>()[\]\.,;:\s@\"]{2,})$')
                              .hasMatch(userStatus.inputData["id"]);
                        }),
                    bottom: 0,
                    right: 0,
                    left: 0)
              ]))),
    );
  }
}

class VerifyCodeInputPage extends StatelessWidget {
  final _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    UserStatus userStatus = Provider.of<UserStatus>(context);

    return LoadingModal(
      child: WillPopScope(
        onWillPop: () async {
          showCustomDialog(
              context: context,
              title: "비밀번호 찾기를 그만 하시겠어요?",
//          content : null,
              cancelButtonText: "취소",
              confirmButtonText: "나가기",
              cancelButtonAction: () {
                Navigator.pop(context);
              },
              confirmButtonAction: () {
                Navigator.pop(context);
                Navigator.pop(context);
                Navigator.pop(context);
              });

          return true;
        },
        child: Scaffold(
            key: scaffoldKey2,
            appBar: DefaultAppBar(),
            body: Container(
                padding: EdgeInsets.all(15),
                child: Stack(children: [
                  Column(
                    children: <Widget>[
                      SizedBox(
                        height: 20,
                      ),
                      Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "${userStatus.inputData["id"]}로 보낸\n인증 코드를 입력해주세요.",
                            style: TextStyle(fontSize: 25),
                          )),
                      TextField(
                        autofocus: true,
                        onChanged: (value) {
                          userStatus.setInputData("verifyCode", value);
                        },
                        keyboardType: TextInputType.number,
                        controller: _controller,
                        style: TextStyle(
                          fontSize: 25,
                        ),
                        decoration: InputDecoration(
//                        border: InputBorder.none,
                          hintText: "6자리의 숫자",
                          contentPadding: EdgeInsets.fromLTRB(0, 10.0, 0, 8.0),

                          helperText: "15분 안에 입력해주세요",

                          hintStyle: TextStyle(
                            fontSize: 25,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Positioned(
                      child: NextButton(
                          text: "다음",
                          onTap: () async {
                            userStatus.inputData["verifyCode"] = _controller.text;

                            bool verifyResult = await userStatus.verifyMailCode();
                            if (verifyResult) {
                              print("OK");
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => PasswordInputPage()),
                              );
                            } else {
                              scaffoldKey.currentState.showSnackBar(SnackBar(
                                  content: Text(
                                "인증번호가 틀렸거나 만료되었습니다.",
                              )));
                            }
                          },
                          textColor: Colors.white,
                          primeColor: primaryRedDark,
                          disabled: () {
                            return userStatus.inputData["verifyCode"] == null ||
                                userStatus.inputData["verifyCode"] == "" ||
                                int.tryParse(userStatus.inputData["verifyCode"]) == null ||
                                !(100000 <= int.parse(userStatus.inputData["verifyCode"]) &&
                                    int.parse(userStatus.inputData["verifyCode"]) <= 999999);
                          }),
                      bottom: 0,
                      right: 0,
                      left: 0)
                ]))),
      ),
    );
  }
}

class PasswordInputPage extends StatelessWidget {
  final _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    UserStatus userStatus = Provider.of<UserStatus>(context);

    return LoadingModal(
      child: WillPopScope(
        onWillPop: () async {
          showCustomDialog(
              context: context,
              title: "비밀번호 찾기를 그만 하시겠어요?",
//          content : null,
              cancelButtonText: "취소",
              confirmButtonText: "나가기",
              cancelButtonAction: () {
                Navigator.pop(context);
              },
              confirmButtonAction: () {
                Navigator.pop(context);
                Navigator.pop(context);
                Navigator.pop(context);
                Navigator.pop(context);
              });

          return true;
        },
        child: Scaffold(
            appBar: DefaultAppBar(),
            body: Container(
                padding: EdgeInsets.all(15),
                child: Stack(children: [
                  Column(
                    children: <Widget>[
                      SizedBox(
                        height: 20,
                      ),
                      Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "새로운 비밀번호를 입력하세요",
                            style: TextStyle(fontSize: 25),
                          )),
                      TextField(
                        autofocus: true,
                        onChanged: (value) {
                          userStatus.setInputData("password", value);
                        },
                        obscureText: true,
                        controller: _controller,
                        style: TextStyle(
                          fontSize: 25,
                        ),
                        decoration: InputDecoration(
//                        border: InputBorder.none,
                          hintText: "",
                          contentPadding: EdgeInsets.fromLTRB(0, 10.0, 0, 8.0),

                          helperText: "영문 또는 숫자 또는 특수문자로 이루어진 6~15자",

                          hintStyle: TextStyle(
                            fontSize: 25,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Positioned(
                      child: NextButton(
                          text: "완료",
                          onTap: () async {
                            userStatus.inputData["password"] = _controller.text;

                            bool changeResult = await userStatus.changePassword();
                            if (changeResult) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => MealState()),
                              );
                              return;
                            } else {}
                          },
                          textColor: Colors.white,
                          primeColor: primaryRedDark,
                          disabled: () {
                            return !RegExp(r'^(?=.*[A-Za-z])(?=.*\d)(?=.*[$@$!%*#?&-_])[A-Za-z\d$@$!%*#?&-_]{6,15}$')
                                .hasMatch(userStatus.inputData["password"]);
                          }),
                      bottom: 0,
                      right: 0,
                      left: 0)
                ]))),
      ),
    );
  }
}

class NextButton extends StatelessWidget {
  String text;

  double textSize;

  var onTap;
  Color textColor;
  Color primeColor;
  double borderRadius;

  bool isRaised;

  var disabled;

  NextButton(
      {this.text,
      this.onTap,
      this.textColor,
      this.primeColor,
      this.isRaised = true,
      this.borderRadius = 10,
      this.textSize = 18,
      this.disabled});

  @override
  Widget build(BuildContext context) {
    if (disabled == null) {
      disabled = () {
        return false;
      };
    }

    return Material(
      color: isRaised ? (!disabled() ? primeColor : Colors.grey) : Colors.white,
      borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
      child: InkWell(
        borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
        onTap: !disabled() ? onTap : null,
        child: Container(
          height: 50,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: !isRaised
                ? Border.all(
                    color: !disabled() ? primeColor : Colors.grey,
                    width: 1,
                  )
                : null,
            borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
          ),
          child: Text(
            text,
            style: TextStyle(fontSize: textSize, color: textColor),
          ),
        ),
      ),
    );
  }
}
