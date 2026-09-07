import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:omniya/core/const/app_color.dart';
import 'package:omniya/core/l10n/app_localizations.dart';

class RouterPasswordWidget extends StatefulWidget {
  final bool supportsDualBand;
  final bool supports2G;
  final bool supports5G;
  final bool is5G;
  final bool isChangingPassword;
  final String? passwordError;
  final String? passwordSuccess;
  final ValueChanged<bool> onBandChanged;
  final Future<void> Function(String password) onChangePassword;
  final ValueChanged<String> onPasswordChanged;

  const RouterPasswordWidget({
    super.key,
    required this.supportsDualBand,
    required this.supports2G,
    required this.supports5G,
    required this.is5G,
    required this.isChangingPassword,
    required this.passwordError,
    required this.passwordSuccess,
    required this.onBandChanged,
    required this.onChangePassword,
    required this.onPasswordChanged,
  });

  @override
  State<RouterPasswordWidget> createState() => _RouterPasswordWidgetState();
}

class _RouterPasswordWidgetState extends State<RouterPasswordWidget> {
  final TextEditingController _passwordController = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return _sectionCard(
      context,
      title: l10n.router_change_wifi_password,
      subtitle: l10n.router_change_wifi_password_subtitle,
      icon: Icons.lock_outline_rounded,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.supportsDualBand) ...[
              Text(
                l10n.router_select_network_band,
                style: AppTextStyles.text15(
                  context,
                  isBold: true,
                ),
              ),
              const SizedBox(height: 10),
              _bandSelector(context),
              const SizedBox(height: 22),
            ],
            Text(
              l10n.router_new_password,
              style: AppTextStyles.text15(
                context,
                isBold: true,
              ),
            ),
            const SizedBox(height: 9),
            TextFormField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              enabled: !widget.isChangingPassword,
              textInputAction: TextInputAction.done,
              onChanged: widget.onPasswordChanged,
              onFieldSubmitted: (_) {
                _submit();
              },
              style: AppTextStyles.text15(
                context,
                isBold: true,
              ),
              decoration: _inputDecoration(context),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return l10n.router_password_required;
                }

                if (value.length < 8) {
                  return l10n.router_password_min_length;
                }

                if (value.contains(' ')) {
                  return l10n.router_password_no_spaces;
                }

                return null;
              },
            ),
            const SizedBox(height: 9),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  size: 17,
                  color: AppColors.grey(context),
                ),
                const SizedBox(width: 7),
                Expanded(
                  child: Text(
                    l10n.router_password_hint,
                    style: AppTextStyles.text13Grey(context),
                  ),
                ),
              ],
            ),
            if (widget.passwordError != null) ...[
              const SizedBox(height: 12),
              _messageBox(
                context,
                widget.passwordError!,
                false,
              ),
            ],
            if (widget.passwordSuccess != null) ...[
              const SizedBox(height: 12),
              _messageBox(
                context,
                widget.passwordSuccess!,
                true,
              ),
            ],
            const SizedBox(height: 22),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: FilledButton.icon(
                onPressed: widget.isChangingPassword ? null : _submit,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor:
                      AppColors.primary.withValues(alpha: .35),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                icon: widget.isChangingPassword
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(
                        Icons.lock_reset_rounded,
                      ),
                label: Text(
                  widget.isChangingPassword
                      ? l10n.router_changing_password
                      : l10n.router_change_password,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            _securityHint(context),
          ],
        ),
      ),
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    FocusScope.of(context).unfocus();

    widget.onChangePassword(
      _passwordController.text.trim(),
    );
  }

  Widget _bandSelector(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 12,
          sigmaY: 12,
        ),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            color: isDark
                ? AppColors.text(context).withValues(alpha: .12)
                : Colors.white.withValues(alpha: .30),
            border: Border.all(
              color: AppColors.text(context).withValues(alpha: .12),
            ),
          ),
          child: Row(
            children: [
              if (widget.supports2G)
                Expanded(
                  child: _bandButton(
                    context,
                    title: l10n.router_24ghz,
                    subtitle: l10n.router_better_coverage,
                    icon: Icons.wifi_rounded,
                    selected: !widget.is5G,
                    onTap: () => widget.onBandChanged(false),
                  ),
                ),
              if (widget.supports2G && widget.supports5G)
                const SizedBox(width: 5),
              if (widget.supports5G)
                Expanded(
                  child: _bandButton(
                    context,
                    title: l10n.router_5ghz,
                    subtitle: l10n.router_higher_speed,
                    icon: Icons.speed_rounded,
                    selected: widget.is5G,
                    onTap: () => widget.onBandChanged(true),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _bandButton(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widget.isChangingPassword ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 12,
        ),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary.withValues(alpha: .88)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          border: selected
              ? Border.all(
                  color: Colors.white.withValues(alpha: .12),
                )
              : null,
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: .18),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: selected
                    ? Colors.white.withValues(alpha: .16)
                    : AppColors.primary.withValues(alpha: .08),
                borderRadius: BorderRadius.circular(11),
                border: Border.all(
                  color: selected
                      ? Colors.white.withValues(alpha: .08)
                      : AppColors.primary.withValues(alpha: .05),
                ),
              ),
              child: Icon(
                icon,
                size: 20,
                color: selected ? Colors.white : AppColors.primary,
              ),
            ),
            const SizedBox(width: 9),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: selected ? Colors.white : AppColors.text(context),
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: selected
                          ? Colors.white.withValues(alpha: .72)
                          : AppColors.grey(context),
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
            if (selected) ...[
              const SizedBox(width: 5),
              const Icon(
                Icons.check_circle_rounded,
                color: Colors.white,
                size: 19,
              ),
            ],
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(
    BuildContext context,
  ) {
    final l10n = AppLocalizations.of(context)!;

    return InputDecoration(
      hintText: l10n.router_enter_new_password,
      hintStyle: TextStyle(
        color: AppColors.grey(context).withValues(alpha: .7),
        fontSize: 13,
      ),
      prefixIcon: Icon(
        Icons.lock_outline_rounded,
        color: AppColors.primary,
      ),
      suffixIcon: IconButton(
        onPressed: widget.isChangingPassword
            ? null
            : () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
        icon: Icon(
          _obscurePassword
              ? Icons.visibility_outlined
              : Icons.visibility_off_outlined,
          color: AppColors.grey(context),
        ),
      ),
      filled: true,
      fillColor: Theme.of(context).brightness == Brightness.dark
          ? AppColors.text(context).withValues(alpha: .10)
          : Colors.white.withValues(alpha: .30),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 17,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: AppColors.primary.withValues(alpha: .075),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: AppColors.primary.withValues(alpha: .075),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: AppColors.primary,
          width: 1.5,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: Color(0xFFD9534F),
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: Color(0xFFD9534F),
          width: 1.5,
        ),
      ),
    );
  }

  Widget _securityHint(
    BuildContext context,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 10,
          sigmaY: 10,
        ),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.text(context).withValues(alpha: .10)
                : Colors.white.withValues(alpha: .30),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: AppColors.text(context).withValues(alpha: .12),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.shield_outlined,
                color: AppColors.primary,
                size: 21,
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  l10n.router_password_security_hint,
                  style: TextStyle(
                    color: AppColors.text(context),
                    fontSize: 11,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _messageBox(
    BuildContext context,
    String message,
    bool success,
  ) {
    final color = success ? const Color(0xFF2E9B68) : const Color(0xFFD9534F);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .07),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: color.withValues(alpha: .16),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            success ? Icons.check_rounded : Icons.error_outline_rounded,
            size: 20,
            color: color,
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 12,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Widget child,
  }) {
    final dark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: dark ? const Color(0xFF171722) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: dark
              ? Colors.white.withValues(alpha: .07)
              : AppColors.primary.withValues(alpha: .075),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: .09),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  icon,
                  color: AppColors.primary,
                  size: 23,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.text17Bold(context),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.text13Grey(context),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          child,
        ],
      ),
    );
  }

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }
}
