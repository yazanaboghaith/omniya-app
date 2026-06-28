import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:omniya/core/const/app_background.dart';
import 'package:omniya/core/const/app_color.dart';
import 'package:omniya/core/const/color.dart';
import 'package:omniya/core/const/url.dart';
import 'package:omniya/core/l10n/app_localizations.dart';
import 'package:omniya/main.dart';
import 'package:omniya/view/auth/devaiceservice/device_service.dart';
import 'package:omniya/core/services/auth_storage.dart';
import 'package:omniya/core/services/security_service.dart';
import 'package:omniya/view/auth/controll/log_in_controller.dart';
import 'package:omniya/view/home/home.dart';
import 'package:omniya/view/home/notification/notifications.dart';
import 'package:url_launcher/url_launcher.dart';

class Login extends StatefulWidget {
  const Login({
    super.key,
    this.fromNotification = false,
  });
  final bool fromNotification;

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final userController = TextEditingController();
  final passwordController = TextEditingController();
  final LoginController loginController = LoginController();
  final AuthStorage storage = AuthStorage();
  final SecurityService securityService = SecurityService();

  bool isPasswordHidden = true;
  bool rememberMe = false;
  String? securityType;
  bool hasSavedSession = false;
  String? originalSavedUsername;
  @override
  void initState() {
    super.initState();
    loadSavedUser();
  }

  Future<void> loadSavedUser() async {
    try {
      final savedUsername = await storage.storage.read(key: "last_username");
      final token = await storage.storage.read(key: "token");
      final secType = await securityService.getSecurityType();

      if (!mounted) return;

      setState(() {
        if (savedUsername != null && token != null) {
          originalSavedUsername = savedUsername;
          userController.text = savedUsername;
          hasSavedSession = true;
          securityType = secType;
        }
      });
    } catch (e) {
      showMsg(AppLocalizations.of(context)!.error_loading_data);
    }
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      showMsg(AppLocalizations.of(context)!.call_not_available);
    }
  }

  Future<void> openWhatsApp(String phone) async {
    final formatted = formatWhatsAppNumber(phone);
    final uri = Uri.parse("https://wa.me/$formatted");

    await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );
  }

  String formatWhatsAppNumber(String phone) {
    String cleaned = phone.trim();
    cleaned = cleaned.replaceAll('+', '');
    if (cleaned.startsWith('0')) {
      cleaned = '963' + cleaned.substring(1);
    }
    return cleaned;
  }

  void _showForgotPasswordDialog() {
    double height = MediaQuery.of(context).size.height;
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.3),
      builder: (BuildContext dialogContext) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Dialog(
            backgroundColor: Colors.white30,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    AppLocalizations.of(context)!.forgot_password,
                    style: AppTextStyles.text17Bold(context),
                  ),
                  SizedBox(height: height * 0.02),
                  Text(
                    AppLocalizations.of(context)!
                        .contact_support_reset_password,
                    style: AppTextStyles.text15(context),
                  ),
                  SizedBox(height: height * 0.02),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.pop(dialogContext);
                            openWhatsApp(AppApi.mopileurl);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: Colors.green.withValues(alpha: 0.6),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Image.asset(
                                  "assets/images/WhatsApp.png",
                                  width: 22,
                                  height: 22,
                                  fit: BoxFit.cover,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  "WhatsApp",
                                  style: AppTextStyles.text13(context).copyWith(
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: MediaQuery.of(context).size.width * 0.06),
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.secondaryText,
                          ),
                          onPressed: () {
                            Navigator.pop(dialogContext);
                            _makePhoneCall('${AppApi.telephoneurl}');
                          },
                          icon:
                              Icon(Icons.call, color: AppColors.text(context)),
                          label: Text(
                            AppLocalizations.of(context)!.call,
                            style: AppTextStyles.text15white(context),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;

    return Scaffold(
      body: AppBackground(
        
        child: Center(
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.text(context).withValues(alpha: 0.1)
                    : Colors.black.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: AppColors.text(context).withValues(alpha: 0.1),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: height * 0.02),
                    _buildLogo(context),
                    SizedBox(height: height * 0.03),
                    Text(AppLocalizations.of(context)!.welcome,
                        style: AppTextStyles.text24(context)),
                    Text(
                      AppLocalizations.of(context)!.login_to_account,
                      style: AppTextStyles.text15Grey(context),
                    ),
                    SizedBox(height: height * 0.03),
                    _buildTextField(
                      context,
                      userController,
                      AppLocalizations.of(context)!.username_or_phone,
                      Icons.person_outline,
                      onChanged: (value) async {
                        if (originalSavedUsername != null) {
                          if (value.trim() != originalSavedUsername!.trim() &&
                              hasSavedSession) {
                            setState(() {
                              hasSavedSession = false;
                              securityType = null;
                            });
                            await securityService.clearSecurityData();

                            showMsg(AppLocalizations.of(context)!
                                .quick_login_disabled);
                          }
                        }
                      },
                    ),
                    SizedBox(height: height * 0.02),
                    _buildTextField(
                      context,
                      passwordController,
                      AppLocalizations.of(context)!.password,
                      Icons.lock_outline,
                      isPassword: true,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () {
                            _showForgotPasswordDialog();
                          },
                          child: Text(
                            AppLocalizations.of(context)!.forgot_password,
                            style: AppTextStyles.text15Grey(context),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Checkbox(
                          value: rememberMe,
                          onChanged: (value) {
                            setState(() {
                              rememberMe = value ?? false;
                            });
                          },
                        ),
                        Text(AppLocalizations.of(context)!.remember_me,
                            style: AppTextStyles.text15(context)),
                      ],
                    ),
                    SizedBox(height: height * 0.01),
                    _buildLoginButton(context),
                    SizedBox(height: height * 0.01),
                    if (hasSavedSession && securityType != null)
                      Center(
                        child: Column(
                          children: [
                            const SizedBox(height: 15),
                            const Divider(),
                            Text(
                              AppLocalizations.of(context)!.or_use_quick_login,
                              style: AppTextStyles.text15Grey(context),
                            ),
                            const SizedBox(height: 10),
                            if (securityType == "bio")
                              ElevatedButton.icon(
                                onPressed: () async {
                                  bool success = await loginWithBiometric();
                                  if (success && mounted) {
                                    if (!context.mounted) return;
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => const Home(),
                                      ),
                                    );
                                  }
                                },
                                icon: const Icon(Icons.fingerprint, size: 24),
                                label: Text(AppLocalizations.of(context)!
                                    .login_fingerprint),
                              ),
                            if (securityType == "pin")
                              ElevatedButton.icon(
                                onPressed: () async {
                                  bool success = await loginWithPinSilent();
                                  if (success && mounted) {
                                    if (!context.mounted) return;
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => const Home(),
                                      ),
                                    );
                                  }
                                },
                                icon: const Icon(Icons.lock, size: 24),
                                label: Text(
                                    AppLocalizations.of(context)!.login_pin),
                              ),
                          ],
                        ),
                      ),
                    SizedBox(height: height * 0.014),
                    _buildFooter(context),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo(BuildContext context) {
    return Center(
      child: SvgPicture.asset(
        'assets/images/Group.svg',
        width: MediaQuery.of(context).size.width * 0.3,
        height: MediaQuery.of(context).size.width * 0.13,
      ),
    );
  }

  Widget _buildTextField(
    BuildContext context,
    TextEditingController controller,
    String hint,
    IconData icon, {
    bool isPassword = false,
    Function(String)? onChanged,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword ? isPasswordHidden : false,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  isPasswordHidden ? Icons.visibility_off : Icons.visibility,
                ),
                onPressed: () {
                  setState(() {
                    isPasswordHidden = !isPasswordHidden;
                  });
                },
              )
            : null,
      ),
    );
  }

  Widget _buildLoginButton(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 200,
        height: 50,
        child: ListenableBuilder(
          listenable: loginController,
          builder: (context, child) {
            return ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              onPressed: loginController.isLoading
                  ? null
                  : () async {
                      if (userController.text.trim().isEmpty) {
                        showMsg(AppLocalizations.of(context)!.enter_username);
                        return;
                      }

                      if (passwordController.text.trim().isEmpty) {
                        showMsg(AppLocalizations.of(context)!.enter_password);
                        return;
                      }

                      try {
                        final deviceData = await DeviceService.getDeviceData();

                        final fcmToken = deviceData["fcm_token"];
                        final deviceType = deviceData["device_type"];
                        final deviceName = deviceData["device_name"];

                        final result = await loginController.login(
                          username: userController.text.trim(),
                          password: passwordController.text.trim(),
                          remember: rememberMe ? "1" : "0",
                          fcmToken: fcmToken,
                          deviceType: deviceType,
                          deviceName: deviceName,
                        );

                        if (!mounted) return;

                        if (!result.success) {
                          showMsg(result.message);
                          return;
                        }

                        showMsg(AppLocalizations.of(context)!.login_success);
                        if (rememberMe) {
                          final savedSecurity =
                              await securityService.getSecurityType();
                          if (savedSecurity == null) {
                            await showSecurityOptions();
                          }
                        }

                        await NotificationFlow.processPending();
                        NotificationFlow.pendingMessage = null;

                        if (widget.fromNotification) {
                          if (!context.mounted) return;
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const Notifications(),
                            ),
                          );
                          return;
                        }
                        if (!context.mounted) return;
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const Home(),
                          ),
                        );
                      } catch (e) {
                        showMsg(AppLocalizations.of(context)!.login_error);
                      }
                    },
              child: loginController.isLoading
                  ? CircularProgressIndicator(
                      color: AppColors.text(context),
                    )
                  : Text(
                      AppLocalizations.of(context)!.login,
                      style: AppTextStyles.text17Bold(context),
                    ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Center(
      child: TextButton(
        onPressed: () {
          // _makePhoneCall('0119351');
          _showForgotPasswordDialog();
        },
        child: RichText(
          text: TextSpan(
            style: const TextStyle(fontFamily: 'Cairo'),
            children: [
              TextSpan(
                text: AppLocalizations.of(context)!.no_account,
                style: AppTextStyles.text15Grey(context),
              ),
              TextSpan(
                text: AppLocalizations.of(context)!.contact_us,
                style: AppTextStyles.text15Grey(context).copyWith(
                  color: AppColors.secondaryText,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> showSecurityOptions() async {
    String? selected;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.quick_access_security),
        content: Text(
          AppLocalizations.of(context)!.choose_security_method,
        ),
        actions: [
          TextButton(
            onPressed: () {
              selected = "bio";
              Navigator.pop(context);
            },
            child: Text(AppLocalizations.of(context)!.fingerprint),
          ),
          TextButton(
            onPressed: () {
              selected = "pin";
              Navigator.pop(context);
            },
            child: Text(AppLocalizations.of(context)!.pin_code),
          ),
          TextButton(
            onPressed: () {
              selected = "none";
              Navigator.pop(context);
            },
            child: Text(AppLocalizations.of(context)!.skip),
          ),
        ],
      ),
    );

    if (selected == "bio") {
      bool authenticated = await securityService.authenticateWithBiometrics(
          AppLocalizations.of(context)!.confirm_fingerprint_enable);
      if (authenticated) {
        await securityService.setSecurityType("bio");
        showMsg(AppLocalizations.of(context)!.fingerprint_enabled_success);
        return true;
      } else {
        showMsg(
            AppLocalizations.of(context)!.fingerprint_failed_or_unavailable);
        return false;
      }
    } else if (selected == "pin") {
      bool pinSaved = await setupNewPin();
      if (pinSaved) {
        return true;
      }
    }
    return false;
  }

  Future<bool> setupNewPin() async {
    final controller = TextEditingController();
    bool isSaved = false;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.setup_pin),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          obscureText: true,
          maxLength: 4,
          decoration: InputDecoration(
              hintText: AppLocalizations.of(context)!.pin_4_digits_only),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(AppLocalizations.of(context)!.cancel,
                style: TextStyle(
                  color: Colors.red.withValues(alpha: 0.6),
                )),
          ),
          TextButton(
            onPressed: () async {
              if (controller.text.length == 4) {
                await securityService.savePin(controller.text);
                isSaved = true;
                if (!mounted) return;
                Navigator.pop(context);
              } else {
                showMsg(AppLocalizations.of(context)!.pin_must_be_4_digits);
              }
            },
            child: Text(AppLocalizations.of(context)!.save),
          ),
        ],
      ),
    );

    return isSaved;
  }

  Future<bool> loginWithPinSilent() async {
    final controller = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.enter_pin),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          obscureText: true,
          maxLength: 4,
          decoration: const InputDecoration(hintText: "****"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(_, false),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          TextButton(
            onPressed: () async {
              bool isValid = await securityService.verifyPin(controller.text);
              Navigator.pop(_, isValid);
            },
            child: Text(AppLocalizations.of(context)!.login),
          ),
        ],
      ),
    );

    if (result == true) {
      showMsg(AppLocalizations.of(context)!.verified_successfully);
    }
    return result ?? false;
  }

  Future<bool> loginWithBiometric() async {
    bool success = await securityService.authenticateWithBiometrics(
        AppLocalizations.of(context)!.confirm_identity_fingerprint);
    if (success) {
      showMsg(AppLocalizations.of(context)!.fingerprint_verified_success);
    }
    return success;
  }

  void showMsg(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: ksecondarycolor,
        content: Center(child: Text(msg, style: AppTextStyles.text15(context))),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
