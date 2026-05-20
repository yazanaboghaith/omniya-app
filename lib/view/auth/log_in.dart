import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:local_auth/local_auth.dart';
import 'package:omniya/const/app_background.dart';
import 'package:omniya/const/app_color.dart';
import 'package:omniya/const/color.dart';
import 'package:omniya/view/auth/services/auth_storage.dart';
import 'package:omniya/view/auth/controll/log_in_controller.dart';
import 'package:omniya/view/home/home.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final userController = TextEditingController();
  final passwordController = TextEditingController();
  final LocalAuthentication auth = LocalAuthentication();
  final LoginController loginController = LoginController();
  final AuthStorage storage = AuthStorage();

  bool isPasswordHidden = true;
  bool rememberMe = false;
  String? securityType;
  bool hasSavedSession = false;

  @override
  void initState() {
    super.initState();
    print("======> بدء تشغيل واجهة تسجيل الدخول <======");
    loadSavedUser();
  }

  Future<void> loadSavedUser() async {
    print("======> جاري البحث عن بيانات جلسة سابقة... <======");
    try {
      final savedUsername = await storage.storage.read(key: "last_username");
      final token = await storage.storage.read(key: "token");
      final secType = await storage.storage.read(key: "security_type");

      if (!mounted) return;

      setState(() {
        if (savedUsername != null && token != null) {
          print(
            "======> تم العثور على جلسة سابقة للمستخدم: $savedUsername <======",
          );
          print("======> نوع الحماية المحفوظ: $secType <======");
          userController.text = savedUsername;
          hasSavedSession = true;
          securityType = secType;
        } else {
          print("======> لا توجد جلسة سابقة، تسجيل دخول جديد <======");
        }
      });
    } catch (e) {
      print("======> خطأ في تحميل البيانات: $e <======");
      showMsg("حدث خطأ أثناء تحميل البيانات");
    }
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;

    return AppBackground(
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
                  Text("أهلاً بك", style: AppTextStyles.text24(context)),
                  Text(
                    "تسجيل الدخول إلى حسابك",
                    style: AppTextStyles.text15Grey(context),
                  ),
                  SizedBox(height: height * 0.03),
                  _buildTextField(
                    context,
                    userController,
                    "اسم المستخدم",
                    Icons.person_outline,
                  ),
                  SizedBox(height: height * 0.02),
                  _buildTextField(
                    context,
                    passwordController,
                    "كلمة المرور",
                    Icons.lock_outline,
                    isPassword: true,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          print(
                            "======> المستخدم ضغط على نسيان كلمة المرور <======",
                          );
                        },
                        child: Text(
                          "نسيت كلمة المرور؟",
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
                            print(
                              "======> حالة 'تذكرني' أصبحت: $rememberMe <======",
                            );
                          });
                        },
                      ),
                      Text("تذكرني", style: AppTextStyles.text15(context)),
                    ],
                  ),
                  SizedBox(height: height * 0.01),
                  _buildLoginButton(context),
                  SizedBox(height: height * 0.01),

                  // أزرار الدخول السريع تظهر فقط إذا كان هناك جلسة محفوظة وتم تحديد نوع حماية
                  if (hasSavedSession && securityType != null)
                    Center(
                      child: Column(
                        children: [
                          const SizedBox(height: 15),
                          const Divider(),
                          Text(
                            "أو استخدم الدخول السريع",
                            style: AppTextStyles.text15Grey(context),
                          ),
                          const SizedBox(height: 10),

                          if (securityType == "bio")
                            ElevatedButton.icon(
                              onPressed: () async {
                                print(
                                  "======> بدء محاولة الدخول بالبصمة <======",
                                );
                                bool success = await loginWithBiometric();
                                if (success && mounted) {
                                  print(
                                    "======> الدخول بالبصمة نجح! جاري الانتقال... <======",
                                  );
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const Home(),
                                    ),
                                  );
                                }
                              },
                              icon: const Icon(Icons.fingerprint, size: 24),
                              label: const Text("الدخول بالبصمة"),
                            ),

                          if (securityType == "pin")
                            ElevatedButton.icon(
                              onPressed: () async {
                                print(
                                  "======> بدء محاولة الدخول عبر PIN <======",
                                );
                                bool success = await loginWithPinSilent();
                                if (success && mounted) {
                                  print(
                                    "======> الدخول بالـ PIN نجح! جاري الانتقال... <======",
                                  );
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const Home(),
                                    ),
                                  );
                                } else {
                                  print(
                                    "======> الدخول بالـ PIN فشل أو تم الإلغاء <======",
                                  );
                                }
                              },
                              icon: const Icon(Icons.lock, size: 24),
                              label: const Text("الدخول عبر PIN"),
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
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword ? isPasswordHidden : false,
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
    // نستخدم ListenableBuilder للاستماع لتغيرات isLoading بداخل الـ controller
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
                  ? null // تعطيل الزر أثناء التحميل
                  : () async {
                      print(
                        "======> تم الضغط على زر تسجيل الدخول الأساسي <======",
                      );

                      if (userController.text.trim().isEmpty) {
                        showMsg("يرجى إدخال اسم المستخدم");
                        return;
                      }
                      if (passwordController.text.trim().isEmpty) {
                        showMsg("يرجى إدخال كلمة المرور");
                        return;
                      }

                      // 1. تنفيذ الدخول من السيرفر
                      final result = await loginController.login(
                        username: userController.text.trim(),
                        password: passwordController.text.trim(),
                        remember: rememberMe ? 1 : 0,
                      );

                      if (!mounted) return;

                      if (!result.success) {
                        print(
                          "======> فشل تسجيل الدخول من السيرفر: ${result.message} <======",
                        );
                        showMsg(result.message);
                        return;
                      }

                      print("======> تسجيل الدخول من السيرفر نجح! <======");

                      // 2. إذا اختار المستخدم "تذكرني" نقوم بعرض خيارات الحماية (إذا لم يتم تعيينها مسبقاً)
                      if (rememberMe) {
                        String? currentType = await storage.storage.read(
                          key: "security_type",
                        );
                        if (currentType == null) {
                          print(
                            "======> المستخدم اختار 'تذكرني' ولا يوجد حماية سابقة. جاري عرض نافذة الحماية... <======",
                          );
                          await showSecurityOptions();
                        } else {
                          print(
                            "======> المستخدم لديه وسيلة حماية محفوظة مسبقاً: $currentType <======",
                          );
                        }
                      }

                      // 3. الانتقال إلى الصفحة الرئيسية
                      if (mounted) {
                        print("======> الانتقال إلى صفحة Home الآن... <======");
                        showMsg("تم تسجيل الدخول بنجاح");
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => const Home()),
                        );
                      }
                    },
              child: loginController.isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(
                      "تسجيل الدخول",
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
        onPressed: () {},
        child: RichText(
          text: TextSpan(
            text: "ليس لديك حساب؟ ",
            style: AppTextStyles.text15Grey(context),
            children: [
              TextSpan(
                text: "تواصل معنا",
                style: TextStyle(
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

  // ===================== دوال الحماية السريعة =====================

  Future<bool> showSecurityOptions() async {
    String? selected;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text("حماية الدخول السريع"),
        content: const Text(
          "لتسهيل الدخول في المرات القادمة، اختر طريقة الحماية:",
        ),
        actions: [
          TextButton(
            onPressed: () {
              selected = "bio";
              Navigator.pop(context);
            },
            child: const Text("بصمة"),
          ),
          TextButton(
            onPressed: () {
              selected = "pin";
              Navigator.pop(context);
            },
            child: const Text("رمز PIN"),
          ),
          TextButton(
            onPressed: () {
              selected = "none";
              Navigator.pop(context);
            },
            child: const Text("تخطي"),
          ),
        ],
      ),
    );

    print("======> اختيار الحماية المفضل: $selected <======");

    if (selected == "bio") {
      bool canCheckBiometrics = await auth.canCheckBiometrics;
      if (canCheckBiometrics) {
        await storage.storage.write(key: "security_type", value: "bio");
        print("======> تم تفعيل بصمة الإصبع <======");
        return true;
      } else {
        print("======> الجهاز لا يدعم البصمة <======");
        showMsg("عذراً، جهازك لا يدعم البصمة");
        return false;
      }
    } else if (selected == "pin") {
      // إذا اختار PIN يجب أن نعرض له نافذة ليكتب الرقم السري ويحفظه
      bool pinSaved = await setupNewPin();
      if (pinSaved) {
        await storage.storage.write(key: "security_type", value: "pin");
        print("======> تم تفعيل وحفظ PIN <======");
        return true;
      }
    }

    return false;
  }

  Future<bool> setupNewPin() async {
    print("======> جاري عرض نافذة إعداد PIN جديد... <======");
    final controller = TextEditingController();
    bool isSaved = false;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text("إعداد رمز PIN"),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          obscureText: true,
          maxLength: 4,
          decoration: const InputDecoration(hintText: "أدخل 4 أرقام فقط"),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // تراجع
            },
            child: const Text("إلغاء", style: TextStyle(color: Colors.red)),
          ),
          TextButton(
            onPressed: () async {
              if (controller.text.length == 4) {
                await storage.storage.write(key: "pin", value: controller.text);
                isSaved = true;
                Navigator.pop(context);
              } else {
                showMsg("يجب أن يتكون الرمز من 4 أرقام");
              }
            },
            child: const Text("حفظ"),
          ),
        ],
      ),
    );

    return isSaved;
  }

  Future<bool> loginWithPinSilent() async {
    final savedPin = await storage.storage.read(key: "pin");
    if (savedPin == null) {
      print("======> خطأ: لا يوجد رمز PIN محفوظ! <======");
      return false;
    }

    final controller = TextEditingController();
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("أدخل رمز PIN الخاص بك"),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          obscureText: true,
          maxLength: 4,
          decoration: const InputDecoration(hintText: "****"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("إلغاء"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context, controller.text == savedPin);
            },
            child: const Text("دخول"),
          ),
        ],
      ),
    );

    return result ?? false;
  }

  Future<bool> loginWithBiometric() async {
    try {
      final success = await auth.authenticate(
        localizedReason: 'يرجى تأكيد هويتك للدخول بالبصمة',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );

      if (success) {
        showMsg("تم التحقق من البصمة بنجاح");
      } else {
        print("======> المستخدم ألغى البصمة أو فشلت <======");
      }
      return success;
    } catch (e) {
      print("======> خطأ في البصمة: $e <======");
      showMsg("البصمة غير متاحة أو حدث خطأ");
      return false;
    }
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
