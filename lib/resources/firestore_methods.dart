import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:spotted_ufersa/models/post.dart';
import 'package:spotted_ufersa/resources/storage_methods.dart';
import 'package:uuid/uuid.dart';

class FireStoreMethods {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> uploadPost(String description, Uint8List file, String uid,
      String username, String campusId, String campus, String photoUrl) async {
    // asking uid here because we dont want to make extra calls to firebase auth when we can just get from our state management
    String res = "Some error occurred";
    try {
      String postId = const Uuid().v1(); // creates unique id based on time
      Post post = Post(
        campusId: campusId,
        campus: campus,
        description: description,
        uid: uid,
        username: username,
        likes: [],
        postId: postId,
        datePublished: DateTime.now(),
        postUrl: photoUrl,
      );
      _firestore.collection('posts').doc(postId).set(post.toJson());
      res = "success";
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<String> likePost(String postId, String uid, List likes) async {
    String res = "Some error occurred";
    try {
      if (likes.contains(uid)) {
        // if the likes list contains the user uid, we need to remove it
        _firestore.collection('posts').doc(postId).update({
          'likes': FieldValue.arrayRemove([uid])
        });
      } else {
        // else we need to add uid to the likes array
        _firestore.collection('posts').doc(postId).update({
          'likes': FieldValue.arrayUnion([uid])
        });
      }
      res = 'success';
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  // Post comment
  Future<String> postComment(
      String postId, String text, String uid, String name) async {
    String res = "Some error occurred";
    try {
      if (text.isNotEmpty) {
        // if the likes list contains the user uid, we need to remove it
        String commentId = const Uuid().v1();
        _firestore
            .collection('posts')
            .doc(postId)
            .collection('comments')
            .doc(commentId)
            .set({
          'name': name,
          'uid': uid,
          'text': text,
          'commentId': commentId,
          'datePublished': DateTime.now(),
        });
        res = 'success';
      } else {
        res = "Please enter text";
      }
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  // Delete Post
  Future<String> deletePost(String postId) async {
    String res = "Some error occurred";
    try {
      await _firestore.collection('posts').doc(postId).delete();
      res = 'success';
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<String> reportPost(String postId, String motivo) async {
    String res = "Some error occurred";
    try {
      DocumentReference<Map<String, dynamic>> post =
          _firestore.collection('reports').doc(postId);
      var getPost = await post.get();
      bool exists = getPost.exists;

      if (exists) {
        List<dynamic> users = getPost.data()!['users'];
        bool containsUser =
            users.contains(FirebaseAuth.instance.currentUser!.email);
        if (containsUser) {
          res = 'Você já reportou esse post';
          return res;
        } else {
          await post.update({
            "motivos": FieldValue.arrayUnion([motivo]),
            "users": FieldValue.arrayUnion(
                [FirebaseAuth.instance.currentUser!.email]),
          });
        }
      } else {
        await post.set({
          'idPost': postId,
          "motivos": FieldValue.arrayUnion([motivo]),
          "users":
              FieldValue.arrayUnion([FirebaseAuth.instance.currentUser!.email]),
        });
      }
      res = 'Reportado com Sucesso';
    } catch (err) {
      res = err.toString();
    }
    print(res);
    return res;
  }

  Future<void> followUser(String uid, String followId) async {
    try {
      DocumentSnapshot snap =
          await _firestore.collection('users').doc(uid).get();
      List following = (snap.data()! as dynamic)['following'];

      if (following.contains(followId)) {
        await _firestore.collection('users').doc(followId).update({
          'followers': FieldValue.arrayRemove([uid])
        });

        await _firestore.collection('users').doc(uid).update({
          'following': FieldValue.arrayRemove([followId])
        });
      } else {
        await _firestore.collection('users').doc(followId).update({
          'followers': FieldValue.arrayUnion([uid])
        });

        await _firestore.collection('users').doc(uid).update({
          'following': FieldValue.arrayUnion([followId])
        });
      }
    } catch (e) {
      if (kDebugMode) print(e.toString());
    }
  }
}
