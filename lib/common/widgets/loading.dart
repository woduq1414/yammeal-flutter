import 'package:flutter/material.dart';
import 'package:meal_flutter/common/provider/mealProvider.dart';
import 'package:meal_flutter/common/provider/userProvider.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import '../color.dart';
import '../font.dart';
import '../asset_path.dart';
import 'package:provider/provider.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';


class LoadingModal extends StatelessWidget {

  Widget child;

  LoadingModal({this.child});


  @override
  Widget build(BuildContext context) {
    UserStatus userStatus = Provider.of<UserStatus>(context);
    return  ModalProgressHUD(
      child: child,
      inAsyncCall: userStatus.isLoading,
      progressIndicator: CircularProgressIndicator(),
      opacity: 0.2,
    );
  }
}

class LoadingMealModal extends StatelessWidget {

  Widget child;

  LoadingMealModal({this.child});


  @override
  Widget build(BuildContext context) {
    MealStatus mealStatus = Provider.of<MealStatus>(context);
    return ModalProgressHUD(
      child: child,
      inAsyncCall: mealStatus.isLoading,
      progressIndicator: CircularProgressIndicator(),
      opacity: 0.2,
    );
  }
}



Widget CircularLoading(){
  return CircularProgressIndicator(
    valueColor: AlwaysStoppedAnimation<Color>(primaryYellow),
  );
}

Widget CustomLoading() {
  return Container(
    margin: EdgeInsets.all(15),
    child: SpinKitThreeBounce(
      color: Colors.white,
      size: 35.0,
    ),
  );
}