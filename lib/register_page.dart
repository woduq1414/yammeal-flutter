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

final registerScaffoldKey1 = GlobalKey<ScaffoldState>();
final registerScaffoldKey2 = GlobalKey<ScaffoldState>();
final registerScaffoldKey3 = GlobalKey<ScaffoldState>();

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

  bool _isConsent = false;

  @override
  Widget build(BuildContext context) {
//    return LoadingModal(
//      child: Scaffold(
//
//          appBar: DefaultAppBar(),
//          body: Container(
//              padding: EdgeInsets.all(15),
//              child: Stack(children: [
//                Column(
//                  children: <Widget>[
//                    SizedBox(
//                      height: 20,
//                    ),
//                    Align(
//                        alignment: Alignment.centerLeft,
//                        child: Text(
//                          "개인정보 처리에 대한 안내",
//                          style: TextStyle(fontSize: 25),
//                        )
//                    ),
//                    SizedBox(height : 15),
//                    Container(
//                      decoration: BoxDecoration(
//                        border: Border.all(
//                          width: 2, //                   <--- border width here
//                        ),
//                      ),
//                      padding: EdgeInsets.all(5),
//                      height: 200,
//                      child: SingleChildScrollView(
//                        child: Text("""
//<애퍼처>('https://www.aperturecs.com/'이하 '애퍼처')은(는) 개인정보보호법에 따라 이용자의 개인정보 보호 및 권익을 보호하고 개인정보와 관련한 이용자의 고충을 원활하게 처리할 수 있도록 다음과 같은 처리방침을 두고 있습니다.
//
//<애퍼처>('애퍼처') 은(는) 회사는 개인정보처리방침을 개정하는 경우 웹사이트 공지사항(또는 개별공지)을 통하여 공지할 것입니다.
//
//○ 본 방침은부터 2020년 1월 1일부터 시행됩니다.
//
//
//1. 개인정보의 처리 목적 <애퍼처>('https://www.aperturecs.com/'이하 '애퍼처')은(는) 개인정보를 다음의 목적을 위해 처리합니다. 처리한 개인정보는 다음의 목적이외의 용도로는 사용되지 않으며 이용 목적이 변경될 시에는 사전동의를 구할 예정입니다.
//
//가. 홈페이지 회원가입 및 관리
//
//회원 가입의사 확인, 회원제 서비스 제공에 따른 본인 식별·인증, 회원자격 유지·관리, 서비스 부정이용 방지 등을 목적으로 개인정보를 처리합니다.
//
//
//2. 개인정보 파일 현황
//
//1. 개인정보 파일명 : 회원 정보
//개인정보 항목 : 이메일, 비밀번호, 학력, 닉네임
//수집방법 : 애플리케이션
//보유근거 : 개인정보제공 동의
//보유기간 : 준영구
//관련법령 :
//
//
//3. 개인정보의 처리 및 보유 기간
//
//① <애퍼처>('애퍼처')은(는) 법령에 따른 개인정보 보유·이용기간 또는 정보주체로부터 개인정보를 수집시에 동의 받은 개인정보 보유,이용기간 내에서 개인정보를 처리,보유합니다.
//
//② 각각의 개인정보 처리 및 보유 기간은 다음과 같습니다.
//
//1.<홈페이지 회원가입 및 관리>
//<홈페이지 회원가입 및 관리>와 관련한 개인정보는 수집.이용에 관한 동의일로부터<준영구>까지 위 이용목적을 위하여 보유.이용됩니다.
//보유근거 : 개인정보제공 동의
//관련법령 :
//예외사유 :
//
//
//4. 개인정보의 제3자 제공에 관한 사항
//
//① <애퍼처>('https://www.aperturecs.com/'이하 '애퍼처')은(는) 정보주체의 동의, 법률의 특별한 규정 등 개인정보 보호법 제17조 및 제18조에 해당하는 경우에만 개인정보를 제3자에게 제공합니다.
//
//② <애퍼처>('https://www.aperturecs.com/')은(는) 다음과 같이 개인정보를 제3자에게 제공하고 있습니다.
//
//1. <>
//개인정보를 제공받는 자 :
//제공받는 자의 개인정보 이용목적 :
//제공받는 자의 보유.이용기간:
//
//
//5. 개인정보처리 위탁
//
//① <애퍼처>('애퍼처')은(는) 원활한 개인정보 업무처리를 위하여 다음과 같이 개인정보 처리업무를 위탁하고 있습니다.
//
//1. <>
//위탁받는 자 (수탁자) :
//위탁하는 업무의 내용 :
//위탁기간 :
//② <애퍼처>('https://www.aperturecs.com/'이하 '애퍼처')은(는) 위탁계약 체결시 개인정보 보호법 제25조에 따라 위탁업무 수행목적 외 개인정보 처리금지, 기술적․관리적 보호조치, 재위탁 제한, 수탁자에 대한 관리․감독, 손해배상 등 책임에 관한 사항을 계약서 등 문서에 명시하고, 수탁자가 개인정보를 안전하게 처리하는지를 감독하고 있습니다.
//
//③ 위탁업무의 내용이나 수탁자가 변경될 경우에는 지체없이 본 개인정보 처리방침을 통하여 공개하도록 하겠습니다.
//
//6. 정보주체와 법정대리인의 권리·의무 및 그 행사방법 이용자는 개인정보주체로써 다음과 같은 권리를 행사할 수 있습니다.
//
//① 정보주체는 애퍼처에 대해 언제든지 개인정보 열람,정정,삭제,처리정지 요구 등의 권리를 행사할 수 있습니다.
//
//② 제1항에 따른 권리 행사는애퍼처에 대해 개인정보 보호법 시행령 제41조제1항에 따라 서면, 전자우편, 모사전송(FAX) 등을 통하여 하실 수 있으며 애퍼처은(는) 이에 대해 지체 없이 조치하겠습니다.
//
//③ 제1항에 따른 권리 행사는 정보주체의 법정대리인이나 위임을 받은 자 등 대리인을 통하여 하실 수 있습니다. 이 경우 개인정보 보호법 시행규칙 별지 제11호 서식에 따른 위임장을 제출하셔야 합니다.
//
//④ 개인정보 열람 및 처리정지 요구는 개인정보보호법 제35조 제5항, 제37조 제2항에 의하여 정보주체의 권리가 제한 될 수 있습니다.
//
//⑤ 개인정보의 정정 및 삭제 요구는 다른 법령에서 그 개인정보가 수집 대상으로 명시되어 있는 경우에는 그 삭제를 요구할 수 없습니다.
//
//⑥ 애퍼처은(는) 정보주체 권리에 따른 열람의 요구, 정정·삭제의 요구, 처리정지의 요구 시 열람 등 요구를 한 자가 본인이거나 정당한 대리인인지를 확인합니다.
//
//
//
//7. 처리하는 개인정보의 항목 작성
//
//① <애퍼처>('https://www.aperturecs.com/'이하 '애퍼처')은(는) 다음의 개인정보 항목을 처리하고 있습니다.
//
//1<홈페이지 회원가입 및 관리>
//필수항목 : 이메일, 비밀번호, 학력, 닉네임
//- 선택항목 :
//
//
//8. 개인정보의 파기<애퍼처>('애퍼처')은(는) 원칙적으로 개인정보 처리목적이 달성된 경우에는 지체없이 해당 개인정보를 파기합니다. 파기의 절차, 기한 및 방법은 다음과 같습니다.
//
//-파기절차
//이용자가 입력한 정보는 목적 달성 후 별도의 DB에 옮겨져(종이의 경우 별도의 서류) 내부 방침 및 기타 관련 법령에 따라 일정기간 저장된 후 혹은 즉시 파기됩니다. 이 때, DB로 옮겨진 개인정보는 법률에 의한 경우가 아니고서는 다른 목적으로 이용되지 않습니다.
//
//-파기기한
//이용자의 개인정보는 개인정보의 보유기간이 경과된 경우에는 보유기간의 종료일로부터 5일 이내에, 개인정보의 처리 목적 달성, 해당 서비스의 폐지, 사업의 종료 등 그 개인정보가 불필요하게 되었을 때에는 개인정보의 처리가 불필요한 것으로 인정되는 날로부터 5일 이내에 그 개인정보를 파기합니다.
//
//-파기방법
//
//전자적 파일 형태의 정보는 기록을 재생할 수 없는 기술적 방법을 사용합니다
//
//
//
//9. 개인정보 자동 수집 장치의 설치•운영 및 거부에 관한 사항
//
//애퍼처 은 정보주체의 이용정보를 저장하고 수시로 불러오는 ‘쿠키’를 사용하지 않습니다.
//
//10. 개인정보 보호책임자 작성
//
//① 애퍼처(‘https://www.aperturecs.com/’이하 ‘애퍼처) 은(는) 개인정보 처리에 관한 업무를 총괄해서 책임지고, 개인정보 처리와 관련한 정보주체의 불만처리 및 피해구제 등을 위하여 아래와 같이 개인정보 보호책임자를 지정하고 있습니다.
//
//▶ 개인정보 보호책임자
//성명 :정재엽
//직책 :책임자
//직급 :책임자
//연락처 :01034081188, jjy37777@naver.com, -
//※ 개인정보 보호 담당부서로 연결됩니다.
//
//▶ 개인정보 보호 담당부서
//부서명 :
//담당자 :
//연락처 :, ,
//② 정보주체께서는 애퍼처(‘https://www.aperturecs.com/’이하 ‘애퍼처) 의 서비스(또는 사업)을 이용하시면서 발생한 모든 개인정보 보호 관련 문의, 불만처리, 피해구제 등에 관한 사항을 개인정보 보호책임자 및 담당부서로 문의하실 수 있습니다. 애퍼처(‘https://www.aperturecs.com/’이하 ‘애퍼처) 은(는) 정보주체의 문의에 대해 지체 없이 답변 및 처리해드릴 것입니다.
//
//11. 개인정보 처리방침 변경
//
//①이 개인정보처리방침은 시행일로부터 적용되며, 법령 및 방침에 따른 변경내용의 추가, 삭제 및 정정이 있는 경우에는 변경사항의 시행 7일 전부터 공지사항을 통하여 고지할 것입니다.
//
//
//
//12. 개인정보의 안전성 확보 조치 <애퍼처>('애퍼처')은(는) 개인정보보호법 제29조에 따라 다음과 같이 안전성 확보에 필요한 기술적/관리적 및 물리적 조치를 하고 있습니다.
//
//1. 개인정보 취급 직원의 최소화 및 교육
//개인정보를 취급하는 직원을 지정하고 담당자에 한정시켜 최소화 하여 개인정보를 관리하는 대책을 시행하고 있습니다.
//
//2. 개인정보의 암호화
//이용자의 개인정보는 비밀번호는 암호화 되어 저장 및 관리되고 있어, 본인만이 알 수 있으며 중요한 데이터는 파일 및 전송 데이터를 암호화 하거나 파일 잠금 기능을 사용하는 등의 별도 보안기능을 사용하고 있습니다.
//
//
//                        """),
//                      ),
//                    ),
//                    Row(
//                      children: <Widget>[
//                        Checkbox(
//                          activeColor: primaryRedDark,
//                          value: _isConsent,
//                          onChanged: (bool value) {
//                            setState(() {
//                              _isConsent = !_isConsent;
//                            });
//                          },
//                        ),
//                        GestureDetector(
//                            onTap: () {
//                              setState(() {
//                                _isConsent = !_isConsent;
//                              });
//                            },
//                            child: Text("저는 만 14세 이상이고, 위에 동의합니다.", style: TextStyle(fontSize: 16),))
//                      ],
//                    )
//                  ],
//                ),
//                Positioned(
//                    child: NextButton(
//                        text: "다음",
//                        onTap: () async {
//                          if(isKakao){
//                            Navigator.push(
//                              context,
//                              MaterialPageRoute(builder: (context) =>  NameRegisterPage()),
//                            );
//                          }
//                          else{
//                            Navigator.push(
//                              context,
//                              MaterialPageRoute(builder: (context) =>  IdRegisterPage()),
//                            );
//                          }
//
//                        },
//                        textColor: Colors.white,
//                        primeColor: primaryRedDark,
//                        disabled: () {
//                          return !_isConsent;
//                        }),
//                    bottom: 0,
//                    right: 0,
//                    left: 0)
//              ]))),
//    );

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
          key: registerScaffoldKey1,
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
                        text: "다음",
                        onTap: () async {
                          userStatus.inputData["id"] = _controller.text;

                          var checkResult = await userStatus.checkIdDuplicate();
                          if (checkResult == false) {
                            registerScaffoldKey1.currentState.showSnackBar(SnackBar(
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
          key: registerScaffoldKey2,
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
                            registerScaffoldKey2.currentState.showSnackBar(
                              SnackBar(
                                  content: Text(
                                    "이미 가입된 닉네임입니다.",
                                  ),
                                  duration: const Duration(seconds: 1)),
                            );
                            return;
                          }


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

                          // Navigator.push(
                          //   context,
                          //   MaterialPageRoute(builder: (context) => SchoolCodeRegisterPage()),
                          // );
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
          key: registerScaffoldKey3,
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
                                registerScaffoldKey3.currentState.showSnackBar(
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

class SchoolInfoRegisterPage extends StatefulWidget {
  @override
  _SchoolInfoRegisterPageState createState() => _SchoolInfoRegisterPageState();
}

class _SchoolInfoRegisterPageState extends State<SchoolInfoRegisterPage> {
  final _controller = TextEditingController();
  bool _isConsent = false;

  Widget build(BuildContext context) {
    UserStatus userStatus = Provider.of<UserStatus>(context);

    if (userStatus.isSchoolCodeVerified) {}
    {
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
                                                          borderRadius: BorderRadius.all(Radius.circular(5)),
                                                          color: primaryRed.withOpacity(0.8),
                                                          child: InkWell(
                                                            borderRadius: BorderRadius.all(Radius.circular(5)),
                                                            onTap: () async {
                                                              var searchResult =
                                                                  await userStatus.searchSchoolName(_controller.text);
                                                            },
                                                            child: Container(
                                                                padding: EdgeInsets.all(5),
                                                                decoration: BoxDecoration(

                                                                  borderRadius: BorderRadius.all(Radius.circular(5)),
                                                                ),
                                                                child: Icon(Icons.search,  color: Colors.white,)),
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
                                                                              mainAxisAlignment: MainAxisAlignment.center,
                                                                              children: <Widget>[
                                                                                Text(
                                                                                  school["schoolName"],
                                                                                  style: TextStyle(
                                                                                      fontSize: fs.s6,
                                                                                  ),
                                                                                ),
                                                                                SizedBox(height: 10),
                                                                                Text(school["schoolAddress"],
                                                                                    style: TextStyle(
                                                                                      fontSize: fs.s7,
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
                                                  child: new Text("닫기"),
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
                    userStatus.classData.length > 0
                        ? Row(
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
                                        })),
                              ),
                            ],
                          )
                        : Container(),
                    SizedBox(height: 25),
                    userStatus.inputData["schoolGrade"] != null && userStatus.classData.length > 0
                        ? Row(
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
                                    items: userStatus.classData[userStatus.inputData["schoolGrade"]]
                                        .map<DropdownMenuItem>((schoolClass) {
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
                          )
                        : Container(),
                  ],
                ),
                Positioned(
                    child: Column(
                      children: <Widget>[
                        NextButton(
                            text: "확인",
                            onTap: () async {
//                            userStatus.inputData["schoolCode"] = _controller.text;

                              bool isConsent = false;

                              showModalBottomSheet(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
                                  ),
                                  context: context,
                                  builder: (BuildContext bc) {
                                    return StatefulBuilder(builder: (BuildContext bc, StateSetter state) {
                                      return Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.all(Radius.circular(15)),
                                        ),
                                        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                                        child: new Wrap(
                                          children: <Widget>[
                                            Column(
                                              children: <Widget>[
                                                SizedBox(
                                                  height: 5,
                                                ),
                                                Align(
                                                    alignment: Alignment.centerLeft,
                                                    child: Text(
                                                      "개인정보 처리에 대한 안내",
                                                      style: TextStyle(fontSize: 25),
                                                    )),
                                                SizedBox(height: 15),
                                                Container(
                                                  decoration: BoxDecoration(
                                                    border: Border.all(
                                                      width: 2, //                   <--- border width here
                                                    ),
                                                  ),
                                                  padding: EdgeInsets.all(5),
                                                  height: 200,
                                                  child: SingleChildScrollView(
                                                    child: Text("""
<애퍼처>('https://www.aperturecs.com/'이하 '애퍼처')은(는) 개인정보보호법에 따라 이용자의 개인정보 보호 및 권익을 보호하고 개인정보와 관련한 이용자의 고충을 원활하게 처리할 수 있도록 다음과 같은 처리방침을 두고 있습니다.

<애퍼처>('애퍼처') 은(는) 회사는 개인정보처리방침을 개정하는 경우 웹사이트 공지사항(또는 개별공지)을 통하여 공지할 것입니다.

○ 본 방침은부터 2020년 1월 1일부터 시행됩니다.


1. 개인정보의 처리 목적 <애퍼처>('https://www.aperturecs.com/'이하 '애퍼처')은(는) 개인정보를 다음의 목적을 위해 처리합니다. 처리한 개인정보는 다음의 목적이외의 용도로는 사용되지 않으며 이용 목적이 변경될 시에는 사전동의를 구할 예정입니다.

가. 홈페이지 회원가입 및 관리

회원 가입의사 확인, 회원제 서비스 제공에 따른 본인 식별·인증, 회원자격 유지·관리, 서비스 부정이용 방지 등을 목적으로 개인정보를 처리합니다.


2. 개인정보 파일 현황

1. 개인정보 파일명 : 회원 정보
개인정보 항목 : 이메일, 비밀번호, 학력, 닉네임
수집방법 : 애플리케이션
보유근거 : 개인정보제공 동의
보유기간 : 준영구
관련법령 :


3. 개인정보의 처리 및 보유 기간

① <애퍼처>('애퍼처')은(는) 법령에 따른 개인정보 보유·이용기간 또는 정보주체로부터 개인정보를 수집시에 동의 받은 개인정보 보유,이용기간 내에서 개인정보를 처리,보유합니다.

② 각각의 개인정보 처리 및 보유 기간은 다음과 같습니다.

1.<홈페이지 회원가입 및 관리>
<홈페이지 회원가입 및 관리>와 관련한 개인정보는 수집.이용에 관한 동의일로부터<준영구>까지 위 이용목적을 위하여 보유.이용됩니다.
보유근거 : 개인정보제공 동의
관련법령 :
예외사유 :


4. 개인정보의 제3자 제공에 관한 사항

① <애퍼처>('https://www.aperturecs.com/'이하 '애퍼처')은(는) 정보주체의 동의, 법률의 특별한 규정 등 개인정보 보호법 제17조 및 제18조에 해당하는 경우에만 개인정보를 제3자에게 제공합니다.

② <애퍼처>('https://www.aperturecs.com/')은(는) 다음과 같이 개인정보를 제3자에게 제공하고 있습니다.

1. <>
개인정보를 제공받는 자 :
제공받는 자의 개인정보 이용목적 :
제공받는 자의 보유.이용기간:


5. 개인정보처리 위탁

① <애퍼처>('애퍼처')은(는) 원활한 개인정보 업무처리를 위하여 다음과 같이 개인정보 처리업무를 위탁하고 있습니다.

1. <>
위탁받는 자 (수탁자) :
위탁하는 업무의 내용 :
위탁기간 :
② <애퍼처>('https://www.aperturecs.com/'이하 '애퍼처')은(는) 위탁계약 체결시 개인정보 보호법 제25조에 따라 위탁업무 수행목적 외 개인정보 처리금지, 기술적․관리적 보호조치, 재위탁 제한, 수탁자에 대한 관리․감독, 손해배상 등 책임에 관한 사항을 계약서 등 문서에 명시하고, 수탁자가 개인정보를 안전하게 처리하는지를 감독하고 있습니다.

③ 위탁업무의 내용이나 수탁자가 변경될 경우에는 지체없이 본 개인정보 처리방침을 통하여 공개하도록 하겠습니다.

6. 정보주체와 법정대리인의 권리·의무 및 그 행사방법 이용자는 개인정보주체로써 다음과 같은 권리를 행사할 수 있습니다.

① 정보주체는 애퍼처에 대해 언제든지 개인정보 열람,정정,삭제,처리정지 요구 등의 권리를 행사할 수 있습니다.

② 제1항에 따른 권리 행사는애퍼처에 대해 개인정보 보호법 시행령 제41조제1항에 따라 서면, 전자우편, 모사전송(FAX) 등을 통하여 하실 수 있으며 애퍼처은(는) 이에 대해 지체 없이 조치하겠습니다.

③ 제1항에 따른 권리 행사는 정보주체의 법정대리인이나 위임을 받은 자 등 대리인을 통하여 하실 수 있습니다. 이 경우 개인정보 보호법 시행규칙 별지 제11호 서식에 따른 위임장을 제출하셔야 합니다.

④ 개인정보 열람 및 처리정지 요구는 개인정보보호법 제35조 제5항, 제37조 제2항에 의하여 정보주체의 권리가 제한 될 수 있습니다.

⑤ 개인정보의 정정 및 삭제 요구는 다른 법령에서 그 개인정보가 수집 대상으로 명시되어 있는 경우에는 그 삭제를 요구할 수 없습니다.

⑥ 애퍼처은(는) 정보주체 권리에 따른 열람의 요구, 정정·삭제의 요구, 처리정지의 요구 시 열람 등 요구를 한 자가 본인이거나 정당한 대리인인지를 확인합니다.



7. 처리하는 개인정보의 항목 작성

① <애퍼처>('https://www.aperturecs.com/'이하 '애퍼처')은(는) 다음의 개인정보 항목을 처리하고 있습니다.

1<홈페이지 회원가입 및 관리>
필수항목 : 이메일, 비밀번호, 학력, 닉네임
- 선택항목 :


8. 개인정보의 파기<애퍼처>('애퍼처')은(는) 원칙적으로 개인정보 처리목적이 달성된 경우에는 지체없이 해당 개인정보를 파기합니다. 파기의 절차, 기한 및 방법은 다음과 같습니다.

-파기절차
이용자가 입력한 정보는 목적 달성 후 별도의 DB에 옮겨져(종이의 경우 별도의 서류) 내부 방침 및 기타 관련 법령에 따라 일정기간 저장된 후 혹은 즉시 파기됩니다. 이 때, DB로 옮겨진 개인정보는 법률에 의한 경우가 아니고서는 다른 목적으로 이용되지 않습니다.

-파기기한
이용자의 개인정보는 개인정보의 보유기간이 경과된 경우에는 보유기간의 종료일로부터 5일 이내에, 개인정보의 처리 목적 달성, 해당 서비스의 폐지, 사업의 종료 등 그 개인정보가 불필요하게 되었을 때에는 개인정보의 처리가 불필요한 것으로 인정되는 날로부터 5일 이내에 그 개인정보를 파기합니다.

-파기방법

전자적 파일 형태의 정보는 기록을 재생할 수 없는 기술적 방법을 사용합니다



9. 개인정보 자동 수집 장치의 설치•운영 및 거부에 관한 사항

애퍼처 은 정보주체의 이용정보를 저장하고 수시로 불러오는 ‘쿠키’를 사용하지 않습니다.

10. 개인정보 보호책임자 작성

① 애퍼처(‘https://www.aperturecs.com/’이하 ‘애퍼처) 은(는) 개인정보 처리에 관한 업무를 총괄해서 책임지고, 개인정보 처리와 관련한 정보주체의 불만처리 및 피해구제 등을 위하여 아래와 같이 개인정보 보호책임자를 지정하고 있습니다.

▶ 개인정보 보호책임자
성명 :정재엽
직책 :책임자
직급 :책임자
연락처 : -, jjy37777@naver.com, -
※ 개인정보 보호 담당부서로 연결됩니다.

▶ 개인정보 보호 담당부서
부서명 :
담당자 :
연락처 :, ,
② 정보주체께서는 애퍼처(‘https://www.aperturecs.com/’이하 ‘애퍼처) 의 서비스(또는 사업)을 이용하시면서 발생한 모든 개인정보 보호 관련 문의, 불만처리, 피해구제 등에 관한 사항을 개인정보 보호책임자 및 담당부서로 문의하실 수 있습니다. 애퍼처(‘https://www.aperturecs.com/’이하 ‘애퍼처) 은(는) 정보주체의 문의에 대해 지체 없이 답변 및 처리해드릴 것입니다.

11. 개인정보 처리방침 변경

①이 개인정보처리방침은 시행일로부터 적용되며, 법령 및 방침에 따른 변경내용의 추가, 삭제 및 정정이 있는 경우에는 변경사항의 시행 7일 전부터 공지사항을 통하여 고지할 것입니다.



12. 개인정보의 안전성 확보 조치 <애퍼처>('애퍼처')은(는) 개인정보보호법 제29조에 따라 다음과 같이 안전성 확보에 필요한 기술적/관리적 및 물리적 조치를 하고 있습니다.

1. 개인정보 취급 직원의 최소화 및 교육
개인정보를 취급하는 직원을 지정하고 담당자에 한정시켜 최소화 하여 개인정보를 관리하는 대책을 시행하고 있습니다.

2. 개인정보의 암호화
이용자의 개인정보는 비밀번호는 암호화 되어 저장 및 관리되고 있어, 본인만이 알 수 있으며 중요한 데이터는 파일 및 전송 데이터를 암호화 하거나 파일 잠금 기능을 사용하는 등의 별도 보안기능을 사용하고 있습니다.


                        """),
                                                  ),
                                                ),
                                              ],
                                            ),

                                            Row(

//                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                children: <Widget>[
                                                  Checkbox(
                                                    activeColor: primaryRedDark,
                                                    value: isConsent,
                                                    onChanged: (bool value) {
                                                      state(() {
                                                        isConsent = !isConsent;
                                                      });
                                                    },
                                                  ),
                                                  GestureDetector(
                                                      onTap: () {
                                                        state(() {
                                                          isConsent = !isConsent;
                                                        });
                                                      },
                                                      child: Text(
                                                        "저는 만 14세 이상이고, 위에 동의합니다.",
                                                        style: TextStyle(fontSize: 16),
                                                      ))
                                                ]),

                                            NextButton(
                                                text: "완료",
                                                onTap: () async {

                                                  Navigator.pop(context);

//                                                  return;
                                                  if (userStatus.isKakao) {
                                                    bool registerResult = await userStatus.registerWithKakao();
                                                    if (registerResult) {
                                                      bool loginResult = await userStatus.loginWithKakao();
                                                      if (loginResult) {
                                                        print("!!!!!!!!!!!!1");
                                                        Navigator.push(
                                                            context, MaterialPageRoute(builder: (context) => MealState()));
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
                                                        Navigator.push(
                                                            context, MaterialPageRoute(builder: (context) => MealState()));
                                                      } else {
                                                        Navigator.of(context).popUntil((route) => route.isFirst);
                                                      }
                                                    }
                                                  }


                                                },
                                                textColor: Colors.white,
                                                primeColor: primaryRedDark,
                                                disabled: () {
                                                  return !isConsent;
                                                }),

//                                                  SizedBox(height : 70)

//                    )
                                          ],
                                        ),
                                      );
                                    });
                                  });
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
