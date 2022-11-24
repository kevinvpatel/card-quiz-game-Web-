// import 'dart:html';
//
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:swipecard_app/constants/constants.dart';
// import 'package:swipecard_app/screen/home_screen.dart';
// import 'package:swipecard_app/screen/login_screen.dart';
//
// class LoginSkipScreen extends StatefulWidget {
//   const LoginSkipScreen({Key? key}) : super(key: key);
//
//   @override
//   _LoginSkipScreenState createState() => _LoginSkipScreenState();
// }
//
// class _LoginSkipScreenState extends State<LoginSkipScreen> {
//
//   User? user;
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//
//   Future skipSignin() async {
//     try {
//       UserCredential credential =  await _auth.signInWithEmailAndPassword(
//           email: 'demo@pingoo.app', password: 'Pingoo2020!'
//       );
//       user = credential.user;
//     } catch(err) {
//       print('signin with email error -> $err');
//     }
//   }
//
//
//   double spacing = 20;
//   @override
//   Widget build(BuildContext context) {
//     double width = 390;
//     double height = MediaQuery.of(context).size.height;
//
//     return Scaffold(
//       body: Row(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 30),
//             height: height,
//             width: width,
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 Image.asset('assets/icons/skipscreen/pingoo2.png',
//                     height: 390 * 0.7, width: 390),
//                 const Text('Great Choice!', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500),),
//                 SizedBox(height: spacing),
//                 const Text('Create an account to track your progress and access your account from your other devices ',
//                   style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400), textAlign: TextAlign.center),
//                 SizedBox(height: spacing * 1.2),
//                 InkWell(
//                   onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context)
//                     => const LoginScreen())),
//                   customBorder: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(6)
//                   ),
//                   child: Container(
//                       width: width,
//                       height: 50,
//                       alignment: Alignment.center,
//                       decoration: BoxDecoration(
//                           color: Colors.transparent,
//                           border: Border.all(color: orangeThemeColor, width: 1.5),
//                           borderRadius: BorderRadius.circular(6)
//                       ),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: const [
//                           Text('Sign in or Sign up', style: TextStyle(color: orangeThemeColor, fontSize: 15, fontWeight: FontWeight.w500),),
//                         ],
//                       )
//                   ),
//                 ),
//                 SizedBox(height: spacing * 1.5),
//                 TextButton(
//                   onPressed: (){
//                     skipSignin().then((value) {
//                       Navigator.push(context, MaterialPageRoute(builder: (context)
//                         => HomeScreen(user: user!)
//                       ));
//                     });
//                   },
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: const [
//                       Text('I\'ll do this later',
//                           style: TextStyle(fontSize: 15, color: Color.fromRGBO(24, 136, 171, 1), fontWeight: FontWeight.w500)),
//                       // const SizedBox(width: 7),
//                       // Image.asset('assets/icons/homescreen/arrow.png', height: 20, width: 20)
//                     ],
//                   )
//                 )
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
//
// Future<User?> skipLogin({required FirebaseAuth auth}) async {
//
//   try {
//     UserCredential credential =  await auth.signInWithEmailAndPassword(
//         email: 'demo@pingoo.app', password: 'Pingoo2020!'
//     );
//     User? user = credential.user;
//     return user;
//   } catch(err) {
//     print('signin with email error -> $err');
//   }
// }
//
// showLoginSkipScreen({required BuildContext context, required isContinue}) {
//   return showModalBottomSheet(
//     context: context,
//     isScrollControlled: true,
//     clipBehavior: Clip.antiAlias,
//     backgroundColor: backgroundColor,
//     builder: (context) {
//
//       double spacing = 20;
//
//       double width = 390;
//       double height = MediaQuery.of(context).size.height;
//
//       return Row(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 30),
//             height: height,
//             width: width,
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 Image.asset('assets/icons/skipscreen/pingoo2.png',
//                     height: 390 * 0.7, width: 390),
//                 const Text('Great Choice!', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500),),
//                 SizedBox(height: spacing),
//                 const Text('Create an account to track your progress and access your account from your other devices ',
//                     style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400), textAlign: TextAlign.center),
//                 SizedBox(height: spacing * 1.2),
//                 InkWell(
//                   onTap: () =>
//                       Navigator.push(context, MaterialPageRoute(builder: (context) =>
//                         const LoginScreen(isStoreData: ))),
//                   customBorder: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(6)
//                   ),
//                   child: Container(
//                       width: width,
//                       height: 50,
//                       alignment: Alignment.center,
//                       decoration: BoxDecoration(
//                           color: Colors.transparent,
//                           border: Border.all(color: orangeThemeColor, width: 1.5),
//                           borderRadius: BorderRadius.circular(6)
//                       ),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: const [
//                           Text('Sign in or Sign up', style: TextStyle(color: orangeThemeColor, fontSize: 15, fontWeight: FontWeight.w500),),
//                         ],
//                       )
//                   ),
//                 ),
//                 SizedBox(height: spacing * 1.5),
//                 TextButton(
//                     onPressed: (){
//                       final FirebaseAuth _auth = FirebaseAuth.instance;
//
//                       skipLogin(auth: _auth).then((user) {
//
//                         if(isContinue) {
//                           Navigator.pop(context);
//                         } else {
//                           Navigator.push(context, MaterialPageRoute(builder: (context)
//                             => HomeScreen(user: user!)
//                           ));
//                         }
//                       });
//                     },
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         const Text('I\'ll do this later',
//                             style: TextStyle(fontSize: 15, color: Color.fromRGBO(24, 136, 171, 1), fontWeight: FontWeight.w500)),
//                         const SizedBox(width: 7),
//                         Image.asset('assets/icons/homescreen/circle-arrow-right.png', height: 20, width: 20)
//                       ],
//                     )
//                 )
//               ],
//             ),
//           ),
//         ],
//       );
//     }
//   );
// }
