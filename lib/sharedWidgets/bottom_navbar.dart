import 'package:flutter/material.dart';
import 'package:tab_indicator_styler/tab_indicator_styler.dart';
import 'package:uicons/uicons.dart';
import 'package:waste_management_app/constants/colors.dart';
import 'package:waste_management_app/screens/social_media/controller/video_list_screen.dart';
import 'package:waste_management_app/screens/trashPickup/views/scheduled_pickups.dart';
import 'package:waste_management_app/screens/home/views/home_screen.dart';
import 'package:waste_management_app/screens/profile/views/profile_screen.dart';

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({Key? key, required this.initailIndex}) : super(key: key);
  final int initailIndex;
  @override
  State<BottomNavBar> createState() => BottomNavBarState();
}

class BottomNavBarState extends State<BottomNavBar>
    with SingleTickerProviderStateMixin {
  late TabController tabController;

  @override
  void initState() {
    super.initState();
    tabController = TabController(
        length: 4, vsync: this, initialIndex: widget.initailIndex);
    tabController.addListener(_handleTabSelection);
  }

  void _handleTabSelection() {
    setState(() {});
  }

  @override
  void dispose() {
    super.dispose();
    tabController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        bottomNavigationBar: CustomNavBarWidget(tabController: tabController),
        body: TabBarView(
          controller: tabController,
          children: [
            HomeScreen(),
            ScheduledPickupScreen(
              backButtonVisible: false,
            ),
            VideoList(),
            ProfileScreen(),
          ],
        ));
  }
}

class CustomNavBarWidget extends StatelessWidget {
  const CustomNavBarWidget({
    Key? key,
    required TabController tabController,
  })  : tabController = tabController,
        super(key: key);

  final TabController tabController;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: ClipRRect(
        borderRadius: const BorderRadius.all(
          Radius.circular(0.0),
        ),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 10),
          child: TabBar(
            indicator: DotIndicator(
              color: kPrimaryColor,
              distanceFromCenter: 20,
              radius: 3,
              paintingStyle: PaintingStyle.fill,
            ),
            controller: tabController,
            tabs: <Widget>[
              Tab(
                icon: Icon(
                  UIcons.regularRounded.home,
                  color: tabController.index == 0
                      ? kPrimaryColor
                      : kUnselectedItemColor,
                ),
              ),
              Tab(
                icon: Icon(
                  UIcons.regularRounded.calendar,
                  color: tabController.index == 1
                      ? kPrimaryColor
                      : kUnselectedItemColor,
                ),
              ),
              Tab(
                icon: Icon(
                  UIcons.regularRounded.shopping_bag,
                  color: tabController.index == 2
                      ? kPrimaryColor
                      : kUnselectedItemColor,
                ),
              ),
              Tab(
                icon: Icon(
                  UIcons.regularRounded.user,
                  color: tabController.index == 3
                      ? kPrimaryColor
                      : kUnselectedItemColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
