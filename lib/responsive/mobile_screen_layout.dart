import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:instagram_clone_flutter/utils/colors.dart';
import 'package:instagram_clone_flutter/utils/global_variable.dart';

class MobileScreenLayout extends StatefulWidget {
  const MobileScreenLayout({Key? key}) : super(key: key);

  @override
  State<MobileScreenLayout> createState() => _MobileScreenLayoutState();
}

class _MobileScreenLayoutState extends State<MobileScreenLayout> {
  int _page = 0;
  late PageController pageController; // for tabs animation

  @override
  void initState() {
    super.initState();
    pageController = PageController();
  }

  @override
  void dispose() {
    super.dispose();
    pageController.dispose();
  }

  void onPageChanged(int page) {
    setState(() {
      _page = page;
    });
  }

  void navigationTapped(int page) {
    pageController.jumpToPage(page);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: PageView(
        controller: pageController,
        onPageChanged: onPageChanged,
        children: homeScreenItems,
      ),
      extendBody: true,
      bottomNavigationBar: CurvedNavigationBar(
        index: _page,
        backgroundColor: Colors.transparent,
        color: Color.fromRGBO(255, 255, 255, 0.2),
        buttonBackgroundColor: Colors.transparent,
        animationCurve: Curves.easeInOut,
        animationDuration: Duration(milliseconds: 600),
        items: <Widget>[
          curvedAsset("assets/home.svg", (_page == 0)),
          curvedAsset("assets/favorite.svg", (_page == 1)),
          curvedAsset("assets/add.svg", (_page == 2)),
          curvedAsset("assets/notifications.svg", (_page == 3)),
          curvedAsset("assets/boneco.svg", (_page == 4)),
        ],
        onTap: navigationTapped,
      ),
    );
  }
}

curvedAsset(String asset, bool isSelected) {
  decoration() {
    return const BoxDecoration(
      gradient: LinearGradient(
        colors: gradient,
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      ),
      shape: BoxShape.circle,
    );
  }

  return Container(
    width: 40,
    height: 40,
    decoration:
        isSelected ? decoration() : BoxDecoration(color: Colors.transparent),
    child: Padding(
      padding: const EdgeInsets.all(10.0),
      child: SvgPicture.asset(
        asset,
        fit: BoxFit.contain,
        color: isSelected ? Colors.white : Color.fromRGBO(26, 5, 86, 1),
      ),
    ),
  );
}
