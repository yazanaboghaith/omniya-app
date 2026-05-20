import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:omniya/const/app_color.dart';
import 'package:omniya/const/controller/theme_controller.dart';
import 'package:omniya/view/home/home_page/controller/home_page_controller.dart';
import 'package:omniya/view/home/notification/notifications.dart';
import 'package:omniya/view/home/profile/profile_bottom_sheet.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';

class AppBackground extends StatelessWidget {
  final Widget child;
  final bool showHeader;

  const AppBackground({
    super.key,
    required this.child,
    this.showHeader = false,
  });

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;

    return Scaffold(
      resizeToAvoidBottomInset: true,

      body: Stack(
        children: [
          Positioned.fill(
            child: IgnorePointer(
              child: RepaintBoundary(
                child: Stack(
                  children: [
                    Positioned(
                      top: -100,
                      right: -182,
                      child: _circle(AppColors.primary),
                    ),
                    Positioned(
                      bottom: -100,
                      left: -202,
                      child: _circle(AppColors.secondary),
                    ),
                    const _BlurLayer(),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,

              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height,
                ),

                child: IntrinsicHeight(
                  child: showHeader
                      ? Column(
                          children: [
                            Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: w * 0.05,
                                vertical: w * 0.02,
                              ),
                              child: _buildHeader(w, context),
                            ),
                            Expanded(child: child),
                          ],
                        )
                      : child,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _circle(Color color) {
    return Container(
      width: 415,
      height: 415,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: 0.5),
      ),
    );
  }

  Widget _buildHeader(double w, BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SvgPicture.asset("assets/images/logohome.svg", height: w * 0.1),

        Row(
          children: [
            GestureDetector(
              onTap: () async {
                await ThemeController.toggleTheme();
              },
              child: Container(
                padding: EdgeInsets.all(w * 0.02),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppColors.text(context).withValues(alpha: 0.6)
                      : Colors.black.withValues(alpha: 0.1),
                ),
                child: Icon(
                  ThemeController.isDark
                      ? Icons.wb_sunny
                      : Icons.nightlight_round,
                  color: AppColors.text(context),
                  size: w * 0.065,
                ),
              ),
            ),

            SizedBox(width: w * 0.03),

            Container(
              padding: EdgeInsets.symmetric(
                horizontal: w * 0.03,
                vertical: w * 0.01,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.text(context).withValues(alpha: 0.6)
                    : Colors.black.withValues(alpha: 0.1),
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        PageTransition(
                          type: PageTransitionType.fade,
                          child: const Notifications(),
                        ),
                      );
                    },
                    icon: Icon(
                      Icons.notifications,
                      color: AppColors.text(context),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      final controller = context.read<HomePageController>();

                      showModalBottomSheet(
                        useSafeArea: true,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        context: context,
                        builder: (_) {
                          return ProfileBottomSheet(user: controller.user);
                        },
                      );
                    },
                    icon: Icon(
                      Icons.account_circle,
                      color: AppColors.text(context),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _BlurLayer extends StatelessWidget {
  const _BlurLayer();

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(
        sigmaX: 12,
        sigmaY: 12,
        tileMode: TileMode.decal,
      ),
      child: const SizedBox.expand(),
    );
  }
}
