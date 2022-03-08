import 'package:cricket_shot_analysis/constant.dart';
import 'package:cricket_shot_analysis/model/sampleanalysismodel.dart';
import 'package:cricket_shot_analysis/random/data.dart';
import 'package:cricket_shot_analysis/server/server_operation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class SampleShots extends StatefulWidget {
  const SampleShots({Key? key}) : super(key: key);

  @override
  State<SampleShots> createState() => _SampleShotsState();
}

class _SampleShotsState extends State<SampleShots> {
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  List sampleId = [];
  void fetchSampleAnalysis() async {
    List data = await ServerOp().fetchSampleAnalysis();
    print(data.length);
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

  void sync() {
    setState(() {
      sampleId = sampleAnalysis.map((e) => e.id).toList();
      // equipmentcategoryid = equipmentcategory.map((e) => e.id).toList();
    });
    fetchSampleAnalysis();
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
          "Sample Analysis",
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
      body: SmartRefresher(
        onRefresh: sync,
        controller: _refreshController,
        child: sampleAnalysis.isEmpty
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                child: GridView.builder(
                    physics: const BouncingScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10.0,
                      mainAxisSpacing: 20.0,
                    ),
                    itemCount: sampleAnalysis.length,
                    itemBuilder: (context, items) {
                      return Card(
                        color: Colors.grey.shade100,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            children: [
                              Expanded(
                                child: Image(
                                  image: NetworkImage(
                                      "https://shotanalysis.000webhostapp.com/sample_analysis/${sampleAnalysis[items].src}"),
                                  width: 150,
                                  height: 130,
                                  loadingBuilder:
                                      ((context, child, loadingProgress) {
                                    if (loadingProgress == null) {
                                      return child;
                                    }
                                    return const Center(
                                        child: CircularProgressIndicator());
                                  }),
                                  fit: BoxFit.fill,
                                ),
                              ),
                              heightSpace(10),
                              Container(
                                width: 140,
                                height: 30,
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
      ),
    );
  }
}
