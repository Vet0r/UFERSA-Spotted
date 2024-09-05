import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:spotted_ufersa/providers/user_provider.dart';
import 'package:spotted_ufersa/resources/auth_methods.dart';
import 'package:spotted_ufersa/resources/firestore_methods.dart';
import 'package:spotted_ufersa/screens/login_screen.dart';
import 'package:spotted_ufersa/utils/colors.dart';
import 'package:spotted_ufersa/utils/utils.dart';
import 'package:spotted_ufersa/widgets/follow_button.dart';

class ProfileScreen extends StatefulWidget {
  final String uid;
  const ProfileScreen({Key? key, required this.uid}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  var userData = {};
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final UserProvider userProvider = Provider.of<UserProvider>(context);
    return isLoading
        ? const Center(
            child: CircularProgressIndicator(),
          )
        : Scaffold(
            appBar: AppBar(
              backgroundColor: mobileBackgroundColor,
              title: Text(
                userProvider.getUser.username,
              ),
              centerTitle: false,
            ),
            body: ListView(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: FollowButton(
                              text: 'Sair',
                              backgroundColor: mobileBackgroundColor,
                              textColor: primaryColor,
                              borderColor: Colors.grey,
                              function: () async {
                                await AuthMethods().signOut();
                                Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(
                                    builder: (context) => const LoginScreen(),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                FutureBuilder(
                  future: FirebaseFirestore.instance
                      .collection('codes')
                      .doc(FirebaseAuth.instance.currentUser!.uid)
                      .get(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return Shimmer.fromColors(
                        baseColor: Colors.white,
                        highlightColor: Colors.grey,
                        child: const Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  SizedBox(
                                    width: 200,
                                    height: 20,
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: FollowButton(
                                      text: '',
                                      backgroundColor: mobileBackgroundColor,
                                      textColor: primaryColor,
                                      borderColor: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    } else {
                      var snap = snapshot as AsyncSnapshot<
                          DocumentSnapshot<Map<String, dynamic>>>;
                      String code = snap.data!.data()!['code'];
                      bool isUsed = snap.data!.data()!['isUsed'];

                      return Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                const Text('Meu Código'),
                                Expanded(
                                  flex: 1,
                                  child: FollowButton(
                                    text: code,
                                    backgroundColor: mobileBackgroundColor,
                                    textColor: primaryColor,
                                    borderColor: Colors.grey,
                                    function: () async {
                                      await Clipboard.setData(
                                          ClipboardData(text: code));
                                    },
                                  ),
                                ),
                                isUsed ? Text('Usado') : Container(),
                                isUsed
                                    ? Icon(
                                        Icons.check,
                                        color: Colors.green,
                                      )
                                    : Container(),
                              ],
                            ),
                          ],
                        ),
                      );
                    }
                  },
                ),
                const Divider(),
              ],
            ),
          );
  }
}
