import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:swipecard_app/constants/constants.dart';
import 'package:swipecard_app/controllers/analytics_controller.dart';
import 'package:swipecard_app/screen/splash_screen.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();

  await Firebase.initializeApp(
      options: const FirebaseOptions(
          apiKey: "AIzaSyAK_j8r7l6hHbn-y2vd3KuPU5KVeQ9JFB0",
          appId: "1:605460580335:web:966381d7d76d81448cd81a",
          messagingSenderId: "605460580335",
          projectId: "innovearn",
          authDomain: "innovearn.firebaseapp.com",
          storageBucket: "innovearn.appspot.com",
          measurementId: "G-HKR0Y51DH4"
      )
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  String? uid;
  String? name;
  String? userEmail;
  String? imageUrl;

  // SharedPreferences? prefs;
  // getUserDetails() async {
  //   prefs = await SharedPreferences.getInstance();
  //   prefs?.getString('uid');
  //   prefs?.getString('name');
  //   prefs?.getString('userEmail');
  //   prefs?.getString('imageUrl');
  // }

  AnalyticsController analyticsController = Get.put(AnalyticsController());

  @override
  Widget build(BuildContext context) {
    // getUserDetails();

    return GetMaterialApp(
      title: 'Pingoo web',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Quicksand',
        splashColor: pinkSplashColor,
        hoverColor: Colors.pinkAccent.withOpacity(0.4),
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: orangeThemeColor
        ),
      ),
      navigatorObservers: <NavigatorObserver>[analyticsController.observer],
      home: SplashScreen()
    );
  }
}
