import 'dart:io';

import 'package:cricket_shot_analysis/model/profilemodel.dart';
import 'package:cricket_shot_analysis/model/shotprofilemodel.dart';
import 'package:cricket_shot_analysis/page/homepage.dart';
import 'package:cricket_shot_analysis/random/data.dart';
import 'package:cricket_shot_analysis/server/server_operation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../constant.dart';

class AddPlayersDetails extends StatefulWidget {
  final String from;
  ProfileModel? profileModel;
  AddPlayersDetails({Key? key, required this.from, this.profileModel})
      : super(key: key);

  @override
  State<AddPlayersDetails> createState() => _AddPlayersDetailsState();
}

class _AddPlayersDetailsState extends State<AddPlayersDetails> {
  String? image;
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _name = TextEditingController();
  final TextEditingController _battingstyle = TextEditingController();
  final TextEditingController _bowlingstyle = TextEditingController();
  final TextEditingController _playingrole = TextEditingController();
  final TextEditingController _teams = TextEditingController();
  final TextEditingController _age = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool loading = false;
  var index;
  @override
  void initState() {
    super.initState();
    // if token is ot in sharedpreferences then gettoken else use sharedpreferences stored token
    if (token == null) {
      generateToken();
    }
    handleindex();
    widget.from == "Edit"
        ? {
            _name.text = widget.profileModel!.name,
            _age.text = widget.profileModel!.age,
            _battingstyle.text = widget.profileModel!.battingstyle,
            _bowlingstyle.text = widget.profileModel!.bowlingstyle,
            _playingrole.text = widget.profileModel!.playingrole,
            _teams.text = widget.profileModel!.teams,
            image = widget.profileModel!.src,
          }
        : null;
  }

  void generateToken() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var data = await ServerOp().generateToken();
    sharedPreferences.setString("token", data["token"]);
  }

  void sharedPrefGetToken() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    token = sharedPreferences.getString("token");
    print("my token is $token");
  }

  void handleindex() {
    // for edit profile we need index from players list to get exact model of player to edit
    index =
        widget.from == "Edit" ? players.indexOf(widget.profileModel!) : null;
    print("hello $index");
    // print(widget.profileModel!.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
        title: widget.from == "Add"
            ? Text(
                "Add Player",
                style: textStyleTitle,
              )
            : Text(
                "Edit Player",
                style: textStyleTitle,
              ),
        leading: IconButton(
            onPressed: () {
              widget.from == "Add"
                  ? Navigator.pop(context, players)
                  : Navigator.pop(context, players[index]);
            },
            icon: const Icon(
              FontAwesomeIcons.chevronLeft,
              color: Colors.black,
            )),
      ),
      body: loading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : SafeArea(
              child: SingleChildScrollView(
              child: Column(
                children: [
                  heightSpace(20),
                  // circle image
                  Center(
                    child: Stack(
                      children: [
                        CircleAvatar(
                            radius: 60,
                            backgroundColor: Colors.green,
                            backgroundImage:
                                const AssetImage("assets/images/loader.gif"),
                            child: ClipOval(
                                child: widget.from == "Add"
                                    ? (image != null
                                        ? Image.file(
                                            File(image!),
                                            fit: BoxFit.cover,
                                          )
                                        : const Image(
                                            image: AssetImage(
                                                "assets/images/user.png")))
                                    : Image.network(
                                        "https://shotanalysis.000webhostapp.com/players/${widget.profileModel!.src}")
                                //  Image.file(
                                //     File(widget.profileModel!.src),
                                //     fit: BoxFit.cover,
                                //   ),
                                )

                            // backgroundImage: const AssetImage("assets/images/user.png"),
                            ),
                        widget.from == "Add"
                            ? Positioned(
                                right: -5,
                                top: -5,
                                child: IconButton(
                                    alignment: Alignment.topRight,
                                    onPressed: () {
                                      showDialog(
                                          context: context,
                                          builder: (context) => showdialog());
                                    },
                                    icon: Icon(
                                      Icons.add_a_photo,
                                      size: 30,
                                      color: Colors.grey.shade700,
                                    )),
                              )
                            : const SizedBox(),
                      ],
                    ),
                  ),
                  heightSpace(20),
                  // form for players details
                  Form(
                      key: _formKey,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(left: 5),
                              child: Text("Name*",
                                  style: TextStyle(
                                      fontFamily: 'OpenSans',
                                      color: kTextColor,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 15)),
                            ),
                            heightSpace(10),
                            TextFormField(
                              controller: _name,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "Please enter your name";
                                }
                                return null;
                              },
                              decoration: InputDecoration(
                                  contentPadding: const EdgeInsets.symmetric(
                                      vertical: 18, horizontal: 10),
                                  hintText: "Enter Name",
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(5),
                                  )),
                            ),
                            heightSpace(20),
                            const Padding(
                              padding: EdgeInsets.only(left: 5),
                              child: Text("Age*",
                                  style: TextStyle(
                                      fontFamily: 'OpenSans',
                                      color: kTextColor,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 15)),
                            ),
                            heightSpace(10),
                            TextFormField(
                              controller: _age,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "Please enter Age";
                                } else if (!RegExp(r'^[0-9]+$')
                                    .hasMatch(value)) {
                                  return "Please enter Type number only";
                                }
                                return null;
                              },
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                  contentPadding: const EdgeInsets.symmetric(
                                      vertical: 18, horizontal: 10),
                                  hintText: "Enter Age",
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(5),
                                  )),
                            ),
                            heightSpace(20),
                            const Padding(
                              padding: EdgeInsets.only(left: 5),
                              child: Text("Batting Style",
                                  style: TextStyle(
                                      fontFamily: 'OpenSans',
                                      color: kTextColor,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 15)),
                            ),
                            heightSpace(10),
                            TextFormField(
                              controller: _battingstyle,
                              decoration: InputDecoration(
                                  contentPadding: const EdgeInsets.symmetric(
                                      vertical: 18, horizontal: 10),
                                  hintText: "Enter Battingstyle",
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(5),
                                  )),
                            ),
                            heightSpace(20),
                            const Padding(
                              padding: EdgeInsets.only(left: 5),
                              child: Text("Bowling Style",
                                  style: TextStyle(
                                      fontFamily: 'OpenSans',
                                      color: kTextColor,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 15)),
                            ),
                            heightSpace(10),
                            TextFormField(
                              controller: _bowlingstyle,
                              decoration: InputDecoration(
                                  contentPadding: const EdgeInsets.symmetric(
                                      vertical: 18, horizontal: 10),
                                  hintText: "Enter Bowlingstyle",
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(5),
                                  )),
                            ),
                            heightSpace(20),
                            const Padding(
                              padding: EdgeInsets.only(left: 5),
                              child: Text("Playing Role*",
                                  style: TextStyle(
                                      fontFamily: 'OpenSans',
                                      color: kTextColor,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 15)),
                            ),
                            heightSpace(10),
                            TextFormField(
                              controller: _playingrole,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "Please enter Playingrole";
                                }
                                return null;
                              },
                              decoration: InputDecoration(
                                  contentPadding: const EdgeInsets.symmetric(
                                      vertical: 18, horizontal: 10),
                                  hintText: "Enter Playingrole",
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(5),
                                  )),
                            ),
                            heightSpace(20),
                            const Padding(
                              padding: EdgeInsets.only(left: 5),
                              child: Text("Teams",
                                  style: TextStyle(
                                      fontFamily: 'OpenSans',
                                      color: kTextColor,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 15)),
                            ),
                            heightSpace(10),
                            TextFormField(
                              controller: _teams,
                              decoration: InputDecoration(
                                  contentPadding: const EdgeInsets.symmetric(
                                      vertical: 18, horizontal: 10),
                                  hintText: "Enter Teams",
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(5),
                                  )),
                            ),
                            heightSpace(20),
                            // submit button
                            Center(
                              child: ElevatedButton(
                                onPressed: () async {
                                  if (_formKey.currentState!.validate()) {
                                    if (image != null) {
                                      setState(() {
                                        loading = true;
                                      });
                                      widget.from == "Add"
                                          ? ServerOp()
                                              .setProfile(
                                                  name: _name.text,
                                                  age: _age.text,
                                                  bowlingstyle:
                                                      _bowlingstyle.text,
                                                  battingstyle:
                                                      _battingstyle.text,
                                                  playingrole:
                                                      _playingrole.text,
                                                  teams: _teams.text,
                                                  imagePath: image!,
                                                  token: token!,
                                                  context: context)
                                              .then((value) => {
                                                    setState(() {
                                                      loading = false;
                                                    }),
                                                    Navigator.pop(
                                                        context, players)
                                                  })
                                          : ServerOp()
                                              .editProfile(
                                                  age: _age.text,
                                                  name: _name.text,
                                                  bowlingstyle:
                                                      _bowlingstyle.text,
                                                  battingstyle:
                                                      _battingstyle.text,
                                                  playingrole:
                                                      _playingrole.text,
                                                  teams: _teams.text,
                                                  id: widget.profileModel!.id,
                                                  context: context)
                                              .then((value) => {
                                                    // print(widget.profileModel!
                                                    //     .tomap()),
                                                    // print(players[4].tomap()),
                                                    // print(players.indexOf(
                                                    //     widget.profileModel!)),
                                                    players[index] = ProfileModel(
                                                        id: widget
                                                            .profileModel!.id,
                                                        name: _name.text,
                                                        src: widget
                                                            .profileModel!.src,
                                                        age: _age.text,
                                                        battingstyle:
                                                            _battingstyle.text,
                                                        bowlingstyle:
                                                            _bowlingstyle.text,
                                                        playingrole:
                                                            _playingrole.text,
                                                        teams: _teams.text,
                                                        shotprofile: widget
                                                            .profileModel!
                                                            .shotprofile,
                                                        token: widget
                                                            .profileModel!
                                                            .token),
                                                    setState(() {
                                                      loading = false;
                                                    }),
                                                    print(
                                                        players[index].tomap()),
                                                    Navigator.pop(
                                                        context, players[index])
                                                  });

                                      print("i am validate");
                                    } else {
                                      SnackBar snackBar = const SnackBar(
                                          duration: Duration(milliseconds: 500),
                                          content: Text(
                                            "Please upload the image",
                                            style: TextStyle(
                                                fontFamily: 'OpenSans',
                                                color: Colors.white,
                                                fontSize: 18),
                                          ));
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(snackBar);
                                    }
                                  }
                                },
                                child: const Text(
                                  "Submit",
                                  style: TextStyle(
                                      fontFamily: 'OpenSans',
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 18),
                                ),
                                style: ElevatedButton.styleFrom(
                                    primary: Colors.blueAccent,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 30,
                                      vertical: 10,
                                    )),
                              ),
                            ),
                            heightSpace(10),
                          ],
                        ),
                      ))
                ],
              ),
            )),
    );
  }

  // Widget formRow(String title, TextEditingController controller) {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       Padding(
  //         padding: const EdgeInsets.only(left: 5),
  //         child: Text(title,
  //             style: const TextStyle(
  //                 fontFamily: 'OpenSans',
  //                 color: kTextColor,
  //                 fontWeight: FontWeight.w700,
  //                 fontSize: 15)),
  //       ),
  //       heightSpace(10),
  //       TextFormField(
  //         controller: controller,
  //         validator: (value) {
  //           if (value != null) {
  //             return value;
  //           } else {
  //             return null;
  //           }
  //         },
  //         decoration: InputDecoration(
  //             contentPadding:
  //                 const EdgeInsets.symmetric(vertical: 18, horizontal: 10),
  //             label: Text("Enter $title"),
  //             border: OutlineInputBorder(
  //               borderRadius: BorderRadius.circular(5),
  //             )),
  //       ),
  //     ],
  //   );
  // }
// for picking image from source = camera,gallery
  Future imagePicker(
    ImageSource source,
  ) async {
    XFile? pickedFile;
    try {
      pickedFile = await _picker.pickImage(source: source);
      print("camerapath ${pickedFile!.path}");
      sharedPrefGetToken();
      setState(() {
        if (pickedFile != null) {
          image = pickedFile.path;
        } else {
          print("No image Selected");
        }
      });
      print(image!);
    } catch (e) {
      return null;
    }
  }

// show from camera or gallery dialog
  Dialog showdialog() {
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
                  imagePicker(ImageSource.gallery);
                  Navigator.pop(context);
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
                  imagePicker(
                    ImageSource.camera,
                  );
                  Navigator.pop(context);
                },
              )
            ],
          ),
        ));
  }

//   Future<File> getImageFileFromAssets(String path) async {
//     final byteData = await rootBundle.load('assets/$path');

//     final file = File('${(await getTemporaryDirectory()).path}/$path');
//     await file.writeAsBytes(byteData.buffer
//         .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));

//     return file;
//   }
}
