import 'package:cricket_shot_analysis/constant.dart';
import 'package:cricket_shot_analysis/model/newsmodel.dart';
import 'package:cricket_shot_analysis/random/data.dart';
import 'package:cricket_shot_analysis/server/server_operation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class LatestNews extends StatefulWidget {
  const LatestNews({Key? key}) : super(key: key);

  @override
  _LatestNewsState createState() => _LatestNewsState();
}

class _LatestNewsState extends State<LatestNews> {
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  List storyId = [];
  void fetch() async {
    List data = await ServerOp().fetchNewsList();
    print(data.length);
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
  }

  void sync() {
    setState(() {
      storyId = news.map((e) => e.id).toList();
      // equipmentcategoryid = equipmentcategory.map((e) => e.id).toList();
    });
    fetch();
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
          "Latest Cricket News",
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
      body: news.isEmpty
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : SmartRefresher(
              onRefresh: sync,
              controller: _refreshController,
              child: ListView.builder(
                  itemCount: news.length,
                  itemBuilder: (context, items) {
                    return Card(
                        margin: const EdgeInsets.only(
                            right: 20, left: 20, bottom: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 15, vertical: 10),
                          width: 250,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              heightSpace(10),
                              Text(
                                news[items].title,
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
    );
  }
}
