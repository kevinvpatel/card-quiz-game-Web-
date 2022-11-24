import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';

class LoginController extends GetxController {

  storeLocalToFirestore({required User user, required dynamic arguments}) async {
    final docEvents = FirebaseFirestore.instance.collection('Users').doc(user.uid);
    final timerBox = await Hive.openBox('Timer_Hive');
    final totalBox = await Hive.openBox('Total_Hive');
    Map<String, dynamic> map;


    DocumentSnapshot snapshot = await docEvents.get();
    Map<String, dynamic> lstSnapshot = snapshot.data() as Map<String, dynamic>;
    if(lstSnapshot['timer_hive'] != null) {
      List<String> lstTimer = [];
      arguments[0]['timer_hive'].forEach((e) {
        lstTimer.add(e);
      });
      print('lstTimer @@ -> ${lstTimer}');


      List<int> lstTotal = [];
      arguments[0]['total_hive'].forEach((e) {
        lstTotal.add(e);
      });
      print('lstTotal @@ -> $lstTotal');


      List<String> lstPercentage = [];
      lstSnapshot['percentage_hive'].forEach((e) {
        lstPercentage.add(e);
      });
      arguments[0]['percentage_hive'].forEach((e) {
        lstPercentage.add(e);
      });
      print('lstPercentage @@ -> $lstPercentage');


      List<String> lstQuestion = [];
      lstSnapshot['questions_hive'].forEach((e) {
        lstQuestion.add(e);
      });
      arguments[0]['questions_hive'].forEach((e) {
        lstQuestion.add(e);
      });


      List<Map> lstTopic = [];
      arguments[0]['topic_box'].forEach((e) {
        lstTopic.add(e);
      });

      List<dynamic> lstResult = [];
      arguments[0]['result_hive'].forEach((e) {
        lstResult.add(e);
      });

      map = {
        "uId" : user.uid,
        "name" : user.displayName,
        "email" : user.email,
        "profilePicture" : user.photoURL,
        "idToken" : await user.getIdToken(),
        "percentage_hive" : lstPercentage,
        "result_hive" : lstResult,
        "timer_hive" : lstTimer,
        "topic_box" : lstTopic,
        "total_hive" : lstTotal,
        "version_hive" : arguments[0]['version_hive'],
        "questions_hive" : lstQuestion,
      };

    } else {
      map = {
        "uId" : user.uid,
        "name" : user.displayName,
        "email" : user.email,
        "profilePicture" : user.photoURL,
        "idToken" : await user.getIdToken(),
        "percentage_hive" : arguments[0]['percentage_hive'],
        "result_hive" : arguments[0]['result_hive'],
        "timer_hive" : arguments[0]['timer_hive'],
        "topic_box" : arguments[0]['topic_box'],
        "total_hive" : arguments[0]['total_hive'],
        "version_hive" : arguments[0]['version_hive'],
        "questions_hive" : arguments[0]['questions_hive'],
      };
    }


    // Map<String, dynamic> map = {
    //   "uId" : user.uid,
    //   "name" : user.displayName,
    //   "email" : user.email,
    //   "profilePicture" : user.photoURL,
    //   "idToken" : await user.getIdToken(),
    //   "QuizPlayedTime" : timerBox.values.first,
    //   "QuizTargetTime" : timerBox.values.last,
    //   "totalPlays" : totalBox.values.first,
    //   "totalScore" : totalBox.values.last,
    //   "todayScore" : arguments[0]['todayScore'],
    //   "todayPercentage" : arguments[0]['todayPercentage'],
    //   "answers" : arguments[0]['answers'],
    // };


    docEvents.set(map);
  }

}