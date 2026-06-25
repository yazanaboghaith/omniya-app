import 'package:flutter/material.dart';
import 'package:omniya/core/l10n/app_localizations.dart';
import 'package:omniya/model/notification_model.dart';
import 'package:omniya/view/home/notification/controller/notifications_controller.dart';
import 'package:provider/provider.dart';

import 'package:omniya/core/const/app_background.dart';
import 'package:omniya/core/const/app_color.dart';

class Notifications extends StatefulWidget {
  const Notifications({super.key});

  @override
  State<Notifications> createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications> {
  int _selectedFilterIndex = 0;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationsController>().getNotifications(
            type: "all",
          );
    });
  }

  String getFilterType(int index) {
    switch (index) {
      case 0:
        return "all";
      case 1:
        return "unreaded";
      case 2:
        return "financial";
      case 3:
        return "system";
      default:
        return "all";
    }
  }

  Future<void> _refreshNotifications() async {
    await context.read<NotificationsController>().getNotifications(
          type: getFilterType(_selectedFilterIndex),
        );
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;

    return Consumer<NotificationsController>(
      builder: (context, controller, child) {
        return AppBackground(
          showHeader: false,
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: SafeArea(
              child: Column(
                children: [
                  _buildHeader(w, context),
                  _buildFilters(w, context, controller),
                  SizedBox(height: w * 0.02),
                  Expanded(
                    child: Stack(
                      children: [
                        RefreshIndicator(
                          onRefresh: _refreshNotifications,
                          child: controller.isLoadingNotification &&
                                  controller.notifications.isEmpty
                              ? const Center(child: CircularProgressIndicator())
                              : controller.notifications.isEmpty
                                  ? ListView(
                                      children: [
                                        SizedBox(height: w * 0.5),
                                        Center(
                                            child: Text(
                                                AppLocalizations.of(context)!
                                                    .no_notifications)),
                                      ],
                                    )
                                  : ListView.builder(
                                      padding: EdgeInsets.only(
                                        top: w * 0.03,
                                        bottom: w * 0.05,
                                      ),
                                      itemCount:
                                          controller.notifications.length,
                                      itemBuilder: (context, index) {
                                        final item =
                                            controller.notifications[index];
                                        final type =
                                            getFilterType(_selectedFilterIndex);

                                        return _buildNotificationCard(
                                          item,
                                          w,
                                          context,
                                          type,
                                        );
                                      },
                                    ),
                        ),
                        _buildTopFade(context),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTopFade(BuildContext context) {
    return IgnorePointer(
      child: Align(
        alignment: Alignment.topCenter,
        child: Container(
          height: 25,
          decoration: BoxDecoration(),
        ),
      ),
    );
  }

  Widget _buildHeader(double w, BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: w * 0.05,
        vertical: w * 0.04,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: w * 0.1,
                height: w * 0.1,
                decoration: BoxDecoration(
                  color: AppColors.text(context).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: Icon(
                    Icons.arrow_back_ios,
                    color: AppColors.text(context),
                    size: w * 0.045,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              SizedBox(width: w * 0.03),
              Text(
                AppLocalizations.of(context)!.notifications,
                style: AppTextStyles.text24(
                  context,
                ).copyWith(fontSize: w * 0.06),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilters(
    double w,
    BuildContext context,
    NotificationsController controller,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final filters = [
      AppLocalizations.of(context)!.all,
      AppLocalizations.of(context)!.unreaded,
      AppLocalizations.of(context)!.financial,
      AppLocalizations.of(context)!.system,
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(filters.length, (index) {
          final isSelected = _selectedFilterIndex == index;

          return Padding(
            padding: EdgeInsets.only(left: w * 0.025),
            child: GestureDetector(
              onTap: () async {
                if (_selectedFilterIndex == index) return;

                setState(() {
                  _selectedFilterIndex = index;
                });

                await controller.getNotifications(
                  type: getFilterType(index),
                );
              },
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: w * 0.06,
                  vertical: w * 0.03,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(w * 0.05),
                  color: isSelected
                      ? (isDark
                          ? AppColors.text(context).withValues(alpha: 0.15)
                          : Colors.black.withValues(alpha: 0.08))
                      : (isDark
                          ? AppColors.text(context).withValues(alpha: 0.08)
                          : Colors.black.withValues(alpha: 0.04)),
                ),
                child: Text(
                  filters[index],
                  style: isSelected
                      ? AppColors.textBold(context).copyWith(
                          fontSize: w * 0.032,
                        )
                      : TextStyle(
                          color: AppColors.text(context),
                          fontSize: w * 0.032,
                        ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildNotificationCard(
    NotificationItem item,
    double w,
    BuildContext context,
    String? currentType,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () async {
        final controller = context.read<NotificationsController>();

        final success = await controller.trackOpen(item.id.toString());

        if (success) {
          await controller.getNotifications(
            type: currentType ?? "all",
          );
        }
      },
      child: Container(
        margin: EdgeInsets.symmetric(
          horizontal: w * 0.05,
          vertical: w * 0.02,
        ),
        padding: EdgeInsets.all(w * 0.04),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(w * 0.07),
          border: Border.all(
            color: AppColors.text(context).withValues(alpha: 0.15),
          ),
          color: isDark
              ? AppColors.text(context).withValues(alpha: 0.08)
              : Colors.black.withValues(alpha: 0.04),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 25),
              child: SizedBox(
                width: w * 0.12,
                height: w * 0.12,
                // decoration: BoxDecoration(
                //   color: item.isRead
                //       ? const Color(0xFF243B59)
                //       : const Color(0xFF384042),
                //   borderRadius: BorderRadius.circular(w * 0.03),
                // ),
                child: Image.asset(
                  "assets/images/icon1.png",
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(width: w * 0.03),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: AppTextStyles.text17Bold(
                      context,
                    ).copyWith(fontSize: w * 0.042),
                  ),
                  SizedBox(height: w * 0.015),
                  Text(
                    item.body,
                    style: AppTextStyles.text13(context).copyWith(
                      height: 1.5,
                      fontSize: w * 0.032,
                      color: AppColors.text(context),
                    ),
                  ),
                  SizedBox(height: w * 0.03),
                  Text(
                    item.createdAt,
                    style: AppTextStyles.text13Grey(
                      context,
                    ).copyWith(fontSize: w * 0.03),
                  ),
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.only(
                top: w * 0.015,
                right: w * 0.03,
              ),
              width: w * 0.03,
              height: w * 0.03,
              decoration: BoxDecoration(
                color:
                    !item.isRead ? AppColors.secondaryText : Colors.transparent,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
