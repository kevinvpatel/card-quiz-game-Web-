import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:swipecard_app/model/Trivia.dart';

// Future<List<Trivia>> getCardData({required User user}) async {
//   String mainUrl = "https://us-central1-innovearn.cloudfunctions.net/api/v1/feed/trivia?lang=english&topicId=-MT2xymn_dO9I2Ck9Mw2";
//   String token = await user.getIdToken();
//   // print('token -> $token');
//   // Trivia trivia = Trivia();
//   List<Trivia> lstTrivia = [];
//
//   try{
//     http.Response response = await http.get(
//         Uri.parse(mainUrl),
//         headers: {
//           'Authorization' : 'Bearer $token'
//         }
//     );
//
//     List responseData = json.decode(response.body);
//
//     for (var element in responseData) {
//       final trivia = Trivia(
//         articleId: element['articleId'],
//         connotation: element['connotation'],
//         difficultyLevelId: element['difficultyLevelId'],
//         groupId: element['groupId'],
//         id: element['id'],
//         img: element['img'],
//         shortAnswer: element['shortAnswer'],
//         sortIndex: element['sortIndex'],
//         tags: element['tags'],
//         templateId: element['templateId'],
//         title: element['title'],
//         topicId: element['topicId'],
//       );
//       // print('triv -> ${trivia.img}');
//       lstTrivia.add(trivia);
//     }
//
//   } catch(e) {
//     print('api error -> $e');
//   }
//   return lstTrivia;
// }


// Future<String> randomTopicIdApi({required User user}) async {
//   String mainUrl = "https://us-central1-innovearn.cloudfunctions.net/api/v1/feed/topics?lang=english";
//   String token = await user.getIdToken();
//   // print('token -> $token');
//   String randomTopicId = '';
//
//   try{
//     http.Response response = await http.get(
//         Uri.parse(mainUrl),
//         headers: {
//           'Authorization' : 'Bearer $token'
//         }
//     );
//
//     List responseData = json.decode(response.body);
//     var randomTopic = (responseData..shuffle()).first;
//     randomTopicId = randomTopic['id'];
//
//   } catch(e) {
//     print('randomTopicIdApi error -> $e');
//   }
//   return randomTopicId;
// }


Future<List<Map<String, String>>> randomTopicNameApi({required User user}) async {
  String mainUrl = "https://us-central1-innovearn.cloudfunctions.net/api/v1/feed/topics?lang=english";
  String token = await user.getIdToken();
  List<Map<String, String>> lstMap = [];

  try{
    http.Response response = await http.get(
        Uri.parse(mainUrl),
        headers: {
          'Authorization' : 'Bearer $token'
        }
    );

    List responseData = json.decode(response.body);
    responseData.forEach((element) {
      Map<String, String> str = {};
      str['title'] = element['title'];
      str['id'] = element['id'];
      str['publishStatusId'] = element['publishStatusId'] ?? 'un-published';
      str['pricePlan'] = element['pricePlan'] ?? 'premium';
      lstMap.add(str);
    });
    lstMap.removeWhere((element) {
      return element['publishStatusId'] == 'un-published' ||
          element['publishStatusId'] == 'in-review' ||
          element['publishStatusId'] == null;
    });

    lstMap.removeWhere((element) {
      return element['pricePlan'] == 'memebers' ||
          element['pricePlan'] == 'premium' ||
          element['pricePlan'] == null;
    });

  } catch(e) {
    print('randomTopicNameApi error -> $e');
  }
  return lstMap;
}



Future<Map<String,dynamic>> getRandomTopicDataApi({required User user, required String topicId, required String topicName}) async {

  List<Trivia> lstTrivia = [];
  Map<String,dynamic> map = {};

  String mainUrl = "https://us-central1-innovearn.cloudfunctions.net/api/v1/feed/trivia?lang=english&topicId=$topicId";
  // String mainUrl = "https://us-central1-innovearn.cloudfunctions.net/api/v1/feed/trivia?lang=english&topicId=-Mwhe49U4qEmQwnJBRO9";
  String token = await user.getIdToken();
  print('token -> $token');
  print('topicId -> $topicId');

  try{
    http.Response response = await http.get(
        Uri.parse(mainUrl),
        headers: {
          'Authorization' : 'Bearer $token'
        }
    );

    List responseData = json.decode(response.body);
    for (var element in responseData) {
      final trivia = Trivia(
          connotation: element['connotation'],
          difficultyLevelId: element['difficultyLevelId'],
          groupId: element['groupId'],
          id: element['id'],
          tags: element['tags'],
          img: element['img'],
          shortAnswer: element['shortAnswer'],
          sortIndex: element['sortIndex'],
          templateId: element['templateId'],
          title: element['title'],
          topicId: element['topicId'],
          postId: element['postId'],
          themeId: element['themeId']
      );
      lstTrivia.add(trivia);
    }
    map['title'] = topicName;
    map['list'] = lstTrivia;
  } catch(e) {
    print('getRandomTopicDataApi error -> $e');
  }

  return map;
}