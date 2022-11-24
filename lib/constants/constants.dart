import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';

const Color backgroundColor = Colors.white;
const Color orangeThemeColor = Color.fromRGBO(255, 58, 0, 1);
Color pinkThemeColor = const Color.fromRGBO(227, 44, 133, 1);
Color pinkSplashColor = const Color.fromRGBO(243, 167, 204, 0.5);
const Color blueThemeColor = Color.fromRGBO(24, 136, 171, 1);

///iphone 12 pro
const double iWidth = 390;
const double iHeight = 390;

final ValueNotifier<bool> isQuizEnable = ValueNotifier<bool>(false);

alert(String msg, BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      double width = 300;

      return AlertDialog(
        title: const Text('Warning!', style: TextStyle(fontSize: 19.5, fontWeight: FontWeight.w700)),
        contentPadding: const EdgeInsets.only(top: 25),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Text(msg, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w500),),
            ),
            const SizedBox(height: 50),
            const Divider(color: orangeThemeColor, height: 0),
            SizedBox(
              height: 45,
              width: width,
              child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                  ),
                  child: const Text("OK", style: TextStyle(fontSize: 15, color: orangeThemeColor, fontWeight: FontWeight.w700),)
              ),
            )
          ],
        ),
      );
    },
  );
}

storeUserToLocal({required User user}) async {
  final userHive = await Hive.openBox('user_hive');
  Map map = {'email' : user.email, 'photoURL' : user.photoURL, 'displayName' : user.displayName, 'uid' : user.uid, 'getIdToken' : await user.getIdToken()};
  userHive.put('user', map);
}