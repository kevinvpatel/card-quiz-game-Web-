import 'package:auto_size_text/auto_size_text.dart';
import 'dart:html' as webView;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_swipecards/flutter_swipecards.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:swipecard_app/constants/constants.dart';
import 'package:swipecard_app/controllers/analytics_controller.dart';
import 'package:swipecard_app/model/Trivia.dart';
import 'package:swipecard_app/screen/login_screen.dart';
import 'package:swipecard_app/screen/result_screen.dart';
import 'package:swipecard_app/screen/splash_screen.dart';
import 'package:swipecard_app/service/Authentication.dart';
import 'package:swipecard_app/service/api_response.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

enum Answer {
  right, wrong, none
}

class HomeScreen extends StatefulWidget {
  final User user;
  final Map<String, dynamic> mapTopic;
  String? uid;
  String? name;
  String? userEmail;
  String? imageUrl;

  HomeScreen({
    Key? key,
    required this.user,
    this.uid,
    this.name,
    this.userEmail,
    this.imageUrl,
    required this.mapTopic
  }) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  int currentIndex = 0;
  List<Widget> cards = [];
  Answer answer = Answer.none;
  CardController cardController = CardController();

  List<Answer> lstRecord = [];

  Map<String,dynamic> mapTrivia = {};
  List<Trivia> lstTrivia = [];
  int cardLength = 0;
  String? topicName;



  Future addData({required String topicId, required String topicName1}) async {
    if(widget.user != null) {
      try {
        futureData = getRandomTopicDataApi(user: widget.user, topicId: topicId, topicName: topicName1).then((value) {
          lstTrivia = value['list'];
          print('cardLength val -> ${lstTrivia.length}');
          lstRecord = List.generate(lstTrivia.length, (index) => Answer.none);
          setState(() {});
          return value;
        });
      } catch(err) {
        print('cardLength err -> $err');
      }
    }

    setState(() {});
  }


  Box? topicBox;
  Future<Map<String, String>> getDailyTopicsFromHive() async {
    Map<String, String> mapTitleId = {};
    topicBox = await Hive.openBox('Topic_Box');
    topicBox?.values.forEach((element) {
      mapTitleId['title'] = element['title'];
      mapTitleId['id'] = element['id'];
    });
    print('mapTitleId HomeScreen -> $mapTitleId');
    return mapTitleId;
  }



  dialoge() {
    double width = 300;
    SchedulerBinding.instance.addPostFrameCallback((_) {
      showDialog(
          context: context,
          builder: (ctx) {
            return AlertDialog(
              backgroundColor: const Color.fromRGBO(230, 241, 255, 1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(9),
                side: const BorderSide(width: 1.5, color: Color.fromRGBO(0, 177, 124, 1))
              ),
              content: SizedBox(
                width: width,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: width * 0.56,
                      child: const Text('Tease your brain 10 cards a day!',
                          style: TextStyle(fontSize: 19, fontWeight: FontWeight.w600), textAlign: TextAlign.center),
                    ),
                    const SizedBox(height: 26),
                    const Text('Play Pingoo to fact check your assumptions and learn about new topics, '
                        'from health and wellness to soft skills and more',
                        style: TextStyle(fontSize: 18.5, fontWeight: FontWeight.w400)
                    ),
                    const SizedBox(height: 30),
                    Container(
                      width: width,
                      alignment: Alignment.centerLeft,
                      child: const Text('This is how it works: ', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w600)),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: UnorderedList(const [
                        "Read each card",
                        "Tap green check mark if the phrase is true, and tap x red circle if you beleive the phrase is false",
                        "See the results, find the right answer and share with your friends"
                      ]),
                    ),
                    const SizedBox(height: 20),
                    InkWell(
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      hoverColor: Colors.transparent,
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            const Text('Start Playing',
                              style: TextStyle(color: Color.fromRGBO(24, 136, 171, 1), fontSize: 14.5, fontWeight: FontWeight.bold),),
                            const SizedBox(width: 9),
                            Image.asset('assets/icons/splashscreen/intro_popup_arrow.png', height: 23, width: 23, fit: BoxFit.fill)
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
            );
          }
      );
    });
  }

  Future<Map<String,dynamic>>? futureData;

  Box? userHive;
  openUserHiveData() async {
    userHive = await Hive.openBox('user_hive');
  }

  AnalyticsController analyticsController = Get.put(AnalyticsController());

  @override
  void initState() {
    analyticsController.screenEvent(
      screenName: 'quiz_screen_web',
      screenClass: 'QuizScreenWeb'
    );
    setCurrentResult();
    createHiveBox();
    openUserHiveData();
    // hoursCheck().then((isQuizEnable) {
    //   print('isQuizEnable HomeScreen -> $isQuizEnable');
    //   if(isQuizEnable) {
    //     print('resultHive!.values.isNotEmpty -@ ${resultHive!.values.isNotEmpty}');
    //     if(resultHive!.values.isNotEmpty) {
    //       resultHive?.clear();
    //     }
    //     setState(() {
    //       Future.delayed(const Duration(milliseconds: 2200),() {
    //         getDailyTopicsFromHive().then((mapVal) {
    //           if(mapVal == null) {
    //
    //           }
    //           topicName = mapVal['title']!;
    //           addData(topicName1: mapVal['title']!, topicId: mapVal['id']!).then((value) => getHiveBox());
    //         });
    //       });
    //     });
    //   }
    // });

    Future.delayed(const Duration(milliseconds: 00),() {
      setState(() {
        getDailyTopicsFromHive().then((mapVal) {
          print('mapVal -@ $mapVal');
          if(mapVal.isNotEmpty) {
            topicName = widget.mapTopic['title'];
            addData(topicName1: widget.mapTopic['title']!, topicId: widget.mapTopic['id']!)
                .then((value) => getHiveBox());
          }
        });
      });
    });

    super.initState();
  }

  getHiveBox() async {
    Future.delayed(const Duration(milliseconds: 500),() {
      final listBox = Hive.box('Questions_Hive');
      listBox.values.forEach((e) {
        lstTrivia.removeWhere((element) => listBox.values.contains(element.title));
      });
      setState(() {});
    });
  }

  Box? box;
  createHiveBox() async {
    box = await Hive.openBox('Questions_Hive');
    print('box!.values.isEmpty -> ${box?.values.isEmpty}');
    if(box!.values.isEmpty) {
      dialoge();
    }
  }


  int i = 0;
  ///initialize and store timer for next quiz play
  Future<int> initCountdownTimer() async {
    try {
      print('initCountdownTimer HomeScreen');
      final timerBox = await Hive.openBox('Timer_Hive');

      DateTime dt = DateTime.now();
      final currentTimeUser = DateTime(dt.year, dt.month, dt.day, dt.hour, dt.minute, dt.second);
      final formattedPlayedTime = currentTimeUser.toString().split('.').first;
      timerBox.put('QuizPlayedTime', formattedPlayedTime);


      DateTime targetTimeUser = await getDestineTimeOfUser(
          destineTime: DateTime(dt.year, dt.month, dt.day, 21, 30));

      if(currentTimeUser.isAfter(targetTimeUser)) {
        targetTimeUser = await getDestineTimeOfUser(
            destineTime: DateTime(dt.year, dt.month, dt.day+1, 21, 30));
      }
      final formattedTargetTime = targetTimeUser.toString().split('.').first;
      timerBox.put('QuizTargetTime', formattedTargetTime);

      DateTime dtTime = DateFormat('yyyy-MM-dd HH:mm:ss').parse(timerBox.values.first);
      DateTime EndTime = DateFormat('yyyy-MM-dd HH:mm:ss').parse(timerBox.values.last);

      print('dtTime HomeScreen-> $dtTime');
      print('EndTime HomeScreen-> $EndTime');
      int diffSeconds = EndTime.difference(dtTime).inSeconds;
      final diffMinutes11 = EndTime.difference(dtTime);
      print('diffMinutes11 HomeScreen -> $diffMinutes11');
      return diffSeconds;
    } catch (err) {
      print('diffMinutes err HomeScreen -> $err');
      return 0;
    }
  }

  ///to store true-false answer and percentage
  Box? resultHive;
  setCurrentResult() async {
    resultHive = await Hive.openBox('result_hive');
    print('resultHive!.values.isNotEmpty -@ ${resultHive!.values.isNotEmpty}');
    if(resultHive!.values.isNotEmpty) {
      resultHive?.clear();
    }
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
          children: [
            Container(
              padding: const EdgeInsets.only(top: 0, left: 0, right: 0),
              height: height,
              width: width,
              child: Column(
                children: [
                  ///Title bar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // IconButton(
                      //   // icon: SvgPicture.asset('assets/icons/homescreen/menu.svg', height: 23, width: 23, semanticsLabel: 'menu'),
                      //   icon: const Icon(CupertinoIcons.home),
                      //   onPressed: (){
                      //     // Authentication.signOutGoogle().then((value) => SplashScreen());
                      //   },
                      // ),

                      Image.asset('assets/icons/homescreen/logo.png', height: 36, width: 36),
                      const Spacer(),
                      const SizedBox(width: 4),
                      const Text('pingoo', style: TextStyle(fontSize: 26.5, fontWeight: FontWeight.w400),),

                      const Spacer(),
                      // userHive?.values == null || userHive?.values.first['email'] == 'demo@pingoo.app' ?
                      IconButton(
                        icon: Image.asset('assets/icons/resultscreen/web.png', height: 23, width: 23),
                        // icon: const Icon(Icons.login),
                        onPressed: (){
                          webView.window.open('https://pingoo.app/', '');
                          // Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginScreen(isStoreData: false)));
                        },
                      )
                      //     : ClipOval(
                      //   child: userHive!.values.first['photoURL'].toString() != null
                      //       // ? Image.network(userHive!.values.first['photoURL'].toString(), height: 28, width: 28)
                      //       ? CachedNetworkImage(
                      //         imageUrl: userHive!.values.first['photoURL'].toString(), height: 28, width: 28,
                      //         fit: BoxFit.cover)
                      //       : Icon(CupertinoIcons.person_alt_circle)
                      // )



                      // IconButton(
                      //   icon: SvgPicture.asset('assets/icons/homescreen/bar-chart.svg', height: 21, width: 21),
                      //   onPressed: () async {
                      //     int timerMinutes = await initCountdownTimer();
                      //     var findTrue = lstRecord.where((element) => element == Answer.right);
                      //     Navigator.push(context, MaterialPageRoute(builder: (context) =>
                      //         ResultScreen(
                      //           minutes: timerMinutes,
                      //           topicName: topicName ?? '',
                      //           correctAns: findTrue.length,
                      //           isRewardPlay: false,
                      //           lstRecord: lstRecord,
                      //           cardLength: 10,
                      //         )));
                      //   },
                      // ),

                    ],
                  ),
                  const Divider(
                    color: Color.fromRGBO(189, 189, 189, 1),
                    height: 3,
                    thickness: 1,
                  ),
                  const Spacer(flex: 3),

                  Container(
                    height: height * 0.54,
                    child: FutureBuilder<Map<String, dynamic>>(
                      future: futureData,
                      builder: (BuildContext context, AsyncSnapshot<Map<String, dynamic>> snapshot) {
                        if(snapshot.connectionState == ConnectionState.none) {
                          return const Center(child: CircularProgressIndicator(color: orangeThemeColor));
                        } else if(snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: AutoSizeText('Loading today’s cards...', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16)));
                        } else {
                          if(snapshot.hasData) {
                            lstTrivia = snapshot.data!['list'];
                            cardLength = lstTrivia.length;

                            return Column(
                              children: [
                                Text(snapshot.data!['title'] ?? '', style: const TextStyle(fontSize: 29, fontWeight: FontWeight.w500), textAlign: TextAlign.center),

                                const SizedBox(height: 15),
                                lstTrivia.isNotEmpty ? Text('Card ${currentIndex + 1} of ${lstTrivia.length < 10 ? lstTrivia.length : 10}',
                                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),)
                                    : const SizedBox.shrink(),

                                Container(
                                  height: height * 0.43,
                                  alignment: cardLength == 0 ? Alignment.center : Alignment.topCenter,
                                  child: cardLength == 0 ? const AutoSizeText(
                                    'No Quiz Available',
                                    style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
                                  ) : Stack(
                                    children: [
                                      const Align(
                                        alignment: Alignment.center,
                                        child: Text('Completed', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                                      ),
                                      IgnorePointer(
                                        ignoring: true,
                                        child: TinderSwapCard(
                                          totalNum: lstTrivia.length < 10 ? lstTrivia.length : 10,
                                          swipeUp: false,
                                          swipeDown: false,
                                          orientation: AmassOrientation.bottom,
                                          stackNum: 3,
                                          maxWidth: width * 0.88,
                                          maxHeight: width * 0.85,
                                          minWidth: width * 0.81,
                                          minHeight: width * 0.81,
                                          // yAxis: 0.26,
                                          cardController: cardController,
                                          allowVerticalMovement: false,
                                          // allowHorizontalMovement: false,
                                          animDuration: 500,
                                          cardBuilder: (context, index) {
                                            return triviaCard(
                                                trivia: lstTrivia[index],
                                                currentIndex: index,
                                                totalCards: cardLength,
                                                width: width,
                                                height: height
                                            );
                                          },
                                          swipeCompleteCallback: (CardSwipeOrientation orientation, int index) async {
                                            currentIndex = index;
                                            i++;
                                            print('i @ $i');
                                            print('i @ ${lstTrivia[index].title!.split('\t')[0]}');

                                            print('quiz contain -> ${box!.values.contains(lstTrivia[index].title!.split('\t')[0])}');
                                            box?.add(lstTrivia[index].title!.split('\t')[0]);

                                            bool? ans;
                                            if(orientation == CardSwipeOrientation.right) {
                                              ans = true;
                                            } else {
                                              ans = false;
                                            }
                                            print('index @ $index');
                                            bool connotation = lstTrivia[index].connotation ?? false;
                                            print('lstTrivia[index].connotation! @ ${connotation}');
                                            if(ans == connotation) {
                                              lstRecord[lstRecord.indexWhere((answer) => answer == Answer.none)] = Answer.right;
                                              answer = Answer.right;
                                              resultHive?.add(true);
                                            } else {
                                              lstRecord[lstRecord.indexWhere((answer) => answer == Answer.none)] = Answer.wrong;
                                              answer = Answer.wrong;
                                              resultHive?.add(false);
                                            }

                                            // ///open result screen after every 10 cards
                                            // if(i == 10 || index == lstTrivia.length - 1) {
                                            //   // showLoginSkipScreen(context: context, isContinue: true);
                                            //
                                            //   int timerMinutes = await initCountdownTimer();
                                            //   final correctAns = lstRecord.where((element) => element == Answer.right);
                                            //
                                            //   final per = 100 * (correctAns.length) / 10;
                                            //   resultHive?.add(per);
                                            //
                                            //   Navigator.push(context, MaterialPageRoute(builder: (context) {
                                            //     return ResultScreen(
                                            //       seconds: timerMinutes,
                                            //       topicName: topicName,
                                            //       isRewardPlay: true,
                                            //       lstRecord: lstRecord,
                                            //       correctAns: correctAns.length,
                                            //       user: widget.user,
                                            //       cardLength: 10,
                                            //     );
                                            //   }));
                                            //   i = 0;
                                            // }

                                            setState(() {});
                                          },
                                        ),
                                      ),
                                      answer == Answer.none ? const SizedBox.shrink() : Align(
                                        alignment: const AlignmentDirectional(0, 0.1),
                                        child: answerCards(
                                            height: height,
                                            width: width,
                                            answer: answer,
                                            onTap: () async {

                                              print('currentIndex -> $currentIndex');
                                              answer = Answer.none;
                                              if(currentIndex == 9) {
                                                int countdownSeconds = await initCountdownTimer();
                                                final correctAns = lstRecord.where((element) => element == Answer.right);

                                                final per = 100 * (correctAns.length) / 10;
                                                resultHive?.add(per);

                                                Navigator.push(context, MaterialPageRoute(builder: (context) {
                                                  return ResultScreen(
                                                    seconds: countdownSeconds,
                                                    topicName: topicName,
                                                    isRewardPlay: true,
                                                    lstRecord: lstRecord,
                                                    correctAns: correctAns.length,
                                                    user: widget.user,
                                                    cardLength: 10,
                                                  );
                                                }));
                                                // showDialog(
                                                //     context: context,
                                                //     barrierDismissible: true,
                                                //     builder: (context) {
                                                //       return ResultScreen(
                                                //         seconds: countdownSeconds,
                                                //         topicName: topicName,
                                                //         isRewardPlay: true,
                                                //         lstRecord: lstRecord,
                                                //         correctAns: correctAns.length,
                                                //         user: widget.user,
                                                //         cardLength: 10,
                                                //       );
                                                //     }
                                                // );
                                              }

                                              setState(() {});
                                            }
                                        ),
                                      )
                                    ],
                                  ),
                                )
                              ],
                            );
                          } else {
                            return const Center(child: AutoSizeText('No Quiz Available', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16)));
                          }
                        }
                      },
                    ),
                  ),

                  const Spacer(flex: 1),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ///false button
                      bottomButtons(
                          imagePath: 'assets/icons/homescreen/false.png',
                          onTap: (){
                            if(answer == Answer.none) {
                              if(lstTrivia.isNotEmpty) {
                                setState(() {
                                  cardController.triggerLeft();
                                });
                              }
                            }
                          },
                          width: width
                      ),
                      const SizedBox(width: 55),
                      ///true button
                      bottomButtons(
                          imagePath: 'assets/icons/homescreen/true.png',
                          onTap: (){
                            if(answer == Answer.none) {
                              if(lstTrivia.isNotEmpty) {
                                setState(() {
                                  cardController.triggerRight();
                                });
                              }
                            }
                          },
                          width: width
                      ),
                    ],
                  ),
                  const Spacer(flex: 3,),

                ],
              ),
            ),
          ],
        )
    );
  }

  answerCards({required double width, required double height, required Answer answer, required Function() onTap}) {
    return Container(
      height: width * 0.85,
      width: width * 0.84,
      decoration: BoxDecoration(
          color: answer == Answer.right ? const Color.fromRGBO(232, 255, 248, 1) : const Color.fromRGBO(246, 225, 228, 1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: answer == Answer.right ? Colors.green : Colors.red, width: 1.2)
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                answer == Answer.right ? Image.asset('assets/icons/homescreen/correct.png', height: 21, width: 21)
                    : Image.asset('assets/icons/homescreen/caution.png', height: 24, width: 24),
                SizedBox(width: 12),
                AutoSizeText(answer == Answer.right ? 'Correct!' : 'Wrong!',
                  group: AutoSizeGroup(),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 15),
            Expanded(
              // height: height * 0.23,
              child: SingleChildScrollView(
                child: Wrap(
                  children: [
                    AutoSizeText(lstTrivia[currentIndex].shortAnswer!,
                      group: AutoSizeGroup(),
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                      maxLines: 15,
                      overflow: TextOverflow.ellipsis,
                    )
                  ],
                ),
              )
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                InkWell(
                  onTap: onTap,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 8),
                    decoration: BoxDecoration(
                      border: Border.all(color: answer == Answer.right ? Colors.green : Colors.red, width: 1.4),
                      borderRadius: BorderRadius.circular(10)
                    ),
                    child: Row(
                      children: [
                        const Text('NEXT CARD', style: TextStyle(color: Colors.black, fontSize: 13, fontWeight: FontWeight.w600),),
                        const SizedBox(width: 4),
                        Image.asset('assets/icons/homescreen/arrow.png', width: 13, height: 13)
                      ],
                    ),
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  bottomButtons({required Function() onTap, required String imagePath, required double width}) {
    return InkWell(
      splashColor: Colors.transparent,
      hoverColor: Colors.transparent,
      onTap: onTap,
      child: SizedBox(
        height: width * 0.15,
        width: width * 0.15,
        child: Image.asset(imagePath),
      ),
    );
  }

  triviaCard({required Trivia trivia, required int currentIndex, required int totalCards, required double width, required double height}) {
    var desc = trivia.title!.split('\t')[0];
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16)
      ),
      child: Container(
        padding: const EdgeInsets.only(top: 25, left: 20, right: 20, bottom: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: AutoSizeText(desc,
                group: AutoSizeGroup(),
                style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 20),
                maxLines: 20,
                maxFontSize: 20,
                minFontSize: 13,
                textScaleFactor: 1.1,
                softWrap: true,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(height: height * 0.02),

            trivia.templateId != null ? Expanded(
              child: CachedNetworkImage(
                imageUrl: trivia.img!,
                width: width * 0.8,
                height: height * 0.2,
                fit: BoxFit.fitHeight,
                errorWidget: (context, url, error) {
                  // return const Icon(Icons.error_outline, color: Colors.red);
                  return const SizedBox.shrink();
                },
              )
            ) : const SizedBox.shrink()
          ],
        ),
      ),
    );
  }
}


///America/Los_Angeles
///Asia/Kolkata
///this will get targetted time from user's location
Future<DateTime> getDestineTimeOfUser({required DateTime destineTime}) async {
  tz.initializeTimeZones();
  // final location = tz.timeZoneDatabase.locations;
  // print('location splashScreen@@-> ${location}');

  ///indian timezone
  var indianTimeZone = tz.getLocation('Asia/Kolkata');
  final indianTime = tz.TZDateTime.now(indianTimeZone);
  DateTime currentTimeIndia = DateTime(indianTime.year, indianTime.month, indianTime.day,
      indianTime.hour, indianTime.minute, indianTime.second);


  ///user's current timezone
  String currentTimeZone = await FlutterNativeTimezone.getLocalTimezone();

  var userTimeZone = tz.getLocation(currentTimeZone == 'Asia/Calcutta' ? 'Asia/Kolkata' : currentTimeZone);
  // var userTimeZone = tz.getLocation('Asia/Singapore');
  final userTime = tz.TZDateTime.now(userTimeZone);
  final currentTimeUser = DateTime(userTime.year, userTime.month, userTime.day,
      userTime.hour, userTime.minute, userTime.second);

  final diff = currentTimeUser.difference(currentTimeIndia);

  ///indian destine Time 9.30 pm
  final destineTimeIndia = destineTime;
  final destineTimeUser = destineTimeIndia.add(diff);
  return destineTimeUser;
}






class UnorderedList extends StatelessWidget {
  UnorderedList(this.texts);
  final List<String> texts;

  @override
  Widget build(BuildContext context) {
    var widgetList = <Widget>[];
    for (var text in texts) {
      // Add list item
      widgetList.add(UnorderedListItem(text));
      // Add space between items
      widgetList.add(const SizedBox(height: 5.0));
    }

    return Column(children: widgetList);
  }
}

class UnorderedListItem extends StatelessWidget {
  UnorderedListItem(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text("• "),
        Expanded(
          child: Text(text, style: TextStyle(fontSize: 18.5, fontWeight: FontWeight.w400)),
        ),
      ],
    );
  }
}


