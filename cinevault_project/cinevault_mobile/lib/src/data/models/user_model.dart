import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

@JsonSerializable()
class UserModel {
  final String? id;
  final String email;
  final String? displayName;
  final String? avatarUrl;
  final DateTime? createdAt;

  UserModel({
    this.id,
    required this.email,
    this.displayName,
    this.avatarUrl,
    this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => 
      _$UserModelFromJson(json);
  
  Map<String, dynamic> toJson() => _$UserModelToJson(this);
}

@JsonSerializable()
class AuthResponse {
  final String accessToken;
  final String? refreshToken;
  final String tokenType;
  final int expiresIn;

  AuthResponse({
    required this.accessToken,
    this.refreshToken,
    required this.tokenType,
    required this.expiresIn,
  });

  String get fullToken => '$tokenType $accessToken';

  factory AuthResponse.fromJson(Map<String, dynamic> json) => 
      _$AuthResponseFromJson(json);
  
  Map<String, dynamic> toJson() => _$AuthResponseToJson(this);
}