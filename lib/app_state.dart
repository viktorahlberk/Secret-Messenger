import 'package:flutter/material.dart';
import 'package:secure_messenger/models/user_profile.dart';
import 'package:secure_messenger/services/database.dart';

class AppState with ChangeNotifier {
  UserProfile? _userProfile;
  get userProfile => _userProfile;
  get userUid {
    if (_userProfile != null) {
      return _userProfile!.uid;
    } else {
      return '';
    }
  }

  get userName {
    if (_userProfile != null) {
      if (_userProfile!.userName != null) {
        return _userProfile!.userName;
      }
    } else {
      return '';
    }
  }

  get userEmail {
    if (_userProfile != null) {
      return _userProfile!.email;
    } else {
      return '';
    }
  }

  // _userProfile!.email;
  get userPicture => _userProfile!.profilePictureUrl;
  // set userProfile(newUserProfile) {
  //   _userProfile = newUserProfile;
  //   // notifyListeners();
  // }

  initUser(uid) async {
    _userProfile = await DatabaseService.fetchUserData(uid);
    notifyListeners();
  }
}
