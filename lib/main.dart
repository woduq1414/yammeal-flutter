import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:meal_flutter/common/color.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:kakao_flutter_sdk/auth.dart';
import 'package:kakao_flutter_sdk/user.dart';
import 'package:http/http.dart' as http;
import 'package:meal_flutter/common/provider/mealProvider.dart';
import "package:meal_flutter/common/font.dart";

import 'package:modal_progress_hud/modal_progress_hud.dart';

import 'package:provider/provider.dart';

import './common/provider/userProvider.dart';
import 'UIs/main_page.dart';
import 'UIs/servey_page.dart';
import 'common/route_transition.dart';

import 'login_page.dart';
import 'first_page.dart';
import 'kakao_register_page.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_crashlytics/firebase_crashlytics.dart';

class MyHttpOverrides extends HttpOverrides{
  @override
  HttpClient createHttpClient(SecurityContext context){
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port)=> true;
  }
}

// and to test that runZonedGuarded() catches the error
final _kShouldTestAsyncErrorOnInit = false;

// Toggle this for testing Crashlytics in your app locally.
final _kTestingCrashlytics = true;

void main() async{

  // Crashlytics.instance.enableInDevMode = true;

  // // Pass all uncaught errors to Crashlytics.
  // FlutterError.onError = Crashlytics.instance.recordFlutterError;
  // WidgetsFlutterBinding.ensureInitialized();
  // SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.bottom]).then((_) {
  //   SharedPreferences.getInstance().then((prefs) {
  //     var darkModeOn = prefs.getBool('darkMode') ?? true;
  //     runZoned(() {
  //       runApp(ChangeNotifierProvider<ThemeNotifier>(
  //         create: (_) => ThemeNotifier(darkModeOn ? darkTheme : lightTheme),
  //         child: MyApp(),
  //       ));
  //     }, onError: Crashlytics.instance.recordError);
  //   });
  // });

  WidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = new MyHttpOverrides();

  runZonedGuarded(() {
    runApp(MyApp());
  }, (error, stackTrace) {
    print('runZonedGuarded: Caught error in my root zone.');
    FirebaseCrashlytics.instance.recordError(error, stackTrace);
  });



}
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  Future<void> _initializeFlutterFireFuture;

  Future<void> _testAsyncErrorOnInit() async {
    Future<void>.delayed(const Duration(seconds: 2), () {
      final List<int> list = <int>[];
      print(list[100]);
    });
  }

  // Define an async function to initialize FlutterFire
  Future<void> _initializeFlutterFire() async {
    // Wait for Firebase to initialize
    await Firebase.initializeApp();

    if (_kTestingCrashlytics) {
      // Force enable crashlytics collection enabled if we're testing it.
      await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
    } else {
      // Else only enable it in non-debug builds.
      // You could additionally extend this to allow users to opt-in.
      await FirebaseCrashlytics.instance
          .setCrashlyticsCollectionEnabled(!kDebugMode);
    }

    // Pass all uncaught errors to Crashlytics.
    Function originalOnError = FlutterError.onError;
    FlutterError.onError = (FlutterErrorDetails errorDetails) async {
      await FirebaseCrashlytics.instance.recordFlutterError(errorDetails);
      // Forward to original handler.
      originalOnError(errorDetails);
    };

    if (_kShouldTestAsyncErrorOnInit) {
      await _testAsyncErrorOnInit();
    }
  }

  @override
  void initState() {
    super.initState();
    _initializeFlutterFireFuture = _initializeFlutterFire();
  }



  // @override
  // Widget build(BuildContext context) {
  //   return MaterialApp(
  //     home: Scaffold(
  //       appBar: AppBar(
  //         title: const Text('Crashlytics example app'),
  //       ),
  //       body: FutureBuilder(
  //         future: _initializeFlutterFireFuture,
  //         builder: (context, snapshot) {
  //           switch (snapshot.connectionState) {
  //             case ConnectionState.done:
  //               if (snapshot.hasError) {
  //                 return Center(
  //                   child: Text('Error: ${snapshot.error}'),
  //                 );
  //               }
  //               return Center(
  //                 child: Column(
  //                   children: <Widget>[
  //                     RaisedButton(
  //                         child: const Text('Key'),
  //                         onPressed: () {
  //                           FirebaseCrashlytics.instance
  //                               .setCustomKey('example', 'flutterfire');
  //                           Scaffold.of(context).showSnackBar(SnackBar(
  //                             content: Text(
  //                                 'Custom Key "example: flutterfire" has been set \n'
  //                                     'Key will appear in Firebase Console once app has crashed and reopened'),
  //                             duration: Duration(seconds: 5),
  //                           ));
  //                         }),
  //                     RaisedButton(
  //                         child: const Text('Log'),
  //                         onPressed: () {
  //                           FirebaseCrashlytics.instance
  //                               .log('This is a log example');
  //                           Scaffold.of(context).showSnackBar(SnackBar(
  //                             content: Text(
  //                                 'The message "This is a log example" has been logged \n'
  //                                     'Message will appear in Firebase Console once app has crashed and reopened'),
  //                             duration: Duration(seconds: 5),
  //                           ));
  //                         }),
  //                     RaisedButton(
  //                         child: const Text('Crash'),
  //                         onPressed: () async {
  //                           Scaffold.of(context).showSnackBar(SnackBar(
  //                             content: Text('App will crash is 5 seconds \n'
  //                                 'Please reopen to send data to Crashlytics'),
  //                             duration: Duration(seconds: 5),
  //                           ));
  //
  //                           // Delay crash for 5 seconds
  //                           sleep(const Duration(seconds: 5));
  //
  //                           // Use FirebaseCrashlytics to throw an error. Use this for
  //                           // confirmation that errors are being correctly reported.
  //                           FirebaseCrashlytics.instance.crash();
  //                         }),
  //                     RaisedButton(
  //                         child: const Text('Throw Error'),
  //                         onPressed: () {
  //                           Scaffold.of(context).showSnackBar(SnackBar(
  //                             content: Text('Thrown error has been caught \n'
  //                                 'Please crash and reopen to send data to Crashlytics'),
  //                             duration: Duration(seconds: 5),
  //                           ));
  //
  //                           // Example of thrown error, it will be caught and sent to
  //                           // Crashlytics.
  //                           throw StateError('Uncaught error thrown by app');
  //                         }),
  //                     RaisedButton(
  //                         child: const Text('Async out of bounds'),
  //                         onPressed: () {
  //                           Scaffold.of(context).showSnackBar(SnackBar(
  //                             content: Text(
  //                                 'Uncaught Exception that is handled by second parameter of runZonedGuarded \n'
  //                                     'Please crash and reopen to send data to Crashlytics'),
  //                             duration: Duration(seconds: 5),
  //                           ));
  //
  //                           // Example of an exception that does not get caught
  //                           // by `FlutterError.onError` but is caught by
  //                           // `runZonedGuarded`.
  //                           runZonedGuarded(() {
  //                             Future<void>.delayed(const Duration(seconds: 2),
  //                                     () {
  //                                   final List<int> list = <int>[];
  //                                   print(list[100]);
  //                                 });
  //                           }, FirebaseCrashlytics.instance.recordError);
  //                         }),
  //                     RaisedButton(
  //                         child: const Text('Record Error'),
  //                         onPressed: () async {
  //                           try {
  //                             Scaffold.of(context).showSnackBar(SnackBar(
  //                               content: Text('Recorded Error  \n'
  //                                   'Please crash and reopen to send data to Crashlytics'),
  //                               duration: Duration(seconds: 5),
  //                             ));
  //                             throw 'error_example';
  //                           } catch (e, s) {
  //                             // "reason" will append the word "thrown" in the
  //                             // Crashlytics console.
  //                             await FirebaseCrashlytics.instance
  //                                 .recordError(e, s, reason: 'as an example');
  //                           }
  //                         }),
  //                   ],
  //                 ),
  //               );
  //               break;
  //             default:
  //               return Center(child: Text('Loading'));
  //           }
  //         },
  //       ),
  //     ),
  //   );
  // }


  @override
  Widget build(BuildContext context) {

    KakaoContext.clientId = '39d6c43a0a346cca6ebc7b2dbb8e4353';
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    return MultiProvider(
        providers: [
          ChangeNotifierProvider<UserStatus>(create: (_) => UserStatus()),
          ChangeNotifierProvider<MealStatus>(create: (_) => MealStatus()),
        ],
        child: MaterialApp(
          navigatorKey: navigatorKey,
          title: 'YAMMEAL',
          theme: ThemeData(
              fontFamily: "GmarketSans",
              primaryColor: primaryRed,
              accentColor: primaryRedDark

            // This is the theme of your application.
            //
            // Try running your application with "flutter run". You'll see the
            // application has a blue toolbar. Then, without quitting the app, try
            // changing the primarySwatch below to Colors.green and then invoke
            // "hot reload" (press "r" in the console where you ran "flutter run",
            // or simply save your changes to "hot reload" in a Flutter IDE).
            // Notice that the counter didn't reset back to zero; the application
            // is not restarted.

          ),
          home: FirstPage(),

        ));
  }
}
