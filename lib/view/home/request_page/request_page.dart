import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:omniya/core/const/app_color.dart';
import 'package:omniya/model/service_package.dart';
import 'package:omniya/view/home/request_page/addrequest/add_request_card.dart';
import 'package:omniya/view/home/request_page/controller/request_page_controller.dart';
import 'package:omniya/view/home/request_page/addrequest/controller/add_request_controller.dart';
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

  ServicePackage? selectedPackage;

  @override
  void initState() {
    super.initState();

    debugPrint(" [PAGE] initState");

    WidgetsBinding.instance.addPostFrameCallback((_) {
      debugPrint(" [PAGE] Loading orders + packages");

      context.read<RequestPageController>().getOrders();
      context.read<AddonServiceController>().getServicePackages();
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

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final w = size.width;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _refresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: w * 0.04, vertical: 12),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 650),
              child: Column(
                children: [
                  AddRequestCard(
                    selectedPackage: selectedPackage,
                    onPackageChanged: (value) {
                      debugPrint(" [PAGE] Package selected => ${value?.name}");

                      setState(() {
                        selectedPackage = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
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
                        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                        child: Container(
                          padding: EdgeInsets.all(w * 0.05),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              buildHeaderTitle(context, size.height),
                              SizedBox(height: w * 0.04),
                              buildSearchField(
                                context,
                                searchController,
                                _debounce,
                                (t) => _debounce = t,
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
