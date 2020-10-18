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
import 'common/widgets/loading.dart';

final scaffoldKey = GlobalKey<ScaffoldState>();
final scaffoldKey2 = GlobalKey<ScaffoldState>();
final scaffoldKey3 = GlobalKey<ScaffoldState>();

class RegisterPage extends StatefulWidget {
  bool isKakao;

  RegisterPage({this.isKakao});

  @override
  _RegisterPageState createState() => _RegisterPageState(isKakao);
}

class _RegisterPageState extends State<RegisterPage> {
  bool isKakao;

  _RegisterPageState(bool _isKakao) {
    isKakao = _isKakao;
  }

  @override
  Widget build(BuildContext context) {
    return isKakao ? NameRegisterPage() : IdRegisterPage();
  }
}

class IdRegisterPage extends StatelessWidget {
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
                          "이메일을 입력하세요",
                          style: TextStyle(fontSize: 25),
                        )),
                    TextField(
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
                        text: "다음",
                        onTap: () async {
                          userStatus.inputData["id"] = _controller.text;

                          var checkResult = await userStatus.checkIdDuplicate();
                          if (checkResult == false) {
                            scaffoldKey.currentState.showSnackBar(SnackBar(
                                content: Text(
                              "이미 가입된 이메일입니다.",
                            )));
                            return;
                          }

                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => PwRegisterPage()),
                          );
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

class PwRegisterPage extends StatelessWidget {
  final _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    UserStatus userStatus = Provider.of<UserStatus>(context);

    return Scaffold(
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
                        "비밀번호를 입력하세요",
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
                      text: "다음",
                      onTap: () {
                        userStatus.inputData["password"] = _controller.text;
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => NameRegisterPage()),
                        );
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
            ])));
  }
}

class NameRegisterPage extends StatelessWidget {
  final _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    UserStatus userStatus = Provider.of<UserStatus>(context);
//    var scaffoldKey = GlobalKey<ScaffoldState>();
    return LoadingModal(
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
                          "닉네임을 입력하세요",
                          style: TextStyle(fontSize: 25),
                        )),
                    TextField(
                      autofocus: true,
                      onChanged: (value) {
                        userStatus.setInputData("nickname", value);
                      },
                      controller: _controller,
                      style: TextStyle(
                        fontSize: 25,
                      ),
                      decoration: InputDecoration(
//                        border: InputBorder.none,
                        hintText: "다른 사람들에게 공개돼요",
                        contentPadding: EdgeInsets.fromLTRB(0, 10.0, 0, 8.0),

                        helperText: "한글 또는 영문 또는 숫자로 이루어진 2~10자",

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
                          userStatus.inputData["nickname"] = _controller.text;
                          print(userStatus.inputData["name"]);

                          var checkResult = await userStatus.checkNicknameDuplicate();
                          if (checkResult == false) {
                            scaffoldKey2.currentState.showSnackBar(
                              SnackBar(
                                  content: Text(
                                    "이미 가입된 닉네임입니다.",
                                  ),
                                  duration: const Duration(seconds: 1)),
                            );
                            return;
                          }

                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => SchoolCodeRegisterPage()),
                          );
                        },
                        textColor: Colors.white,
                        primeColor: primaryRedDark,
                        disabled: () {
                          return !RegExp(r'^[가-힣0-9A-Za-z]{2,10}$').hasMatch(userStatus.inputData["nickname"]);
                        }),
                    bottom: 0,
                    right: 0,
                    left: 0)
              ]))),
    );
  }
}

class SchoolCodeRegisterPage extends StatelessWidget {
  final _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    UserStatus userStatus = Provider.of<UserStatus>(context);

    return LoadingModal(
      child: Scaffold(
          key: scaffoldKey3,
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
                          "학교 인증 코드를 입력하세요",
                          style: TextStyle(fontSize: 25),
                        )),
                    TextField(
                      autofocus: true,
                      onChanged: (value) {
                        userStatus.setInputData("schoolCode", value);
                      },
                      controller: _controller,
                      style: TextStyle(
                        fontSize: 25,
                      ),
                      decoration: InputDecoration(
//                        border: InputBorder.none,
                        hintText: "학교에서 준 코드",
                        contentPadding: EdgeInsets.fromLTRB(0, 10.0, 0, 8.0),

                        helperText: "영문 4~8자",

                        hintStyle: TextStyle(
                          fontSize: 25,
                        ),
                      ),
                    ),
                  ],
                ),
                Positioned(
                    child: Column(
                      children: <Widget>[
                        NextButton(
                          text: "학교 인증 코드를 몰라요",
                          onTap: () {
                            userStatus.setInputData("schoolCode", "");
                            userStatus.setInputData("schoolName", "");
                            userStatus.setInputData("schoolId", "");
                            userStatus.setInputData("schoolGrade", null);
                            userStatus.setInputData("schoolClass", null);
//                          userStatus.setInputData("schoolGrade", 1);
                            userStatus.setIsSchoolCodeVerified(false);

                            userStatus.setClassData("");

                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => SchoolInfoRegisterPage()),
                            );
                          },
                          textColor: Colors.grey[800],
                          primeColor: Colors.grey[400],
                          isRaised: false,
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        NextButton(
                            text: "다음",
                            onTap: () async {
                              print(_controller.text);

                              var verifySchoolCodeResult = await userStatus.verifySchoolCode();
                              if (verifySchoolCodeResult == null) {
                                scaffoldKey3.currentState.showSnackBar(
                                  SnackBar(
                                      content: Text(
                                        "인증 코드가 일치하지 않습니다.",
                                      ),
                                      duration: const Duration(seconds: 1)),
                                );
                              } else {
                                print(verifySchoolCodeResult);
                                userStatus.inputData["schoolId"] = verifySchoolCodeResult["schoolId"];
                                userStatus.inputData["schoolName"] = verifySchoolCodeResult["schoolName"];

                                userStatus.setClassData(verifySchoolCodeResult["schoolId"]);

                                userStatus.setInputData("schoolGrade", null);
                                userStatus.setInputData("schoolClass", null);

                                userStatus.setIsSchoolCodeVerified(true);
                                print(userStatus.inputData);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => SchoolInfoRegisterPage()),
                                );
                              }
                            },
                            textColor: Colors.white,
                            primeColor: primaryRedDark,
                            disabled: () {
                              return !RegExp(r'^[a-zA-Z]{4,8}$').hasMatch(userStatus.inputData["schoolCode"]);
                            }),
                      ],
                    ),
                    bottom: 0,
                    right: 0,
                    left: 0)
              ]))),
    );
  }
}

class SchoolInfoRegisterPage extends StatelessWidget {
//  bool isSchoolVerified =

  final _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    UserStatus userStatus = Provider.of<UserStatus>(context);

    if(userStatus.isSchoolCodeVerified){

    }{
//      userStatus.classData = {};
    }




    return LoadingModal(
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
                          "학교 정보를 입력해주세요.",
                          style: TextStyle(fontSize: 25),
                        )),
                    SizedBox(
                      height: 25,
                    ),
                    Row(
                      children: <Widget>[
                        Container(
                          alignment: Alignment.center,
                          width: 70,
                          child: Text(
                            "학교명",
                            style: TextStyle(fontSize: 20),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Flexible(
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.all(Radius.circular(10)),
                            ),
                            child: Material(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.all(Radius.circular(10)),
                              child: InkWell(
                                onTap: userStatus.isSchoolCodeVerified
                                    ? null
                                    : () {
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            userStatus.initSchoolSsearchList();

                                            // return object of type Dialog
                                            return AlertDialog(
                                              title: Text("학교 검색"),
                                              content: Container(
                                                width: 100000,
                                                child: Column(
                                                  children: <Widget>[
                                                    Row(
                                                      children: [
                                                        Flexible(
                                                          child: TextField(
                                                            autofocus: true,
                                                            onChanged: (value) {
                                                              userStatus.setInputData("schoolName", value);
                                                            },
                                                            onSubmitted: (value) async {
                                                              var searchResult = await userStatus.searchSchoolName(value);
                                                            },
                                                            controller: _controller,
                                                            style: TextStyle(
                                                              fontSize: 18,
                                                            ),
                                                            textInputAction: TextInputAction.search,
                                                            decoration: InputDecoration(
//                        border: InputBorder.none,
                                                              hintText: "학교 이름",
                                                              contentPadding: EdgeInsets.fromLTRB(0, 10.0, 0, 8.0),

                                                              hintStyle: TextStyle(
                                                                fontSize: 18,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        Material(
                                                          borderRadius: BorderRadius.all(Radius.circular(500)),
                                                          color: Colors.grey[200],
                                                          child: InkWell(
                                                            borderRadius: BorderRadius.all(Radius.circular(500)),
                                                            onTap: () async {
                                                              var searchResult =
                                                                  await userStatus.searchSchoolName(_controller.text);
                                                            },
                                                            child: Container(
                                                                padding: EdgeInsets.all(5),
                                                                decoration: BoxDecoration(
                                                                  borderRadius: BorderRadius.all(Radius.circular(500)),
                                                                ),
                                                                child: Icon(Icons.search)),
                                                          ),
                                                        )
                                                      ],
                                                    ),
                                                    Flexible(child: Builder(
                                                      builder: (context) {
                                                        UserStatus userStatus = Provider.of<UserStatus>(context);
                                                        return !userStatus.isSearchingSchool
                                                            ? ListView(
                                                                children: userStatus.schoolSearchList.map((school) {
                                                                return Material(
                                                                    child: InkWell(
                                                                        onTap: () {
                                                                          userStatus.setInputData(
                                                                              "schoolName", school["schoolName"]);
                                                                          userStatus.setInputData(
                                                                              "schoolId", school["schoolId"]);

                                                                          userStatus.setClassData(school["schoolId"]);

                                                                          Navigator.pop(context);
                                                                        },
                                                                        child: Container(
                                                                          height: 70,
                                                                          child: Container(
                                                                            padding: EdgeInsets.all(5),
                                                                            child: Column(
                                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                                              children: <Widget>[
                                                                                Text(
                                                                                  school["schoolName"],
                                                                                  style: TextStyle(
                                                                                      fontSize: 18,
                                                                                      fontWeight: FontWeight.bold),
                                                                                ),
                                                                                SizedBox(height: 10),
                                                                                Text(school["schoolAddress"],
                                                                                    style: TextStyle(
                                                                                      fontSize: 14,
                                                                                    ))
                                                                              ],
                                                                            ),
                                                                          ),
                                                                        )));
                                                              }).toList())
                                                            : Container(
                                                                margin: EdgeInsets.only(top: 20),
                                                                child: CircularProgressIndicator());
                                                      },
                                                    ))
                                                  ],
                                                ),
                                              ),
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                                              actions: <Widget>[
                                                new FlatButton(
                                                  child: new Text("Close"),
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                  },
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      },
                                borderRadius: BorderRadius.all(Radius.circular(10)),
                                child: Container(
                                    alignment: Alignment.center,
                                    height: 45,
                                    child: Text(
                                      userStatus.isSchoolCodeVerified == true
                                          ? userStatus.inputData["schoolName"]
                                          : (userStatus.inputData["schoolName"] == ""
                                              ? "학교 검색"
                                              : userStatus.inputData["schoolName"]),
                                      textAlign: TextAlign.center,
                                    )),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 25),
                    userStatus.classData.length > 0 ? Row(
                      children: <Widget>[
                        Container(
                          alignment: Alignment.center,
                          width: 70,
                          child: Text(
                            "학년",
                            style: TextStyle(fontSize: 20),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Flexible(
                          child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.all(Radius.circular(10)),
                              ),
                              child: DropdownButton(
//                            value: _selectedCompany,
                                value: userStatus.inputData["schoolGrade"],

                                items: userStatus.classData.keys.map((k) {
                                  return DropdownMenuItem(
                                    value: k,
                                    child: Container(
                                        padding: EdgeInsets.symmetric(horizontal: 20),
                                        child: Text((k).toString() + "학년")),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                        userStatus.setInputData("schoolGrade", value);
                                      }
                              )),
                        ),
                      ],
                    ) : Container(),
                    SizedBox(height: 25),
                    userStatus.inputData["schoolGrade"] != null && userStatus.classData.length > 0 ? Row(
                      children: <Widget>[
                        Container(
                          alignment: Alignment.center,
                          width: 70,
                          child: Text(
                            "반",
                            style: TextStyle(fontSize: 20),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Flexible(
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.all(Radius.circular(10)),
                            ),
                            child: DropdownButton(
//                            value: _selectedCompany,
                              value: userStatus.inputData["schoolClass"],
                              items: userStatus.classData[userStatus.inputData["schoolGrade"]].map<DropdownMenuItem>((schoolClass) {
                                return DropdownMenuItem(
                                  value: schoolClass,
                                  child: Container(
                                      padding: EdgeInsets.symmetric(horizontal: 20),
                                      child: Text((schoolClass).toString() + "반")),
                                );
                              }).toList(),
                              onChanged: (value) {
                                userStatus.setInputData("schoolClass", value);
                              },
                            ),
                          ),
                        ),
                      ],
                    ) : Container(),
                  ],
                ),
                Positioned(
                    child: Column(
                      children: <Widget>[
                        NextButton(
                            text: "완료",
                            onTap: () async {
//                            userStatus.inputData["schoolCode"] = _controller.text;

                              if (userStatus.isKakao) {
                                bool registerResult = await userStatus.registerWithKakao();
                                if (registerResult) {
                                  bool loginResult = await userStatus.loginWithKakao();
                                  if (loginResult) {
                                    print("!!!!!!!!!!!!1");
                                    Navigator.push(context, MaterialPageRoute(builder: (context) => MealState()));
                                  } else {
                                    Navigator.of(context).popUntil((route) => route.isFirst);
                                  }
                                }
                              } else {
                                bool registerResult = await userStatus.registerDefault();
                                if (registerResult) {
                                  bool loginResult = await userStatus.loginDefault(
                                      userStatus.inputData["id"], userStatus.inputData["password"]);
                                  if (loginResult) {
                                    print("!!!!!!!!!!!!1");
                                    Navigator.push(context, MaterialPageRoute(builder: (context) => MealState()));
                                  } else {
                                    Navigator.of(context).popUntil((route) => route.isFirst);
                                  }
                                }
                              }

//                            Navigator.push(
//                              context,
//                              MaterialPageRoute(builder: (context) => IdRegisterPage()),
//                            );
                            },
                            textColor: Colors.white,
                            primeColor: primaryRedDark,
                            disabled: () {
                              return userStatus.inputData["schoolName"] == "" ||
                                  userStatus.inputData["schoolGrade"] == null ||
                                  userStatus.inputData["schoolClass"] == null;
                            }),
                      ],
                    ),
                    bottom: 0,
                    right: 0,
                    left: 0)
              ]))),
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
