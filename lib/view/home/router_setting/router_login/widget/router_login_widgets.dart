import 'package:flutter/material.dart';
import 'package:omniya/core/const/app_color.dart';
import 'package:omniya/core/l10n/app_localizations.dart';
import 'package:omniya/model/setting/router_model.dart';
import 'package:omniya/view/home/router_setting/router_login/controller/router_login_page_controller.dart';

class RouterLoginWidgets extends StatelessWidget {
  final String gateway;
  final RouterModel router;
  final RouterLoginPageController controller;
  final VoidCallback onLogin;
  final VoidCallback onBack;

  const RouterLoginWidgets({
    super.key,
    required this.gateway,
    required this.router,
    required this.controller,
    required this.onLogin,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: RouterLoginBackButton(
            controller: controller,
            onBack: onBack,
          ),
        ),
        SizedBox(
          height: _spacing(context, 18, 24),
        ),
        RouterLoginHeader(
          router: router,
        ),
        SizedBox(
          height: _spacing(context, 22, 30),
        ),
        RouterLoginCard(
          gateway: gateway,
          controller: controller,
          onLogin: onLogin,
        ),
        SizedBox(
          height: _spacing(context, 16, 22),
        ),
        RouterLoginHelpText(),
      ],
    );
  }

  double _spacing(
    BuildContext context,
    double small,
    double large,
  ) {
    final width = MediaQuery.sizeOf(context).width;

    if (width >= 900) {
      return large;
    }

    return small;
  }
}

class RouterLoginBackButton extends StatelessWidget {
  final RouterLoginPageController controller;
  final VoidCallback onBack;

  const RouterLoginBackButton({
    super.key,
    required this.controller,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: isDark
          ? Colors.white.withValues(alpha: .08)
          : Colors.white.withValues(alpha: .75),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: controller.isLoading ? null : onBack,
        child: Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: .10)
                  : Colors.black.withValues(alpha: .05),
            ),
          ),
          child: Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 19,
            color: AppColors.text(context),
          ),
        ),
      ),
    );
  }
}

class RouterLoginHeader extends StatelessWidget {
  final RouterModel router;

  const RouterLoginHeader({
    super.key,
    required this.router,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

    final iconSize = width < 360
        ? 36.0
        : width < 600
            ? 44.0
            : 48.0;

    final circleSize = width < 360
        ? 76.0
        : width < 600
            ? 88.0
            : 96.0;

    final titleSize = width < 360
        ? 21.0
        : width < 600
            ? 24.0
            : 27.0;

    return Column(
      children: [
        Container(
          width: circleSize,
          height: circleSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primary,
                AppColors.secondary,
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(
                  alpha: .28,
                ),
                blurRadius: 25,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Icon(
            Icons.router_rounded,
            color: Colors.white,
            size: iconSize,
          ),
        ),
        SizedBox(
          height: width < 600 ? 15 : 18,
        ),
        Text(
          router.name,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: AppColors.text(context),
            fontSize: titleSize,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          router.modelNumber,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: AppColors.grey(context),
            fontSize: width < 600 ? 13 : 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class RouterLoginCard extends StatelessWidget {
  final String gateway;
  final RouterLoginPageController controller;
  final VoidCallback onLogin;

  const RouterLoginCard({
    super.key,
    required this.gateway,
    required this.controller,
    required this.onLogin,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final width = MediaQuery.sizeOf(context).width;

    final cardPadding = width < 360
        ? 15.0
        : width < 600
            ? 20.0
            : 26.0;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(cardPadding),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: .08)
            : Colors.white.withValues(alpha: .88),
        borderRadius: BorderRadius.circular(
          width < 600 ? 24 : 28,
        ),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: .12)
              : Colors.white.withValues(alpha: .90),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: isDark ? .18 : .08,
            ),
            blurRadius: 30,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        children: [
          RouterConnectionInfo(
            gateway: gateway,
          ),
          SizedBox(
            height: width < 600 ? 20 : 25,
          ),
          RouterUsernameField(
            controller: controller,
          ),
          SizedBox(
            height: width < 600 ? 13 : 16,
          ),
          RouterPasswordField(
            controller: controller,
            onSubmitted: onLogin,
          ),
          SizedBox(
            height: width < 600 ? 15 : 18,
          ),
          RouterLoginStatus(
            controller: controller,
          ),
          const SizedBox(height: 10),
          RouterLoginButton(
            controller: controller,
            onLogin: onLogin,
          ),
        ],
      ),
    );
  }
}

class RouterConnectionInfo extends StatelessWidget {
  final String gateway;

  const RouterConnectionInfo({
    super.key,
    required this.gateway,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.black.withValues(alpha: .12)
            : AppColors.secondary.withValues(alpha: .045),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: .08)
              : AppColors.secondary.withValues(alpha: .08),
        ),
      ),
      child: RouterInfoItem(
        icon: Icons.wifi_rounded,
        title: l10n.gateway,
        value: gateway,
      ),
    );
  }
}

class RouterInfoItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const RouterInfoItem({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(
              alpha: .10,
            ),
            borderRadius: BorderRadius.circular(11),
          ),
          child: Icon(
            icon,
            size: 20,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: AppColors.grey(context),
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                value,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: AppColors.text(context),
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class RouterUsernameField extends StatelessWidget {
  final RouterLoginPageController controller;

  const RouterUsernameField({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return TextField(
      controller: controller.usernameController,
      enabled: !controller.isLoading,
      textInputAction: TextInputAction.next,
      keyboardType: TextInputType.text,
      textDirection: TextDirection.ltr,
      style: TextStyle(
        color: AppColors.text(context),
        fontSize: 15,
        fontWeight: FontWeight.w600,
      ),
      decoration: RouterInputDecoration(
        context: context,
        label: l10n.user_name,
        icon: Icons.person_outline_rounded,
      ).decoration(),
    );
  }
}

class RouterPasswordField extends StatelessWidget {
  final RouterLoginPageController controller;
  final VoidCallback onSubmitted;

  const RouterPasswordField({
    super.key,
    required this.controller,
    required this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return TextField(
      controller: controller.passwordController,
      enabled: !controller.isLoading,
      obscureText: controller.obscurePassword,
      textInputAction: TextInputAction.done,
      textDirection: TextDirection.ltr,
      onSubmitted: controller.isLoading ? null : (_) => onSubmitted(),
      style: TextStyle(
        color: AppColors.text(context),
        fontSize: 15,
        fontWeight: FontWeight.w600,
      ),
      decoration: RouterInputDecoration(
        context: context,
        label: l10n.password,
        icon: Icons.lock_outline_rounded,
        suffixIcon: IconButton(
          onPressed:
              controller.isLoading ? null : controller.togglePasswordVisibility,
          icon: Icon(
            controller.obscurePassword
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
            color: AppColors.grey(context),
            size: 21,
          ),
        ),
      ).decoration(),
    );
  }
}

class RouterInputDecoration {
  final BuildContext context;
  final String label;
  final IconData icon;
  final Widget? suffixIcon;

  RouterInputDecoration({
    required this.context,
    required this.label,
    required this.icon,
    this.suffixIcon,
  });

  InputDecoration decoration() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(
        color: AppColors.grey(context),
        fontSize: 13,
      ),
      floatingLabelStyle: TextStyle(
        color: AppColors.primary,
        fontWeight: FontWeight.w600,
      ),
      prefixIcon: Icon(
        icon,
        color: AppColors.primary,
        size: 21,
      ),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: isDark
          ? Colors.white.withValues(alpha: .055)
          : Colors.black.withValues(alpha: .025),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 17,
      ),
      border: _border(
        isDark,
      ),
      enabledBorder: _border(
        isDark,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: AppColors.primary,
          width: 1.6,
        ),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: AppColors.grey(context).withValues(alpha: .10),
        ),
      ),
    );
  }

  OutlineInputBorder _border(bool isDark) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(
        color: isDark
            ? Colors.white.withValues(alpha: .10)
            : Colors.black.withValues(alpha: .07),
      ),
    );
  }
}

class RouterLoginStatus extends StatelessWidget {
  final RouterLoginPageController controller;

  const RouterLoginStatus({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    if (controller.status.isEmpty) {
      return const SizedBox.shrink();
    }

    final isLoading = controller.isLoading;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: isLoading
            ? AppColors.secondary.withValues(alpha: .08)
            : AppColors.primary.withValues(alpha: .08),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          if (isLoading)
            SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.primary,
              ),
            )
          else
            Icon(
              Icons.info_outline_rounded,
              size: 19,
              color: AppColors.primary,
            ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              controller.status,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: AppColors.text(context),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class RouterLoginButton extends StatelessWidget {
  final RouterLoginPageController controller;
  final VoidCallback onLogin;

  const RouterLoginButton({
    super.key,
    required this.controller,
    required this.onLogin,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              AppColors.primary,
              AppColors.secondary,
            ],
          ),
          borderRadius: BorderRadius.circular(17),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(
                alpha: .25,
              ),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: controller.isLoading ? null : onLogin,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.white,
            disabledBackgroundColor: Colors.transparent,
            disabledForegroundColor: Colors.white70,
            shadowColor: Colors.transparent,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(17),
            ),
          ),
          child: controller.isLoading
              ? const SizedBox(
                  width: 23,
                  height: 23,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.3,
                    color: Colors.white,
                  ),
                )
              : FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.login_rounded,
                        size: 21,
                      ),
                      const SizedBox(width: 9),
                      Text(
                        l10n.connect_to_router,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}

class RouterLoginHelpText extends StatelessWidget {
  const RouterLoginHelpText({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          Icons.info_outline_rounded,
          size: 16,
          color: AppColors.grey(context),
        ),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            l10n.router_connection_help,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.grey(context),
              fontSize: 11.5,
              fontWeight: FontWeight.w500,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}
