import 'package:cricket_shot_analysis/model/profilemodel.dart';
import 'package:cricket_shot_analysis/model/shotprofilemodel.dart';
import 'package:cricket_shot_analysis/random/data.dart';
import 'package:flutter/cupertino.dart';

class Shotprovider with ChangeNotifier {
  // for profilemodel
  ProfileModel? profileModel;
  ProfileModel get profilemodel => profileModel!;
  void setProfileModel(profileModelCopy) {
    profileModel = profileModelCopy;
  }

// for piechart datamap
  Map<String, double>? dataMap;
  Map<String, double> get datamap => dataMap!;
  void setDataMap(dataMapCopy) {
    dataMap = dataMapCopy;
  }

  // for token provider

  String? tokenProviderDAta;
  String get toKen => tokenProviderDAta!;

  void setToken(String tokenKey) {
    tokenProviderDAta = tokenKey;
  }

// update shot
  void update(ProfileModel profileModel) {
    for (int i = 0; i < players.length; i++) {
      if (profileModel.id == players[i].id) {
        players[i] = profileModel;
        print(players[i].name);
        print(players[i].tomap());
        setProfileModel(profileModel);
        print("i here");
      }
    }

    notifyListeners();
  }
  // update datamap for piechart

  void dataMapValue(ProfileModel profileModel) {
    dataMap = {
      profileModel.shotprofile[0].shotname:
          profileModel.shotprofile[0].frequency.toDouble(),
      profileModel.shotprofile[1].shotname:
          profileModel.shotprofile[1].frequency.toDouble(),
      profileModel.shotprofile[2].shotname:
          profileModel.shotprofile[2].frequency.toDouble(),
      profileModel.shotprofile[3].shotname:
          profileModel.shotprofile[3].frequency.toDouble(),
      profileModel.shotprofile[4].shotname:
          profileModel.shotprofile[4].frequency.toDouble(),
      profileModel.shotprofile[5].shotname:
          profileModel.shotprofile[5].frequency.toDouble(),
    };
    notifyListeners();
  }
}
