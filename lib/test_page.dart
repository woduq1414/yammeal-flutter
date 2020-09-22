import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:kakao_flutter_sdk/auth.dart';
import 'package:kakao_flutter_sdk/user.dart';
import 'package:http/http.dart' as http;
import 'package:meal_flutter/common/widgets/loading.dart';
import 'package:meal_flutter/register_page.dart';
import 'package:provider/provider.dart';

import './common/provider/userProvider.dart';
import 'common/route_transition.dart';
import 'kakao_register_page.dart';

import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'package:path/path.dart';

import 'package:async/async.dart';


class TestPage extends StatefulWidget {
  @override
  _TestPageState createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {

  final _idController = TextEditingController();
  final _passwordController = TextEditingController();

  var _image;



  @override
  Widget build(BuildContext context) {
    UserStatus userStatus = Provider.of<UserStatus>(context);
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
              Text(userStatus.userInfo["nickname"] + "님 ㅎㅇ"),


              RaisedButton(
                child: Text("이미지 테스트"),
                onPressed: () async{
                  final picker = ImagePicker();
                  final pickedFile = await picker.getImage(source: ImageSource.camera);

                  setState(() {
                    _image = File(pickedFile.path);
//                    _image = temp;
                  });

                },
              ),

//              Center(
//                child: _image == null
//                    ? Text('No image selected.')
//                    : Image.file(_image, height : 100,),
//              ),

              RaisedButton(
                child: Text("업로드"),
                onPressed: () async {


                  // open a byteStream
                  var stream = new http.ByteStream(DelegatingStream.typed(_image.openRead()));
                  // get file length
                  var length = await _image.length();

                  // string to uri
                  var uri = Uri.parse("http://192.168.21.1:5000/api/board/meal");

                  // create multipart request
                  var request = new http.MultipartRequest("POST", uri);

                  // if you need more parameters to parse, add those like this. i added "user_id". here this "user_id" is a key of the API request
                  request.fields["jsonRequestData"] = jsonEncode({
                    "menuDate" : "20191219",
                    "title" : "제목입니다.",
                    "content" : "우리 학교 급식 꿀맛 ㄹㅇㅋㅋㅋ"
                  });
                  // multipart that takes file.. here this "image_file" is a key of the API request
                  var multipartFile = new http.MultipartFile('imageFile', stream, length, filename: basename(_image.path));

                  // add file to multipart
                  request.files.add(multipartFile);

                  request.headers['authorization'] = await getToken();
                  request.headers['authorization'] = "Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJkYXRhIjp7ImlkIjoicXdlMTIzNEBuYXZlci5jb20iLCJuaWNrbmFtZSI6Ilx1YzVjNFx1YzkwMFx1YzJkZHNzOCIsInNjaG9vbCI6eyJzY2hvb2xOYW1lIjoiXHVkNTVjXHVhZDZkXHViNTE0XHVjOWMwXHVkMTM4XHViYmY4XHViNTE0XHVjNWI0XHVhY2UwXHViNGYxXHVkNTU5XHVhZDUwIiwic2Nob29sSWQiOjc1MzA1NjAsInNjaG9vbEdyYWRlIjoxLCJzY2hvb2xDbGFzcyI6OH19LCJleHAiOjE2MDA1NzE0MDB9.IoCJK7gClWneKtyMf8NLXvTncFz5vRdu_pNNke3jixY";

//                  print(await getToken());
                  // send request to upload image
                  await request.send().then((response) async {
                    // listen for response
                    response.stream.transform(utf8.decoder).listen((value) {
                      print(value);
                    });

                  }).catchError((e) {
                    print(e);
                  });

//                  final res = await http.post
//                    (
//                    "http://127.0.0.1:5000/api/board/meal",
//                    body : {
//                      "imageFile" : _image,
//                      "jsonRequestData" : {
//                        "menuDate" : "20191219",
//                        "title" : "제목입니다zz.",
//                        "content" : "우리 학교 급식zz 꿀맛 ㄹㅇㅋㅋㅋ"
//                      },
//                    },
//                    headers: {},
//                  );
                }
              ),

            ],
          ),
        ),
      ),
    );


  }




}
