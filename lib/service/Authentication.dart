import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:hive/hive.dart';
import 'package:swipecard_app/constants/constants.dart';

class Authentication {


  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static Future<User?> signInWithGoogle({required BuildContext context}) async {
    User? user;
    GoogleAuthProvider googleAuthProvider = GoogleAuthProvider();

    try {
      final UserCredential credential = await _auth.signInWithPopup(googleAuthProvider);
      user = credential.user!;

      storeUserToLocal(user: user);

    } on FirebaseException catch (err) {
      print('google signin err -> $err');
      alert(err.message!, context);
    }

    return user;
  }

  static Future signOutGoogle() async {
    print('signed out from -> ${_auth.currentUser}');
    final userHive = await Hive.openBox('user_hive');
    userHive.clear();
    await _auth.signOut();
  }


  static Future<User?> signInWithEmail({required BuildContext context, required String email, required String password}) async {
    User? user;
    try {
      UserCredential credential = await _auth.signInWithEmailAndPassword(email: email, password: password);
      user = credential.user;

      storeUserToLocal(user: user!);

    } on FirebaseException catch(err) {
      print('login email err -> $err');
      alert(err.message!, context);
    }
    return user!;
  }

}