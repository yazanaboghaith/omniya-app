import 'package:flutter/material.dart';
import 'package:omniya/const/app_background.dart';
import 'package:omniya/const/app_color.dart';

class Notifications extends StatefulWidget {
  const Notifications({super.key});

  @override
  State<Notifications> createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications> {
  int _selectedFilterIndex = 0;
  final List<String> _filters = ["الكل", "المالية", "النظام"];

  final List<Map<String, dynamic>> _notifications = [
    {
      "title": "تم شحن الباقة بنجاح",
      "body": "لقد تمت إضافة 10 غيغا بايت إلى حسابك بنجاح.",
      "time": "منذ دقيقتين",
      "iconColor": const Color(0xFF384042),
      "isUnread": true,
    },
    {
      "title": "تحديث النظام",
      "body": "سيكون هناك أعمال صيانة دورية للنظام.",
      "time": "أمس 10:30 م",
      "iconColor": const Color(0xFF243B59),
      "isUnread": false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;

    return AppBackground(
      showHeader: false,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Directionality(
          textDirection: TextDirection.rtl,
          child: SafeArea(
            child: Column(
              children: [
                _buildHeader(w, context),
                _buildFilters(w, context),

                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.only(top: w * 0.03, bottom: w * 0.05),
                    itemCount: _notifications.length,
                    itemBuilder: (context, index) {
                      return _buildNotificationCard(
                        _notifications[index],
                        w,
                        context,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ================= HEADER =================
  Widget _buildHeader(double w, BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: w * 0.05, vertical: w * 0.04),
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
                "الإشعارات",
                style: AppTextStyles.text24(
                  context,
                ).copyWith(fontSize: w * 0.06),
              ),
            ],
          ),

          TextButton(
            onPressed: () {},
            child: Text(
              "قراءة الكل",
              style: TextStyle(
                color: AppColors.secondaryText,
                fontSize: w * 0.035,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================= FILTERS =================
  Widget _buildFilters(double w, BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: w * 0.05, vertical: w * 0.02),
      child: Row(
        children: List.generate(_filters.length, (index) {
          final isSelected = _selectedFilterIndex == index;

          return Padding(
            padding: EdgeInsets.only(left: w * 0.025),
            child: GestureDetector(
              onTap: () => setState(() => _selectedFilterIndex = index),
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
                  _filters[index],
                  style: TextStyle(
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.text(context),
                    fontWeight: FontWeight.bold,
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

  // ================= CARD =================
  Widget _buildNotificationCard(
    Map<String, dynamic> item,
    double w,
    BuildContext context,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: w * 0.05, vertical: w * 0.02),
      padding: EdgeInsets.all(w * 0.04),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(w * 0.07),

        // border theme-aware
        border: Border.all(
          color: AppColors.text(context).withValues(alpha: 0.15),
        ),

        // background theme-aware
        color: isDark
            ? AppColors.text(context).withValues(alpha: 0.08)
            : Colors.black.withValues(alpha: 0.04),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: w * 0.12,
            height: w * 0.12,
            decoration: BoxDecoration(
              color: item['iconColor'],
              borderRadius: BorderRadius.circular(w * 0.03),
            ),
          ),

          SizedBox(width: w * 0.03),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['title'],
                  style: AppTextStyles.text17Bold(
                    context,
                  ).copyWith(fontSize: w * 0.042),
                ),

                SizedBox(height: w * 0.015),

                Text(
                  item['body'],
                  style: AppTextStyles.text13(context).copyWith(
                    height: 1.5,
                    fontSize: w * 0.032,
                    color: AppColors.text(context),
                  ),
                ),

                SizedBox(height: w * 0.03),

                Text(
                  item['time'],
                  style: AppTextStyles.text13Grey(
                    context,
                  ).copyWith(fontSize: w * 0.03),
                ),
              ],
            ),
          ),

          Container(
            margin: EdgeInsets.only(top: w * 0.015, right: w * 0.03),
            width: w * 0.03,
            height: w * 0.03,
            decoration: BoxDecoration(
              color: item['isUnread']
                  ? AppColors.secondaryText
                  : Colors.transparent,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }
}
