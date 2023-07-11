import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:healthy_cook/color_scheme.dart';
import 'package:healthy_cook/views/add_page.dart';
import 'package:healthy_cook/views/initial_page.dart';
import 'package:healthy_cook/views/profile_page.dart';
import 'package:healthy_cook/views/search_page.dart';
import 'package:line_icons/line_icons.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int selectedPage = 0;
  late PageController pController;
  Color navBarBackgroundColor = lightColorScheme.primary;

  @override
  void initState() {
    super.initState();
    pController = PageController(initialPage: selectedPage);
  }

  setSelectedPage(page) {
    setState(() {
      selectedPage = page;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (Theme.of(context).brightness == Brightness.dark) {
      navBarBackgroundColor = darkColorScheme.primary;
    } else {
      navBarBackgroundColor = lightColorScheme.primary;
    }

    return Scaffold(
      body: PageView(
        controller: pController,
        onPageChanged: setSelectedPage,
        children: const [
          InitialPage(),
          AddPage(),
          SearchPage(),
          ProfilePage(),
        ],
      ),
      bottomNavigationBar: GNav(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        selectedIndex: selectedPage,
        gap: 8,
        haptic: true,
        tabBorderRadius: 45,
        curve: Curves.easeInToLinear,
        tabs: const [
          GButton(
            icon: LineIcons.home,
            text: 'Home',
          ),
          GButton(
            icon: LineIcons.plus,
            text: 'Add',
          ),
          GButton(
            icon: LineIcons.search,
            text: 'Search',
          ),
          GButton(
            icon: LineIcons.user,
            text: 'Profile',
          )
        ],
        backgroundColor: navBarBackgroundColor,
        onTabChange: (page) => pController.animateToPage(page,
            duration: const Duration(milliseconds: 400), curve: Curves.easeIn),
      ),
    );
  }
}
