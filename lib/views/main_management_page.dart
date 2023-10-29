import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:healthy_cook/views/add_page.dart';
import 'package:healthy_cook/views/home_page.dart';
import 'package:healthy_cook/views/profile_page.dart';
import 'package:healthy_cook/views/search_page.dart';
import 'package:line_icons/line_icons.dart';

class MainManagementPage extends StatefulWidget {
  const MainManagementPage({Key? key}) : super(key: key);

  @override
  State<MainManagementPage> createState() => _MainManagementPageState();
}

class _MainManagementPageState extends State<MainManagementPage> {
  int selectedPage = 0;
  late PageController pController;

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
    return Scaffold(
      body: PageView(
        controller: pController,
        onPageChanged: setSelectedPage,
        children: const [
          HomePage(),
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
            text: 'Início',
          ),
          GButton(
            icon: LineIcons.plus,
            text: 'Adicionar',
          ),
          GButton(
            icon: LineIcons.search,
            text: 'Pesquisa',
          ),
          GButton(
            icon: LineIcons.user,
            text: 'Perfil',
          )
        ],
        onTabChange: (page) => pController.animateToPage(page,
            duration: const Duration(milliseconds: 400), curve: Curves.easeIn),
      ),
    );
  }
}
