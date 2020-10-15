import 'package:flutter/material.dart';

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

class KakaoRegisterPage extends StatefulWidget {
  @override
  _KakaoRegisterPageState createState() => _KakaoRegisterPageState();
}

class _KakaoRegisterPageState extends State<KakaoRegisterPage> {
  final TextEditingController _idController = new TextEditingController();
  final TextEditingController _pwController = new TextEditingController();
  final TextEditingController _nameController = new TextEditingController();

  bool _inAsyncCall;

  Map<String, dynamic> _buildHint = {"id" : Container(), "pw": Container(), "name" : Container()};



  @override
  void initState() {
    super.initState();
    _inAsyncCall = false;
    _buildHint = {"id" : Container(), "pw": Container(), "name" : Container()};
  }





  @override
  Widget build(BuildContext context) {
    UserStatus userStatus = Provider.of<UserStatus>(context);

    return Scaffold(
      appBar: DefaultAppBar(title: "회원가입"),
      body: ModalProgressHUD(
        inAsyncCall: _inAsyncCall,
        progressIndicator: CircularProgressIndicator(),
        opacity: 0.2,
        child: Container(
          margin: EdgeInsets.symmetric(vertical: 25, horizontal: 20),
          child: Form(
            child: Column(
              children: <Widget>[
                SizedBox(height: 10),

                Row(
                  children: <Widget>[
                    Container(
                      alignment: Alignment.center,
                      width : 80,
                      child: Text("아이디"),
                    ),
                    Flexible(
                      child: Container(

                        height: 45,
                        child: TextField(
                          controller: _idController,
                          textInputAction: TextInputAction.next,
                          onSubmitted: (_) => FocusScope.of(context).nextFocus(),
                          onChanged: (value) {
                            setState(() {
                              var reg = RegExp(r'^[A-Za-z0-9]{6,12}$');
                              if(reg.hasMatch(_idController.text) == true){
                                _buildHint["id"] = Text("좋은 ID입니다.", style: TextStyle(color: Colors.green),);
                              }else{
                                _buildHint["id"] =Text("대/소문자, 숫자로 된 6~12글자여야 합니다.", style: TextStyle(color: Colors.red),);
                              }
                            });

                          },
                          textAlignVertical: TextAlignVertical.center,
                          textAlign: TextAlign.left,
                          decoration: InputDecoration(
//                  contentPadding: EdgeInsets.all(10.0),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: cardColor,
//                    focusColor: Colors.grey,

                            hintText: "아이디를 입력하시던가요ㅋㅋㅋㅋㅋㅋ",
                            hintStyle: TextStyle(fontSize: 13, color: Colors.black),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: <Widget>[
                    SizedBox(width : 80),
                    _buildHint["id"],
                  ],
                ),




                SizedBox(height: 10),
                Row(
                  children: <Widget>[
                    Container(
                      alignment: Alignment.center,
                      width : 80,
                      child: Text("비밀번호"),
                    ),
                    Flexible(
                      child: Container(

                        height: 45,
                        child: TextField(
                          controller: _pwController,
                          textInputAction: TextInputAction.next,
                          onSubmitted: (_) => FocusScope.of(context).nextFocus(),
                          onChanged: (value) {

                            setState(() {
                              var reg = RegExp(r'^.*(?=^.{8,15}$)(?=.*\d)(?=.*[a-zA-Z])(?=.*[!@#$%^&+=]).*$');
                              if(reg.hasMatch(_pwController.text) == true){
                                _buildHint["pw"] = Text("좋은 비밀번호입니다.", style: TextStyle(color: Colors.green),);
                              }else{
                                reg = RegExp(r'^.*(?=.*\d)(?=.*[a-zA-Z])(?=.*[!@#$%^&+=]).*$');
                                if(reg.hasMatch(_pwController.text) == true){
                                  _buildHint["pw"] =Text("8~15글자여야 합니다.", style: TextStyle(color: Colors.red),);
                                }else{
                                  _buildHint["pw"] =Text("특수문자, 영문, 숫자를 모두 포함해야합니다.", style: TextStyle(color: Colors.red),);
                                }

                              }
                            });

                          },
                          textAlignVertical: TextAlignVertical.center,
                          textAlign: TextAlign.left,
                          decoration: InputDecoration(
//                  contentPadding: EdgeInsets.all(10.0),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: cardColor,
//                    focusColor: Colors.grey,

                            hintText: "비밀번호를 입력하시던가요ㅋㅋㅋㅋㅋㅋ",
                            hintStyle: TextStyle(fontSize: 13, color: Colors.black),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: <Widget>[
                    SizedBox(width : 80),
                    _buildHint["pw"],
                  ],
                ),

                SizedBox(height: 10),
                Row(
                  children: <Widget>[
                    Container(
                      alignment: Alignment.center,
                      width : 80,
                      child: Text("이름"),
                    ),
                    Flexible(
                      child: Container(

                        height: 45,
                        child: TextField(
                          controller: _nameController,
                          textInputAction: TextInputAction.done,
                          onSubmitted: (_) => FocusScope.of(context).nextFocus(),
                          onChanged: (value) {

                            setState(() {
                              var reg = RegExp(r'^[A-Z0-9a-z가-힣]+$');
                              if(reg.hasMatch(_nameController.text) == true){
                                _buildHint["name"] = Text("좋은 이름입니다.", style: TextStyle(color: Colors.green),);
                              }else{
                                _buildHint["name"] =Text("한글, 영문, 숫자만 사용가능합니다.", style: TextStyle(color: Colors.red),);
                              }
                            });

                          },
                          textAlignVertical: TextAlignVertical.center,
                          textAlign: TextAlign.left,
                          decoration: InputDecoration(
//                  contentPadding: EdgeInsets.all(10.0),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: cardColor,
//                    focusColor: Colors.grey,

                            hintText: "이름을 입력하시던가요ㅋㅋㅋㅋㅋㅋ",
                            hintStyle: TextStyle(fontSize: 13, color: Colors.black),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: <Widget>[
                    SizedBox(width : 80),
                    _buildHint["name"],
                  ],
                ),

                SizedBox(height: 15),
                Material(
                  color: Color(0xFFE1E1E1),
                  borderRadius: BorderRadius.circular(10.0),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(10.0),
                    onTap: () async {
                      setState(() {
                        _inAsyncCall = true;
                      });


                      String id = _idController.text;
                      String pw = _pwController.text;
                      String name = _nameController.text;

                      bool registerResult = await userStatus.registerWithKakao();
                      if(registerResult == true){
                        print("!!!!!!!!!!!!11");
                        bool loginResult = await userStatus.loginWithKakao();

//                        if(loginResult == true){
//                          goMainPage();
//                        }else{
//
//                        }

                        setState(() {
                          _inAsyncCall = false;
                        });


                      }


                      setState(() {
                        _inAsyncCall = false;
                      });


//                    request.register(id, pw, name);
                    },

                    child: Container(
                      width: double.infinity,
                      alignment: Alignment.center,
                      height: 45,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.0),
//                      border: Border.all(width: 0.4),
                      ),
                      child: Text("회원가입 하던가 ㅋㅋㅋㅋㅋ"),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }


//
//  void goMainPage() {
//    Navigator.push(
//      context,
//      FadeRoute(page: MainPage()),
//    );
//  }

}

//페이지 이동 디졸브 트랜지션

