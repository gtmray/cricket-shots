import 'package:cricket_shot_analysis/model/shotProfileModel.dart';

class ProfileModel {
  final int id;
  final String name;
  final String src;
  final String age;
  final String battingstyle;
  final String bowlingstyle;
  final String playingrole;
  final String teams;
  final String token;
  List<ShotProfileModel> shotprofile;
  ProfileModel({
    required this.id,
    required this.name,
    required this.src,
    required this.age,
    required this.battingstyle,
    required this.bowlingstyle,
    required this.playingrole,
    required this.teams,
    required this.shotprofile,
    required this.token,
  });
  factory ProfileModel.fromMap(Map<String, dynamic> map) => ProfileModel(
      id: int.parse(map['id']),
      name: map['name'],
      src: map['src'],
      age: map['age'],
      battingstyle: map['battingstyle'],
      bowlingstyle: map['bowlingstyle'],
      playingrole: map['playingrole'],
      teams: map['teams'],
      shotprofile: map['shot_profile'],
      token: map['token']);
  Map<String, dynamic> tomap() => {
        'name': name,
        'imageSrc': src,
        'age': age,
        "batting style": battingstyle,
        "bowling style": bowlingstyle,
        "playing role": playingrole,
        "teams": teams,
        "shotprofile": shotprofile
      };
}
