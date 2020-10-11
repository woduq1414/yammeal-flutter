import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';


class MealSurvey extends StatefulWidget {
  @override
  _MealSurveyState createState() => _MealSurveyState();
}

class _MealSurveyState extends State<MealSurvey> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(child: Text('설문조사를 해보자')),
    );
  }
}
