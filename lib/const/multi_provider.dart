import 'package:omniya/const/controller/language_provider.dart';
import 'package:omniya/view/auth/controll/log_in_controller.dart';
import 'package:omniya/view/home/home_page/controller/home_page_controller.dart';
import 'package:omniya/view/home/notification/controller/notifications_controller.dart';
import 'package:omniya/view/home/payment_screen/controller/bankController.dart';
import 'package:omniya/view/home/recharge_package/controller/recharge_package_controller.dart';
import 'package:omniya/view/home/request_page/addrequest/controller/add_request_controller.dart';
import 'package:omniya/view/home/request_page/controller/request_page_controller.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

List<SingleChildWidget> listproviders = [
  ChangeNotifierProvider(create: (_) => LoginController()),
  ChangeNotifierProvider(create: (_) => HomePageController()),
  ChangeNotifierProvider(create: (_) => RequestPageController()),
  ChangeNotifierProvider(create: (_) => RechargePackageController()),
  ChangeNotifierProvider(create: (_) => NotificationsController()),
  ChangeNotifierProvider(create: (_) => LanguageProvider()),
  ChangeNotifierProvider(create: (_) => Bankcontroller()),
  ChangeNotifierProvider(create: (_) => AddonServiceController()),
];
