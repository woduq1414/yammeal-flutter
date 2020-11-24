
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';

import './common/color.dart';
import './common/provider/userProvider.dart';
import './common/widgets/appbar.dart';
import 'common/font.dart';
import 'common/provider/userProvider.dart';
import 'common/widgets/appbar.dart';
import 'common/widgets/dialog.dart';
import 'common/widgets/loading.dart';

final scaffoldKey = GlobalKey<ScaffoldState>();
final scaffoldKey2 = GlobalKey<ScaffoldState>();
final scaffoldKey3 = GlobalKey<ScaffoldState>();
FontSize fs;

class SetAllergyPage extends StatefulWidget {
  @override
  _SetAllergyPageState createState() => _SetAllergyPageState();
}

class _SetAllergyPageState extends State<SetAllergyPage> {
  List<String> alg_list = [
    "난류(가금류)",
    "우유",
    "메밀",
    "땅콩",
    "대두",
    "밀",
    "고등어",
    "게",
    "새우",
    "돼지고기",
    "복숭아",
    "토마토",
    "아황산염",
    "호두",
    "닭고기",
    "쇠고기",
    "오징어",
    "조개류"
  ];
  List<bool> checked_alg = List.generate(20, (_) => false);

  getAlgFromStorage() async {
    var storage = FlutterSecureStorage();
    var saved_list = await storage.read(key: "algList");
    if(saved_list == null){
      return;
    }
    for(var i in saved_list.split(",")){
      setState(() {
        checked_alg[int.parse(i)] = true;
      });
    }
  }


  @override
  void initState() {

    getAlgFromStorage();
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

    return WillPopScope(
      onWillPop: () async {

        showCustomDialog(
            context: context,
            title: "돌아가시겠어요?",
            content : "저장하지 않으면 적용되지 않습니다.",
            cancelButtonText: "취소",
            confirmButtonText: "나가기",
            cancelButtonAction: () {
              Navigator.pop(context);
            },
            confirmButtonAction: () {
              Navigator.pop(context);
              Navigator.pop(context);
            });

        return true;
      }
      ,
      child: LoadingModal(
        child: Scaffold(
            key: scaffoldKey,
            appBar: DefaultAppBar(
              onActionButtonPressed: () async {
                var storage = FlutterSecureStorage();

                List<int> temp = [];
                for(int i = 0 ; i < checked_alg.length ; i ++){
                  if(checked_alg[i] == true){
                    temp.add(i);
                  }
                }

                storage.write(key: "algList", value: temp.join(","));

                Navigator.pop(context);
                showCustomAlert(
                  context: context,
                  isSuccess: true,
                  title: "저장 완료!",
                  duration: Duration(seconds: 1),
                );
    


              },
            ),
            body: Container(
              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 8),
              child: Column(
                children: <Widget>[
                  SizedBox(
                    height: 20,
                  ),
                  Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "본인의 알레르기에 체크해주세요.",
                        style: TextStyle(fontSize: 25),
                      )),
                  Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "기기에만 저장됩니다.",
                        style: TextStyle(fontSize: 18),
                      )),
                  SizedBox(
                    height: 10,
                  ),
                  Expanded(
                    child: ListView(
                        children: alg_list.map((alg) {
                      int alg_id = alg_list.indexOf(alg) + 1;
                      return Container(
                        margin: EdgeInsets.only(bottom: 5, top: 5),
                        child: Material(
                          color: cardColor,
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                checked_alg[alg_id] = !checked_alg[alg_id];
                              });
                            },
                            child: Container(


                              padding: EdgeInsets.only(left: 5, right: 5),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  Flexible(
                                      child: Text(
                                    alg,
                                    style: TextStyle(fontSize: fs.s6),
                                  )),
                                  Checkbox(
                                    activeColor: primaryRedDark,
                                    value: checked_alg[alg_id],
                                    onChanged: (bool value) {
                                      setState(() {
                                        checked_alg[alg_id] = !checked_alg[alg_id];
                                      });
                                    },
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList()),
                  )
                ],
              ),
            )),
      ),
    );
  }
}
