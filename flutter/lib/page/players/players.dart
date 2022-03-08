import 'package:cricket_shot_analysis/model/profilemodel.dart';
import 'package:cricket_shot_analysis/model/shotprofilemodel.dart';
import 'package:cricket_shot_analysis/page/players/playersdetails.dart';
import 'package:cricket_shot_analysis/provider/shotprovider.dart';
import 'package:cricket_shot_analysis/random/data.dart';
import 'package:cricket_shot_analysis/server/server_operation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../constant.dart';

class Players extends StatefulWidget {
  const Players({Key? key}) : super(key: key);

  @override
  State<Players> createState() => _PlayersState();
}

class _PlayersState extends State<Players> {
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  List playerId = [];
  // for fetching player
  List<ProfileModel> dataManage(data, id) {
    List<ProfileModel> playersCopy = [];
    List profiledetailsmatchdata = [];

    // print(id);
    for (int i = 0; i < id.length; i++) {
      List<ShotProfileModel> shot = [];
      for (int j = 0; j < 6; j++) {
        shot.add(ShotProfileModel.fromMap({
          "shot_name": data[6 * i + j]['shot_name'],
          "shot_frequency": data[6 * i + j]['shot_frequency'],
          "efficiency": data[6 * i + j]['efficiency'],
        }));
      }
      print(shot);
      profiledetailsmatchdata.add(data[6 * i]);
      profiledetailsmatchdata[i].remove("shot_name");
      profiledetailsmatchdata[i].remove("efficiency");
      profiledetailsmatchdata[i].remove("shot_frequency");
      profiledetailsmatchdata[i]["shot_profile"] = shot;
      print(profiledetailsmatchdata[i]);

      playersCopy.add(ProfileModel.fromMap(profiledetailsmatchdata[i]));

      print("\n");
    }
    return playersCopy;
  }

  void fetchPlayer() async {
    List data = await ServerOp().fetchplayerProfile();
    //print(data.length);
    Set id = {};
    for (int i = 0; i < data.length; i++) {
      id.add(int.parse(data[i]['id']));
    }
    if (playerId.isEmpty) {
      setState(() {
        players = dataManage(data, id);
      });
    } else {
      if (playerId != id) {
        setState(() {
          players = dataManage(data, id);
        });
      }
    }
  }

  void sync() {
    setState(() {
      playerId = players.map((e) => e.id).toList();
      // equipmentcategoryid = equipmentcategory.map((e) => e.id).toList();
    });
    fetchPlayer();
    _refreshController.refreshCompleted();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
        title: Text(
          "Players",
          style: textStyleTitle,
        ),
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(
              FontAwesomeIcons.chevronLeft,
              color: Colors.black,
            )),
      ),
      body: players.isEmpty
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : SmartRefresher(
              onRefresh: sync,
              controller: _refreshController,
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: GridView.builder(
                    physics: const BouncingScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10.0,
                      mainAxisSpacing: 20.0,
                    ),
                    itemCount: players.length,
                    itemBuilder: (context, items) {
                      return InkWell(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => PlayersDetails(
                                      profileModel: players[items])));
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
                              children: [
                                Expanded(
                                  child: Image(
                                    loadingBuilder:
                                        ((context, child, loadingProgress) {
                                      if (loadingProgress == null) {
                                        return child;
                                      }
                                      return const Center(
                                          child: CircularProgressIndicator());
                                    }),
                                    image: NetworkImage(
                                        "https://shotanalysis.000webhostapp.com/players/${players[items].src}"),
                                    height: 120,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                heightSpace(10),
                                Container(
                                  // width: 140,
                                  // height: 40,
                                  alignment: Alignment.center,
                                  child: Text(
                                    players[items].name,
                                    style: const TextStyle(
                                      fontFamily: "OpenSans",
                                      fontSize: 15,
                                      color: kPrimaryColor,
                                    ),
                                    textAlign: TextAlign.center,
                                    maxLines: 1,
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
            ),
    );
  }
}
