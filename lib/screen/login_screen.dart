import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:swipecard_app/constants/constants.dart';
import 'package:swipecard_app/controllers/login_controller.dart';
import 'package:swipecard_app/controllers/splash_controller.dart';
import 'package:swipecard_app/screen/error_screen.dart';
import 'package:swipecard_app/screen/home_screen.dart';
import 'package:swipecard_app/screen/result_screen.dart';
import 'package:swipecard_app/screen/signup_screen.dart';
import 'package:swipecard_app/screen/splash_screen.dart';
import 'package:swipecard_app/service/Authentication.dart';
import 'package:swipecard_app/service/api_response.dart';

class LoginScreen extends StatefulWidget {

  final bool isStoreData;

  const LoginScreen({Key? key, required this.isStoreData}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  double spacing = 23;

  TextEditingController txtEmail = TextEditingController();
  TextEditingController txtPassword = TextEditingController();

  final LoginController loginController = Get.put(LoginController());
  final SplashController splashController = Get.put(SplashController());




  @override
  void initState() {
    super.initState();
    final data = Get.arguments;
    print('argument data -> $data');
  }


  @override
  Widget build(BuildContext context) {
    double width = 390;
    double height = MediaQuery.of(context).size.height;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: backgroundColor,
      body: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 20, left: 0, right: 0, bottom: 0),
            width: width,
            height: height,
            child: ScrollConfiguration(
              behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ///back icon
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        InkWell(
                          hoverColor: Colors.transparent,
                          child: Container(
                            height: 27,
                            width: 27,
                            alignment: Alignment.centerLeft,
                            child: SvgPicture.asset("assets/icons/loginscreen/back_arrow.svg", height: 21, width: 21),
                          ),
                          onTap: (){
                            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) =>
                              SplashScreen()
                            ));
                          },
                        ),
                      ],
                    ),
                    SizedBox(height: spacing - 12),

                    ///Title
                    const Text('Create an account', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w500),),
                    SizedBox(height: spacing - 5),

                    ///Custom text
                    const Text(
                      'Track your progress and access the content from your other devices',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: spacing + 5),

                    ///Buttons
                    ///Google
                    socialMediaButtons(
                        borderColor: pinkThemeColor,
                        btnName: "Continue with Google",
                        btnWidth: width,
                        textColor: pinkThemeColor,
                        onPress: (){

                          Authentication.signInWithGoogle(context: context).then((user) {
                            if(user != null) {
                              if(widget.isStoreData == true) {
                                loginController.storeLocalToFirestore(user: user, arguments: Get.arguments);
                              }

                              splashController.todaysTopic(user: user).then((mapTopic) async {
                                List<Answer>? lstAnswer;
                                splashController.resultBox = await Hive.openBox('Result_Hive');
                                splashController.resultBox?.values.forEach((element) {
                                  lstAnswer?.add(element == 'true' ? Answer.right : Answer.wrong);
                                });

                                splashController.hoursCheck().then((isQuizEnable) {
                                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
                                    if(isQuizEnable) {
                                      print(' ');
                                      print('mapTopic SplashScreen @@@ -> $mapTopic');
                                      print(' ');
                                      return HomeScreen(user: user, mapTopic: mapTopic);
                                    } else {
                                      DateTime dtTime = DateFormat('yyyy-MM-dd HH:mm:ss').parse(splashController.timerBox?.values.first);
                                      DateTime EndTime = DateFormat('yyyy-MM-dd HH:mm:ss').parse(splashController.timerBox?.values.last);
                                      int diffSeconds = EndTime.difference(dtTime).inSeconds;

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
                            }
                          });

                        }
                    ),
                    SizedBox(height: spacing / 1.8),
                    ///Facebook
                    socialMediaButtons(
                        borderColor: pinkThemeColor,
                        btnName: "Continue with Facebook",
                        btnWidth: width,
                        textColor: pinkThemeColor,
                        onPress: (){}
                    ),
                    SizedBox(height: spacing / 1.8),
                    ///Email
                    socialMediaButtons(
                        borderColor: orangeThemeColor,
                        btnName: "Sign up with email",
                        btnWidth: width,
                        textColor: Colors.black,
                        symbolBefore: '@',
                        onPress: () => Get.to(SignUpScreen())
                    ),
                    SizedBox(height: spacing / 1.3),

                    ///Privacy Policy text
                    privacyPolicy(),
                    SizedBox(height: spacing * 1.7),

                    ///Divider
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(color: const Color.fromRGBO(224, 224, 224, 1), height: 1.5, width: width * 0.37),
                        SizedBox(width: width * 0.13),
                        Container(color: const Color.fromRGBO(224, 224, 224, 1), height: 1.5, width: width * 0.37),
                      ],
                    ),
                    SizedBox(height: spacing * 1.5),

                    const Text(
                      'Have an account already?',
                      style: TextStyle(fontSize: 23, fontWeight: FontWeight.w500),
                    ),
                    SizedBox(height: spacing / 2.3),
                    const Text(
                      'Sign in with your email',
                      style: TextStyle(fontSize: 23, fontWeight: FontWeight.w500),
                    ),
                    SizedBox(height: spacing),

                    ///Sign in fields
                    textField(
                        width: width,
                        hintText: "Email",
                        controller: txtEmail
                    ),
                    SizedBox(height: spacing / 1.8),
                    textField(
                        width: width,
                        hintText: "Password",
                        controller: txtPassword
                    ),
                    SizedBox(height: spacing / 1.8),
                    ///sign in button
                    socialMediaButtons(
                        btnWidth: width,
                        borderColor: orangeThemeColor,
                        btnName: "Sign in",
                        textColor: Colors.white,
                        backgroundColor: orangeThemeColor,
                        onPress: (){
                          print('login emaillllll');
                          Authentication.signInWithEmail(context: context, email: txtEmail.text.toLowerCase().trim(), password: txtPassword.text.trim())
                              .then((userEmail) => Get.to(SplashScreen()));
                        }
                    ),
                    SizedBox(height: spacing / 1.3),

                    ///forget password
                    GestureDetector(
                      onTap: (){
                        print('forget emaillllll');
                        },
                      child: const Text('forgot your password?', style: TextStyle(color: blueThemeColor, fontWeight: FontWeight.w500, fontSize: 16),),
                    )


                  ],
                ),
              ),
            )
          ),
        ]
      )
    );
  }

  ///social media buttons
  socialMediaButtons({
    required double btnWidth,
    required Color borderColor,
    required String btnName,
    Color? textColor,
    String? symbolBefore = "",
    required Function() onPress,
    Color backgroundColor = Colors.transparent
  }) {
    return InkWell(
      onTap: onPress,
      customBorder: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(6)
      ),
      child: Container(
        width: btnWidth,
        height: 55,
        alignment: Alignment.center,
        decoration: BoxDecoration(
            color: backgroundColor,
            border: Border.all(color: borderColor, width: 2),
            borderRadius: BorderRadius.circular(6)
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(symbolBefore!, style: TextStyle(color: textColor, fontSize: 22, fontWeight: FontWeight.w800),),
            const SizedBox(width: 5),
            Text(btnName, style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.w600),),
          ],
        )
      ),
    );
  }

  ///privacy policy
  privacyPolicy() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'I am 18 years of age or older, and agree with',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        const SizedBox(height: 5),
        Row(
          children: [
            GestureDetector(
              onTap: (){},
              child: const Text(
                'Terms of Use',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: blueThemeColor, decoration: TextDecoration.underline),
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'and',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: (){},
              child: const Text(
                'Privacy Policy.',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: blueThemeColor, decoration: TextDecoration.underline),
              ),
            )
          ],
        )
      ],
    );
  }

  ///Signin textfield
  textField({
    required double width,
    required String hintText,
    required TextEditingController controller,
  }) {
      return SizedBox(
        height: 55,
        width: width,
        child: TextField(
          controller: controller,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.all(18),
            hintText: hintText,
            hintStyle: const TextStyle(color: Colors.black87, fontSize: 18, fontWeight: FontWeight.w500),
            enabledBorder: const OutlineInputBorder(borderSide: BorderSide()),
            focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Color.fromRGBO(255, 66, 0, 1)))
          ),
        ),
      );
    }

}
