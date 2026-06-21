import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:omniya/const/app_color.dart';
import 'package:omniya/view/home/payment_screen/const/custom_glass_dropdown.dart';
import 'package:omniya/view/home/request_page/controller/request_page_controller.dart';
import 'package:omniya/view/home/request_page/request_page_widgets.dart';
import 'package:provider/provider.dart';

class RequestPage extends StatefulWidget {
  const RequestPage({super.key});

  @override
  State<RequestPage> createState() => _RequestPageState();
}

class _RequestPageState extends State<RequestPage> {
  final TextEditingController searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<RequestPageController>(context, listen: false).getOrders();
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _refresh() async {
    await context.read<RequestPageController>().refreshOrders();
  }

  String? selectedRequestType;

  final List<String> requestTypes = [
    "طلب صيانة",
    "طلب اشتراك",
    "طلب خدمة",
  ];
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final h = size.height;
    final w = size.width;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _refresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.symmetric(
            horizontal: w * 0.04,
            vertical: 12,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 650),
              child: Column(
                children: [
                  Column(
                    children: [
                      AddRequestCard(
                        requestTypes: requestTypes,
                        selectedRequestType: selectedRequestType,
                        onRequestTypeChanged: (value) {
                          setState(() {
                            selectedRequestType = value;
                          });
                        },
                        isFormValid: selectedRequestType != null,
                        onSubmit: () {
                          debugPrint(
                            "تم إرسال الطلب من النوع: $selectedRequestType",
                          );
                        },
                      ),

                      const SizedBox(height: 16),

                      // تقرير الطلبات الحالي كما هو
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(w * 0.07),
                          border: Border.all(
                            color:
                                AppColors.text(context).withValues(alpha: 0.15),
                          ),
                          color: isDark
                              ? AppColors.text(context).withValues(alpha: 0.08)
                              : Colors.black.withValues(alpha: 0.04),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(28),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(
                              sigmaX: 16,
                              sigmaY: 16,
                            ),
                            child: Container(
                              padding: EdgeInsets.all(w * 0.05),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  buildHeaderTitle(context, h),
                                  SizedBox(height: w * 0.04),
                                  buildSearchField(
                                    context,
                                    searchController,
                                    _debounce,
                                    (timer) => _debounce = timer,
                                  ),
                                  SizedBox(height: w * 0.04),
                                  Consumer<RequestPageController>(
                                    builder: (context, controller, child) {
                                      return buildBody(
                                        context,
                                        controller,
                                        controller.orders,
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      Consumer<RequestPageController>(
                        builder: (context, controller, child) {
                          return buildPagination(
                            context,
                            controller,
                          );
                        },
                      ),
                    ],
                  ),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(w * 0.07),
                      border: Border.all(
                        color: AppColors.text(context).withValues(alpha: 0.15),
                      ),
                      color: isDark
                          ? AppColors.text(context).withValues(alpha: 0.08)
                          : Colors.black.withValues(alpha: 0.04),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(28),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 16.0, sigmaY: 16.0),
                        child: Container(
                          padding: EdgeInsets.all(w * 0.05),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              buildHeaderTitle(context, h),
                              SizedBox(height: w * 0.04),
                              buildSearchField(
                                context,
                                searchController,
                                _debounce,
                                (timer) => _debounce = timer,
                              ),
                              SizedBox(height: w * 0.04),
                              Consumer<RequestPageController>(
                                builder: (context, controller, child) {
                                  return buildBody(
                                    context,
                                    controller,
                                    controller.orders,
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Consumer<RequestPageController>(
                    builder: (context, controller, child) {
                      return buildPagination(context, controller);
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class AddRequestCard extends StatelessWidget {
  final List<String> requestTypes;
  final String? selectedRequestType;
  final ValueChanged<String?> onRequestTypeChanged;
  final VoidCallback onSubmit;
  final bool isFormValid;

  const AddRequestCard({
    super.key,
    required this.requestTypes,
    required this.selectedRequestType,
    required this.onRequestTypeChanged,
    required this.onSubmit,
    required this.isFormValid,
  });

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(w * 0.05 < 24 ? w * 0.05 : 24),
      decoration: _glassDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "إضافة طلب",
            style: AppTextStyles.text19Bold(context),
          ),
          SizedBox(height: w * 0.04),
          Text(
            "نوع الطلب",
            style: AppTextStyles.text15(context),
          ),
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: 1,
              vertical: 4,
            ),
            child: CustomGlassDropdown<String>(
              isLoading: false,
              items: requestTypes,
              selectedItem: selectedRequestType,
              hint: "اختر نوع الطلب",
              itemAsString: (item) => item,
              onChanged: onRequestTypeChanged,
            ),
          ),
          SizedBox(height: w * 0.06),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: isFormValid
                    ? Colors.green.withValues(alpha: 0.6)
                    : Colors.grey.withOpacity(0.15),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              onPressed: isFormValid ? onSubmit : null,
              child: const Text(
                "إضافة طلب",
              ),
            ),
          ),
        ],
      ),
    );
  }
}

BoxDecoration _glassDecoration(BuildContext context) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final w = MediaQuery.of(context).size.width;

  return BoxDecoration(
    borderRadius: BorderRadius.circular(w * 0.07),
    border: Border.all(
      width: 1,
      color: AppColors.text(context).withValues(alpha: 0.1),
    ),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.08),
        blurRadius: 20,
        offset: const Offset(0, 8),
      ),
      BoxShadow(
        color: Colors.white.withValues(alpha: 0.03),
        blurRadius: 6,
        offset: const Offset(0, 2),
      ),
    ],
    color: isDark
        ? AppColors.text(context).withValues(alpha: 0.08)
        : Colors.black.withValues(alpha: 0.04),
  );
}

class GlassCard extends StatelessWidget {
  final Widget child;

  const GlassCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(w * 0.07),
        border: Border.all(
          color: AppColors.text(context).withValues(alpha: 0.15),
        ),
        color: isDark
            ? AppColors.text(context).withValues(alpha: 0.08)
            : Colors.black.withValues(alpha: 0.04),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: child,
      ),
    );
  }
}
