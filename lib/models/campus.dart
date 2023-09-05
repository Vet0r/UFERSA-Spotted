import 'package:cloud_firestore/cloud_firestore.dart';

class Campus {
  final String campusId;
  final String name;

  const Campus({
    required this.name,
    required this.campusId,
  });

  static Campus fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;

    return Campus(name: snapshot["name"], campusId: snapshot["campusId"]);
  }

  Map<String, dynamic> toJson() => {
        "name": name,
        "campusId": campusId,
      };
}