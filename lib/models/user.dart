import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String email;
  final String uid;
  final String username;
  final String campusId;
  final String notificationsToken;
  bool verifyed;

  User(
      {required this.username,
      required this.uid,
      required this.email,
      required this.campusId,
      required this.verifyed,
      required this.notificationsToken});

  static User fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;

    return User(
      notificationsToken: snapshot["notificationsToken"],
      username: snapshot["username"],
      uid: snapshot["uid"],
      email: snapshot["email"],
      campusId: snapshot["campusId"],
      verifyed: snapshot["verifyed"],
    );
  }

  Map<String, dynamic> toJson() => {
        "notificationsToken": notificationsToken,
        "username": username,
        "uid": uid,
        "email": email,
        "campusId": campusId,
        "verifyed": verifyed,
      };
}
