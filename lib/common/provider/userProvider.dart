import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:http/http.dart' as http;

import 'package:kakao_flutter_sdk/auth.dart';
import 'package:kakao_flutter_sdk/user.dart';

import 'dart:convert';

import '../ip.dart';

Map<String, dynamic> parseJwtPayLoad(String token) {
  final parts = token.split('.');
  if (parts.length != 3) {
    throw Exception('invalid token');
  }

  final payload = _decodeBase64(parts[1]);
  final payloadMap = json.decode(payload);
  if (payloadMap is! Map<String, dynamic>) {
    throw Exception('invalid payload');
  }

  return payloadMap;
}

Map<String, dynamic> parseJwtHeader(String token) {
  final parts = token.split('.');
  if (parts.length != 3) {
    throw Exception('invalid token');
  }

  final payload = _decodeBase64(parts[0]);
  final payloadMap = json.decode(payload);
  if (payloadMap is! Map<String, dynamic>) {
    throw Exception('invalid payload');
  }

  return payloadMap;
}

String _decodeBase64(String str) {
  String output = str.replaceAll('-', '+').replaceAll('_', '/');

  switch (output.length % 4) {
    case 0:
      break;
    case 2:
      output += '==';
      break;
    case 3:
      output += '=';
      break;
    default:
      throw Exception('Illegal base64url string!"');
  }

  return utf8.decode(base64Url.decode(output));
}

class UserStatus with ChangeNotifier {
//  KakaoContext.clientId = '39d6c43a0a346cca6ebc7b2dbb8e4353';


  bool isLoading = false;

  bool isLogined = false;
  Map<String, dynamic> userInfo = {"nickname": ""};

  Map<String, dynamic> inputData = {
    "nickname": "",
    "id": "",
    "password": "",
    "schoolCode": "",
    "schoolName": "",
    "schoolId": "",
    "schoolGrade": 1,
    "schoolClass": 1
  };

  bool isSchoolCodeVerified = false;
  List<dynamic> schoolSearchList = [];

  bool isSearchingSchool = false;

  bool isKakao = false;

  void setIsKakao(value) {
    isKakao = value;
    if (isKakao) {
      inputData = {"nickname": "", "schoolCode": "", "schoolName": "", "schoolId": "", "schoolGrade": 1, "schoolClass": 1};
    } else {
      inputData = {
        "nickname": "",
        "id": "",
        "password": "",
        "schoolCode": "",
        "schoolName": "",
        "schoolId": "",
        "schoolGrade": 1,
        "schoolClass": 1
      };
    }

    notifyListeners();
  }

  void setInputData(key, value) {
    inputData[key] = value;
    notifyListeners();
  }

  void setIsSchoolCodeVerified(value) {
    isSchoolCodeVerified = value;
    notifyListeners();
  }

  void initSchoolSsearchList() {
    schoolSearchList = [];
    notifyListeners();
  }

  void setIsLoading(value) {
    isLoading = value;
    notifyListeners();
  }

  void setIsSearchingSchool(value) {
    isSearchingSchool = value;
    notifyListeners();
  }



  Future<dynamic> GET({String url}) async {
    isLoading = true;
    notifyListeners();
    final res = await http.get(
      url,
    );
    isLoading = false;
    notifyListeners();

    return res;
  }

  Future<dynamic> POST({String url, dynamic body}) async {
    isLoading = true;
    notifyListeners();
    final res = await http.post
      (
      url,body: jsonEncode(body),
      headers: {"Content-Type": "application/json"},
    );
    isLoading = false;
    notifyListeners();

    return res;
  }


  Future<bool> checkIdDuplicate() async {
    isLoading = true;
    notifyListeners();
    final res = await GET(url : "${Host.address}/students/check-duplicate/id/${inputData["id"]}");
    isLoading = false;
    notifyListeners();

    if (res.statusCode == 200){
      return true;
    }else{
      return false;
    }

  }

  Future<bool> checkNicknameDuplicate() async {
    final res = await GET(
      url : "${Host.address}/students/check-duplicate/nickname/${inputData["nickname"]}",
    );
    if (res.statusCode == 200){
      return true;
    }else{
      return false;
    }

  }


  Future<dynamic> verifySchoolCode() async {
    final res = await GET(
      url :
      "${Host.address}/schools/code-verify/${inputData["schoolCode"]}",
    );

    if (res.statusCode == 200) {
      print("success");
      Map<String, dynamic> resData = jsonDecode(res.body);
      return resData["data"];
    } else {
      print("failed");
      print(res.body);
      return null;
    }
  }

  Future<dynamic> searchSchoolName(search) async {

    setIsSearchingSchool(true);


    final res = await GET(
      url:
      "${Host.address}/schools?schoolName=${search}",
    );
    setIsSearchingSchool(false);

    if (res.statusCode == 200) {
      print("success");
      var resData = jsonDecode(res.body);
      schoolSearchList = resData["data"];

      print(schoolSearchList);

      notifyListeners();

      return resData;
    } else {
      print("failed");
      print(res.body);
      return null;
    }



  }


  bool _isKakaoTalkInstalled;

  UserStatus() {
    init();
  }

  bool getIsInstalledKakao() {
    return _isKakaoTalkInstalled;
  }

  _issueAccessToken(String authCode) async {
    print(authCode);
    try {
      var token = await AuthApi.instance.issueAccessToken(authCode);
      AccessTokenStore.instance.toStore(token);
      print(token.accessToken);
      return token;

//      final res = await http.post(
//        "http://192.168.21.1:5000/api/auth/kakao/register",
//        body: jsonEncode({"accessToken" : token.accessToken}),  headers: {"Content-Type": "application/json"},);

    } catch (e) {
      print("error on issuing access token: $e");
    }
  }


  Future<bool> registerDefault() async {
    var param = {
      "id" : inputData["id"],
      "password" : inputData["password"],
      "nickname": inputData["nickname"],
      "schoolCode": inputData["schoolCode"],
      "schoolId": inputData["schoolId"],
      "schoolGrade": inputData["schoolGrade"],
      "schoolClass": inputData["schoolClass"]
    };
    if(param["schoolCode"] == ""){
      param.remove("schoolCode");
    }




    final res = await http.post(
      "${Host.address}/students",
      body: jsonEncode(param),
      headers: {"Content-Type": "application/json"},
    );

    if (res.statusCode == 201) {
      print("success");
      return true;
    } else {
      print("failed");
      print(res.body);
      return false;
    }
  }



  Future<bool> registerWithKakao() async {
    var code;
    if (_isKakaoTalkInstalled == true) {
      code = await AuthCodeClient.instance.requestWithTalk();
    } else {
      code = await AuthCodeClient.instance.request();
    }

    var token = await _issueAccessToken(code);


    var param = {
      "nickname": inputData["nickname"],
      "schoolCode": inputData["schoolCode"],
      "schoolId": inputData["schoolId"],
      "schoolGrade": inputData["schoolGrade"],
      "schoolClass": inputData["schoolClass"]
    };

    param["accessToken"] = token.accessToken;
    param.remove("schoolName");
    if(param["schoolCode"] == ""){
      param.remove("schoolCode");
    }


    print(inputData);
    final res = await POST(
      url:
      "${Host.address}/auth/kakao/register",
      body: param,
//      headers: {"Content-Type": "application/json"},
    );

    if (res.statusCode == 201) {
      print("success");
      return true;
    } else {

      print("failed");
      print(res.body);
      return false;
    }

  }

  Future<bool> loginDefault(id ,pw) async {
    final res = await POST(
      url:
      "${Host.address}/auth",
      body: {"id" : id, "password" : pw},
//      headers: {"Content-Type": "application/json"},
    );
    Map<String, dynamic> resData = jsonDecode(res.body);
    switch (res.statusCode) {
      case 404:
        print("회원가입이나 하세요");

        return false;
        break;
      case 200:
        var storage = FlutterSecureStorage();
        storage.write(key: "token", value: resData["accessToken"]);

        isLogined = true;
        userInfo["nickname"] = parseJwtPayLoad(resData["accessToken"])["data"]["nickname"];
        print("SDFASFD");
        notifyListeners();
        return true;
        break;
    }
  }



  Future<bool> loginWithKakao() async {
    try {
      var code;
      if (_isKakaoTalkInstalled == true) {
        code = await AuthCodeClient.instance.requestWithTalk();
      } else {
        code = await AuthCodeClient.instance.request();
      }

      var token = await _issueAccessToken(code);


      final res = await POST(
        url :
        "${Host.address}/auth/kakao/login",
        body: {"accessToken": token.accessToken},
//        headers: {"Content-Type": "application/json"},

      );
      Map<String, dynamic> resData = jsonDecode(res.body);
      switch (res.statusCode) {
        case 404:
          print("회원가입이나 하세요");

          return false;
          break;
        case 200:
          var storage = FlutterSecureStorage();
          storage.write(key: "token", value: resData["accessToken"]);

          isLogined = true;
          userInfo["nickname"] = parseJwtPayLoad(resData["accessToken"])["data"]["nickname"];
          print("성공");
          notifyListeners();
          return true;
          break;
      }
    } catch (e) {
      print(e);
    }
  }

  Future<bool> login(String id, String pw) async {
    final res = await POST(url : "${Host.address}/User/login", body: {"id": id, "password": pw});
    print(res.body);
    Map<String, dynamic> data = jsonDecode(res.body);
    if (data["status"] != 200) {
      return false;
    }
    var token = res.headers["set-cookie"].split("user=")[1].split(";")[0];
    print(token);

    var storage = FlutterSecureStorage();
    storage.write(key: "token", value: token);

    isLogined = true;
    userInfo["nickname"] = parseJwtPayLoad(token)["nickname"];

    notifyListeners();
//  print();
    return true;
  }

  Future<bool> kakaoLogin(Map<String, dynamic> data) async {
    print(data);
    final res = await POST(
      url :
      "${Host.address}/auth/kakao/login",
      body: data,
    );

    Map<String, dynamic> resData = jsonDecode(res.body);

    print(resData);

//    if(data["status"] == 200){
//      return true;
//    }else{
//      return false;
//    }
  }

  void logout() {
    var storage = FlutterSecureStorage();
    storage.write(key: "token", value: "");
    isLogined = false;
    userInfo = {"nickname": ""};

    notifyListeners();
  }

  unlinkTalk() async {
    try {
      var code = await UserApi.instance.unlink();
      print(code.toString());
    } catch (e) {
      print(e);
    }
  }

  init() async {
    final installed = await isKakaoTalkInstalled();
    print('kakao Install : ' + installed.toString());

    _isKakaoTalkInstalled = installed;

    final storage = new FlutterSecureStorage();
    var token = await storage.read(key: "token");

    //jwt 토큰이 유효한지 서버에서 가져와야할 것 같은데 일단 생략

    if (token != null) {
      try {
        userInfo["id"] = parseJwtPayLoad(token)["id"];
        isLogined = true;
      } catch (e) {
        isLogined = false;
      }

//      userInfo["id"] = parseJwtPayLoad(token)["id"];
    } else {
      isLogined = false;
    }

    print(token);
    notifyListeners();
  }






}

getToken() async {
  final storage = new FlutterSecureStorage();
  var token = await storage.read(key: "token");
  if(token == null){
    return "";
  }
  return "Bearer " + token;
}