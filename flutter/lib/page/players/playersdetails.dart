import 'package:cricket_shot_analysis/model/profilemodel.dart';
import 'package:cricket_shot_analysis/model/shotProfileModel.dart';
import 'package:cricket_shot_analysis/model/shotmodel.dart';
import 'package:cricket_shot_analysis/page/analysis/image.dart';
import 'package:cricket_shot_analysis/page/homepage.dart';
import 'package:cricket_shot_analysis/page/players/addplayersdetails.dart';
import 'package:cricket_shot_analysis/provider/shotprovider.dart';
import 'package:cricket_shot_analysis/random/data.dart';
import 'package:cricket_shot_analysis/server/server_operation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../constant.dart';

class PlayersDetails extends StatefulWidget {
  final ProfileModel profileModel;
  const PlayersDetails({Key? key, required this.profileModel})
      : super(key: key);

  @override
  // ignore: no_logic_in_create_state
  _PlayersDetailsState createState() => _PlayersDetailsState(profileModel);
}

class _PlayersDetailsState extends State<PlayersDetails> {
  final ImagePicker _picker = ImagePicker();
  ProfileModel _profileModel;
  Map result = {};
  _PlayersDetailsState(this._profileModel);
  late Shotprovider _shotprovider;
  String? _mostPlayedShot;
  ProfileModel? _fromEditprofileModel;
  int? _times;
  // late List shot;
  String? detectedShot;
  // color for piechart
  List<Color> colorList = [
    Colors.red,
    Colors.green,
    Colors.blue,
    Colors.blueGrey,
    Colors.yellow,
    Colors.teal
  ];
  late Map<String, double> dataMap;
  // list of shots for check
  Map<int, String> classeslist = {
    0: 'CutShot',
    1: 'CoverDrive',
    2: 'StraightDrive',
    3: 'PullShot',
    4: 'LegGlance',
    5: 'Scoop'
  };
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (token == null) {
      generateToken();
    }
    dataMap = {
      _profileModel.shotprofile[0].shotname:
          _profileModel.shotprofile[0].frequency.toDouble(),
      _profileModel.shotprofile[1].shotname:
          _profileModel.shotprofile[1].frequency.toDouble(),
      _profileModel.shotprofile[2].shotname:
          _profileModel.shotprofile[2].frequency.toDouble(),
      _profileModel.shotprofile[3].shotname:
          _profileModel.shotprofile[3].frequency.toDouble(),
      _profileModel.shotprofile[4].shotname:
          _profileModel.shotprofile[4].frequency.toDouble(),
      _profileModel.shotprofile[5].shotname:
          _profileModel.shotprofile[5].frequency.toDouble(),
    };

    for (int i = 0; i < _profileModel.shotprofile.length; i++) {
      print(_profileModel.shotprofile[i].toMap());
    }
  }

  void generateToken() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var data = await ServerOp().generateToken();
    print(data);
    print(data.runtimeType);
    sharedPreferences.setString("token", data["token"]);
  }

  ShotProfileModel checkMostPlayedShot(Shotprovider shotprovider) {
    List _shotTimes = [];
    ShotProfileModel shotSelected = _shotprovider.profilemodel.shotprofile[0];
    for (int i = 0; i < _shotprovider.profilemodel.shotprofile.length; i++) {
      _shotTimes.add(_shotprovider.profilemodel.shotprofile[i].frequency);
    }
    _shotTimes.sort();

    for (int i = 0; i < _shotprovider.profilemodel.shotprofile.length; i++) {
      if (_shotprovider.profilemodel.shotprofile[i].frequency ==
          _shotTimes.last) {
        shotSelected = _shotprovider.profilemodel.shotprofile[i];
      }
    }
    return shotSelected;
  }

// for least played shot
  ShotProfileModel checkLeastPlayedShot(Shotprovider shotprovider) {
    List _shotTimes = [];
    ShotProfileModel shotSelected = _shotprovider.profilemodel.shotprofile[0];

    for (int i = 0; i < _shotprovider.profilemodel.shotprofile.length; i++) {
      // added data on list
      _shotTimes.add(_shotprovider.profilemodel.shotprofile[i].frequency);
    }
    // short data
    _shotTimes.sort();

    for (int i = 0; i < _shotprovider.profilemodel.shotprofile.length; i++) {
      if (_shotprovider.profilemodel.shotprofile[i].frequency ==
          _shotTimes.first) {
        shotSelected = _shotprovider.profilemodel.shotprofile[i];
      }
    }
    return shotSelected;
  }

// update shot on detect
  void updateShot(Shotprovider shotprovider) {
    for (int item = 0; item < 6; item++) {
      print("$result");
      if (result.isNotEmpty) {
        print(_shotprovider.profileModel!.shotprofile[item].shotname);
        print(result['PredictedShot']);
        print(classeslist[result['PredictedShot']]);
        // if predicted shot is match with available shot then update
        if (_shotprovider.profileModel!.shotprofile[item].shotname ==
            classeslist[result['PredictedShot']]) {
          print("i am inside shot");
          shotprovider
              .update(profileModelReturn(classeslist[result['PredictedShot']]));
          print(shotprovider.profileModel!.shotprofile);
          print("shot is ${shotprovider.profileModel!.shotprofile[0].toMap()}");
          shotprovider.dataMapValue(_shotprovider.profilemodel);
          // print(_shotprovider.profilemodel.shotprofile[item].frequency);
          // print("hello");
          // print(shotmodel.length);
          for (int i = 0; i < shotmodel.length; i++) {
            // print("seperate");
            // print(shotmodel[i].playerid);
            // print(_shotprovider.profilemodel.id);

            // print(shotmodel[i].shotid);
            // print(_shotprovider
            //     .profilemodel.shotprofile[item].id);
            if ((shotmodel[i].playerid == _shotprovider.profilemodel.id) &&
                (shotmodel[i].shotid ==
                    _shotprovider.profilemodel.shotprofile[item].id)) {
              print("i am sdfsdf");
              print(shotmodel[i].id);
              Map<String, dynamic> shotmap = {
                "id": shotmodel[i].id.toString(),
                "shot_id":
                    _shotprovider.profilemodel.shotprofile[item].id.toString(),
                "player_id": _shotprovider.profilemodel.id.toString(),
                "shot_frequency": _shotprovider
                    .profilemodel.shotprofile[item].frequency
                    .toString(),
                "efficiency": "0.0",
              };
              print(shotmap);
              ServerOp().updateShot(
                  shotModel: ShotModel.fromMap(shotmap), context: context);
            }
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // shot provider for update shot on all screen
    _shotprovider = Provider.of<Shotprovider>(context, listen: false);
    result.isEmpty
        ? (_fromEditprofileModel == null
            ? _shotprovider.profileModel = _profileModel
            : null)
        : null;
    result.isEmpty ? _shotprovider.dataMap = dataMap : null;

    // _shotprovider.tokenProviderDAta = token;
// consumer of shot provider for getting updated data of shot
    return Consumer<Shotprovider>(builder: (_, shotprovider, __) {
      return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.transparent,
          automaticallyImplyLeading: false,
          leading: IconButton(
              onPressed: () {
                Navigator.pop(context, _shotprovider.profilemodel);
              },
              icon: const Icon(
                FontAwesomeIcons.chevronLeft,
                color: Colors.black,
              )),
          actions: [
            _shotprovider.profilemodel.token == token
                ? IconButton(
                    onPressed: () {
                      Future data = Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => AddPlayersDetails(
                                    from: "Edit",
                                    profileModel: _shotprovider.profileModel,
                                  )));
                      data.then((value) => {
                            print("from $value"),
                            if (value != null)
                              {
                                setState(() => {
                                      _fromEditprofileModel = value,
                                      _shotprovider.profileModel = value,
                                    })
                              }
                          });
                    },
                    icon: const Icon(
                      Icons.edit,
                      color: Colors.black,
                    ))
                : const SizedBox()
          ],
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                heightSpace(20),
                Center(
                  child: CircleAvatar(
                    radius: 50,
                    foregroundImage: NetworkImage(
                        "https://shotanalysis.000webhostapp.com/players/${_shotprovider.profilemodel.src}"),
                    backgroundImage:
                        const AssetImage("assets/images/loader.gif"),
                  ),
                ),
                heightSpace(20),
                Text(
                  _shotprovider.profilemodel.name,
                  style: textStyle,
                  textAlign: TextAlign.center,
                ),
                heightSpace(30),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          heightSpace(5),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("AGE "),
                              Text(_shotprovider.profilemodel.age.toString())
                            ],
                          ),
                          heightSpace(10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("BATTING STYLE "),
                              widthSpace(70),
                              Expanded(
                                  child: Text(
                                _shotprovider.profilemodel.battingstyle,
                                textDirection: TextDirection.rtl,
                              ))
                            ],
                          ),
                          heightSpace(10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("BOWLING STYLE "),
                              widthSpace(70),
                              Expanded(
                                  child: Text(
                                _shotprovider.profilemodel.bowlingstyle,
                                textDirection: TextDirection.rtl,
                              ))
                            ],
                          ),
                          heightSpace(10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("PLAYING ROLE "),
                              widthSpace(70),
                              Expanded(
                                  child: Text(
                                _shotprovider.profilemodel.playingrole,
                                textDirection: TextDirection.rtl,
                              ))
                            ],
                          ),
                          heightSpace(10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("TEAMS "),
                              widthSpace(80),
                              Expanded(
                                  child: Text(
                                _shotprovider.profilemodel.teams,
                                textDirection: TextDirection.rtl,
                              ))
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 13,
                            vertical: 20,
                          ),
                          child: Column(
                            children: [
                              Text(
                                "List of Analysed Shot ",
                                style: textStyle,
                              ),
                              heightSpace(10),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Shot",
                                    style: textStyle,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    "Shot_frequency",
                                    style: textStyle,
                                    overflow: TextOverflow.ellipsis,
                                  )
                                ],
                              ),
                              heightSpace(5),
                              ListView.builder(
                                  itemCount: _shotprovider
                                      .profilemodel.shotprofile.length,
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemBuilder: (context, index) {
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 5),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(_shotprovider.profilemodel
                                              .shotprofile[index].shotname),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                right: 20),
                                            child: Text(_shotprovider
                                                .profilemodel
                                                .shotprofile[index]
                                                .frequency
                                                .toString()),
                                          )
                                        ],
                                      ),
                                    );
                                  }),
                            ],
                          ),
                        ))),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 20,
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("MOST PLAYED SHOT "),
                              Text(checkMostPlayedShot(_shotprovider).shotname)
                            ],
                          ),
                          heightSpace(10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("SHOT_FREQUENCY"),
                              Padding(
                                padding: const EdgeInsets.only(right: 20),
                                child: Text(checkMostPlayedShot(_shotprovider)
                                    .frequency
                                    .toString()),
                              )
                            ],
                          ),
                          // heightSpace(10),
                          // Row(
                          //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          //   children: [
                          //     Text("EFFICIENCY"),
                          //     Text(checkMostPlayedShot(_shotprovider)
                          //         .efficiency
                          //         .toString())
                          //   ],
                          // ),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 20,
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("LEAST PLAYED SHOT "),
                              Text(checkLeastPlayedShot(_shotprovider).shotname)
                            ],
                          ),
                          heightSpace(10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("SHOT_FREQUENCY"),
                              Padding(
                                padding: const EdgeInsets.only(right: 20),
                                child: Text(checkLeastPlayedShot(_shotprovider)
                                    .frequency
                                    .toString()),
                              )
                            ],
                          ),
                          // heightSpace(10),
                          // Row(
                          //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          //   children: [
                          //     Text("EFFICIENCY"),
                          //     Text(checkLeastPlayedShot(_shotprovider)
                          //         .efficiency
                          //         .toString())
                          //   ],
                          // ),
                        ],
                      ),
                    ),
                  ),
                ),
                heightSpace(30),
                PieChart(
                  dataMap: shotprovider.datamap,
                  animationDuration: const Duration(milliseconds: 800),
                  chartLegendSpacing: 32,
                  chartRadius: MediaQuery.of(context).size.width / 2.5,
                  colorList: colorList,
                  initialAngleInDegree: 0,
                  chartType: ChartType.disc,
                  ringStrokeWidth: 32,

                  legendOptions: const LegendOptions(
                    showLegendsInRow: false,
                    legendPosition: LegendPosition.right,
                    showLegends: true,
                    legendShape: BoxShape.circle,
                    legendTextStyle: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  chartValuesOptions: const ChartValuesOptions(
                    showChartValueBackground: true,
                    showChartValues: true,
                    showChartValuesInPercentage: true,
                    showChartValuesOutside: false,
                    decimalPlaces: 0,
                  ),
                  // gradientList: ---To add gradient colors---
                  // emptyColorGradient: ---Empty Color gradient---
                ),
                heightSpace(20),
                _shotprovider.profilemodel.token == token
                    ? IconButton(
                        onPressed: () {
                          // updateShot(shotprovider);
                          showDialog(
                              context: context,
                              builder: (context) => showdialog(shotprovider));
                          // Future value = Navigator.push(
                          //     context,
                          //     MaterialPageRoute(
                          //         builder: (context) =>
                          //             const Analysis(from: "Camera")));
                          // value.then((value) => {
                          //       if (value != null)
                          //         {
                          //           ServerOp().updateShot(
                          //               shotModel: value, context: context)
                          //         }
                          //     });
                        },
                        icon: const Icon(
                          FontAwesomeIcons.camera,
                          size: 50,
                        ))
                    // ListView.builder(
                    //     shrinkWrap: true,
                    //     itemCount: 6,
                    //     itemBuilder: (context, item) {
                    //       return Padding(
                    //         padding: const EdgeInsets.only(right: 10),
                    //         child: Center(
                    //           child: ElevatedButton(
                    //             onPressed: () {
                    //               shotprovider.update(profileModelReturn(
                    //                   _shotprovider.profilemodel
                    //                       .shotprofile[item].shotname));
                    //               shotprovider
                    //                   .dataMapValue(_shotprovider.profilemodel);
                    //               print(_shotprovider.profilemodel
                    //                   .shotprofile[item].frequency);
                    //               // print("hello");
                    //               // print(shotmodel.length);
                    //               for (int i = 0; i < shotmodel.length; i++) {
                    //                 // print("seperate");
                    //                 // print(shotmodel[i].playerid);
                    //                 // print(_shotprovider.profilemodel.id);

                    //                 // print(shotmodel[i].shotid);
                    //                 // print(_shotprovider
                    //                 //     .profilemodel.shotprofile[item].id);
                    //                 if ((shotmodel[i].playerid ==
                    //                         _shotprovider.profilemodel.id) &&
                    //                     (shotmodel[i].shotid ==
                    //                         _shotprovider.profilemodel
                    //                             .shotprofile[item].id)) {
                    //                   print("i am sdfsdf");
                    //                   print(shotmodel[i].id);
                    //                   Map<String, dynamic> shotmap = {
                    //                     "id": shotmodel[i].id.toString(),
                    //                     "shot_id": _shotprovider
                    //                         .profilemodel.shotprofile[item].id
                    //                         .toString(),
                    //                     "player_id": _shotprovider
                    //                         .profilemodel.id
                    //                         .toString(),
                    //                     "shot_frequency": _shotprovider
                    //                         .profilemodel
                    //                         .shotprofile[item]
                    //                         .frequency
                    //                         .toString(),
                    //                     "efficiency": "0.0",
                    //                   };
                    //                   print(shotmap);
                    //                   ServerOp().updateShot(
                    //                       shotModel: ShotModel.fromMap(shotmap),
                    //                       context: context);
                    //                 }
                    //               }
                    //             },
                    //             child: Text(
                    //               _shotprovider
                    //                   .profilemodel.shotprofile[item].shotname,
                    //               style: textStyle,
                    //             ),
                    //             style: ElevatedButton.styleFrom(
                    //                 padding: const EdgeInsets.symmetric(
                    //                     horizontal: 20, vertical: 10)),
                    //           ),
                    //         ),
                    //       );
                    //     })
                    : const SizedBox(),

                heightSpace(30),
                // result.isNotEmpty ? Text("$result") : const SizedBox(),
                // result.isNotEmpty ? heightSpace(20) : const SizedBox(),
                // Text(
                //   "token: ${_shotprovider.profilemodel.token}",
                //   textAlign: TextAlign.center,
                //   style: textStyle,
                // ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Dialog showdialog(Shotprovider shotProvider) {
    return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              InkWell(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      const Icon(
                        FontAwesomeIcons.fileUpload,
                        size: 25,
                      ),
                      widthSpace(30),
                      Text(
                        "Pick From File",
                        style: textStyleTitle,
                      ),
                    ],
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  Future value = Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              const Analysis(from: "Gallery")));
                  value.then((value) => {
                        setState(() => {result = value}),
                        updateShot(shotProvider)
                      });

                  // imagePicker(ImageSource.gallery);
                },
              ),
              heightSpace(10),
              InkWell(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      const Icon(
                        FontAwesomeIcons.camera,
                        size: 25,
                      ),
                      widthSpace(33),
                      Text(
                        "Camera",
                        style: textStyleTitle,
                      ),
                    ],
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              const Analysis(from: "Camera")));
                  // imagePicker(
                  //   ImageSource.camera,
                  // );
                },
              )
            ],
          ),
        ));
  }

// for update profilemodel
  ProfileModel profileModelReturn(String? shot) {
    List<ShotProfileModel> shotprofileModel = [];
    print(shot_profile.length);
    for (int i = 0; i < shot_profile.length; i++) {
      int frequency = _shotprovider.profilemodel.shotprofile[i].frequency;
      print("my shot is $shot");
      print(
          "other shot is ${_shotprovider.profilemodel.shotprofile[i].shotname}");
      if (_shotprovider.profilemodel.shotprofile[i].shotname == shot) {
        frequency++;
        print("i am in");
      }
      print("i am $frequency");
      Map<String, dynamic> map = {
        "id": _shotprovider.profilemodel.shotprofile[i].id.toString(),
        "shot_name": _shotprovider.profilemodel.shotprofile[i].shotname,
        "efficiency":
            _shotprovider.profilemodel.shotprofile[i].efficiency.toString(),
        "shot_frequency": frequency.toString(),
      };
      print(map);
      shotprofileModel.add(ShotProfileModel.fromMap(map));
      print(shotprofileModel);
    }
    Map<String, dynamic> profileModelmap = {
      "id": _shotprovider.profilemodel.id.toString(),
      "name": _shotprovider.profilemodel.name,
      "age": _shotprovider.profilemodel.age.toString(),
      "src": _shotprovider.profilemodel.src,
      "battingstyle": _shotprovider.profilemodel.battingstyle,
      "bowlingstyle": _shotprovider.profilemodel.bowlingstyle,
      "playingrole": _shotprovider.profilemodel.playingrole,
      "teams": _shotprovider.profilemodel.teams,
      "token": _shotprovider.profileModel!.token,
      "shot_profile": shotprofileModel,
    };
    print(profileModelmap);
    ProfileModel _profilemodel = ProfileModel.fromMap(profileModelmap);
    return _profilemodel;
  }
}
