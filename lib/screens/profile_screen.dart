import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
                const Divider(),
              ],
            ),
          );
  }
}
