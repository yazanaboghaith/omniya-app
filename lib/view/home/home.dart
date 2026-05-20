import 'package:flutter/material.dart';
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

  final List<Widget> pages = const [HomePage(), PaymentScreen(), RequestPage()];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,

      body: PageView(
        controller: _pageController,

        physics: const BouncingScrollPhysics(),
        onPageChanged: (index) {
          setState(() {
            currentIndex = index;
          });
        },

        children: pages,
      ),

      bottomNavigationBar: CustomBottomBar(
        currentIndex: currentIndex,

        onTap: (index) {
          setState(() {
            currentIndex = index;
          });

          _pageController.animateToPage(
            index,
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOutCubic,
          );
        },
      ),
    );
  }
}
