import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en')
  ];

  /// No description provided for @account_Info.
  ///
  /// In en, this message translates to:
  /// **'Account Information'**
  String get account_Info;

  /// No description provided for @recharge_package.
  ///
  /// In en, this message translates to:
  /// **'Recharge Package'**
  String get recharge_package;

  /// No description provided for @user_name.
  ///
  /// In en, this message translates to:
  /// **'User Name'**
  String get user_name;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// No description provided for @service_name.
  ///
  /// In en, this message translates to:
  /// **'Service Name'**
  String get service_name;

  /// No description provided for @monthly_subscription.
  ///
  /// In en, this message translates to:
  /// **'Monthly Subscription'**
  String get monthly_subscription;

  /// No description provided for @expiry_date.
  ///
  /// In en, this message translates to:
  /// **'Expiry Date'**
  String get expiry_date;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @arabic.
  ///
  /// In en, this message translates to:
  /// **'Arabic'**
  String get arabic;

  /// No description provided for @user_Status.
  ///
  /// In en, this message translates to:
  /// **'User Status'**
  String get user_Status;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get logout;

  /// No description provided for @confirm_logout.
  ///
  /// In en, this message translates to:
  /// **'Confirm Logout?'**
  String get confirm_logout;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @logout_success.
  ///
  /// In en, this message translates to:
  /// **'Logout Successful'**
  String get logout_success;

  /// No description provided for @logout_failed.
  ///
  /// In en, this message translates to:
  /// **'Logout Failed'**
  String get logout_failed;

  /// No description provided for @no_Internet.
  ///
  /// In en, this message translates to:
  /// **'No Internet Connection'**
  String get no_Internet;

  /// No description provided for @server_Error.
  ///
  /// In en, this message translates to:
  /// **'Server Connection Problem'**
  String get server_Error;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @current_Balance.
  ///
  /// In en, this message translates to:
  /// **'Current Balance'**
  String get current_Balance;

  /// No description provided for @currency.
  ///
  /// In en, this message translates to:
  /// **'SYP'**
  String get currency;

  /// No description provided for @total_Usage.
  ///
  /// In en, this message translates to:
  /// **'Total Usage'**
  String get total_Usage;

  /// No description provided for @unlimited_Subscription.
  ///
  /// In en, this message translates to:
  /// **'Unlimited Subscription'**
  String get unlimited_Subscription;

  /// No description provided for @current_Speed.
  ///
  /// In en, this message translates to:
  /// **'Current Speed'**
  String get current_Speed;

  /// No description provided for @basic_Package.
  ///
  /// In en, this message translates to:
  /// **'Basic Package'**
  String get basic_Package;

  /// No description provided for @recharge_Package.
  ///
  /// In en, this message translates to:
  /// **'Recharge Package'**
  String get recharge_Package;

  /// No description provided for @valid_Until.
  ///
  /// In en, this message translates to:
  /// **'Valid Until'**
  String get valid_Until;

  /// No description provided for @remaining.
  ///
  /// In en, this message translates to:
  /// **'Remaining'**
  String get remaining;

  /// No description provided for @from.
  ///
  /// In en, this message translates to:
  /// **'from'**
  String get from;

  /// No description provided for @gigabyte.
  ///
  /// In en, this message translates to:
  /// **'GB'**
  String get gigabyte;

  /// No description provided for @extra_Packages.
  ///
  /// In en, this message translates to:
  /// **'Extra Packages'**
  String get extra_Packages;

  /// No description provided for @extra_Package.
  ///
  /// In en, this message translates to:
  /// **'Extra Package'**
  String get extra_Package;

  /// No description provided for @processing_Payment.
  ///
  /// In en, this message translates to:
  /// **'Processing payment...'**
  String get processing_Payment;

  /// No description provided for @confirm_Add_Bank_Payment.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to add a bank payment?'**
  String get confirm_Add_Bank_Payment;

  /// No description provided for @bank_Name.
  ///
  /// In en, this message translates to:
  /// **'Bank Name:'**
  String get bank_Name;

  /// No description provided for @notification_Number.
  ///
  /// In en, this message translates to:
  /// **'Notification Number:'**
  String get notification_Number;

  /// No description provided for @total_Amount.
  ///
  /// In en, this message translates to:
  /// **'Total Amount:'**
  String get total_Amount;

  /// No description provided for @payment_Added_Success.
  ///
  /// In en, this message translates to:
  /// **'Payment added successfully!'**
  String get payment_Added_Success;

  /// No description provided for @payment_Added_Failed.
  ///
  /// In en, this message translates to:
  /// **'Failed to add payment, please try again later.'**
  String get payment_Added_Failed;

  /// No description provided for @add_Bank_Payment.
  ///
  /// In en, this message translates to:
  /// **'Add Bank Payment'**
  String get add_Bank_Payment;

  /// No description provided for @select_Bank.
  ///
  /// In en, this message translates to:
  /// **'Select Bank'**
  String get select_Bank;

  /// No description provided for @example_Number.
  ///
  /// In en, this message translates to:
  /// **'Example: 992311'**
  String get example_Number;

  /// No description provided for @amount.
  ///
  /// In en, this message translates to:
  /// **'Amount (SYP)'**
  String get amount;

  /// No description provided for @example_Amount.
  ///
  /// In en, this message translates to:
  /// **'Example: 5000'**
  String get example_Amount;

  /// No description provided for @select_Bank_Warning.
  ///
  /// In en, this message translates to:
  /// **'Please select a bank to continue'**
  String get select_Bank_Warning;

  /// No description provided for @fill_Fields_Title.
  ///
  /// In en, this message translates to:
  /// **'Fill Fields'**
  String get fill_Fields_Title;

  /// No description provided for @fill_All_Fields.
  ///
  /// In en, this message translates to:
  /// **'Please fill all fields to continue'**
  String get fill_All_Fields;

  /// No description provided for @submit_Payment.
  ///
  /// In en, this message translates to:
  /// **'Submit Payment'**
  String get submit_Payment;

  /// No description provided for @payment_Report.
  ///
  /// In en, this message translates to:
  /// **'Payment Report'**
  String get payment_Report;

  /// No description provided for @no_Data.
  ///
  /// In en, this message translates to:
  /// **'No Data'**
  String get no_Data;

  /// No description provided for @previous.
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get previous;

  /// No description provided for @page.
  ///
  /// In en, this message translates to:
  /// **'Page'**
  String get page;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @accepted.
  ///
  /// In en, this message translates to:
  /// **'Accepted'**
  String get accepted;

  /// No description provided for @number.
  ///
  /// In en, this message translates to:
  /// **'Number'**
  String get number;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'search'**
  String get search;

  /// No description provided for @success.
  ///
  /// In en, this message translates to:
  /// **'success'**
  String get success;

  /// No description provided for @prepaid.
  ///
  /// In en, this message translates to:
  /// **'Prepaid'**
  String get prepaid;

  /// No description provided for @postpaid.
  ///
  /// In en, this message translates to:
  /// **'Postpaid'**
  String get postpaid;

  /// No description provided for @check_balance_before_purchase.
  ///
  /// In en, this message translates to:
  /// **'Please check your balance before purchase'**
  String get check_balance_before_purchase;

  /// No description provided for @no_packages.
  ///
  /// In en, this message translates to:
  /// **'No packages available'**
  String get no_packages;

  /// No description provided for @buy_now.
  ///
  /// In en, this message translates to:
  /// **'Buy Now'**
  String get buy_now;

  /// No description provided for @buy_package.
  ///
  /// In en, this message translates to:
  /// **'Buy Package'**
  String get buy_package;

  /// No description provided for @confirm_buy_package.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to buy this package?'**
  String get confirm_buy_package;

  /// No description provided for @package_activated_success.
  ///
  /// In en, this message translates to:
  /// **'Package activated successfully!'**
  String get package_activated_success;

  /// No description provided for @activating_package.
  ///
  /// In en, this message translates to:
  /// **'Activating package...'**
  String get activating_package;

  /// No description provided for @orders_report.
  ///
  /// In en, this message translates to:
  /// **'Orders Report'**
  String get orders_report;

  /// No description provided for @order.
  ///
  /// In en, this message translates to:
  /// **'Order'**
  String get order;

  /// No description provided for @rejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get rejected;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date: '**
  String get date;

  /// No description provided for @invalid_code.
  ///
  /// In en, this message translates to:
  /// **'The code you entered is incorrect'**
  String get invalid_code;

  /// No description provided for @enter_pin.
  ///
  /// In en, this message translates to:
  /// **'Enter your PIN'**
  String get enter_pin;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @error_loading_data.
  ///
  /// In en, this message translates to:
  /// **'Error loading data'**
  String get error_loading_data;

  /// No description provided for @call_not_available.
  ///
  /// In en, this message translates to:
  /// **'Call is not available at the moment'**
  String get call_not_available;

  /// No description provided for @contact_support_reset_password.
  ///
  /// In en, this message translates to:
  /// **'Please contact customer support to reset your password via:'**
  String get contact_support_reset_password;

  /// No description provided for @call.
  ///
  /// In en, this message translates to:
  /// **'Call'**
  String get call;

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get welcome;

  /// No description provided for @login_to_account.
  ///
  /// In en, this message translates to:
  /// **'Login to your account'**
  String get login_to_account;

  /// No description provided for @username_or_phone.
  ///
  /// In en, this message translates to:
  /// **'Username / Phone number'**
  String get username_or_phone;

  /// No description provided for @quick_login_disabled.
  ///
  /// In en, this message translates to:
  /// **'Quick login has been disabled to change username'**
  String get quick_login_disabled;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @forgot_password.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgot_password;

  /// No description provided for @remember_me.
  ///
  /// In en, this message translates to:
  /// **'Remember me'**
  String get remember_me;

  /// No description provided for @or_use_quick_login.
  ///
  /// In en, this message translates to:
  /// **'Or use quick login'**
  String get or_use_quick_login;

  /// No description provided for @login_fingerprint.
  ///
  /// In en, this message translates to:
  /// **'Login with fingerprint'**
  String get login_fingerprint;

  /// No description provided for @login_pin.
  ///
  /// In en, this message translates to:
  /// **'Login via PIN'**
  String get login_pin;

  /// No description provided for @enter_username.
  ///
  /// In en, this message translates to:
  /// **'Please enter username'**
  String get enter_username;

  /// No description provided for @enter_password.
  ///
  /// In en, this message translates to:
  /// **'Please enter password'**
  String get enter_password;

  /// No description provided for @login_success.
  ///
  /// In en, this message translates to:
  /// **'Login successful'**
  String get login_success;

  /// No description provided for @login_error.
  ///
  /// In en, this message translates to:
  /// **'Login error occurred'**
  String get login_error;

  /// No description provided for @no_account.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? '**
  String get no_account;

  /// No description provided for @contact_us.
  ///
  /// In en, this message translates to:
  /// **'Contact us'**
  String get contact_us;

  /// No description provided for @quick_access_security.
  ///
  /// In en, this message translates to:
  /// **'Quick Access Security'**
  String get quick_access_security;

  /// No description provided for @choose_security_method.
  ///
  /// In en, this message translates to:
  /// **'To make login easier next time, choose a security method:'**
  String get choose_security_method;

  /// No description provided for @fingerprint.
  ///
  /// In en, this message translates to:
  /// **'Fingerprint'**
  String get fingerprint;

  /// No description provided for @pin_code.
  ///
  /// In en, this message translates to:
  /// **'PIN Code'**
  String get pin_code;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @confirm_fingerprint_enable.
  ///
  /// In en, this message translates to:
  /// **'Confirm fingerprint to enable quick access'**
  String get confirm_fingerprint_enable;

  /// No description provided for @fingerprint_enabled_success.
  ///
  /// In en, this message translates to:
  /// **'Fingerprint login enabled successfully'**
  String get fingerprint_enabled_success;

  /// No description provided for @fingerprint_failed_or_unavailable.
  ///
  /// In en, this message translates to:
  /// **'Fingerprint verification failed or is not available'**
  String get fingerprint_failed_or_unavailable;

  /// No description provided for @setup_pin.
  ///
  /// In en, this message translates to:
  /// **'Set up PIN code'**
  String get setup_pin;

  /// No description provided for @pin_4_digits_only.
  ///
  /// In en, this message translates to:
  /// **'Enter 4 digits only'**
  String get pin_4_digits_only;

  /// No description provided for @pin_must_be_4_digits.
  ///
  /// In en, this message translates to:
  /// **'PIN must be 4 digits'**
  String get pin_must_be_4_digits;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @verified_successfully.
  ///
  /// In en, this message translates to:
  /// **'Verified successfully'**
  String get verified_successfully;

  /// No description provided for @confirm_identity_fingerprint.
  ///
  /// In en, this message translates to:
  /// **'Please confirm your identity using fingerprint'**
  String get confirm_identity_fingerprint;

  /// No description provided for @fingerprint_verified_success.
  ///
  /// In en, this message translates to:
  /// **'Fingerprint verified successfully'**
  String get fingerprint_verified_success;

  /// No description provided for @unreaded.
  ///
  /// In en, this message translates to:
  /// **'Un read'**
  String get unreaded;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @financial.
  ///
  /// In en, this message translates to:
  /// **'Financial'**
  String get financial;

  /// No description provided for @system.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get system;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @payments.
  ///
  /// In en, this message translates to:
  /// **'My payments'**
  String get payments;

  /// No description provided for @requests.
  ///
  /// In en, this message translates to:
  /// **'My requests'**
  String get requests;

  /// No description provided for @usage.
  ///
  /// In en, this message translates to:
  /// **'Usage'**
  String get usage;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar': return AppLocalizationsAr();
    case 'en': return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
