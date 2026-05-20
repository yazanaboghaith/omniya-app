import 'package:omniya/view/auth/controll/log_in_controller.dart';
import 'package:omniya/view/home/home_page/controller/home_page_controller.dart';
import 'package:omniya/view/home/recharge_package/controller/recharge_package_controller.dart';
import 'package:omniya/view/home/request_page/controller/request_page_controller.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

List<SingleChildWidget> listproviders = [
  ChangeNotifierProvider(create: (_) => LoginController()),

  ChangeNotifierProvider(create: (_) => HomePageController()),
  ChangeNotifierProvider(create: (_) => RequestPageController()),
  ChangeNotifierProvider(create: (_) => RechargePackageController()),
];
