import 'dart:io';
import 'package:cricket_shot_analysis/constant.dart';
import 'package:cricket_shot_analysis/model/profilemodel.dart';
import 'package:cricket_shot_analysis/model/shotmodel.dart';
import 'package:cricket_shot_analysis/random/data.dart';
import 'package:cricket_shot_analysis/server/server_operation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';

class Analysis extends StatefulWidget {
  final String from;
  final ProfileModel? profileModel;
  const Analysis({Key? key, required this.from, this.profileModel})
      : super(key: key);

  @override
  _AnalysisState createState() => _AnalysisState();
}

class _AnalysisState extends State<Analysis> {
  ShotModel? _shotModel;
  File? image;
  Map<String, dynamic> result = {};
  double? _imageHeight;
  double? _imageWidth;
  var _recognitions;
  final ImagePicker _picker = ImagePicker();
  double? efficiency;
  int? frequency;
  bool isWorking = false;
  Map<int, String> classes_list = {
    0: 'Cut Shot',
    1: 'Cover Drive',
    2: 'Straight Drive',
    3: 'Pull Shot',
    4: 'Leg Glance Shot',
    5: 'Scoop Shot'
  };

  Future imagePicker(ImageSource source) async {
    XFile? pickedFile;
    try {
      pickedFile = await _picker.pickImage(source: source);
      // final temporaryImage = media!.path;
      // setState(() {
      //   image = temporaryImage;
      // });
      setState(() {
        if (pickedFile != null) {
          image = File(pickedFile.path);
        } else {
          print("No image Selected");
        }
      });
      if (image != null) {
        print("image");
        var data = await ServerOp().predictShot(filePath: image!.path);
        print("hello $data");
        print(data.runtimeType);
        setState(() {
          result = data;
        });
        // detectObject(image!);
      }
      print(image!.path);
    } catch (e) {
      return null;
    }
  }

  @override
  void initState() {
    super.initState();
    // check whether the widget is navigated from camera or gallery
    widget.from == "Camera"
        ? imagePicker(ImageSource.camera)
        : imagePicker(ImageSource.gallery);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, result);
        return true;
      },
      child: Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: Container(
              height: MediaQuery.of(context).size.height,
              child: Stack(
                children: [
                  (image != null)
                      ? SizedBox(
                          height: MediaQuery.of(context).size.height,
                          // width:_imageWidth,
                          child: Center(child: Image.file(image!)))
                      : SizedBox(
                          height: MediaQuery.of(context).size.height,
                          width: MediaQuery.of(context).size.width,
                          child: Center(
                            child: InkWell(
                              onTap: () {
                                widget.from == "Camera"
                                    ? imagePicker(ImageSource.camera)
                                    : imagePicker(ImageSource.gallery);
                              },
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    widget.from == "Camera"
                                        ? FontAwesomeIcons.camera
                                        : FontAwesomeIcons.image,
                                    size: 50,
                                  ),
                                  heightSpace(20),
                                  Text(
                                    widget.from == "Camera"
                                        ? "Capture the image to predict"
                                        : "Select the image to predict",
                                    style: textStyle,
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                  Positioned(
                      top: 5,
                      right: 5,
                      child: InkWell(
                        onTap: () {
                          Navigator.pop(context, result);
                        },
                        child: const CircleAvatar(
                          backgroundColor: Colors.black45,
                          radius: 20,
                          child: Center(
                              child: Icon(
                            FontAwesomeIcons.times,
                            color: Colors.white,
                            size: 20,
                          )),
                        ),
                      )),
                  //   widget.from == "Camera"
                  result.isNotEmpty
                      ? Positioned(
                          bottom: 0,
                          width: MediaQuery.of(context).size.width,
                          left: 0,
                          child: Card(
                            shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.only(
                                    topRight: Radius.circular(10),
                                    topLeft: Radius.circular(10))),
                            child: Center(
                              child: Column(
                                children: [
                                  Text(
                                    "Prediction :  ${classes_list[result['PredictedShot']] ?? "Unknown"}",
                                    style: textStyle,
                                  ),
                                  heightSpace(10),
                                  Text(
                                    "Efficiency :  ${result['Efficiency']} \n",
                                    style: textStyle,
                                  ),
                                ],
                              ),
                            ),
                          ))
                      : image != null
                          ? Positioned(
                              bottom: 40,
                              left: MediaQuery.of(context).size.width / 2 - 10,
                              child: CircularProgressIndicator(
                                color: Colors.grey.shade900,
                              ),
                            )
                          : const SizedBox()
                  // ...renderBoxes(MediaQuery.of(context).size)
                ],
              ),
            ),
          )),
    );
  }

  // List<dynamic> renderBoxes(Size screen) {
  //   if (widget.from != "Camera") {
  //     if (_imageWidth == null || _imageHeight == null || result == '') {
  //       return [];
  //     } else {
  //       double factorX = screen.width;
  //       double factorY = screen.height;

  //       Color blue = Colors.blue;

  //       return _recognitions.map((re) {
  //         return Container(
  //           child: Positioned(
  //               left: re['rect']['x'] * factorX,
  //               top: re['rect']['y'] * factorY,
  //               width: re['rect']['w'] * factorX,
  //               height: re['rect']['h'] * factorY,
  //               child: ((re["confidenceInClass"] > 0.50))
  //                   ? Container(
  //                       decoration: BoxDecoration(
  //                           border: Border.all(
  //                         color: blue,
  //                         width: 3,
  //                       )),
  //                       child: Text(
  //                         "${re["detectedClass"]} ${(re["confidenceInClass"] * 100).toStringAsFixed(0)}%",
  //                         style: TextStyle(
  //                           background: Paint()..color = blue,
  //                           color: Colors.white,
  //                           fontSize: 15,
  //                         ),
  //                       ),
  //                     )
  //                   : Container()),
  //         );
  //       }).toList();
  //     }
  //   } else {
  //     return [];
  //   }
  // }
}
