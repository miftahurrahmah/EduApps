// To parse this JSON data, do
//
//     final modelUpdateProfile = modelUpdateProfileFromJson(jsonString);

import 'dart:convert';

ModelUpdateProfile modelUpdateProfileFromJson(String str) => ModelUpdateProfile.fromJson(json.decode(str));

String modelUpdateProfileToJson(ModelUpdateProfile data) => json.encode(data.toJson());

class ModelUpdateProfile {
  bool isSuccess;
  int value;
  String message;

  ModelUpdateProfile({
    required this.isSuccess,
    required this.value,
    required this.message,
  });

  factory ModelUpdateProfile.fromJson(Map<String, dynamic> json) => ModelUpdateProfile(
    isSuccess: json["is_success"],
    value: json["value"],
    message: json["message"],
  );

  Map<String, dynamic> toJson() => {
    "is_success": isSuccess,
    "value": value,
    "message": message,
  };
}