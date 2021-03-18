
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:meal_flutter/common/color.dart';
import 'package:meal_flutter/common/font.dart';
import 'package:meal_flutter/common/widgets/loading.dart';
import 'package:meal_flutter/pages/login_page.dart';

import 'package:meal_flutter/common/provider/userProvider.dart';
import 'main_page.dart';
import 'package:meal_flutter/common/route_transition.dart';

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

    if(! await verifyToken()){
     return null;
    }else{
      setState(() {
        _isLogined = true;
        Navigator.push(
          context,
          FadeRoute(page: MealState()),
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
