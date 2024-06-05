import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/widgets.dart';
import 'package:spotted_ufersa/models/user.dart';
import 'package:spotted_ufersa/resources/auth_methods.dart';

class UserProvider with ChangeNotifier {
  User? _user;
  final AuthMethods _authMethods = AuthMethods();

  User get getUser => _user!;

  Future<void> refreshUser() async {
    bool ver = auth.FirebaseAuth.instance.currentUser!.emailVerified;
    Map<String, dynamic> authuser = {"verifyed": ver};
    User user = await _authMethods.getUserDetails();
    FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .update(authuser);
    user.verifyed = ver;
    _user = user;
    notifyListeners();
  }
}
