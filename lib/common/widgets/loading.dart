import 'package:flutter/material.dart';
import 'package:meal_flutter/common/provider/userProvider.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import '../color.dart';
import '../font.dart';
import '../asset_path.dart';
import 'package:provider/provider.dart';

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
