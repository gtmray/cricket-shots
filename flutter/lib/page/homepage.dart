import 'dart:io';

import 'package:cricket_shot_analysis/constant.dart';
import 'package:cricket_shot_analysis/model/newsmodel.dart';
import 'package:cricket_shot_analysis/model/profilemodel.dart';
import 'package:cricket_shot_analysis/model/sampleanalysismodel.dart';
import 'package:cricket_shot_analysis/model/shotProfileModel.dart';
import 'package:cricket_shot_analysis/model/shotmodel.dart';
import 'package:cricket_shot_analysis/page/analysis/image.dart';
import 'package:cricket_shot_analysis/page/news/latestnews.dart';
import 'package:cricket_shot_analysis/page/players/addplayersdetails.dart';
import 'package:cricket_shot_analysis/page/players/players.dart';
import 'package:cricket_shot_analysis/page/players/playersdetails.dart';
import 'package:cricket_shot_analysis/page/shots/sampleshot.dart';
import 'package:cricket_shot_analysis/random/data.dart';
import 'package:cricket_shot_analysis/server/server_operation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cricket_shot_analysis/server/server_operation.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shared_preferences/shared_preferences.dart';

String? token;

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // controller for refresh
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  bool isFetching = true;
  // for unique id not repeat while sync
  Set storyId = {};
  Set playerId = {};
  Set sampleId = {};
  Set shotId = {};
  // initial state before running build
  @override
  void initState() {
    // TODO: implement initState
    // fetchdata();
    // get token number stored in sharedpreferences
    // sharedpreferences = stored value according to key state locally
    sharedPrefGetToken();
    // fetch sample analysis data from api
    fetchSampleAnalysis();
    // fetch news from rapid api
    fetchNews();
    // fetch player details from api
    fetchPlayer();
    // fetch shots from api
    fetchshot();

    super.initState();
  }

  void sharedPrefGetToken() async {
    // instance for share preferences
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    // set value from sharedpreferences token to token
    token = sharedPreferences.getString("token");
    print("my token is $token");
  }

  // void fetchdata() {
  //   for (int i = 0; i < news.length; i++) {
  //     newsModel.add(NewsModel.fromMap(news[i]));
  //   }
  // }
// for manage profilemodel list
// profileModel = Model for player details
  List<ProfileModel> dataManage(data, id) {
    List<ProfileModel> playersCopy = [];
    List profiledetailsmatchdata = [];

    // print(id);
    // loop for number of id length
    for (int i = 0; i < id.length; i++) {
      List<ShotProfileModel> shot = [];
      // have 6 shots so multiple of 6
      for (int j = 0; j < 6; j++) {
        shot.add(ShotProfileModel.fromMap({
          "id": data[6 * i + j]['shot_id'],
          "shot_name": data[6 * i + j]['shot_name'],
          "shot_frequency": data[6 * i + j]['shot_frequency'],
          "efficiency": data[6 * i + j]['efficiency'],
        }));
      }
      print(shot);
      // add players details from data to profiledetails
      profiledetailsmatchdata.add(data[6 * i]);
      // remove shot_name,efficiency,shot_frequency from api fetch
      profiledetailsmatchdata[i].remove("shot_name");
      profiledetailsmatchdata[i].remove("efficiency");
      profiledetailsmatchdata[i].remove("shot_frequency");
      //  add new key shot_profile and add list of shot data from above on it
      profiledetailsmatchdata[i]["shot_profile"] = shot;
      print(profiledetailsmatchdata[i]);
      // add rearrange data on player profile
      playersCopy.add(ProfileModel.fromMap(profiledetailsmatchdata[i]));

      print("\n");
    }
    return playersCopy;
  }

  void fetchPlayer() async {
    // fetch from fetchplayerprofile function from serverop class
    List data = await ServerOp().fetchplayerProfile();
    //print(data.length);
    // for check the new id inserted or not
    Set id = {};
    for (int i = 0; i < data.length; i++) {
      id.add(int.parse(data[i]['id']));
    }
    // if fetch first or have no data
    if (playerId.isEmpty) {
      setState(() {
        players = dataManage(data, id);
      });
    } else {
      // if playerid is not match with newly fetch data id then add on players list
      if (playerId != id) {
        setState(() {
          players = dataManage(data, id);
        });
      }
    }
  }

  void fetchshot() async {
    List data = await ServerOp().fetchShot();
    print("fetch ${data.length}");
    print(data);
    for (int i = 0; i < data.length; i++) {
      if (data[i] != null) {
        if (shotId.isEmpty) {
          print(data[i]);
          print("seperate");
          setState(() {
            shotmodel.add(ShotModel.fromMap(data[i]));
          });
        } else {
          if (!shotId.contains((int.parse(data[i]['id'])))) {
            setState(() {
              shotmodel.add(ShotModel.fromMap(data[i]));
            });
          }
        }
      }
    }
  }

  void fetchSampleAnalysis() async {
    List data = await ServerOp().fetchSampleAnalysis();
    // print(data.length);
    for (int i = 0; i < data.length; i++) {
      if (data[i] != null) {
        if (sampleId.isEmpty) {
          setState(() {
            sampleAnalysis.add(SampleAnalysis.fromMap(data[i]));
          });
        } else {
          if (!sampleId.contains((int.parse(data[i]['id'])))) {
            setState(() {
              sampleAnalysis.add(SampleAnalysis.fromMap(data[i]));
            });
          }
        }
      }
    }
  }

  void fetchNews() async {
    List data = await ServerOp().fetchNewsList();
    // print(data.length);
    for (int i = 0; i < data.length; i++) {
      if (data[i] != null) {
        if (storyId.isEmpty) {
          setState(() {
            news.add(NewsModel.fromMap(data[i]));
          });
        } else {
          if (!storyId.contains((data[i]['id']))) {
            setState(() {
              news.add(NewsModel.fromMap(data[i]));
            });
          }
        }
      }
    }
    setState(() {
      isFetching = false;
    });
  }
  // for sync data on refresh

  void sync() {
    // set list of id
    setState(() {
      storyId = news.map((e) => e.id).toSet();
      playerId = players.map((e) => e.id).toSet();
      sampleId = sampleAnalysis.map((e) => e.id).toSet();
      shotId = shotmodel.map((e) => e.id).toSet();
      // equipmentcategoryid = equipmentcategory.map((e) => e.id).toList();
    });
    sharedPrefGetToken();
    fetchSampleAnalysis();
    fetchNews();
    fetchshot();
    fetchPlayer();

    _refreshController.refreshCompleted();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        // not automatically set back button
        automaticallyImplyLeading: false,
        elevation: 0.0,
        backgroundColor: Colors.transparent,
        title: Text(
          "Cricket Shot Ananysis",
          style: textStyleTitle,
        ),
        // centerTitle: true,
        // widget on left
        leading: Container(
          padding: const EdgeInsets.all(2),
          margin: const EdgeInsets.only(left: 10),
          child: CircleAvatar(
            radius: 30,
            backgroundColor: Colors.grey.shade300,
            backgroundImage: const AssetImage("assets/images/user.png"),
          ),
        ),
      ),
      body: SmartRefresher(
        onRefresh: sync,
        controller: _refreshController,
        child: SingleChildScrollView(
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  heightSpace(10),
                  // analyse shot
                  Container(
                    margin: const EdgeInsets.only(left: 10),
                    child: Text(
                      "Analyse Shot",
                      style: textStyleTitle,
                    ),
                  ),
                  heightSpace(30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      // camera
                      Column(
                        children: [
                          InkWell(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const Analysis(
                                            from: 'Camera',
                                          )));
                              // showDialog(
                              //     context: context,
                              //     builder: (context) => showdialog());
                            },
                            child: const Icon(
                              FontAwesomeIcons.camera,
                              color: kButtonColor,
                              size: 70,
                            ),
                          ),
                          heightSpace(10),
                          Text(
                            "Capture",
                            style: textStyle,
                          ),
                        ],
                      ),
                      // gallery
                      Column(
                        children: [
                          InkWell(
                            onTap: () {
                              // imagePicker(ImageSource.gallery, context);
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const Analysis(from: "upload")));
                            },
                            child: const Icon(
                              Icons.upload_file,
                              color: kButtonColor,
                              size: 70,
                            ),
                          ),
                          heightSpace(10),
                          Text(
                            "Upload",
                            style: textStyle,
                          ),
                        ],
                      )
                    ],
                  ),
                  // : InkWell(
                  //     onLongPress: () {
                  //       setState(() {
                  //         image = null;
                  //       });
                  //     },
                  //     child: Image.file(
                  //       File(image!),
                  //       height: 150,
                  //     ),
                  //   ),
                  //  Image(
                  //     image: Image.file(image!),
                  //     height: 150,
                  //   ),
                  //Image(image: FileImage(image!)),
                  heightSpace(50),
                  // sample analysis
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(left: 10),
                        child: Text(
                          "Sample Analysis",
                          style: textStyleTitle,
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const SampleShots()));
                        },
                        child: Container(
                          margin: const EdgeInsets.only(right: 10),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.shade200,
                                )
                              ]),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 15, vertical: 8),
                          child: const Text(
                            "See All",
                            style: TextStyle(
                              fontFamily: 'OpenSans',
                              fontSize: 15,
                              color: kPrimaryColor,
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                  heightSpace(30),
                  // sample shot display
                  SizedBox(
                    height: 200,
                    child: sampleAnalysis.isEmpty
                        ? const Center(child: CircularProgressIndicator())
                        : ListView.builder(
                            // horizontal scroll
                            scrollDirection: Axis.horizontal,
                            itemCount: sampleAnalysis.length,
                            physics: const BouncingScrollPhysics(),
                            shrinkWrap: true,
                            padding: const EdgeInsets.only(left: 10),
                            itemBuilder: (context, items) {
                              return Card(
                                margin: const EdgeInsets.only(right: 20),
                                color: Colors.grey.shade100,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 8),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Image(
                                        // image from network image
                                        image: NetworkImage(
                                            "https://shotanalysis.000webhostapp.com/sample_analysis/${sampleAnalysis[items].src}"),
                                        width: 150,
                                        height: 150,
                                        loadingBuilder:
                                            ((context, child, loadingProgress) {
                                          if (loadingProgress == null) {
                                            return child;
                                          }
                                          return const Center(
                                              child:
                                                  CircularProgressIndicator());
                                        }),
                                        fit: BoxFit.fill,
                                      ),
                                      heightSpace(10),
                                      Container(
                                        width: 140,
                                        height: 20,
                                        alignment: Alignment.center,
                                        child: Text(
                                          sampleAnalysis[items].name,
                                          style: const TextStyle(
                                            fontFamily: "OpenSans",
                                            fontSize: 15,
                                            color: kPrimaryColor,
                                          ),
                                          textAlign: TextAlign.center,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              );
                            }),
                  ),
                  heightSpace(50),
                  // latest cricket news
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(left: 10),
                          child: Text(
                            "Latest Cricket News",
                            style: textStyleTitle,
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const LatestNews()));
                          },
                          child: Container(
                            margin: const EdgeInsets.only(right: 10),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.shade200,
                                  )
                                ]),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 15, vertical: 8),
                            child: const Text(
                              "See All",
                              style: TextStyle(
                                fontFamily: 'OpenSans',
                                fontSize: 15,
                                color: kPrimaryColor,
                              ),
                            ),
                          ),
                        )
                      ]),
                  heightSpace(30),
                  // latest cricket news horizontal view
                  SizedBox(
                    height: 260,
                    child: isFetching
                        ? const Center(
                            child: CircularProgressIndicator(
                              color: kPrimaryColor,
                            ),
                          )
                        : ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: news.length,
                            physics: const BouncingScrollPhysics(),
                            padding: const EdgeInsets.only(left: 10),
                            shrinkWrap: true,
                            itemBuilder: (context, items) {
                              return Card(
                                  margin: const EdgeInsets.only(right: 20),
                                  color: Colors.grey.shade100,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 15, vertical: 10),
                                    width: 250,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        heightSpace(10),
                                        Text(
                                          news[items].title,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontFamily: "OpenSans",
                                            color: kTextColor,
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        heightSpace(10),
                                        Text(
                                          news[items].subtitle,
                                          maxLines: 4,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontFamily: "OpenSans",
                                            color: kTextColor,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w300,
                                          ),
                                        ),
                                        heightSpace(20),
                                        Text(
                                          "Context : ${news[items].context}",
                                          maxLines: 2,
                                          style: const TextStyle(
                                            color: kTextColor,
                                            fontFamily: "OpenSans",
                                          ),
                                        ),
                                      ],
                                    ),
                                  ));
                            }),
                  ),
                  heightSpace(50),
                  // players
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(left: 10),
                          child: Text(
                            "Players",
                            style: textStyleTitle,
                          ),
                        ),
                        Row(
                          children: [
                            InkWell(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => const Players()));
                              },
                              child: Container(
                                margin: const EdgeInsets.only(right: 10),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(15),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.shade200,
                                      )
                                    ]),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 15, vertical: 8),
                                child: const Text(
                                  "See All",
                                  style: TextStyle(
                                    fontFamily: 'OpenSans',
                                    fontSize: 15,
                                    color: kPrimaryColor,
                                  ),
                                ),
                              ),
                            ),
                            IconButton(
                                onPressed: () {
                                  Future data = Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              AddPlayersDetails(
                                                from: "Add",
                                              )));
                                  data.then((value) => {
                                        setState(() {
                                          fetchPlayer();
                                        })
                                      });
                                },
                                icon: const Icon(Icons.add_circle,
                                    size: 30, color: Colors.black38))
                          ],
                        )
                      ]),
                  heightSpace(30),
                  // players horizontal view
                  SizedBox(
                    height: 220,
                    child: players.isEmpty
                        ? const Center(
                            child: CircularProgressIndicator(),
                          )
                        : ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: players.length,
                            physics: const BouncingScrollPhysics(),
                            shrinkWrap: true,
                            padding: const EdgeInsets.only(left: 10),
                            itemBuilder: (context, items) {
                              return InkWell(
                                onTap: () {
                                  Future data = Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => PlayersDetails(
                                              profileModel: players[
                                                  players.length -
                                                      items -
                                                      1])));
                                  data.then((value) => {
                                        setState(() {
                                          players[players.length - items - 1] =
                                              value;
                                        })
                                      });
                                },
                                child: Card(
                                  margin: const EdgeInsets.only(right: 20),
                                  color: Colors.grey.shade100,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 8),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Image.network(
                                          "https://shotanalysis.000webhostapp.com/players/${players[players.length - items - 1].src}",
                                          loadingBuilder: ((context, child,
                                              loadingProgress) {
                                            if (loadingProgress == null) {
                                              return child;
                                            }
                                            return const Center(
                                                child:
                                                    CircularProgressIndicator());
                                          }),
                                          // image: NetworkImage(
                                          //     "https://shotanalysis.000webhostapp.com/players/${players[players.length - items - 1].src}"),
                                          width: 150,
                                          height: 150,
                                          fit: BoxFit.cover,
                                        ),
                                        heightSpace(10),
                                        Container(
                                          width: 140,
                                          height: 40,
                                          alignment: Alignment.center,
                                          child: Text(
                                            players[players.length - items - 1]
                                                .name,
                                            style: const TextStyle(
                                              fontFamily: "OpenSans",
                                              fontSize: 15,
                                              color: kPrimaryColor,
                                            ),
                                            textAlign: TextAlign.center,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Dialog showdialog() {
  //   return Dialog(
  //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
  //       child: Padding(
  //         padding: const EdgeInsets.all(20.0),
  //         child: Column(
  //           mainAxisSize: MainAxisSize.min,
  //           children: [
  //             InkWell(
  //               child: Padding(
  //                 padding: const EdgeInsets.all(8.0),
  //                 child: Row(
  //                   mainAxisAlignment: MainAxisAlignment.center,
  //                   children: [
  //                     const Icon(
  //                       FontAwesomeIcons.image,
  //                       size: 25,
  //                     ),
  //                     widthSpace(30),
  //                     Text(
  //                       "Image",
  //                       style: textStyleTitle,
  //                     ),
  //                   ],
  //                 ),
  //               ),
  //               onTap: () {
  //                 imagePicker(ImageSource.camera, context);
  //               },
  //             ),
  //             heightSpace(10),
  //             InkWell(
  //               child: Padding(
  //                 padding: const EdgeInsets.all(8.0),
  //                 child: Row(
  //                   mainAxisAlignment: MainAxisAlignment.center,
  //                   children: [
  //                     const Icon(
  //                       FontAwesomeIcons.video,
  //                       size: 25,
  //                     ),
  //                     widthSpace(33),
  //                     Text(
  //                       "Video",
  //                       style: textStyleTitle,
  //                     ),
  //                   ],
  //                 ),
  //               ),
  //               onTap: () {
  //                 videoPicker(ImageSource.camera, context);
  //               },
  //             )
  //           ],
  //         ),
  //       ));
  // }

}
