import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:get/get.dart';

class AnalyticsController extends GetxController {

  static FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  FirebaseAnalyticsObserver observer = FirebaseAnalyticsObserver(analytics: analytics);

  addUserIdEvent(String uid) async {
    await analytics.setUserId(id: uid);
  }

  addShareButtonEvent() async {
    await analytics.logEvent(
        name: 'share_btn_click',
        parameters: {
          'click_share' : 'share'
        }
    );
    print('-------->  share button event successfully logged  <--------');
  }
  
  shareButtonEvent() async {
    // await analytics.logShare(contentType: contentType, itemId: itemId, method: method);
    print('-------->  share button event successfully logged  <--------');
  }

  iOSButtonEvent() async {
    await analytics.logEvent(
        name: 'appstore_btn_click',
        parameters: {
          'click_appstore_btn' : 'open_appstore'
        }
    );
  }

  androidButtonEvent() async {
    await analytics.logEvent(
        name: 'playstore_btn_click',
        parameters: {
          'click_playstore_btn' : 'open_playstore'
        }
    );
  }

  screenEvent({required String screenName, required String screenClass}) async {
    await analytics.logEvent(
      name: 'screen_view',
      parameters: {
        'firebase_screen': screenName,
        'firebase_screen_class': screenClass,
      },
    );
  }

}