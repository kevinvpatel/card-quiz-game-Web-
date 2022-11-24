import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:swipecard_app/constants/constants.dart';
import 'package:swipecard_app/controllers/splash_controller.dart';
import 'package:swipecard_app/screen/home_screen.dart';
import 'package:swipecard_app/screen/result_screen.dart';
import 'package:swipecard_app/service/api_response.dart';
import 'package:timezone/data/latest.dart' as tz;

class SplashScreen extends StatefulWidget {
  final bool isClearAll;

  SplashScreen({Key? key, bool? isClearAll})
      : isClearAll = isClearAll ?? false;

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  User? user;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  SplashController splashController = Get.put(SplashController());


  Future<User> skipSignin() async {
    try {
      splashController.resultBox = await Hive.openBox('Result_Hive');
      splashController.timerBox = await Hive.openBox('Timer_Hive');
      final userHive = await Hive.openBox('user_hive');

      print(' ');
      print('_auth.currentUser -> ${_auth.currentUser}');
      print(' ');
      print('userHive.values -> ${userHive.values}');
      print(' ');
      if(userHive.values.isNotEmpty) {
        if(userHive.values.first['email'] != 'demo@pingoo.app') {
          user = _auth.currentUser;
          print('user 1 -> $user');
          print(' ');
        } else {
          UserCredential credential =  await _auth.signInWithEmailAndPassword(
              email: 'demo@pingoo.app', password: 'Pingoo2020!'
          );
          user = credential.user;
          print('user 2 -> ${user}');
          print(' ');
        }
      } else {
        UserCredential credential =  await _auth.signInWithEmailAndPassword(
            email: 'demo@pingoo.app', password: 'Pingoo2020!'
        );
        user = credential.user;
      }
      print('user @@@@ -> ${user}');
      print(' ');

      if(_auth.currentUser != null) {
        user = _auth.currentUser;
        print('user 1 -> $user');
      } else {
        UserCredential credential =  await _auth.signInWithEmailAndPassword(
            email: 'demo@pingoo.app', password: 'Pingoo2020!'
        );
        user = credential.user;
        print('user 2 -> ${user}');
      }

      splashController.resultBox?.values.forEach((element) {
        lstAnswer.add(element == 'true' ? Answer.right : Answer.wrong);
      });

      return user!;
    } on FirebaseException catch (err) {
      print('signin with email error 1111 -> $err');
      alert(err.message!, context);
      return user!;
    }
  }


  int? diffSeconds;
  List<Answer> lstAnswer = [];

  @override
  void initState() {
    super.initState();
    tz.initializeTimeZones();

    Future.delayed(const Duration(milliseconds: 1), () {
      skipSignin().then((_) {
        storeUserToLocal(user: user!);
        splashController.checkIfVersionMatch(isClearAll: widget.isClearAll, auth: _auth);
          splashController.todaysTopic(user: user!).then((mapTopic) {
            splashController.hoursCheck().then((isQuizEnable) {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                if(isQuizEnable) {
                  print(' ');
                  print('mapTopic SplashScreen @@@ -> $mapTopic');
                  print(' ');
                  return HomeScreen(user: user!, mapTopic: mapTopic);
                } else {
                  // DateTime dtTime = DateFormat('yyyy-MM-dd HH:mm:ss').parse(splashController.timerBox?.values.first);
                  DateTime currentDt = DateTime.now();
                  DateTime EndTime = DateFormat('yyyy-MM-dd HH:mm:ss').parse(splashController.timerBox?.values.last);
                  print('difference SplashScreen @@@ -> ${EndTime.difference(currentDt)}');
                  int diffSeconds = EndTime.difference(currentDt).inSeconds;

                  return ResultScreen(
                    seconds: diffSeconds,
                    topicName: mapTopic['title'],
                    isRewardPlay: false,
                    cardLength: 10,
                    lstRecord: lstAnswer,
                  );
                }
              }));
            });
          });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // double width = 390;
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            alignment: Alignment.center,
            height: height,
            width: width,
            color: const Color.fromRGBO(255, 58, 0, 1),
            child: Image.asset('assets/icons/splashscreen/pingoo1.png',
            height: 390 * 0.7, width: 390),
          ),
        ],
      ),
    );
  }
}
