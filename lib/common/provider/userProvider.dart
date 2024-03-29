

import 'package:meal_flutter/common/widgets/dialog.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:http/http.dart' as http;

import 'package:kakao_flutter_sdk/auth.dart';
import 'package:kakao_flutter_sdk/user.dart';

import 'dart:convert';

import 'package:meal_flutter/pages/login_page.dart';
import 'package:meal_flutter/main.dart';
import 'package:meal_flutter/common/ip.dart';

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

  String tempToken = "";
  String tempRefreshToken = "";
  bool isLoading = false;

  bool isConsent = false;

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
    "schoolClass": 1,
    "verifyCode": -1
  };

  bool isSchoolCodeVerified = false;
  List<dynamic> schoolSearchList = [];

  bool isSearchingSchool = false;

  bool isKakao = false;

  String filteredMail = "";

  void setIsConsent(value) {
    isConsent = value;
    notifyListeners();
  }

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

  Future<bool> verifyMail() async {
    final res = await POST(
      url: "${currentHost}/students/password-reset/check-mail",
      body: {"id": inputData["id"]},
    );

    if (res.statusCode == 200) {
      print("success");
      return true;
    } else {
      print("failed");
      print(res.body);
      return false;
    }
  }

  Future<int> findMail() async {
    final res = await GET(url: "${currentHost}/students/id-hint?nickname=${inputData["nickname"]}");

    if (res.statusCode == 200) {
      print("success");
      Map<String, dynamic> resData = jsonDecode(res.body);
      filteredMail = resData["data"];
      return 200;
    } else {
      print("failed");
      print(res.body);
      return res.statusCode;
    }
  }

  Future<bool> verifyMailCode() async {
    final res = await POST(
      url: "${currentHost}/students/password-reset/check-code",
      body: {
        "code": inputData["verifyCode"],
        "id": inputData["id"],
      },
    );

    if (res.statusCode == 200) {
      print("success");
      Map<String, dynamic> resData = jsonDecode(res.body);
      tempToken = resData["accessToken"];
      tempRefreshToken = resData["refreshToken"];
      return true;
    } else {
      print("failed");
      print(res.body);
      return false;
    }
  }

  Future<bool> changePassword() async {
    isLoading = true;
    notifyListeners();
    final res = await http.put(
      "${currentHost}/students/password-reset",
      body: jsonEncode({"password": inputData["password"]}),
      headers: {"Content-Type": "application/json", "Authorization": "Bearer " + tempToken},
    );
    isLoading = false;
    notifyListeners();

    if (res.statusCode == 200) {
      print("success");
      Map<String, dynamic> resData = jsonDecode(res.body);
      var storage = FlutterSecureStorage();
      storage.write(key: "token", value: tempToken);
      storage.write(key: "refreshToken", value: tempRefreshToken);

      isLogined = true;
      userInfo = parseJwtPayLoad(tempToken)["data"];
      print("SDFASFD");
      notifyListeners();
      return true;
    } else {
      print("failed");
      print(res.body);
      return false;
    }
  }

  void setInputData(key, value) {
    inputData[key] = value;
    notifyListeners();
  }

  var classData = {};

  void setClassData(schoolId) async {
    if (schoolId == "") {
      classData = {};
      setInputData("schoolGrade", null);
      setInputData("schoolClass", null);
      notifyListeners();
    }

    final res = await GET(url: "${currentHost}/schools/class?schoolId=${schoolId}");
    if (res.statusCode == 200) {
      Map<String, dynamic> resData = jsonDecode(res.body);
      classData = resData["data"];
      setInputData("schoolGrade", null);
      setInputData("schoolClass", null);
    } else {}

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
    final res = await http.post(
      url,
      body: jsonEncode(body),
      headers: {"Content-Type": "application/json"},
    );
    isLoading = false;
    notifyListeners();

    return res;
  }

  Future<bool> checkIdDuplicate() async {
    isLoading = true;
    notifyListeners();
    final res = await GET(url: "${currentHost}/students/check-duplicate/id/${inputData["id"]}");
    isLoading = false;
    notifyListeners();

    if (res.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> checkNicknameDuplicate() async {
    final res = await GET(
      url: "${currentHost}/students/check-duplicate/nickname/${inputData["nickname"]}",
    );
    if (res.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

  Future<dynamic> verifySchoolCode() async {
    final res = await GET(
      url: "${currentHost}/schools/code-verify/${inputData["schoolCode"]}",
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
      url: "${currentHost}/schools?schoolName=${search}",
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
      schoolSearchList = [];
      notifyListeners();
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
      "id": inputData["id"],
      "password": inputData["password"],
      "nickname": inputData["nickname"],
      "schoolCode": inputData["schoolCode"],
      "schoolId": inputData["schoolId"],
      "schoolGrade": inputData["schoolGrade"],
      "schoolClass": inputData["schoolClass"]
    };
    if (param["schoolCode"] == "") {
      param.remove("schoolCode");
    }

    final res = await POST(
      url: "${currentHost}/students",
      body: param,
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
    setIsLoading(true);

    var code;
    if (_isKakaoTalkInstalled == true) {
      code = await AuthCodeClient.instance.requestWithTalk();
    } else {
      code = await AuthCodeClient.instance.request();
    }

    var token = await _issueAccessToken(code);
    setIsLoading(false);

    print(token);

    var param = {
      "nickname": inputData["nickname"],
      "schoolCode": inputData["schoolCode"],
      "schoolId": inputData["schoolId"],
      "schoolGrade": inputData["schoolGrade"],
      "schoolClass": inputData["schoolClass"]
    };

    param["accessToken"] = token.accessToken;
    param.remove("schoolName");
    if (param["schoolCode"] == "") {
      param.remove("schoolCode");
    }

    print(inputData);
    final res = await POST(
      url: "${currentHost}/auth/kakao/register",
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

  Future<bool> loginDefault(id, pw) async {
    final res = await POST(
      url: "${currentHost}/auth",
      body: {"id": id, "password": pw},
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
        storage.write(key: "refreshToken", value: resData["refreshToken"]);

        isLogined = true;
        userInfo = parseJwtPayLoad(resData["accessToken"])["data"];
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
      print(token);
      print(code);
      print(token.accessToken);

      final res = await POST(
        url: "${currentHost}/auth/kakao/login",
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
          storage.write(key: "refreshToken", value: resData["refreshToken"]);
          isLogined = true;
          userInfo = parseJwtPayLoad(resData["accessToken"])["data"];
          print("성공");
          notifyListeners();
          return true;
          break;
      }
    } catch (e) {
      print(e);
    }
  }



  Future<bool> kakaoLogin(Map<String, dynamic> data) async {
    print(data);
    final res = await POST(
      url: "${currentHost}/auth/kakao/login",
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
        userInfo = parseJwtPayLoad(token)["data"];
        print(userInfo["nickname"]);
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
  if (token == null) {
    return "";
  }
  return "Bearer " + token;
}

getRefreshToken() async {
  final storage = new FlutterSecureStorage();
  var token = await storage.read(key: "refreshToken");
  if (token == null) {
    return "";
  }
  return "Bearer " + token;
}

getUserInfo() async {
  var token = await getToken();
  var userInfo = parseJwtPayLoad(token)["data"];
  return userInfo;
}


refreshTokenExpired() {
  var storage = FlutterSecureStorage();



  navigatorKey.currentState.popUntil((route) => route.isFirst);

  navigatorKey.currentState.push(MaterialPageRoute(builder: (context) => LoginPage()));
//    Navigator.push(context, MaterialPageRoute(builder: (context) => LoginPage()));

  showCustomDialog(
      context: navigatorKey.currentState.overlay.context,
      title: "로그인 만료!",
      content: "번거로우시겠지만 다시 로그인해주세요!",
      cancelButtonText: null,
      confirmButtonText: "확인",
      confirmButtonAction: () {
        Navigator.pop(navigatorKey.currentState.overlay.context);
      }
  );

  storage.write(key: "token", value: "");
  storage.write(key: "refreshToken", value: "");
  return false;
}



Future<bool> verifyToken() async {
  var storage = FlutterSecureStorage();
  String token = await getToken();
  print(token);

  int exp;
  try {
    exp = parseJwtPayLoad(token)["exp"];
  } on Exception {
    navigatorKey.currentState.popUntil((route) => route.isFirst);

    navigatorKey.currentState.push(MaterialPageRoute(builder: (context) => LoginPage()));
//    Navigator.push(context, MaterialPageRoute(builder: (context) => LoginPage()));
    var storage = FlutterSecureStorage();
    storage.write(key: "token", value: "");
    return false;
  }
  print(exp);

  int now = DateTime.now().toUtc().millisecondsSinceEpoch ~/ 1000;

  print(now);
  if (exp < now) {
    var refreshToken = await getRefreshToken();
    final res = await http.post(
      "${currentHost}/auth/refresh",
      headers: {
        "Content-Type": "application/json",
        "Authorization": refreshToken,
      },
    );

    if (res.statusCode == 200) {
      Map<String, dynamic> resData = jsonDecode(res.body);
      storage.write(key: "token", value: resData["accessToken"]);
      token = resData["accessToken"];

      return true;
    }else{
     refreshTokenExpired();
    }


  }

  return true;
}


postWithToken(url, {body}) async {

  if(! await verifyToken()){
    return null;
  }

  var storage = FlutterSecureStorage();
  String token = await getToken();
  final res = await http.post(
    url,
    body: jsonEncode(body),
    headers: {
      "Content-Type": "application/json",
      "Authorization": token,
    },
  );

  if (res.statusCode == 401) {
    refreshTokenExpired();
    return null;
  }

  return res;
}

getWithToken(url) async {
  if(! await verifyToken()){
    return null;
  }
  var storage = FlutterSecureStorage();
  String token = await getToken();

  final res = await http.get(url, headers: {
    "Authorization": token,
  });

  if (res.statusCode == 401) {
    refreshTokenExpired();
    return null;
  }
  return res;

}

deleteWithToken(url) async {
  if(! await verifyToken()){
    return null;
  }
  var storage = FlutterSecureStorage();
  String token = await getToken();

  final res = await http.delete(url, headers: {
    "Authorization": token,
  });

  if (res.statusCode == 401) {
    refreshTokenExpired();
    return null;
  }
  return res;

}
