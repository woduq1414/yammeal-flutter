import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:meal_flutter/UIs/servey_page.dart';
import 'package:meal_flutter/common/asset_path.dart';
import 'package:meal_flutter/common/provider/mealProvider.dart';
import 'package:meal_flutter/common/provider/userProvider.dart';
import 'package:provider/provider.dart';
import 'package:speech_bubble/speech_bubble.dart';
import 'dart:math' as math;

import 'package:date_format/date_format.dart';
import 'package:http/http.dart' as http;


class FontSize{
  BuildContext context;
  double deviceWidth;

  double s1;
  double s2;
  double s3;
  double s4;
  double s5;
  double s6;
  double s7;
  double s8;


  FontSize(_context){
    context = _context;
    deviceWidth = MediaQuery.of(context).size.width;
    s1 = deviceWidth * 0.1;
    s2 = deviceWidth * 0.09;
    s3 = deviceWidth * 0.08;
    s4 = deviceWidth * 0.07;
    s5 = deviceWidth * 0.06;
    s6 = deviceWidth * 0.05;
    s7 = deviceWidth * 0.04;
    s8 = deviceWidth * 0.035;


  }



//  double s1(){
//    return ;
//  }
}

