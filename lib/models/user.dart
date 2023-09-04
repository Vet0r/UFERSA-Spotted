import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String email;
  final String uid;
  final String username;
  final String campusId;

  const User({
    required this.username,
    required this.uid,
    required this.email,
    required this.campusId,
  });

  static User fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;

    return User(
        username: snapshot["username"],
        uid: snapshot["uid"],
        email: snapshot["email"],
        campusId: snapshot["campusId"]);
  }

  Map<String, dynamic> toJson() => {
        "username": username,
        "uid": uid,
        "email": email,
        "campusId": campusId,
      };
}
