import 'dart:convert';

class UserToken {
  String? token;

  UserToken({
    this.token,
  });

  Map<String, dynamic> toMap() {
    return {
      'token': token,
    };
  }

  factory UserToken.fromMap(Map<String, dynamic> map) {
    return UserToken(
      token: map['token'],
    );
  }

  String toJson() => json.encode(toMap());

  factory UserToken.fromJson(String source) =>
      UserToken.fromMap(json.decode(source));
}
