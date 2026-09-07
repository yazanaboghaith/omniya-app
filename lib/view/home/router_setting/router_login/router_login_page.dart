import 'package:flutter/material.dart';
import 'package:omniya/core/const/app_background.dart';
import 'package:omniya/core/const/app_notifier.dart';
import 'package:omniya/core/l10n/app_localizations.dart';
import 'package:omniya/model/setting/router_model.dart';
import 'package:omniya/view/home/home.dart';
import 'package:omniya/view/home/router_setting/router_login/controller/router_login_page_controller.dart';
import 'package:omniya/view/home/router_setting/router_login/controller/router_controller.dart';
import 'package:omniya/view/home/router_setting/router_login/widget/router_login_widgets.dart';
import 'package:omniya/view/home/router_setting/router_mangment/router_management_page.dart';

class RouterLoginPage extends StatefulWidget {
  final String gateway;
  final String modelSlug;
  final int routerId;
  final RouterModel router;
  final RouterController controller;

  const RouterLoginPage({
    super.key,
    required this.gateway,
    required this.modelSlug,
    required this.routerId,
    required this.router,
    required this.controller,
  });

  @override
  State<RouterLoginPage> createState() => _RouterLoginPageState();
}

class _RouterLoginPageState extends State<RouterLoginPage> {
  static const String _defaultPassword = 'admin';

  late final RouterLoginPageController loginController;

  @override
  void initState() {
    super.initState();

    loginController = RouterLoginPageController(
      routerId: widget.routerId,
    );

    loginController.usernameController.text = widget.router.defaultUsername;

    loginController.passwordController.text = _defaultPassword;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _autoLogin();
    });
  }

  Future<void> _autoLogin() async {
    final l10n = AppLocalizations.of(context)!;

    final success = await loginController.login(
      gateway: widget.gateway,
      port: widget.router.defaultPort,
      context: context,
    );

    if (!mounted) return;

    if (success) {
      await _openManagementPage();
      return;
    }

    loginController.status = l10n.default_login_failed;

    _showError(
      loginController.errorMessage ?? l10n.default_login_failed_manual,
    );
  }

  Future<void> _login() async {
    final l10n = AppLocalizations.of(context)!;

    FocusScope.of(context).unfocus();

    final username = loginController.usernameController.text.trim();

    final password = loginController.passwordController.text;

    if (username.isEmpty) {
      _showError(l10n.router_enter_username);
      return;
    }

    if (password.isEmpty) {
      _showError(l10n.router_enter_password);
      return;
    }

    final success = await loginController.login(
      gateway: widget.gateway,
      port: widget.router.defaultPort,
      context: context,
    );

    if (!mounted) return;

    if (!success) {
      _showError(
        loginController.errorMessage ?? l10n.router_invalid_credentials,
      );
      return;
    }

    await _openManagementPage();
  }

  Future<void> _openManagementPage() async {
    if (!mounted) return;

    loginController.transferTelnetService();

    await Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => RouterManagementPage(
          gateway: widget.gateway,
          router: widget.router,
          routerId: widget.routerId,
          telnetService: loginController.telnetService,
        ),
      ),
    );
  }

  void _showError(String message) {
    if (!mounted) return;

    AppNotifier.instance.msg(
      context,
      message,
    );
  }

  Future<void> _goBack() async {
    if (loginController.isLoading) return;

    if (!mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => Home(),
      ),
      (route) => false,
    );
  }

  @override
  void dispose() {
    loginController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: loginController,
      builder: (context, _) {
        return AppBackground(
          showHeader: false,
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.symmetric(
                      horizontal: _horizontalPadding(
                        constraints.maxWidth,
                      ),
                      vertical: _verticalPadding(
                        constraints.maxHeight,
                      ),
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: _contentMaxWidth(
                            constraints.maxWidth,
                          ),
                        ),
                        child: RouterLoginWidgets(
                          gateway: widget.gateway,
                          router: widget.router,
                          controller: loginController,
                          onLogin: _login,
                          onBack: _goBack,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  double _horizontalPadding(double width) {
    if (width < 360) {
      return 12;
    }

    if (width < 600) {
      return 18;
    }

    if (width < 900) {
      return 32;
    }

    return 48;
  }

  double _verticalPadding(double height) {
    if (height < 600) {
      return 12;
    }

    if (height < 800) {
      return 20;
    }

    return 28;
  }

  double _contentMaxWidth(double width) {
    if (width < 600) {
      return width;
    }

    if (width < 900) {
      return 560;
    }

    return 620;
  }
}
