import 'package:flutter/material.dart';
import 'package:omniya/core/const/connection_error_view.dart';
import 'package:omniya/model/setting/router_model.dart';
import 'package:omniya/view/home/router_setting/router/controller/router_model_controller.dart';
import 'package:omniya/view/home/router_setting/router/widget/router_brand_content.dart';
import 'package:omniya/view/home/router_setting/router/widget/router_empty_state.dart';
import 'package:omniya/view/home/router_setting/router/widget/router_models_sheet.dart';
import 'package:omniya/view/home/router_setting/router_login/router_login_page.dart';

class RouterSelectionPage extends StatefulWidget {
  const RouterSelectionPage({
    super.key,
  });

  @override
  State<RouterSelectionPage> createState() => _RouterSelectionPageState();
}

class _RouterSelectionPageState extends State<RouterSelectionPage> {
  late final RouterModelController controller;

  bool isRefreshing = false;

  @override
  void initState() {
    super.initState();

    controller = RouterModelController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initialize();
    });
  }

  Future<void> _initialize() async {
    if (!mounted) {
      return;
    }

    await controller.initialize();
  }

  Future<void> _selectBrand(
    RouterBrand brand,
  ) async {
    final success = await controller.getRoutersByBrand(
      brand,
    );

    if (!mounted) {
      return;
    }

    if (!success) {
      _showError(
        controller.errorMessage ?? 'Error',
      );

      return;
    }

    if (controller.routers.isEmpty) {
      _showError(
        'No models',
      );

      return;
    }

    if (controller.routers.length == 1) {
      await _selectRouter(
        controller.routers.first,
      );

      return;
    }

    await _showRouterModels();
  }

  Future<void> _selectRouter(
    RouterModel router,
  ) async {
    final gateway = controller.gateway;

    if (gateway == null || gateway.trim().isEmpty) {
      _showError(
        'Gateway',
      );

      return;
    }

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) {
          return RouterLoginPage(
            gateway: gateway,
            modelSlug: router.modelNumber,
            router: router,
            controller: controller.routerController,
            routerId: router.id,
          );
        },
      ),
    );
  }

  Future<void> _showRouterModels() async {
    if (!mounted) {
      return;
    }

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      barrierColor: Colors.transparent,
      builder: (_) {
        return RouterModelsSheet(
          routers: controller.routers,
          onRouterSelected: (router) async {
            Navigator.of(context).pop();

            await _selectRouter(router);
          },
        );
      },
    );
  }

  Future<void> _retryInitialization() async {
    if (isRefreshing) {
      return;
    }

    setState(() {
      isRefreshing = true;
    });

    try {
      final success = await controller.retry();

      if (!success && mounted && controller.errorMessage != null) {
        _showError(
          controller.errorMessage!,
        );
      }
    } finally {
      if (!mounted) {
        return;
      }

      setState(() {
        isRefreshing = false;
      });
    }
  }

  Future<void> _refresh() async {
    final success = await controller.refresh();

    if (!success && mounted && controller.errorMessage != null) {
      _showError(
        controller.errorMessage!,
      );
    }
  }

  Future<void> _retryRefresh() async {
    if (isRefreshing) {
      return;
    }

    setState(() {
      isRefreshing = true;
    });

    try {
      final success = await controller.refresh();

      if (!success && mounted && controller.errorMessage != null) {
        _showError(
          controller.errorMessage!,
        );
      }
    } finally {
      if (!mounted) {
        return;
      }

      setState(() {
        isRefreshing = false;
      });
    }
  }

  void _showError(
    String message,
  ) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (controller.isInitializing) {
      return const PageLoadingView(
        message: 'Loading',
      );
    }

    if (controller.hasError && !controller.initialized) {
      return ConnectionErrorView(
        isLoading: isRefreshing,
        onRetry: _retryInitialization,
      );
    }

    if (controller.isLoadingBrands) {
      return const PageLoadingView(
        message: 'Loading',
      );
    }

    if (controller.brands.isEmpty) {
      return RouterEmptyState(
        isRefreshing: isRefreshing,
        onRetry: _retryRefresh,
      );
    }

    return RouterBrandContent(
      brands: controller.brands,
      onRefresh: _refresh,
      onBrandSelected: _selectBrand,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            bottom: false,
            child: _buildBody(),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    controller.dispose();

    super.dispose();
  }
}
