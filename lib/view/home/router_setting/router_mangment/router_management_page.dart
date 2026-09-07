import 'package:flutter/material.dart';
import 'package:omniya/core/const/app_background.dart';
import 'package:omniya/core/const/app_color.dart';
import 'package:omniya/core/l10n/app_localizations.dart';
import 'package:omniya/model/setting/router_model.dart';
import 'package:omniya/view/home/home.dart';
import 'package:omniya/view/home/router_setting/router_mangment/controller/router_management_controller.dart';
import 'package:omniya/view/home/router_setting/router_mangment/service/router_report_service.dart';
import 'package:omniya/view/home/router_setting/router_mangment/widget/router_overview_widget.dart';
import 'package:omniya/view/home/router_setting/router_mangment/widget/router_password_widget.dart';
import 'package:omniya/view/home/router_setting/router_mangment/widget/router_values_widget.dart';
import 'package:omniya/view/home/router_setting/router_telnet_split/router_telnet_service.dart';

class RouterManagementPage extends StatefulWidget {
  final String gateway;
  final RouterModel router;
  final int routerId;
  final RouterTelnetService telnetService;

  const RouterManagementPage({
    super.key,
    required this.gateway,
    required this.router,
    required this.routerId,
    required this.telnetService,
  });

  @override
  State<RouterManagementPage> createState() => _RouterManagementPageState();
}

class _RouterManagementPageState extends State<RouterManagementPage> {
  late final RouterManagementController controller;

  bool _is5G = false;
  bool _isDisconnecting = false;

  Color get _primary => AppColors.primary;
  Color get _error => const Color(0xFFD9534F);

  final RouterReportService reportService = RouterReportService();

  @override
  void initState() {
    super.initState();

    controller = RouterManagementController(
      routerId: widget.routerId,
      telnetService: widget.telnetService,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _loadPageData();
      }
    });
  }

  Future<void> _loadPageData() async {
    final commandsSuccess = await controller.loadRouterCommands();

    if (!mounted) return;

    if (!commandsSuccess) {
      _showError(
        controller.errorMessage ??
            AppLocalizations.of(context)!.router_commands_error,
      );
      return;
    }

    if (!controller.supports2G && controller.supports5G) {
      setState(() {
        _is5G = true;
      });
    } else if (controller.supports2G && !controller.supports5G) {
      setState(() {
        _is5G = false;
      });
    }

    await controller.loadLineStatistics();

    if (!mounted) return;

    await reportService.sendRouterReport(
      routerModelId: widget.routerId,
      values: {
        'DataRateDown': controller.lineStatisticsValues['downstreamRate'] ?? '',
        'DataRateUP': controller.lineStatisticsValues['upstreamRate'] ?? '',
        'CRC': controller.downstreamCrc.toString(),
        'SNRUP': controller.lineStatisticsValues['upstreamSnr'] ?? '',
        'SNRDown': controller.lineStatisticsValues['downstreamSnr'] ?? '',
        'Lineattenutionup':
            controller.lineStatisticsValues['upstreamAttenuation'] ?? '',
        'Lineattenutiondown':
            controller.lineStatisticsValues['downstreamAttenuation'] ?? '',
      },
      errorMessage: controller.lineStatisticsError,
    );
  }

  Future<void> _refresh() async {
    if (controller.isLoading || controller.isLoadingLineStatistics) {
      return;
    }
    await _loadPageData();
  }

  Future<void> _changePassword(String password) async {
    if (controller.isChangingPassword) {
      return;
    }

    FocusScope.of(context).unfocus();
    controller.clearPasswordMessages();

    final success = await controller.changeWifiPassword(
      password: password.trim(),
      is5G: _is5G,
    );

    if (!mounted) return;

    if (success) {
      await _handlePasswordChanged();
    } else {
      _showError(
        controller.passwordError ??
            AppLocalizations.of(context)!.router_password_change_error,
      );
    }
  }

  Future<void> _handlePasswordChanged() async {
    if (!mounted) return;

    final l10n = AppLocalizations.of(context)!;

    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.check_circle_rounded,
              color: Colors.white,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                l10n.router_password_changed_successfully,
              ),
            ),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        backgroundColor: const Color(0xFF2E9B68),
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );

    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => Home(),
      ),
      (route) => false,
    );
  }

  Future<void> _disconnect() async {
    if (_isDisconnecting) {
      return;
    }

    setState(() {
      _isDisconnecting = true;
    });

    try {
      await controller.disconnect();
    } catch (_) {}

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => Home(),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return AppBackground(
          showHeader: false,
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: _buildAppBar(),
            body: _buildBody(),
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar() {
    final l10n = AppLocalizations.of(context)!;

    return AppBar(
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: Colors.transparent,
      centerTitle: true,
      titleSpacing: 18,
      title: Text(
        l10n.router_management,
        style: AppTextStyles.text19Bold(context),
      ),
      actions: [
        IconButton(
          tooltip: l10n.router_disconnect,
          onPressed: _isDisconnecting ? null : _disconnect,
          style: IconButton.styleFrom(
            backgroundColor: Theme.of(context).brightness == Brightness.dark
                ? const Color(0xFF171722).withValues(alpha: .85)
                : Colors.white.withValues(alpha: .85),
            foregroundColor: AppColors.text(context),
            disabledForegroundColor:
                AppColors.grey(context).withValues(alpha: .4),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          icon: const Icon(
            Icons.logout_rounded,
            size: 21,
          ),
        ),
        const SizedBox(width: 12),
      ],
    );
  }

  Widget _buildBody() {
    if (controller.isLoading) {
      return _loadingView();
    }

    if (controller.hasError && controller.response == null) {
      return _errorView();
    }

    return RefreshIndicator(
      color: _primary,
      onRefresh: _refresh,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final horizontalPadding = width < 360
              ? 10.0
              : width < 600
                  ? 14.0
                  : width < 900
                      ? 24.0
                      : 32.0;

          return ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: 12,
            ),
            children: [
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: 1100,
                  ),
                  child: Column(
                    children: [
                      RouterOverviewWidget(
                        router: widget.router,
                      ),
                      const SizedBox(height: 14),
                      if (controller.isLoadingLineStatistics)
                        RouterStatisticsLoadingWidget()
                      else if (controller.showLineStatistics)
                        RouterValuesWidget(
                          values: controller.lineStatisticsValues,
                          downstreamCrc: controller.downstreamCrc,
                        ),
                      if (controller.isLoadingLineStatistics ||
                          controller.showLineStatistics)
                        const SizedBox(height: 18),
                      RouterPasswordWidget(
                        supportsDualBand: controller.supportsDualBand,
                        supports2G: controller.supports2G,
                        supports5G: controller.supports5G,
                        is5G: _is5G,
                        isChangingPassword: controller.isChangingPassword,
                        passwordError: controller.passwordError,
                        passwordSuccess: controller.passwordSuccess,
                        onBandChanged: (value) {
                          setState(() {
                            _is5G = value;
                          });
                          controller.clearPasswordMessages();
                        },
                        onChangePassword: _changePassword,
                        onPasswordChanged: (_) {
                          controller.clearPasswordMessages();
                        },
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _loadingView() {
    final l10n = AppLocalizations.of(context)!;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: _primary.withValues(alpha: .08),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  color: _primary,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              l10n.router_loading_settings,
              textAlign: TextAlign.center,
              style: AppTextStyles.text19Bold(context),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.router_connecting_loading_data,
              textAlign: TextAlign.center,
              style: AppTextStyles.text13Grey(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _errorView() {
    final l10n = AppLocalizations.of(context)!;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: _error.withValues(alpha: .08),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(
                  Icons.router_outlined,
                  size: 45,
                  color: _error,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              l10n.router_connection_failed,
              textAlign: TextAlign.center,
              style: AppTextStyles.text19Bold(context),
            ),
            const SizedBox(height: 8),
            Text(
              controller.errorMessage ?? l10n.router_unexpected_error,
              textAlign: TextAlign.center,
              style: AppTextStyles.text13Grey(context),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: _primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: () async {
                final success = await controller.retry();

                if (!mounted) return;

                if (!success) {
                  _showError(
                    controller.errorMessage ?? l10n.router_router_data_error,
                  );
                }
              },
              icon: const Icon(Icons.refresh_rounded),
              label: Text(
                l10n.retry,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showError(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: Colors.white,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: _error,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
