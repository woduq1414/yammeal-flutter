import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class UnderNextButton extends StatelessWidget {
  String text;

  double textSize;

  var onTap;
  Color textColor;
  Color primeColor;
  double borderRadius;

  bool isRaised;

  var disabled;

  UnderNextButton(
      {this.text,
        this.onTap,
        this.textColor,
        this.primeColor,
        this.isRaised = true,
        this.borderRadius = 10,
        this.textSize = 18,
        this.disabled});

  @override
  Widget build(BuildContext context) {
    if (disabled == null) {
      disabled = () {
        return false;
      };
    }

    return Material(
      color: isRaised ? (!disabled() ? primeColor : Colors.grey) : Colors.white,
      borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
      child: InkWell(
        borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
        onTap: !disabled() ? onTap : null,
        child: Container(
          height: 50,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: !isRaised
                ? Border.all(
              color: !disabled() ? primeColor : Colors.grey,
              width: 1,
            )
                : null,
            borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
          ),
          child: Text(
            text,
            style: TextStyle(fontSize: textSize, color: textColor),
          ),
        ),
      ),
    );
  }
}