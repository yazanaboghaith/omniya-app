import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:omniya/const/app_color.dart';
import 'package:omniya/const/color.dart';
import 'package:omniya/model/user_model.dart';
import 'package:omniya/view/auth/services/auth_storage.dart';
import 'package:omniya/view/home/splash/splash.dart';
import 'package:page_transition/page_transition.dart';

class ProfileBottomSheet extends StatefulWidget {
  final UserModel? user;

  const ProfileBottomSheet({super.key, required this.user});

  @override
  State<ProfileBottomSheet> createState() => _ProfileBottomSheetState();
}

class _ProfileBottomSheetState extends State<ProfileBottomSheet> {
  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        margin: const EdgeInsets.only(top: 200),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 5),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                color: isDark
                    ? AppColors.text(context).withValues(alpha: 0.2)
                    : AppColors.grey(context).withValues(alpha: 0),
                border: Border.all(
                  color: AppColors.text(context).withValues(alpha: 0.2),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Divider(
                    thickness: 4,
                    color: AppColors.text(context),
                    indent: 150,
                    endIndent: 150,
                  ),

                  const SizedBox(height: 20),

                  Text("معلومات الحساب", style: AppTextStyles.text24(context)),

                  const SizedBox(height: 25),

                  _buildItem(
                    context,
                    title: "اسم المستخدم",
                    value:
                        widget.user?.arabicName ??
                        widget.user?.username ??
                        "--",
                  ),

                  Divider(
                    color: AppColors.text(context).withValues(alpha: 0.2),
                  ),

                  _buildItem(
                    context,
                    title: "رقم الهاتف",
                    value: widget.user?.phone ?? widget.user?.mobile ?? "--",
                  ),

                  Divider(
                    color: AppColors.text(context).withValues(alpha: 0.2),
                  ),

                  _buildItem(
                    context,
                    title: "اسم الخدمة",
                    value: widget.user?.baseService.name ?? "--",
                  ),

                  Divider(
                    color: AppColors.text(context).withValues(alpha: 0.2),
                  ),

                  _buildItem(
                    context,
                    title: "الرمز الشهري",
                    value: widget.user?.id.toString() ?? "--",
                  ),

                  Divider(
                    color: AppColors.text(context).withValues(alpha: 0.2),
                  ),

                  _buildItem(
                    context,
                    title: "تاريخ الصلاحية",
                    value: widget.user?.expiryDate ?? "--",
                  ),

                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "حالة المستخدم",
                        style: AppTextStyles.text17Bold(context),
                      ),

                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: MediaQuery.of(context).size.width * 0.05,
                          vertical: MediaQuery.of(context).size.height * 0.015,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: widget.user?.status == "Active"
                              ? Colors.green.withValues(alpha: 0.8)
                              : Colors.red.withValues(alpha: 0.8),
                        ),
                        child: Text(
                          widget.user?.arabicStatus ?? "--",
                          style: AppTextStyles.text15(context),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.33,
                    child: ElevatedButton(
                      onPressed: isLoading
                          ? null
                          : () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (_) => Dialog(
                                  // backgroundColor: Colors.transparent,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(28),

                                    child: BackdropFilter(
                                      filter: ImageFilter.blur(
                                        sigmaX: 8,
                                        sigmaY: 8,
                                      ),

                                      child: Container(
                                        padding: const EdgeInsets.all(20),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            28,
                                          ),
                                          border: Border.all(
                                            color: AppColors.text(
                                              context,
                                            ).withValues(alpha: 0.1),
                                            width: 1,
                                          ),
                                          gradient: LinearGradient(
                                            colors: [
                                              AppColors.text(
                                                context,
                                              ).withValues(alpha: 0.01),
                                              AppColors.text(
                                                context,
                                              ).withValues(alpha: 0.01),
                                            ],
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                          ),
                                        ),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            SizedBox(
                                              height:
                                                  MediaQuery.of(
                                                    context,
                                                  ).size.height *
                                                  0.01,
                                            ),
                                            Container(
                                              height:
                                                  MediaQuery.of(
                                                    context,
                                                  ).size.height *
                                                  0.12,
                                              width:
                                                  MediaQuery.of(
                                                    context,
                                                  ).size.width *
                                                  0.26,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                              ),
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                                child: Image.asset(
                                                  "assets/images/icon.png",
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              height:
                                                  MediaQuery.of(
                                                    context,
                                                  ).size.height *
                                                  0.04,
                                            ),

                                            Text(
                                              "هل أنت متأكد أنك تريد تسجيل الخروج؟",
                                              style: AppTextStyles.text15(
                                                context,
                                              ),
                                            ),

                                            SizedBox(
                                              height:
                                                  MediaQuery.of(
                                                    context,
                                                  ).size.height *
                                                  0.04,
                                            ),

                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                TextButton(
                                                  onPressed: () async {
                                                    final AuthStorage storage =
                                                        AuthStorage();
                                                    await storage.logout();

                                                    if (!mounted) return;
                                                    Navigator.pushAndRemoveUntil(
                                                      context,
                                                      PageTransition(
                                                        type: PageTransitionType
                                                            .fade,
                                                        child: const Splash(),
                                                      ),
                                                      (route) => false,
                                                    );
                                                  },
                                                  child: const Text(
                                                    "تأكيد",
                                                    style: TextStyle(
                                                      color: Colors.redAccent,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 17,
                                                    ),
                                                  ),
                                                ),
                                                TextButton(
                                                  onPressed: () =>
                                                      Navigator.pop(
                                                        context,
                                                        false,
                                                      ),
                                                  child: Text(
                                                    "إلغاء",
                                                    style:
                                                        AppTextStyles.text17Bold(
                                                          context,
                                                        ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );

                              if (confirm != true) return;

                              setState(() => isLoading = true);

                              try {
                                final storage = AuthStorage();
                                await storage.logout();

                                if (!mounted) return;

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    backgroundColor: ksecondarycolor,
                                    content: Center(
                                      child: Text(
                                        "تم تسجيل الخروج بنجاح",
                                        style: AppTextStyles.text15(context),
                                      ),
                                    ),
                                  ),
                                );

                                Navigator.of(context).pop();
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    backgroundColor: ksecondarycolor,
                                    content: Center(
                                      child: Text(
                                        "حدث خطأ أثناء تسجيل الخروج",
                                        style: AppTextStyles.text15(context),
                                      ),
                                    ),
                                  ),
                                );
                              } finally {
                                if (mounted) {
                                  setState(() => isLoading = false);
                                }
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDark
                            ? AppColors.text(context).withValues(alpha: 0.2)
                            : AppColors.text(context).withAlpha(38),
                        padding: const EdgeInsets.symmetric(vertical: 17),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(26),
                        ),
                      ),
                      child: isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(
                              "تسجيل خروج",
                              style: AppTextStyles.text15BlackBold(),
                            ),
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildItem(
    BuildContext context, {
    required String title,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Text(
            title,
            style: TextStyle(
              color: AppColors.text(context),
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.left,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
