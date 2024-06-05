import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:spotted_ufersa/models/user.dart' as model;

class AuthMethods {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<model.User> getUserDetails() async {
    User currentUser = _auth.currentUser!;

    DocumentSnapshot documentSnapshot =
        await _firestore.collection('users').doc(currentUser.uid).get();

    return model.User.fromSnap(documentSnapshot);
  }

  Future<String> signUpUser({
    required String email,
    required String password,
    required String username,
    required String password2,
    required String campusId,
  }) async {
    String res = "Some error Occurred";
    try {
      if (campusId.isNotEmpty &&
          email.isNotEmpty &&
          password.isNotEmpty &&
          username.isNotEmpty &&
          password2.isNotEmpty) {
        if (!email.contains("@alunos.ufersa.edu.br")) {
          return "Insira seu email institucional";
        }
        if (password2 != password) {
          return "As senhas não coincidem";
        }
        UserCredential cred = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        model.User user = model.User(
          username: username,
          uid: cred.user!.uid,
          email: email,
          campusId: campusId,
          verifyed: FirebaseAuth.instance.currentUser!.emailVerified,
        );
        await _firestore
            .collection("users")
            .doc(cred.user!.uid)
            .set(user.toJson());
        res = "Verifique seu Email!";
        FirebaseAuth.instance.currentUser!.sendEmailVerification();
      } else {
        res = "Preencha todos os campos";
      }
    } catch (err) {
      return err.toString();
    }
    return res;
  }

  Future<String> loginUser({
    required String email,
    required String password,
  }) async {
    String res = "Some error Occurred";
    try {
      if (email.isNotEmpty || password.isNotEmpty) {
        await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        _auth.currentUser!.emailVerified
            ? res = "success"
            : res = "Verifique seu email";
      } else {
        res = "Preencha todos os campos";
      }
    } catch (err) {
      return err.toString();
    }
    return res;
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
