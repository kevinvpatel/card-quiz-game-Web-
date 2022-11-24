import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:swipecard_app/screen/home_screen.dart';
import 'package:swipecard_app/service/api_response.dart';

class SplashController extends GetxController {

  Box? timerBox;
  Box? resultBox;

  Future<bool> hoursCheck() async {
    timerBox = await Hive.openBox('Timer_Hive');
    final dt = DateTime.now();

    try {
      if(timerBox!.values.isNotEmpty) {
        ///from this we will get last played time
        DateTime dtTime = DateFormat('yyyy-MM-dd HH:mm:ss').parse(timerBox?.values.first);
        DateTime EndTime = DateFormat('yyyy-MM-dd HH:mm:ss').parse(timerBox?.values.last);

        print('  ');
        print(' >>>>>>>>>>>>>>>>>');
        print('dtTime SplashScreen -> $dtTime');
        print('EndTime SplashScreen -> $EndTime');
        print(' <<<<<<<<<<<<<<<<<');
        print('  ');

        if(dt.isAfter(EndTime)) {
          print(' is After ');
          print(' dt 1-> $dt ');
          print(' EndTime 1-> $EndTime ');
        } else {
          print(' isBefore ');
          print(' dt 2-> $dt ');
          print(' EndTime 2-> $EndTime ');
        }
        return dt.isAfter(EndTime) ? true : false;
        // return true;
      } else {
        return true;
      }
    } catch (err) {
      print('timerBox err SplashScreen -> $err');
      return false;
    }

  }



  Future<Map<String, dynamic>> todaysTopic({required User user}) async {
    Map<String, String> mapShuffle;
    Map<String, dynamic> mapDate;
    final dt = DateTime.now();
    final topicBox = await Hive.openBox('Topic_Box');

    final lstMap = await randomTopicNameApi(user: user);
    mapShuffle = lstMap[DateTime.now().day];
    print('mapShuffle @@@ -> $mapShuffle');

    if(topicBox.values.isEmpty) {
      final targetTime1 = await getDestineTimeOfUser(
          destineTime: DateTime(dt.year, dt.month, dt.day, 21, 30)
      );
      mapDate = {'targetTime' : targetTime1, 'title' : mapShuffle['title'], 'id' : mapShuffle['id'], 'previousTime' : DateTime.now()};
      print('mapDate 1 SplashScreen @@@ -> $mapDate');

      topicBox.put(0, mapDate);
    } else {
      final targetTime = await getDestineTimeOfUser(
          destineTime: DateTime(dt.year, dt.month, dt.day, 21, 30)
      );

      DateTime currenttTime = DateTime(dt.year, dt.month, dt.day, dt.hour, dt.minute);
      print('targetTime SplashScreen @@@ -> $targetTime');
      print('currenttTime SplashScreen @@@ -> $currenttTime');

      print('=============> ');
      print('topicBox.values -> ${topicBox.values.first}');

      if(currenttTime.isBefore(targetTime)) {
        DateTime previousTime = topicBox.values.first['previousTime'];
        print(' ');
        print('previousTime.day -> ${previousTime.day}');
        print('targetTime.day -> ${targetTime.day}');
        print(' ');

        if(previousTime.day < targetTime.day) {
          mapShuffle = lstMap[targetTime.day];
          mapDate = {
            'targetTime' : targetTime,
            'title' : mapShuffle['title'],
            'id' : mapShuffle['id'],
            'previousTime' : DateTime.now()
          };
        } else {

          ///juno topic avse
          mapDate = {
            'targetTime' : targetTime,
            'title' : topicBox.values.first['title'],
            'id' : topicBox.values.first['id'],
            'previousTime' : DateTime.now()
          };
        }

        print('mapDate 2 SplashScreen @@@ -> $mapDate');
        topicBox.putAt(0, mapDate);
      } else {
        final targetTime1 = await getDestineTimeOfUser(
            destineTime: DateTime(dt.year, dt.month, dt.day+1, 21, 30)
        );
        mapShuffle = lstMap[targetTime1.day];
        mapDate = {
          'targetTime' : targetTime1,
          'title' : mapShuffle['title'],
          'id' : mapShuffle['id'],
          'previousTime' : DateTime.now()
        };
        print('mapDate 3 SplashScreen @@@ -> $mapDate');
        topicBox.putAt(0, mapDate);
      }
    }
    print('today topic id -> ${mapDate['id']}  |  name -> ${mapDate['title']}');
    return mapDate;
  }



  ///increase version everytime you make change in code and deploy
  checkIfVersionMatch({required FirebaseAuth auth, required bool isClearAll}) async {
    final resultBox = await Hive.openBox('Result_Hive');
    final topicBox = await Hive.openBox('Topic_Box');
    final timerBox = await Hive.openBox('Timer_Hive');
    final questionBox = await Hive.openBox('Questions_Hive');
    final percentageBox = await Hive.openBox('Percentage_Hive');
    final totalBox = await Hive.openBox('Total_Hive');
    final versionBox = await Hive.openBox('Version_Hive');

    final checkVersion = versionBox.get(0);
    print('checkVersion -> $checkVersion');


    // if(auth.currentUser != null || auth.currentUser?.email != 'demo@pingoo.app') {
    //   resultBox.clear();
    //   topicBox.clear();
    //   timerBox.clear();
    //   questionBox.clear();
    //   percentageBox.clear();
    //   totalBox.clear();
    //   ///version_hive
    //   ///percentage_hive
    //   ///questions_hive
    //   ///result_hive
    //   ///timer_hive
    //   ///topic_box
    //   ///total_hive
    //
    //   DocumentSnapshot snapshot = await FirebaseFirestore.instance.collection('Users').doc(auth.currentUser?.uid).get();
    //   print('auth.currentUser?.uid SplashController -> ${auth.currentUser?.uid}');
    //
    //   if(snapshot.data() != null) {
    //     Map<String, dynamic> lst = snapshot.data() as Map<String, dynamic>;
    //
    //     timerBox.put('QuizPlayedTime', lst['timer_hive'].first);
    //     timerBox.put('QuizTargetTime', lst['timer_hive'].last);
    //
    //     totalBox.put('totalPlays', lst['total_hive'].first);
    //     totalBox.put('totalScore', lst['total_hive'].last);
    //
    //     lst['percentage_hive'].forEach((e) {
    //       percentageBox.add(e);
    //     });
    //
    //     lst['questions_hive'].forEach((e) {
    //       questionBox.add(e);
    //     });
    //
    //     Map mapTopic = {"id" : lst['topic_box'][0]['id'], "title" : lst['topic_box'][0]['title'], "targetTime" : lst['topic_box'][0]['targetTime'].toDate()};
    //     topicBox.add(mapTopic);
    //
    //     lst['result_hive'].forEach((e) {
    //       resultBox.add(e);
    //     });
    //     print('resultBox -> ${resultBox.values}');
    //   }
    //
    // }


    // if(isClearAll == true) {
    //   resultBox.clear();
    //   topicBox.clear();
    //   timerBox.clear();
    //   questionBox.clear();
    //   percentageBox.clear();
    //   totalBox.clear();
    // }

    int version;
    if(checkVersion == null || checkVersion < 6) {
      version = 6;
      // resultBox.clear();
      topicBox.clear();
      // timerBox.clear();
      // questionBox.clear();
      // percentageBox.clear();
      // totalBox.clear();
    } else {
      version = versionBox.get(0);
    }

    print('version -> $version');
    versionBox.put(0, version);
  }

}