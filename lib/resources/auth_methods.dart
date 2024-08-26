import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
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
    required bool isCodeRequired,
    String? code,
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
        if (isCodeRequired) {
          if (code != '') {
            var docCode = await FirebaseFirestore.instance
                .collection('codes')
                .where('code', isEqualTo: code)
                .get();
            if (docCode.docs.isNotEmpty) {
              if (!docCode.docs.first['isUsed']) {
                UserCredential cred =
                    await _auth.createUserWithEmailAndPassword(
                  email: email,
                  password: password,
                );
                String? notificatiosnToken =
                    await FirebaseMessaging.instance.getToken();
                model.User user = model.User(
                  username: username,
                  uid: cred.user!.uid,
                  email: email,
                  campusId: campusId,
                  verifyed: FirebaseAuth.instance.currentUser!.emailVerified,
                  notificationsToken: notificatiosnToken!,
                );
                await FirebaseMessaging.instance.subscribeToTopic(campusId);
                await _firestore
                    .collection("users")
                    .doc(cred.user!.uid)
                    .set(user.toJson());
                res = "Verifique seu Email!";
                FirebaseAuth.instance.currentUser!.sendEmailVerification();
                FirebaseFirestore.instance
                    .collection('codes')
                    .doc(docCode.docs.first.id)
                    .update(
                  {
                    'isUsed': true,
                  },
                );
              } else {
                return 'Esse código já foi usado';
              }
            } else {
              return 'Código Inválido';
            }
          }
        }
      } else {
        res = "Preencha todos os campos";
      }
    } catch (err) {
      return err.toString();
    }
    return res;
  }

  Future<String> forgotPass({required String email}) async {
    String res = "Algo deu errado";
    try {
      if (email.isNotEmpty) {
        if (email.contains("@alunos.ufersa.edu.br")) {
          await _auth.sendPasswordResetEmail(
            email: email,
          );
          res = "Email enviado!";
        } else {
          res = "Email inválido";
        }
      } else {
        res = "Preencha o email";
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
    String res = "Algo deu errado";
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
