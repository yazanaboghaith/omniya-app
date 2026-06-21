import 'package:flutter/material.dart';
import 'package:omniya/const/app_background.dart';
import 'package:omniya/view/home/const/custom_bottom_bar.dart';

import 'package:omniya/view/home/home_page/home_page.dart';
import 'package:omniya/view/home/payment_screen/payment_screen.dart';
import 'package:omniya/view/home/request_page/request_page.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int currentIndex = 0;
  late PageController _pageController;

  final List<Widget> pages = const [
    HomePage(),
    PaymentScreen(),
    RequestPage(),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      showHeader: true,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBody: true,
        body: PageView(
          controller: _pageController,
          onPageChanged: (i) => setState(() => currentIndex = i),
          children: pages,
        ),
      
        bottomNavigationBar: SafeArea(
          top: false,
          left: false,
          right: false,
          bottom:
              true, 
          child: CustomBottomBar(
            currentIndex: currentIndex,
            onTap: (i) {
              setState(() => currentIndex = i);
              _pageController.animateToPage(
                i,
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
              );
            },
          ),
        ),
      ),
    );
  }
}
