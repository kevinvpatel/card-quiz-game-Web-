// class Trivia {
//   String? articleId;
//   bool? connotation;
//   String? difficultyLevelId;
//   String? groupId;
//   String? id;
//   String? img;
//   String? shortAnswer;
//   int? sortIndex;
//   List<dynamic>? tags;
//   String? templateId;
//   String? title;
//   String? topicId;
//
//   Trivia(
//       {this.articleId,
//         this.connotation,
//         this.difficultyLevelId,
//         this.groupId,
//         this.id,
//         this.img,
//         this.shortAnswer,
//         this.sortIndex,
//         this.tags,
//         this.templateId,
//         this.title,
//         this.topicId});
//
//   factory Trivia.fromJson(Map<String, dynamic> json) =>
//     Trivia(
//       articleId: json['articleId'],
//       connotation: json['connotation'],
//       difficultyLevelId: json['difficultyLevelId'],
//       groupId: json['groupId'],
//       id: json['id'],
//       img: json['img'],
//       shortAnswer: json['shortAnswer'],
//       sortIndex: json['sortIndex'],
//       tags: json['tags'],
//       templateId: json['templateId'],
//       title: json['title'],
//       topicId: json['topicId'],
//     );
//
//   Map<String, dynamic> toJson() => {
//     'articleId' : articleId,
//     'connotation' : connotation,
//     'difficultyLevelId' : difficultyLevelId,
//     'groupId' : groupId,
//     'id' : id,
//     'img' : img,
//     'shortAnswer' : shortAnswer,
//     'sortIndex' : sortIndex,
//     'tags' : tags,
//     'templateId' : templateId,
//     'title' : title,
//     'topicId' : topicId,
//   };
// }

class Trivia {
  bool? connotation;
  String? difficultyLevelId;
  String? groupId;
  String? id;
  String? img;
  String? postId;
  String? shortAnswer;
  int? sortIndex;
  List<dynamic>? tags;
  String? templateId;
  String? themeId;
  String? title;
  String? topicId;

  Trivia(
      {this.connotation,
        this.difficultyLevelId,
        this.groupId,
        this.id,
        this.img,
        this.postId,
        this.shortAnswer,
        this.sortIndex,
        this.tags,
        this.templateId,
        this.themeId,
        this.title,
        this.topicId});

  factory Trivia.fromJson(Map<String, dynamic> json) => Trivia(
    connotation : json['connotation'],
    difficultyLevelId : json['difficultyLevelId'],
    groupId : json['groupId'],
    id : json['id'],
    img : json['img'],
    postId : json['postId'],
    shortAnswer : json['shortAnswer'],
    sortIndex : json['sortIndex'],
    tags : json['tags'].cast<String>(),
    templateId : json['templateId'],
    themeId : json['themeId'],
    title : json['title'],
    topicId : json['topicId']
  );

  Map<String, dynamic> toJson() => {
    'connotation' : connotation,
    'difficultyLevelId' : difficultyLevelId,
    'groupId' : groupId,
    'id' : id,
    'img' : img,
    'postId' : postId,
    'shortAnswer' : shortAnswer,
    'sortIndex' : sortIndex,
    'tags' : tags,
    'templateId' : templateId,
    'themeId' : themeId,
    'title' : title,
    'topicId' : topicId
  };
}