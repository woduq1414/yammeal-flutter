
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../color.dart';
import '../font.dart';
import '../asset_path.dart';
import 'package:provider/provider.dart';



class DefaultAppBar extends StatefulWidget implements PreferredSizeWidget {
  DefaultAppBar({this.onActionButtonPressed, this.title, this.backgroundColor});

  var onActionButtonPressed;
  var title;
  var backgroundColor;

  @override
  _DefaultAppBarState createState() =>
      _DefaultAppBarState(onActionButtonPressed, title, backgroundColor);

  @override
  // TODO: implement preferredSize
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}

class _DefaultAppBarState extends State<DefaultAppBar>
    with TickerProviderStateMixin {
  String value;
  var onActionButtonPressed;
  var title;
  var backgroundColor;

  _DefaultAppBarState(_onActionButtonPressed, _title, _backgroundColor) {
    onActionButtonPressed = _onActionButtonPressed;
    title = _title;
    backgroundColor = _backgroundColor;
  }

  int result = 0;

  void calculate(num1, num2) {
    setState(() {
      result = num1 + num2;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      // Here we take the value from the MyHomePage object that was created by
      // the App.build method, and use it to set our appbar title.
      titleSpacing: 0.0,

      backgroundColor: backgroundColor != null ? backgroundColor : navColor,

      centerTitle: true,
      title: _buildDefaultAppBarTitle(),

      elevation: 0.0,
      flexibleSpace: Container(
        decoration: BoxDecoration(),
      ),
      actions: <Widget>[
        _buildDefaultAppBarActionButton(),
        SizedBox(
          width: 30,
        )
      ],
    );
  }

  Widget _buildDefaultAppBarActionButton() {
    Widget temp;
    if (onActionButtonPressed != null) {
      temp = GestureDetector(
        onTap: onActionButtonPressed,
        child: Container(
          alignment: Alignment.center,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text("저장", style: TextStyle(fontSize: 18),),
              SizedBox(width: 3,),
              Icon(
                Icons.check, size: 25,
              )
            ],
          )
        ),
      );
    } else {
      temp = Container();
    }
    return temp;
  }

  Widget _buildDefaultAppBarTitle() {
    Widget temp;
    if (title != null) {
      temp = Text(
        title,
        textAlign: TextAlign.center,
        style: TextStyle(
            fontSize: 18, fontWeight: FontWeight.bold),
      );
    } else {

      temp = Container();


    }
    return temp;
  }
}

