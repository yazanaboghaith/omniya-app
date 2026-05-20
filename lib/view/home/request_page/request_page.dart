import 'dart:async';

import 'package:flutter/material.dart';
import 'package:omniya/const/app_background.dart';
import 'package:omniya/const/app_color.dart';
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

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final h = size.height;

    final controller = context.watch<RequestPageController>();
    final orders = controller.orders;
    return AppBackground(
      showHeader: true,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Column(
            children: [
              SizedBox(height: h * 0.02),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 40),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    padding: const EdgeInsets.all(16),
                    decoration: _glassDecoration(context),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        buildHeaderTitle(context, h),
                        SizedBox(height: h * 0.02),
                        buildSearchField(
                          context,
                          searchController,
                          _debounce,
                          (timer) => _debounce = timer,
                        ),
                        SizedBox(height: h * 0.02),
                        Expanded(
                          child: buildBody(
                            context,
                            controller,
                            orders,
                            _refresh,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              SizedBox(height: h * 0.02),
            ],
          ),
        ),
      ),
    );
  }

  BoxDecoration _glassDecoration(BuildContext context) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(28),
      border: Border.all(
        color: AppColors.text(context).withValues(alpha: 0.15),
        width: 1,
      ),
      gradient: LinearGradient(
        colors: [
          AppColors.text(context).withValues(alpha: 0.25),
          AppColors.text(context).withValues(alpha: 0.25),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    );
  }
}
