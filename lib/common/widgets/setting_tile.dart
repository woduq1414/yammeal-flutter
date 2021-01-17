import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../color.dart';
import '../font.dart';

class SettingTile extends StatelessWidget {
  String title;
  String description;

  bool isUseRightButton;
  var rightButtonOnPressed;
  String rightButtonText;

  bool rightSwitchValue;
  var rightSwitchOnChanged;

  SettingTile({this.title, this.description, this.isUseRightButton, this.rightButtonOnPressed, this.rightButtonText,
      this.rightSwitchValue, this.rightSwitchOnChanged});

  @override
  Widget build(BuildContext context) {
    FontSize fs = FontSize(context);

    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                title,
                style: TextStyle(fontSize: fs.s6),
              ),
              description != null ? Text(
                description,
                style: TextStyle(fontSize: fs.s7),
              ) : Container()
            ],
          ),

          isUseRightButton == true ?
          RaisedButton(
            color: primaryRedDark,
            onPressed: rightButtonOnPressed,
            child: Text(
              rightButtonText,
              style: TextStyle(fontSize: fs.s7),
            ),
          )
              :
          Switch(
            value: rightSwitchValue,
            onChanged: (value) {
              rightSwitchOnChanged(value);
            },
            activeTrackColor: primaryRed,
            activeColor: primaryRedDark,
          ),
        ],
      ),
    );
  }
}
