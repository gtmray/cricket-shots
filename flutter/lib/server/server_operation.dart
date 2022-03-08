import 'dart:convert';
import 'package:cricket_shot_analysis/constant.dart';
import 'package:cricket_shot_analysis/model/profilemodel.dart';
import 'package:cricket_shot_analysis/model/shotmodel.dart';
import 'package:cricket_shot_analysis/random/data.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class ServerOp {
  Dio dio = Dio();
  final String _apiKey = "35a0e66686msh0132bd26a0c4c52p19b51bjsn87c08e9f9fbb";
  final String _website = "https://shotanalysis.000webhostapp.com";
  final String _fastapi =
      // "http://cricketshotanalysis.herokuapp.com";
      "http://ec2-3-22-51-152.us-east-2.compute.amazonaws.com:8000";
  Future<List> fetchNewsList() async {
    try {
      Uri url =
          Uri.parse("https://unofficial-cricbuzz.p.rapidapi.com/news/list");
      var headers = {
        'accept': 'application/json',
        'x-rapidapi-key': _apiKey,
        'x-rapidapi-host': 'unofficial-cricbuzz.p.rapidapi.com'
      };
      var response = await http.get(
        url,
        headers: headers,
      );
      var outputdata = jsonDecode(response.body)['newsList'];
      List story = [];
      for (int i = 0; i < outputdata.length; i++) {
        story.add(outputdata[i]['story']);
      }

      return story;
    } catch (e) {
      return [];
    }
  }

  Future fetchplayerProfile() async {
    try {
      final uri = Uri.parse("$_website/getplayernew.php");
      var response = await http.get(uri);
      if (response.statusCode == 200) {
        // print(response.body);
        return jsonDecode(response.body);
      } else {
        // print(response.statusCode);
        return null;
      }
    } catch (e) {
      // print(e);
      return null;
    }
  }

  Future fetchShot() async {
    try {
      final uri = Uri.parse("$_website/getshot.php");
      var response = await http.get(uri);
      // print(response.statusCode);
      if (response.statusCode == 200) {
        // print(response.body);
        return jsonDecode(response.body);
      } else {
        // print(response.statusCode);
        return null;
      }
    } catch (e) {
      // print(e);
      return null;
    }
  }

  Future fetchSampleAnalysis() async {
    try {
      final uri = Uri.parse("$_website/get_sample_analysis.php");
      var response = await http.get(uri);
      if (response.statusCode == 200) {
        print(response.body);
        return jsonDecode(response.body);
      } else {
        print(response.statusCode);
      }
    } catch (e) {
      print(e);
    }
  }

  Future setProfile(
      {required String age,
      required String name,
      required String bowlingstyle,
      required String battingstyle,
      required String playingrole,
      required String teams,
      required String imagePath,
      required String token,
      required BuildContext context}) async {
    try {
      final uri = Uri.parse("$_website/players_upload.php");
      var request = http.MultipartRequest('POST', uri);
      request.fields["name"] = name;
      request.fields["age"] = age;
      request.fields["bowlingstyle"] = bowlingstyle;
      request.fields["battingstyle"] = battingstyle;
      request.fields["playingrole"] = playingrole;
      request.fields["teams"] = teams;
      request.fields["token"] = token;
      // added image on api
      var picture = await http.MultipartFile.fromPath("image", imagePath);
      request.files.add(picture);
      var response = await request.send();
      // print(response.statusCode);
      if (response.statusCode == 200) {
        SnackBar snackBar = const SnackBar(
            duration: Duration(milliseconds: 500),
            content: Text(
              "Players added",
              style: TextStyle(
                  fontFamily: 'OpenSans', color: Colors.white, fontSize: 18),
            ));
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        List data = await fetchplayerProfile();
        Map playerdetail = data[data.length - 1];
        // print("playerdetaild $playerdetail");
        // add six shot on shot of db
        for (int i = 0; i < shot_profile.length; i++) {
          Map<String, dynamic> shotmap = {
            "id": "1",
            "shot_id": shot_profile[i]['id'].toString(),
            "player_id": playerdetail['id'].toString(),
            "shot_frequency": "0",
            "efficiency": "0.0",
          };
          // print(shotmap);
          ShotModel shotModel = ShotModel.fromMap(shotmap);
          // print(shotModel.shotid);
          addShot(shotModel: shotModel, context: context);
        }
      } else {
        SnackBar snackBar = const SnackBar(
            duration: Duration(milliseconds: 500),
            content: Text(
              "Failed to upload",
              style: TextStyle(
                  fontFamily: 'OpenSans', color: Colors.white, fontSize: 18),
            ));
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    } catch (e) {
      // print(e);
    }
  }

  Future editProfile(
      {required String age,
      required String name,
      required String bowlingstyle,
      required String battingstyle,
      required String playingrole,
      required String teams,
      required int id,
      required BuildContext context}) async {
    try {
      print("$_website/profile_edit.php");
      final uri = Uri.parse("$_website/profile_edit.php");
      var body = {
        "id": id.toString(),
        "name": name,
        "age": age,
        "bowlingstyle": bowlingstyle,
        "battingstyle": battingstyle,
        "playingrole": playingrole,
        "teams": teams
      };
      var response = await http.post(uri, body: body);
      if (response.statusCode == 200) {
        SnackBar snackBar = const SnackBar(
            duration: Duration(milliseconds: 500),
            content: Text(
              "Players Edited",
              style: TextStyle(
                  fontFamily: 'OpenSans', color: Colors.white, fontSize: 18),
            ));
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      } else {
        SnackBar snackBar = const SnackBar(
            duration: Duration(milliseconds: 500),
            content: Text(
              "Failed to Edit",
              style: TextStyle(
                  fontFamily: 'OpenSans', color: Colors.white, fontSize: 18),
            ));
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    } catch (e) {
      // print(e);
    }
  }

  Future generateToken() async {
    String url = "$_fastapi/uuid";
    Response response = await dio.get(url);
    print(response.statusCode);
    if (response.statusCode == 200) {
      print("asdad ${response.data}");
      return response.data;
    }
  }

  Future predictShot({required String filePath}) async {
    try {
      String url = "$_fastapi/files/";
      var headers = {
        'accept': 'application/json',
        'Content-Type': 'multipart/form-data'
      };
      String filename = filePath.split('/').last;
      FormData formData = FormData.fromMap({
        "file": await MultipartFile.fromFile(
          filePath,
          filename: filename,
          contentType: MediaType('image', 'jpeg'),
        ),
        "type": 'image/jpeg'
      });
      Response response = await dio.post(url,
          data: formData,
          options: Options(
            headers: headers,
          ));
      if (response.statusCode == 200) {
        return response.data;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  Future addShot(
      {required ShotModel shotModel, required BuildContext context}) async {
    try {
      final uri = Uri.parse("$_website/shot_upload.php");
      var body = {
        "player_id": shotModel.playerid.toString(),
        "shot_id": shotModel.shotid.toString(),
        "shot_frequency": shotModel.frequency.toString(),
        "efficiency": shotModel.efficiency.toString(),
      };
      var response = await http.post(uri, body: body);
      if (response.statusCode == 200) {
        // SnackBar snackBar = SnackBar(
        //     content: Text(
        //   "Uploaded shot Successfully",
        //   style: textStyle,
        // ));
        // ScaffoldMessenger.of(context).showSnackBar(snackBar);
      } else {
        SnackBar snackBar = SnackBar(
            content: Text(
          "Failed to upload shot",
          style: textStyle,
        ));
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    } catch (e) {
      print(e);
    }
  }

  Future updateShot(
      {required ShotModel shotModel, required BuildContext context}) async {
    try {
      final uri = Uri.parse("$_website/shot_edit.php");
      var body = {
        "id": shotModel.id.toString(),
        "player_id": shotModel.playerid.toString(),
        "shot_id": shotModel.shotid.toString(),
        "shot_frequency": shotModel.frequency.toString(),
        "efficiency": shotModel.efficiency.toString(),
      };
      var response = await http.post(uri, body: body);
      print(response.statusCode);
      if (response.statusCode == 200) {
        // SnackBar snackBar = SnackBar(
        //     content: Text(
        //   "Uploaded shot Successfully",
        //   style: textStyle,
        // ));
        // ScaffoldMessenger.of(context).showSnackBar(snackBar);
      } else {
        SnackBar snackBar = SnackBar(
            content: Text(
          "Failed to upload shot",
          style: textStyle,
        ));
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    } catch (e) {
      print(e);
    }
  }
}
