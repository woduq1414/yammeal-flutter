import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'common/font.dart';
import 'common/provider/mealProvider.dart';
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
import 'login_page.dart';

import "common/func.dart";

final scaffoldKey = GlobalKey<ScaffoldState>();
final scaffoldKey2 = GlobalKey<ScaffoldState>();
final scaffoldKey3 = GlobalKey<ScaffoldState>();
FontSize fs;

class FindAllFavoritePage extends StatefulWidget {
//  bool isKakao;
//
//  FindPasswordPage({this.isKakao});

  @override
  _FindAllFavoritePageState createState() => _FindAllFavoritePageState();
}

class _FindAllFavoritePageState extends State<FindAllFavoritePage> {
//  bool isKakao;
//
//  _FindPasswordPageState(bool _isKakao) {
//    isKakao = _isKakao;
//  }

  List _favoriteList;
  bool _isGetFavorite = false;

  getAllFavorite() async {
    http.Response res = await getWithToken('${currentHost}/meals/rating/favorite-all');
    print(res.statusCode);
    if (res.statusCode == 200) {
//      print(jsonDecode(res.body));
      print(jsonDecode(res.body));

      var jsonBody = jsonDecode(res.body)["data"];
      setState(() {
        _isGetFavorite = true;
        _favoriteList = jsonBody;
      });

      print(_favoriteList.length);

      return;
    } else {
      setState(() {
        _isGetFavorite = true;
      });
      return;
    }
  }

  @override
  void initState() {
    super.initState();
    _favoriteList = [];
    getAllFavorite();
  }

  Iterable<E> mapIndexed<E, T>(Iterable<T> items, E Function(int index, T item) f) sync* {
    var index = 0;

    for (final item in items) {
      yield f(index, item);
      index = index + 1;
    }
  }

  @override
  Widget build(BuildContext context) {
    fs = FontSize(context);

    UserStatus userStatus = Provider.of<UserStatus>(context);
    MealStatus mealStatus = Provider.of<MealStatus>(context);
    return WillPopScope(
      onWillPop: () async {
        return true;
      },
      child: ModalProgressHUD(
        inAsyncCall: !_isGetFavorite,
        child: LoadingMealModal(
          child: Scaffold(
              key: scaffoldKey,
              appBar: DefaultAppBar(
                title: "즐겨찾기 음식",
              ),
              body: Container(
                  padding: EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                  child: _isGetFavorite
                      ? (_favoriteList.length > 0
                          ? Column(
                              children: <Widget>[
                                // SizedBox(
                                //   height: 20,
                                // ),
                                // Align(
                                //     alignment: Alignment.centerLeft,
                                //     child: Text(
                                //       "본인의 알레르기에 체크해주세요.",
                                //       style: TextStyle(fontSize: 25),
                                //     )),
                                // Align(
                                //     alignment: Alignment.centerLeft,
                                //     child: Text(
                                //       "기기에만 저장됩니다.",
                                //       style: TextStyle(fontSize: 18),
                                //     )),
                                // SizedBox(
                                //   height: 10,
                                // ),
                                Expanded(
                                  child: ListView(
                                      children: _favoriteList.map((menu) {
                                    // int alg_id = fa.indexOf(alg) + 1;
                                    return Container(
                                        margin: EdgeInsets.only(bottom: 5, top: 5),
                                        child: Dismissible(
                                          key: Key(menu),
                                          onDismissed: (direction) async {
                                            setState(() {
                                              _favoriteList.remove(menu);
                                            });
                                            mealStatus.setIsLoading(true);
                                            http.Response res = await deleteWithToken(
                                                '${currentHost}/meals/rating/favorite?menuName=${Uri.encodeComponent(menu)}');
                                            mealStatus.setIsLoading(false);
                                            print('딜리트');
                                            print(res.statusCode);
                                            if (res.statusCode == 200) {
                                              print('딜리트 성공');
                                            } else {}
                                          },
                                          child: Container(
                                            padding: EdgeInsets.symmetric(vertical: 0, horizontal: 5),
                                            decoration: BoxDecoration(
                                                color: cardColor, borderRadius: BorderRadius.all(Radius.circular(5))),
                                            child: ListTile(
                                                title: Container(
                                                    child: Text(
                                              menu,
                                              style: TextStyle(fontSize: fs.s6),
                                            ))),
                                          ),
                                          background: Container(
                                              alignment: Alignment.center,
                                              color: Colors.red,
                                              child: Row(
                                                children: <Widget>[
                                                  SizedBox(
                                                    width: 10,
                                                  ),
                                                  Icon(
                                                    Icons.delete,
                                                    color: Colors.white,
                                                  ),
                                                  Text(
                                                    "삭제",
                                                    style: TextStyle(fontSize: fs.s7, color: Colors.white),
                                                  )
                                                ],
                                              )),
                                        ));
                                  }).toList()),
                                )
                              ],
                            )
                          : Container(
                              alignment: Alignment.center,
                              child: Text(
                                "즐겨찾기한 메뉴가 없어요 !",
                                style: TextStyle(fontSize: fs.s6, color: Colors.black),
                              )))
                      : Container())),
        ),
      ),
    );
  }
}
