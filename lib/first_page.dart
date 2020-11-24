
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:meal_flutter/common/color.dart';
import 'package:meal_flutter/common/font.dart';
import 'package:meal_flutter/common/widgets/loading.dart';
import 'package:meal_flutter/login_page.dart';

import './common/provider/userProvider.dart';
import 'UIs/main_page.dart';
import 'common/route_transition.dart';

class FirstPage extends StatefulWidget {
  @override
  _FirstPageState createState() => _FirstPageState();
}

FontSize fs;

class _FirstPageState extends State<FirstPage> {
  final _idController = TextEditingController();
  final _passwordController = TextEditingController();

  var _isLogined = null;

  void getIsLogined() async {
    var storage = FlutterSecureStorage();
    String token = await getToken();
    int exp;

    try{
      exp = parseJwtPayLoad(token)["exp"];
    }on Exception {
      setState(() {
        _isLogined = false;
        Navigator.push(
          context,
          FadeRoute(page: LoginPage()),
        );
      });
      return;
    }


    int now = (DateTime.now().millisecondsSinceEpoch / 1000).toInt();

    if (exp >= now) {
      setState(() {
        _isLogined = true;
        Navigator.push(
          context,
          FadeRoute(page: MealState()),
        );
      });
    } else {
      setState(() {
        _isLogined = false;
        Navigator.push(
          context,
          FadeRoute(page: LoginPage()),
        );
      });
    }
  }

  @override
  void initState() {
    getIsLogined();
    SchedulerBinding.instance.addPostFrameCallback((_) {
    });
  }

  @override
  Widget build(BuildContext context) {
    fs = FontSize(context);

    return Scaffold(
        backgroundColor: primaryYellow,
        body: Center(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              "YAMMEAL",
              style: TextStyle(
                fontSize: fs.s2,
                fontWeight: Font.bold,
                letterSpacing: 8,
              ),
            ),
            SizedBox(
              height: 30,
            ),
            CustomLoading(),
          ],
        )));
  }
}
