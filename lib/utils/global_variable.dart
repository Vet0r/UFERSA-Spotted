import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:spotted_ufersa/screens/add_post_screen.dart';
import 'package:spotted_ufersa/screens/feed_screen.dart';
import 'package:spotted_ufersa/screens/notifications_screens.dart';
import 'package:spotted_ufersa/screens/profile_screen.dart';
import 'package:spotted_ufersa/screens/search_screen.dart';

const webScreenSize = 600;

List<Widget> homeScreenItems = [
  const FeedScreen(),
  const SearchScreen(),
  const AddPostScreen(),
  const NotificationsScreen(),
  ProfileScreen(
    uid: FirebaseAuth.instance.currentUser!.uid,
  ),
];
