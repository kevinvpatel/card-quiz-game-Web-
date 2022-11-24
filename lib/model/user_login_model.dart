class UserLoginModel{
  final String? uId;
  final String? name;
  final String? email;
  final String? profilePicture;
  final String? idToken;

  UserLoginModel({this.idToken, this.uId, this.name, this.email, this.profilePicture});
  factory UserLoginModel.fromJson(Map<String, dynamic>json) =>
      UserLoginModel(
          uId: json['uId'],
          name: json['name'],
          email: json['email'],
          profilePicture: json['profilePicture'],
          idToken: json['idToken'].forEach((e) => e)
      );

  Map<String,dynamic> toJson()=>{
    'uId': uId,
    'name': name,
    'email': email,
    'profilePicture': profilePicture,
    'idToken': idToken,
  };
}