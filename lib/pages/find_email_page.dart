
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:meal_flutter/common/color.dart';
import 'package:meal_flutter/common/provider/userProvider.dart';
import 'package:meal_flutter/common/widgets/appbar.dart';
import 'package:meal_flutter/common/provider/userProvider.dart';
import 'package:meal_flutter/common/widgets/appbar.dart';
import 'package:meal_flutter/common/widgets/loading.dart';
import 'login_page.dart';

final scaffoldKey = GlobalKey<ScaffoldState>();
final scaffoldKey2 = GlobalKey<ScaffoldState>();
final scaffoldKey3 = GlobalKey<ScaffoldState>();

class FindEmailPage extends StatefulWidget {
//  bool isKakao;
//
//  FindPasswordPage({this.isKakao});

  @override
  _FindEmailPageState createState() => _FindEmailPageState();
}

class _FindEmailPageState extends State<FindEmailPage> {
//  bool isKakao;
//
//  _FindPasswordPageState(bool _isKakao) {
//    isKakao = _isKakao;
//  }

  @override
  Widget build(BuildContext context) {
    return NicknameInputPage();
  }
}

class NicknameInputPage extends StatelessWidget {
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
                          "가입했던 닉네임을 입력하세요",
                          style: TextStyle(fontSize: 25),
                        )),
                    TextField(
                      keyboardType: TextInputType.emailAddress,
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
                        hintText: "닉네임",
                        contentPadding: EdgeInsets.fromLTRB(0, 10.0, 0, 8.0),

//                        helperText: "비밀번호 찾기에 이용돼요",

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

                          int findResult = await userStatus.findMail();
                          if (findResult == 200) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => MailInfoPage()),
                            );
                          } else {
                            if (findResult == 401) {
                              scaffoldKey.currentState.showSnackBar(SnackBar(
                                  content: Text(
                                "소셜 로그인 회원입니다.",
                              )));
                            } else {
                              scaffoldKey.currentState.showSnackBar(SnackBar(
                                  content: Text(
                                "닉네임을 찾을 수 없습니다.",
                              )));
                            }
                          }
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

class MailInfoPage extends StatelessWidget {
  final _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    UserStatus userStatus = Provider.of<UserStatus>(context);

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
                          "${userStatus.inputData["nickname"]}님의 이메일은",
                          style: TextStyle(fontSize: 25),
                        )),
                    SizedBox(
                      height: 20,
                    ),
                    Align(
                        alignment: Alignment.topCenter,
                        child: Text(
                          "${userStatus.filteredMail}",
                          style: TextStyle(fontSize: 30),
                        )),
                    SizedBox(
                      height: 20,
                    ),
                    Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "입니다.",
                          style: TextStyle(fontSize: 25),
                        )),
                    SizedBox(
                      height: 20,
                    ),
                    Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "(별 개수와 실제 이메일 주소와는 무관합니다.)",
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        )),
                  ],
                ),
                Positioned(
                    child: NextButton(
                        text: "확인",
                        onTap: () async {
                          Navigator.popUntil(context, (route) => route.isFirst);
                          Navigator.push(context, MaterialPageRoute(builder: (context) => LoginPage()));
                        },
                        textColor: Colors.white,
                        primeColor: primaryRedDark,
                        disabled: () {
                          return false;
                        }),
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
