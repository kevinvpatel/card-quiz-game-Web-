import 'dart:html' as webView;
import 'package:flutter/foundation.dart';
import 'package:confetti/confetti.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:oktoast/oktoast.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';
import 'package:swipecard_app/controllers/analytics_controller.dart';
import 'package:swipecard_app/controllers/login_controller.dart';
import 'package:swipecard_app/screen/home_screen.dart';
import 'package:swipecard_app/screen/login_screen.dart';
import 'package:swipecard_app/screen/splash_screen.dart';
import 'package:swipecard_app/service/Authentication.dart';
import 'package:google_tag_manager/google_tag_manager.dart' as gtm;

class ResultScreen extends StatefulWidget {

  final int _cardLength;
  final int _correctAns;
  final List<Answer>? lstRecord;
  final bool isRewardPlay;
  final User? user;
  final String? topicName;
  final int seconds;

  ResultScreen({
    Key? key,
    int? cardLength,
    int? correctAns,
    this.lstRecord,
    required this.isRewardPlay,
    this.user,
    required this.topicName,
    required this.seconds,
  }) : _cardLength = cardLength ?? 10,
      _correctAns = correctAns ?? 0;

  @override
  _ResultScreenState createState() => _ResultScreenState();
}



class _ResultScreenState extends State<ResultScreen> {
  double spacing = 10;
  late ConfettiController _confettiController;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  LoginController loginController = Get.put(LoginController());

  int? totalPlays;
  int? totalScore;
  int? totalPercentage;

  int? todayScore;

  String percentage() {
    var per = 100 * widget._correctAns / 10;
    return widget._correctAns == 0 ? percentageInt.toString()
        : per.toStringAsFixed(0);
  }

  String score() {
    var points = double.parse(percentage()) * 160 / 100;
    return points.toStringAsFixed(0);
  }


  ///Storing percentage in local
  Box? perBox;
  createPercentageHiveBox() async {
    perBox = await Hive.openBox('Percentage_Hive');

    try {
      var per1 = 100 * widget._correctAns / 10;
      totalPercentage = int.parse(per1.toStringAsFixed(0));
      print('per1.toStringAsFixed(0) -> ${per1.toStringAsFixed(0)}');
      if(per1.toStringAsFixed(0) != '0') {
        perBox?.add('${per1.toStringAsFixed(0)}%');
      }
      setState(() {});
    } catch(err) {
      print('==>>>  createPercentageHiveBox create err -> $err   <<<==');
    }
  }

  getPercentage({required int index}) {
    final lstPer = perBox?.values.where((element) => element == '${index+1}0%');
    return Text('${lstPer?.length ?? 0} ', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w400));
  }

  getChartBarWidth({required int index}){
    final lstPer = perBox?.values.where((element) => element == '${index+1}0%');
    int count = lstPer?.length ?? 0;
    double width = 240 * (count*2) / 100;
    if(width < 10) {
      return 10;
    } else if(width > 240) {
      return 240;
    } else {
      return width;
    }
  }


  ///Storing totals in local
  Box? totalBox;
  createTotalHiveBox() async {
    print(' ');
   try {
     totalBox = await Hive.openBox('Total_Hive');

     if(totalBox!.values.isEmpty) {
       totalBox?.put('totalPlays', 0);
       totalBox?.put('totalScore', 0);
     }

     print('percentage() -> ${percentage()}');
     double doublePercentage = double.parse(percentage());
     var points = doublePercentage * 160 / 100;
     todayScore = int.parse(points.toStringAsFixed(0));

     if(totalBox?.values != null) {
       print('box.values 1 -> ${totalBox?.values}');
       int incrementScore = widget.isRewardPlay ? todayScore! : 0;
       totalScore = totalBox?.get('totalScore') + incrementScore;
       int incrementPlays;
       if(totalBox?.get('totalPlays') == 0) {
          incrementPlays = 1;
       } else {
          incrementPlays = widget.isRewardPlay ? 1 : 0;
       }
       totalPlays = totalBox?.get('totalPlays') + incrementPlays;
       print('totalPlays -> $totalPlays');
     }

     print('todayScore -> $todayScore');

     totalBox?.putAt(0, totalPlays);
     totalBox?.putAt(1, totalScore);
   } catch(err) {
     print('==>>>  totalBox create err -> $err   <<<==');
   }
  }


  ///Next topic timer "StopWatch"/
  DateTime currentTime = DateTime.now();
  late DateTime endTime;
  int? diffDateTime;

  StopWatchTimer? stopWatchTimer;

  String durationToString(int minutes) {
    var d = Duration(minutes:minutes);
    List<String> parts = d.toString().split(':');
    return '${parts[0].padLeft(2, '0')}:${parts[1].padLeft(2, '0')}';
  }


  List<Answer> lstAnswers = [];
  int? percentageInt;

  Box? resultHive;
  getResultHive() async {
    resultHive = await Hive.openBox('result_hive');
    print('resultHive Result Screen isNotEmpty -> ${resultHive!.values.isNotEmpty}');
    if(resultHive!.values.isNotEmpty) {
      resultHive?.values.forEach((element) {
        if(element != resultHive?.values.last) {
          element == true ? lstAnswers.add(Answer.right) : lstAnswers.add(Answer.wrong);
        } else {
          percentageInt = element;
        }
      });
    }
  }

  Box? userHive;
  openUserHiveData() async {
    userHive = await Hive.openBox('user_hive');
  }

  AnalyticsController analyticsController = Get.put(AnalyticsController());


  @override
  void initState() {
    analyticsController.screenEvent(
        screenName: 'result_screen_web',
        screenClass: 'ResultScreenWeb'
    );
    openUserHiveData();

    getResultHive();
    print('widget.seconds -> ${widget.seconds}');
    print('StopWatchTimer -> ${durationToString(widget.seconds)}');
    stopWatchTimer = StopWatchTimer(
        mode: StopWatchMode.countDown,
        presetMillisecond: StopWatchTimer.getMilliSecFromSecond(widget.seconds),
        onChange: (value) {},
        onChangeRawSecond: (value) {},
        onChangeRawMinute: (value) {},
        onStop: (){}
    );

    ///Create Totals Hive database
    createTotalHiveBox();
    ///Create Percentage Hive database
    createPercentageHiveBox();

    ///Confetti Animation
    _confettiController = ConfettiController(duration: const Duration(microseconds: 2000));
    if(widget.isRewardPlay) {
      _confettiController.play();
    }
    // fToast?.init(context);
    setState(() {
      stopWatchTimer?.onExecute.add(StopWatchExecute.start);
    });

    // if(_auth.currentUser != null || _auth.currentUser?.email != 'demo@pingoo.app') {
    //   Future.delayed(const Duration(milliseconds: 2500) ,() async {
    //     final timerBox = await Hive.openBox('Timer_Hive');
    //     final topicBox = await Hive.openBox('Topic_Box');
    //     final versionBox = await Hive.openBox('Version_Hive');
    //     final questionBox = await Hive.openBox('Questions_Hive');
    //
    //     loginController.storeLocalToFirestore(
    //         user: _auth.currentUser!,
    //         arguments: [
    //           {
    //             "percentage_hive" : perBox?.values,
    //             "result_hive" : resultHive?.values,
    //             "timer_hive" : timerBox.values,
    //             "topic_box" : topicBox.values,
    //             "total_hive" : totalBox?.values,
    //             "version_hive" : versionBox.values,
    //             "questions_hive" : questionBox.values,
    //           }
    //         ]);
    //   });
    // }

    super.initState();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    stopWatchTimer?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double webWidth = 370;
    double webHeight = MediaQuery.of(context).size.height * 0.8;
    // double mobileWidth = MediaQuery.of(context).size.width * 0.9;
    double mobileWidth = 370;
    double mobileHeight = MediaQuery.of(context).size.height * 0.95;

    return Scaffold(
        backgroundColor: Colors.transparent,
        body: LayoutBuilder(
          builder: (context, constraints) {
            return OKToast(
              child: Align(
                alignment: const AlignmentDirectional(0, 0),
                child: Stack(
                  children: [
                    Align(
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(6),
                                boxShadow: const [
                                  BoxShadow(color: Colors.black12, offset: Offset(0, 0), spreadRadius: 2, blurRadius: 7)
                                ]
                            ),
                            alignment: Alignment.center,
                            padding: const EdgeInsets.only(left: 18, right: 18),
                            height: defaultTargetPlatform == TargetPlatform.iOS || defaultTargetPlatform == TargetPlatform.android
                                ? mobileHeight
                                : webHeight,
                            width: defaultTargetPlatform == TargetPlatform.iOS || defaultTargetPlatform == TargetPlatform.android
                                ? mobileWidth
                                : webWidth,
                            child: SingleChildScrollView(
                              physics: constraints.maxHeight < 870 ? BouncingScrollPhysics() : NeverScrollableScrollPhysics(),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(height: spacing * 1),
                                  SizedBox(height: spacing),
                                  Text('Answered Correctly: ${percentage()}%',
                                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
                                  SizedBox(height: spacing - 5),
                                  Text('Today\'s Score: ${score()}',
                                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w400)),

                                  SizedBox(height: spacing * 1.4),
                                  Container(
                                    alignment: Alignment.center,
                                    height: 28,
                                    child: ListView.builder(
                                        scrollDirection: Axis.horizontal,
                                        shrinkWrap: true,
                                        physics: const NeverScrollableScrollPhysics(),
                                        itemCount: lstAnswers.isNotEmpty ? lstAnswers.length : 0,
                                        itemBuilder: (context, index) {
                                          return lstAnswers[index] == Answer.right
                                              ? Padding(
                                            padding: const EdgeInsets.only(right: 5),
                                            child: Image.asset('assets/icons/resultscreen/right.png', height: 23, width: 23),
                                          )
                                              : lstAnswers[index] == Answer.wrong
                                              ? Padding(
                                            padding: const EdgeInsets.only(right: 5),
                                            child: Image.asset('assets/icons/resultscreen/wrong.png', height: 19, width: 19),
                                          )
                                              : const SizedBox.shrink();
                                        }
                                    ),
                                  ),

                                  SizedBox(height: spacing),
                                  Divider(
                                    color: Colors.grey.shade800,
                                    thickness: 0.5,
                                  ),
                                  SizedBox(height: spacing),

                                  ///Total Score
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Column(
                                        children: [
                                          const Text('Total plays', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),),
                                          Text(totalPlays.toString(), style: const TextStyle(color: Colors.red, fontSize: 26, fontWeight: FontWeight.w600),),
                                        ],
                                      ),
                                      SizedBox(width: spacing * 5),
                                      Column(
                                        children: [
                                          const Text('Total score', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),),
                                          Text(totalScore.toString(), style: const TextStyle(color: Colors.red, fontSize: 26, fontWeight: FontWeight.w600),),
                                        ],
                                      )
                                    ],
                                  ),

                                  SizedBox(height: spacing * 1.2),
                                  const Text('Summary', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),),

                                  SizedBox(height: spacing * 1.2),
                                  ///Progress bars
                                  SizedBox(
                                    height: 230,
                                    child: ListView.builder(
                                        physics: const NeverScrollableScrollPhysics(),
                                        padding: const EdgeInsets.symmetric(horizontal: 5),
                                        shrinkWrap: true,
                                        itemCount: 10,
                                        itemBuilder: (context, index) {
                                          String idx = '${index + 1}0';
                                          double length = double.parse(idx);
                                          return Container(
                                            width: defaultTargetPlatform == TargetPlatform.iOS || defaultTargetPlatform == TargetPlatform.android
                                                ? mobileWidth * 0.9
                                                : webWidth * 0.9,
                                            margin: const EdgeInsets.only(bottom: 2),
                                            alignment: Alignment.center,
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              children: [
                                                Container(
                                                  alignment: Alignment.centerRight,
                                                  margin: const EdgeInsets.only(right: 13),
                                                  width: 40,
                                                  child: Text('${index + 1}0%', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),),
                                                ),
                                                Container(
                                                    height: 18,
                                                    width: getChartBarWidth(index: index),
                                                    decoration: BoxDecoration(
                                                        color: percentage() == '${index + 1}0' ?  const Color.fromRGBO(24, 136, 171, 1)
                                                            : const Color.fromRGBO(219, 232, 247, 1),
                                                        borderRadius: BorderRadius.circular(5)
                                                    ),
                                                    alignment: Alignment.centerRight,
                                                    child: getPercentage(index: index)
                                                )
                                              ],
                                            ),
                                          );
                                        }
                                    ),
                                  ),

                                  ///Share Button and Timer
                                  Container(
                                    margin: const EdgeInsets.only(left: 5, right: 5),
                                    child: IntrinsicHeight(
                                      child: Row(
                                        mainAxisSize: MainAxisSize.max,
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          SizedBox(
                                            width: defaultTargetPlatform == TargetPlatform.iOS || defaultTargetPlatform == TargetPlatform.android
                                                ? mobileWidth * 0.34
                                                : webWidth * 0.34,
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                const Text('Next Topic', style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w500)),
                                                StreamBuilder<int>(
                                                    stream: stopWatchTimer?.rawTime,
                                                    initialData: stopWatchTimer?.rawTime.value,
                                                    builder: (BuildContext context,AsyncSnapshot<int> snapshot) {
                                                      final displayTime = StopWatchTimer.getDisplayTime(snapshot.data!);
                                                      return Text(displayTime.split('.').first, style: const TextStyle(color: Colors.red, fontSize: 20, fontWeight: FontWeight.w600));
                                                    }
                                                ),
                                              ],
                                            ),
                                          ),
                                          const VerticalDivider(
                                            color: Color.fromRGBO(224, 224, 224, 1),
                                            thickness: 1.5,
                                          ),
                                          const SizedBox(width: 20),
                                          InkWell(
                                            onTap: () async {
                                              gtm.push({'click_share' : 'share_result'});
                                              analyticsController.addUserIdEvent(_auth.currentUser!.uid);
                                              analyticsController.addShareButtonEvent();


                                              List<String> lstImage = [];
                                              lstAnswers.forEach((answer) {
                                                if(answer == Answer.right) {
                                                  ///emoji code to send in url
                                                  lstImage.add('%E2%9C%85');
                                                } else if(answer == Answer.wrong) {
                                                  lstImage.add('%E2%9D%8C');
                                                } else {
                                                  lstImage.add('');
                                                }
                                              });

                                              String emotes = lstImage.toString().replaceAll('[', '').replaceAll(']', '').replaceAll(',', '');
                                              String text = 'My today’s score %40pingooapp for %23${widget.topicName?.replaceAll(' ', '').replaceAll(RegExp(r'[^\w\s]+'),'')} was ${score()} play.pingoo.app'
                                                  '%0A$emotes';

                                              print('topic name -> ${widget.topicName}');
                                              print('twitter topic name -> ${widget.topicName?.replaceAll(' ', '').replaceAll(RegExp(r'[^\w\s]+'),'')}');

                                              ///url to open twitter and tweet in it
                                              var url = 'https://twitter.com/intent/tweet?text=$text';
                                              print('url -> $url');

                                              webView.window.open(url, '');
                                            },
                                            child: Container(
                                                margin: const EdgeInsets.symmetric(vertical: 6),
                                                decoration: BoxDecoration(
                                                    color: const Color.fromRGBO(255, 58, 0, 1),
                                                    borderRadius: BorderRadius.circular(6)
                                                ),
                                                height: 41,
                                                width: defaultTargetPlatform == TargetPlatform.iOS || defaultTargetPlatform == TargetPlatform.android
                                                    ? mobileWidth * 0.365
                                                    : webWidth * 0.365,
                                                alignment: Alignment.center,
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    const Text('Share', style: TextStyle(color: Colors.white, fontSize: 22),),
                                                    const SizedBox(width: 8),
                                                    Image.asset('assets/icons/resultscreen/share.png', height: 19, width: 19)
                                                  ],
                                                )
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),

                                  SizedBox(height: spacing * 2),

                                  // userHive?.values.isNotEmpty == null || userHive?.values.first['email'] == 'demo@pingoo.app' ? Wrap(
                                  //   crossAxisAlignment: WrapCrossAlignment.center,
                                  //   alignment: WrapAlignment.center,
                                  //   children: [
                                  //     const Text('To track your progress ', style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w400)),
                                  //     InkWell(
                                  //       onTap: () async {
                                  //         final timerBox = await Hive.openBox('Timer_Hive');
                                  //         final topicBox = await Hive.openBox('Topic_Box');
                                  //         final versionBox = await Hive.openBox('Version_Hive');
                                  //         final questionBox = await Hive.openBox('Questions_Hive');
                                  //
                                  //         Get.to(const LoginScreen(isStoreData: true), arguments: [
                                  //           {
                                  //             "percentage_hive" : perBox?.values,
                                  //             "result_hive" : resultHive?.values,
                                  //             "timer_hive" : timerBox.values,
                                  //             "topic_box" : topicBox.values,
                                  //             "total_hive" : totalBox?.values,
                                  //             "version_hive" : versionBox.values,
                                  //             "questions_hive" : questionBox.values,
                                  //           }
                                  //         ]);
                                  //       },
                                  //       child: const Text('Create Account ',
                                  //           style: TextStyle(fontSize: 14.5, color: Colors.red, fontWeight: FontWeight.w600)),
                                  //     ),
                                  //     const Text('Or ', style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w400)),
                                  //     InkWell(
                                  //       onTap: () async {
                                  //         final timerBox = await Hive.openBox('Timer_Hive');
                                  //         final topicBox = await Hive.openBox('Topic_Box');
                                  //         final versionBox = await Hive.openBox('Version_Hive');
                                  //         final questionBox = await Hive.openBox('Questions_Hive');
                                  //
                                  //         Get.to(const LoginScreen(isStoreData: true), arguments: [
                                  //           {
                                  //             "percentage_hive" : perBox?.values,
                                  //             "result_hive" : resultHive?.values,
                                  //             "timer_hive" : timerBox.values,
                                  //             "topic_box" : topicBox.values,
                                  //             "total_hive" : totalBox?.values,
                                  //             "version_hive" : versionBox.values,
                                  //             "questions_hive" : questionBox.values,
                                  //           }
                                  //         ]);
                                  //       },
                                  //       child: const Text('Login',
                                  //           style: TextStyle(fontSize: 14.5, color: Colors.red, fontWeight: FontWeight.w600)),
                                  //     )
                                  //   ],
                                  // ) : Wrap(
                                  //   crossAxisAlignment: WrapCrossAlignment.center,
                                  //   alignment: WrapAlignment.center,
                                  //   children: [
                                  //     const Text('To disconnect ', style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w400)),
                                  //     InkWell(
                                  //       onTap: () async {
                                  //         Authentication.signOutGoogle().then((value) =>
                                  //           Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) =>
                                  //               SplashScreen(isClearAll: true)
                                  //           ))
                                  //         );
                                  //       },
                                  //       child: const Text('Logout',
                                  //           style: TextStyle(fontSize: 14.5, color: Colors.red, fontWeight: FontWeight.w600)),
                                  //     )
                                  //   ],
                                  // ),

                                  SizedBox(height: spacing * 2),

                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Image.asset('assets/icons/resultscreen/barcode.png',
                                        height: 105, width: 105,
                                      ),
                                      Column(
                                        children: [
                                          const Text('Play more', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),),
                                          SizedBox(height: spacing * 1.2),
                                          downloadButton(
                                              height: 35,
                                              width: defaultTargetPlatform == TargetPlatform.iOS || defaultTargetPlatform == TargetPlatform.android
                                                  ? mobileWidth * 0.30
                                                  : webWidth * 0.31,
                                              imagePath: 'assets/icons/resultscreen/apple-btn.png',
                                              boxFit: BoxFit.fill,
                                              onTap: () {
                                                gtm.push({'click_appstore_btn' : 'open_appstore'});
                                                analyticsController.iOSButtonEvent();

                                                String urlAppStore = 'https://apps.apple.com/us/app/pingoo/id1553723926';
                                                webView.window.open(urlAppStore, '');
                                              }
                                          ),
                                          SizedBox(height: spacing * 0.5),
                                          downloadButton(
                                              height: 44,
                                              width: defaultTargetPlatform == TargetPlatform.iOS || defaultTargetPlatform == TargetPlatform.android
                                                  ? mobileWidth * 0.35
                                                  : webWidth * 0.35,
                                              imagePath: 'assets/icons/resultscreen/google-btn.png',
                                              boxFit: BoxFit.contain,
                                              onTap: () {
                                                gtm.push({'click_playstore_btn' : 'open_playstore'});
                                                analyticsController.androidButtonEvent();

                                                String urlPlayStore = 'https://play.google.com/store/apps/details?id=app.pingoo';
                                                webView.window.open(urlPlayStore, '');
                                              }
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                  SizedBox(height: spacing * 2)

                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Align(
                      alignment: Alignment.topCenter,
                      child: ConfettiWidget(
                        confettiController: _confettiController,
                        blastDirectionality: BlastDirectionality.explosive,
                        blastDirection: 0,
                        emissionFrequency: 0.5,
                        numberOfParticles: 65,
                        gravity: 0.1,
                        shouldLoop: false,
                      ),
                    )
                  ],
                ),
              ),
            );
          }),
        );

  }

  // Widget toast = Container(
  //   height: 60,
  //   width: 200,
  //   alignment: Alignment.center,
  //   decoration: BoxDecoration(
  //     color: Colors.black,
  //     borderRadius: BorderRadius.circular(5)
  //   ),
  //   child: const Text('Copied results to clipboard', style: TextStyle(fontSize: 14.5, color: Colors.white),),
  // );

  downloadButton({
    required double width,
    required double height,
    required String imagePath,
    required BoxFit boxFit,
    required Function() onTap
  }) {
    return InkWell(
      splashColor: Colors.transparent,
      hoverColor: Colors.transparent,
      onTap: onTap,
      child: SizedBox(
        height: height,
        width: width,
        child: Image.asset(imagePath, fit: boxFit),
      ),
    );
  }
}
