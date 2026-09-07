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
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
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
  /// **'Username'**
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
  /// **'Monthly Fee'**
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
  /// **'Are you sure you want to log out?'**
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
  /// **'Logged out successfully'**
  String get logout_success;

  /// No description provided for @logout_failed.
  ///
  /// In en, this message translates to:
  /// **'Logout failed'**
  String get logout_failed;

  /// No description provided for @canceled.
  ///
  /// In en, this message translates to:
  /// **'Canceled'**
  String get canceled;

  /// No description provided for @completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// No description provided for @accepted.
  ///
  /// In en, this message translates to:
  /// **'Accepted'**
  String get accepted;

  /// No description provided for @rejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get rejected;

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

  /// No description provided for @success.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get success;

  /// No description provided for @unexpected_error.
  ///
  /// In en, this message translates to:
  /// **'Unexpected error'**
  String get unexpected_error;

  /// No description provided for @server_error_message.
  ///
  /// In en, this message translates to:
  /// **'Server error, please try again'**
  String get server_error_message;

  /// No description provided for @failed_fetch_data.
  ///
  /// In en, this message translates to:
  /// **'Failed to fetch data. Error code: '**
  String get failed_fetch_data;

  /// No description provided for @no_internet_connection.
  ///
  /// In en, this message translates to:
  /// **'No internet connection'**
  String get no_internet_connection;

  /// No description provided for @session_expired.
  ///
  /// In en, this message translates to:
  /// **'Session expired, please log in again'**
  String get session_expired;

  /// No description provided for @error_loading_data.
  ///
  /// In en, this message translates to:
  /// **'Error loading data'**
  String get error_loading_data;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

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

  /// No description provided for @number.
  ///
  /// In en, this message translates to:
  /// **'Number'**
  String get number;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date: '**
  String get date;

  /// No description provided for @current_Balance.
  ///
  /// In en, this message translates to:
  /// **'Current Balance'**
  String get current_Balance;

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
  /// **'of'**
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
  /// **'Check your balance before purchase'**
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

  /// No description provided for @services.
  ///
  /// In en, this message translates to:
  /// **'Services'**
  String get services;

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

  /// No description provided for @invalid_code.
  ///
  /// In en, this message translates to:
  /// **'The code you entered is incorrect'**
  String get invalid_code;

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get welcome;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @login_to_account.
  ///
  /// In en, this message translates to:
  /// **'Login to your account'**
  String get login_to_account;

  /// No description provided for @username_or_phone.
  ///
  /// In en, this message translates to:
  /// **'Username / Phone'**
  String get username_or_phone;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

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

  /// No description provided for @no_account.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? '**
  String get no_account;

  /// No description provided for @contact_us.
  ///
  /// In en, this message translates to:
  /// **'Contact Us'**
  String get contact_us;

  /// No description provided for @login_success.
  ///
  /// In en, this message translates to:
  /// **'Login successful'**
  String get login_success;

  /// No description provided for @login_error.
  ///
  /// In en, this message translates to:
  /// **'Login error'**
  String get login_error;

  /// No description provided for @login_failed.
  ///
  /// In en, this message translates to:
  /// **'Login failed'**
  String get login_failed;

  /// No description provided for @connection_error.
  ///
  /// In en, this message translates to:
  /// **'Connection error'**
  String get connection_error;

  /// No description provided for @quick_login_disabled.
  ///
  /// In en, this message translates to:
  /// **'Quick login disabled to change username'**
  String get quick_login_disabled;

  /// No description provided for @or_use_quick_login.
  ///
  /// In en, this message translates to:
  /// **'Or use quick login'**
  String get or_use_quick_login;

  /// No description provided for @login_fingerprint.
  ///
  /// In en, this message translates to:
  /// **'Login with Fingerprint'**
  String get login_fingerprint;

  /// No description provided for @login_pin.
  ///
  /// In en, this message translates to:
  /// **'Login with PIN'**
  String get login_pin;

  /// No description provided for @enter_pin.
  ///
  /// In en, this message translates to:
  /// **'Enter PIN'**
  String get enter_pin;

  /// No description provided for @quick_access_security.
  ///
  /// In en, this message translates to:
  /// **'Quick Access Security'**
  String get quick_access_security;

  /// No description provided for @choose_security_method.
  ///
  /// In en, this message translates to:
  /// **'Choose a security method for quick login'**
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
  /// **'Confirm fingerprint to enable quick login'**
  String get confirm_fingerprint_enable;

  /// No description provided for @fingerprint_enabled_success.
  ///
  /// In en, this message translates to:
  /// **'Fingerprint login enabled'**
  String get fingerprint_enabled_success;

  /// No description provided for @fingerprint_failed_or_unavailable.
  ///
  /// In en, this message translates to:
  /// **'Fingerprint verification failed'**
  String get fingerprint_failed_or_unavailable;

  /// No description provided for @setup_pin.
  ///
  /// In en, this message translates to:
  /// **'Set Up PIN'**
  String get setup_pin;

  /// No description provided for @pin_4_digits_only.
  ///
  /// In en, this message translates to:
  /// **'Enter 4 digits only'**
  String get pin_4_digits_only;

  /// No description provided for @pin_must_be_4_digits.
  ///
  /// In en, this message translates to:
  /// **'PIN must contain 4 digits'**
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
  /// **'Confirm your identity with fingerprint'**
  String get confirm_identity_fingerprint;

  /// No description provided for @fingerprint_verified_success.
  ///
  /// In en, this message translates to:
  /// **'Fingerprint verified'**
  String get fingerprint_verified_success;

  /// No description provided for @call_not_available.
  ///
  /// In en, this message translates to:
  /// **'Call unavailable'**
  String get call_not_available;

  /// No description provided for @contact_support_reset_password.
  ///
  /// In en, this message translates to:
  /// **'Contact customer support to reset your password via:'**
  String get contact_support_reset_password;

  /// No description provided for @call.
  ///
  /// In en, this message translates to:
  /// **'Call'**
  String get call;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @no_notifications.
  ///
  /// In en, this message translates to:
  /// **'No notifications'**
  String get no_notifications;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @unreaded.
  ///
  /// In en, this message translates to:
  /// **'Unread'**
  String get unreaded;

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
  /// **'My Payments'**
  String get payments;

  /// No description provided for @requests.
  ///
  /// In en, this message translates to:
  /// **'My Requests'**
  String get requests;

  /// No description provided for @usage.
  ///
  /// In en, this message translates to:
  /// **'Usage'**
  String get usage;

  /// No description provided for @renew_subscription.
  ///
  /// In en, this message translates to:
  /// **'Renew Subscription'**
  String get renew_subscription;

  /// No description provided for @subscription_extension_options.
  ///
  /// In en, this message translates to:
  /// **'Extension Options'**
  String get subscription_extension_options;

  /// No description provided for @extension_for_1_day.
  ///
  /// In en, this message translates to:
  /// **'Extend 1 Day'**
  String get extension_for_1_day;

  /// No description provided for @extension_for_2_days.
  ///
  /// In en, this message translates to:
  /// **'Extend 2 Days'**
  String get extension_for_2_days;

  /// No description provided for @extension_for_3_days.
  ///
  /// In en, this message translates to:
  /// **'Extend 3 Days'**
  String get extension_for_3_days;

  /// No description provided for @free.
  ///
  /// In en, this message translates to:
  /// **'Free'**
  String get free;

  /// No description provided for @free_of_charge.
  ///
  /// In en, this message translates to:
  /// **'Free of Charge'**
  String get free_of_charge;

  /// No description provided for @confirm_extension.
  ///
  /// In en, this message translates to:
  /// **'Confirm Extension'**
  String get confirm_extension;

  /// No description provided for @confirm_extension_message.
  ///
  /// In en, this message translates to:
  /// **'Extend subscription for'**
  String get confirm_extension_message;

  /// No description provided for @extension_success.
  ///
  /// In en, this message translates to:
  /// **'Subscription extended successfully'**
  String get extension_success;

  /// No description provided for @extension_failed.
  ///
  /// In en, this message translates to:
  /// **'Extension failed, please try again'**
  String get extension_failed;

  /// No description provided for @day.
  ///
  /// In en, this message translates to:
  /// **'Day'**
  String get day;

  /// No description provided for @two_days.
  ///
  /// In en, this message translates to:
  /// **'2 Days'**
  String get two_days;

  /// No description provided for @days.
  ///
  /// In en, this message translates to:
  /// **'Days'**
  String get days;

  /// No description provided for @cost.
  ///
  /// In en, this message translates to:
  /// **'Cost'**
  String get cost;

  /// No description provided for @processing_Payment.
  ///
  /// In en, this message translates to:
  /// **'Processing payment...'**
  String get processing_Payment;

  /// No description provided for @confirm_Add_Bank_Payment.
  ///
  /// In en, this message translates to:
  /// **'Add this bank payment?'**
  String get confirm_Add_Bank_Payment;

  /// No description provided for @bank_Name.
  ///
  /// In en, this message translates to:
  /// **'Bank Name:'**
  String get bank_Name;

  /// No description provided for @notification_Number.
  ///
  /// In en, this message translates to:
  /// **'Reference Number:'**
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
  /// **'Failed to add payment, try again later'**
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

  /// No description provided for @example_Amount.
  ///
  /// In en, this message translates to:
  /// **'Example: 50000'**
  String get example_Amount;

  /// No description provided for @amount.
  ///
  /// In en, this message translates to:
  /// **'Amount (SYP)'**
  String get amount;

  /// No description provided for @syp.
  ///
  /// In en, this message translates to:
  /// **'SYP'**
  String get syp;

  /// No description provided for @select_Bank_Warning.
  ///
  /// In en, this message translates to:
  /// **'Select a bank to continue'**
  String get select_Bank_Warning;

  /// No description provided for @fill_Fields_Title.
  ///
  /// In en, this message translates to:
  /// **'Fill Fields'**
  String get fill_Fields_Title;

  /// No description provided for @fill_All_Fields.
  ///
  /// In en, this message translates to:
  /// **'Please fill all fields'**
  String get fill_All_Fields;

  /// No description provided for @submit_Payment.
  ///
  /// In en, this message translates to:
  /// **'Add Payment'**
  String get submit_Payment;

  /// No description provided for @payment_Report.
  ///
  /// In en, this message translates to:
  /// **'Payment Report'**
  String get payment_Report;

  /// No description provided for @bank_payment.
  ///
  /// In en, this message translates to:
  /// **'Bank Payment'**
  String get bank_payment;

  /// No description provided for @online_payment.
  ///
  /// In en, this message translates to:
  /// **'Online Payment'**
  String get online_payment;

  /// No description provided for @payment_success.
  ///
  /// In en, this message translates to:
  /// **'Payment Success'**
  String get payment_success;

  /// No description provided for @payment_pending.
  ///
  /// In en, this message translates to:
  /// **'Payment Pending'**
  String get payment_pending;

  /// No description provided for @payment_error.
  ///
  /// In en, this message translates to:
  /// **'Payment Error'**
  String get payment_error;

  /// No description provided for @payment_confirmed_successfully.
  ///
  /// In en, this message translates to:
  /// **'Payment confirmed successfully'**
  String get payment_confirmed_successfully;

  /// No description provided for @payment_not_confirmed_yet.
  ///
  /// In en, this message translates to:
  /// **'Payment not confirmed yet'**
  String get payment_not_confirmed_yet;

  /// No description provided for @payment_status_check_error.
  ///
  /// In en, this message translates to:
  /// **'Error checking payment status'**
  String get payment_status_check_error;

  /// No description provided for @enter_payment_amount.
  ///
  /// In en, this message translates to:
  /// **'Enter Payment Amount'**
  String get enter_payment_amount;

  /// No description provided for @payment_gateway.
  ///
  /// In en, this message translates to:
  /// **'Payment Gateway'**
  String get payment_gateway;

  /// No description provided for @confirm_payment.
  ///
  /// In en, this message translates to:
  /// **'Confirm Payment'**
  String get confirm_payment;

  /// No description provided for @payment_creation_failed.
  ///
  /// In en, this message translates to:
  /// **'Payment creation failed'**
  String get payment_creation_failed;

  /// No description provided for @missing_data.
  ///
  /// In en, this message translates to:
  /// **'Missing Data'**
  String get missing_data;

  /// No description provided for @missing_data_title.
  ///
  /// In en, this message translates to:
  /// **'Missing Data'**
  String get missing_data_title;

  /// No description provided for @missing_data_message.
  ///
  /// In en, this message translates to:
  /// **'Please fill all fields'**
  String get missing_data_message;

  /// No description provided for @please_fill_all_fields.
  ///
  /// In en, this message translates to:
  /// **'Please fill all fields'**
  String get please_fill_all_fields;

  /// No description provided for @fill_all_fields_message.
  ///
  /// In en, this message translates to:
  /// **'Please fill all fields'**
  String get fill_all_fields_message;

  /// No description provided for @payment_completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get payment_completed;

  /// No description provided for @payment_sent_successfully.
  ///
  /// In en, this message translates to:
  /// **'Payment sent successfully'**
  String get payment_sent_successfully;

  /// No description provided for @payment_send_failed.
  ///
  /// In en, this message translates to:
  /// **'Failed to send payment'**
  String get payment_send_failed;

  /// No description provided for @sending_error.
  ///
  /// In en, this message translates to:
  /// **'Error while sending'**
  String get sending_error;

  /// No description provided for @payment_reference_number.
  ///
  /// In en, this message translates to:
  /// **'Reference Number'**
  String get payment_reference_number;

  /// No description provided for @payment_amount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get payment_amount;

  /// No description provided for @gateway.
  ///
  /// In en, this message translates to:
  /// **'Gateway'**
  String get gateway;

  /// No description provided for @loading_data.
  ///
  /// In en, this message translates to:
  /// **'Loading data...'**
  String get loading_data;

  /// No description provided for @data_loaded.
  ///
  /// In en, this message translates to:
  /// **'Data loaded'**
  String get data_loaded;

  /// No description provided for @loading_sending.
  ///
  /// In en, this message translates to:
  /// **'Sending...'**
  String get loading_sending;

  /// No description provided for @creating_payment.
  ///
  /// In en, this message translates to:
  /// **'Creating payment...'**
  String get creating_payment;

  /// No description provided for @browser_opened.
  ///
  /// In en, this message translates to:
  /// **'Browser opened'**
  String get browser_opened;

  /// No description provided for @transaction_id.
  ///
  /// In en, this message translates to:
  /// **'Transaction ID'**
  String get transaction_id;

  /// No description provided for @payment_url.
  ///
  /// In en, this message translates to:
  /// **'Payment URL'**
  String get payment_url;

  /// No description provided for @checking_payment.
  ///
  /// In en, this message translates to:
  /// **'Checking payment'**
  String get checking_payment;

  /// No description provided for @payment_processing.
  ///
  /// In en, this message translates to:
  /// **'Processing payment'**
  String get payment_processing;

  /// No description provided for @loading_payment_methods.
  ///
  /// In en, this message translates to:
  /// **'Loading payment methods'**
  String get loading_payment_methods;

  /// No description provided for @select_payment_method.
  ///
  /// In en, this message translates to:
  /// **'Select Payment Method'**
  String get select_payment_method;

  /// No description provided for @bank_transfer.
  ///
  /// In en, this message translates to:
  /// **'Bank Transfer'**
  String get bank_transfer;

  /// No description provided for @online_gateway.
  ///
  /// In en, this message translates to:
  /// **'Online Gateway'**
  String get online_gateway;

  /// No description provided for @reset_session.
  ///
  /// In en, this message translates to:
  /// **'Reset Session'**
  String get reset_session;

  /// No description provided for @payment_method_online.
  ///
  /// In en, this message translates to:
  /// **'Online Payment'**
  String get payment_method_online;

  /// No description provided for @payment_method_bank.
  ///
  /// In en, this message translates to:
  /// **'Bank Transfer'**
  String get payment_method_bank;

  /// No description provided for @identity_verification.
  ///
  /// In en, this message translates to:
  /// **'Payment Verification'**
  String get identity_verification;

  /// No description provided for @no_payment_gateways.
  ///
  /// In en, this message translates to:
  /// **'No payment gateways'**
  String get no_payment_gateways;

  /// No description provided for @add_request.
  ///
  /// In en, this message translates to:
  /// **'Add Request'**
  String get add_request;

  /// No description provided for @request_type.
  ///
  /// In en, this message translates to:
  /// **'Request Type'**
  String get request_type;

  /// No description provided for @choose_request_type.
  ///
  /// In en, this message translates to:
  /// **'Choose Request Type'**
  String get choose_request_type;

  /// No description provided for @add_request_button.
  ///
  /// In en, this message translates to:
  /// **'Add Request'**
  String get add_request_button;

  /// No description provided for @confirm_request_title.
  ///
  /// In en, this message translates to:
  /// **'Confirm Request'**
  String get confirm_request_title;

  /// No description provided for @confirm_request_message.
  ///
  /// In en, this message translates to:
  /// **'Confirm request: {name}?'**
  String confirm_request_message(Object name);

  /// No description provided for @storage_cleared.
  ///
  /// In en, this message translates to:
  /// **'Session data cleared'**
  String get storage_cleared;

  /// No description provided for @no_token_found.
  ///
  /// In en, this message translates to:
  /// **'No authentication token found'**
  String get no_token_found;

  /// No description provided for @router_management.
  ///
  /// In en, this message translates to:
  /// **'Router Management'**
  String get router_management;

  /// No description provided for @router_local_network.
  ///
  /// In en, this message translates to:
  /// **'Local Network'**
  String get router_local_network;

  /// No description provided for @router_connect.
  ///
  /// In en, this message translates to:
  /// **'Connect'**
  String get router_connect;

  /// No description provided for @router_disconnect.
  ///
  /// In en, this message translates to:
  /// **'Disconnect from Router'**
  String get router_disconnect;

  /// No description provided for @router_enter_username.
  ///
  /// In en, this message translates to:
  /// **'Enter username'**
  String get router_enter_username;

  /// No description provided for @router_enter_password.
  ///
  /// In en, this message translates to:
  /// **'Enter password'**
  String get router_enter_password;

  /// No description provided for @router_invalid_gateway.
  ///
  /// In en, this message translates to:
  /// **'Invalid gateway'**
  String get router_invalid_gateway;

  /// No description provided for @connect_to_router.
  ///
  /// In en, this message translates to:
  /// **'Connect to Router'**
  String get connect_to_router;

  /// No description provided for @router_connecting.
  ///
  /// In en, this message translates to:
  /// **'Connecting...'**
  String get router_connecting;

  /// No description provided for @router_loading_commands.
  ///
  /// In en, this message translates to:
  /// **'Loading commands...'**
  String get router_loading_commands;

  /// No description provided for @router_logging_in.
  ///
  /// In en, this message translates to:
  /// **'Logging in...'**
  String get router_logging_in;

  /// No description provided for @router_verifying_subscription.
  ///
  /// In en, this message translates to:
  /// **'Verifying...'**
  String get router_verifying_subscription;

  /// No description provided for @router_login_success.
  ///
  /// In en, this message translates to:
  /// **'Router login successful'**
  String get router_login_success;

  /// No description provided for @router_connection_failed.
  ///
  /// In en, this message translates to:
  /// **'Router Connection Failed'**
  String get router_connection_failed;

  /// No description provided for @router_connection_error.
  ///
  /// In en, this message translates to:
  /// **'Unable to connect'**
  String get router_connection_error;

  /// No description provided for @router_token_not_found.
  ///
  /// In en, this message translates to:
  /// **'Session expired. Log in again'**
  String get router_token_not_found;

  /// No description provided for @router_login_data_error.
  ///
  /// In en, this message translates to:
  /// **'Unable to read login data'**
  String get router_login_data_error;

  /// No description provided for @router_commands_load_failed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load commands'**
  String get router_commands_load_failed;

  /// No description provided for @router_commands_load_error.
  ///
  /// In en, this message translates to:
  /// **'Unable to load router commands'**
  String get router_commands_load_error;

  /// No description provided for @router_invalid_server_response.
  ///
  /// In en, this message translates to:
  /// **'Invalid response'**
  String get router_invalid_server_response;

  /// No description provided for @router_commands_http_error.
  ///
  /// In en, this message translates to:
  /// **'Failed to load commands'**
  String get router_commands_http_error;

  /// No description provided for @router_subscriber_data_not_found.
  ///
  /// In en, this message translates to:
  /// **'Subscriber data not found'**
  String get router_subscriber_data_not_found;

  /// No description provided for @router_username_not_found.
  ///
  /// In en, this message translates to:
  /// **'Unable to read username'**
  String get router_username_not_found;

  /// No description provided for @router_data_mismatch.
  ///
  /// In en, this message translates to:
  /// **'Router data does not match your account'**
  String get router_data_mismatch;

  /// No description provided for @router_verification_success.
  ///
  /// In en, this message translates to:
  /// **'Verified successfully'**
  String get router_verification_success;

  /// No description provided for @router_pppoe_commands_not_found.
  ///
  /// In en, this message translates to:
  /// **'PPPoE commands not found'**
  String get router_pppoe_commands_not_found;

  /// No description provided for @router_disconnect_error.
  ///
  /// In en, this message translates to:
  /// **'Disconnect error'**
  String get router_disconnect_error;

  /// No description provided for @default_login_failed.
  ///
  /// In en, this message translates to:
  /// **'Default login failed'**
  String get default_login_failed;

  /// No description provided for @default_login_failed_manual.
  ///
  /// In en, this message translates to:
  /// **'Default credentials are incorrect'**
  String get default_login_failed_manual;

  /// No description provided for @router_default_credentials_failed.
  ///
  /// In en, this message translates to:
  /// **'Default login failed'**
  String get router_default_credentials_failed;

  /// No description provided for @router_manual_credentials_required.
  ///
  /// In en, this message translates to:
  /// **'Enter router credentials manually'**
  String get router_manual_credentials_required;

  /// No description provided for @router_connection_help.
  ///
  /// In en, this message translates to:
  /// **'Connect to the router network first'**
  String get router_connection_help;

  /// No description provided for @router_invalid_credentials.
  ///
  /// In en, this message translates to:
  /// **'Invalid credentials'**
  String get router_invalid_credentials;

  /// No description provided for @router_not_found_on_network.
  ///
  /// In en, this message translates to:
  /// **'Router not found'**
  String get router_not_found_on_network;

  /// No description provided for @router_network_mismatch.
  ///
  /// In en, this message translates to:
  /// **'Device is not on the router network'**
  String get router_network_mismatch;

  /// No description provided for @router_gateway_not_found.
  ///
  /// In en, this message translates to:
  /// **'Router not found'**
  String get router_gateway_not_found;

  /// No description provided for @router_telnet_unavailable.
  ///
  /// In en, this message translates to:
  /// **'Router service unavailable'**
  String get router_telnet_unavailable;

  /// No description provided for @router_connection_refused.
  ///
  /// In en, this message translates to:
  /// **'Router refused connection'**
  String get router_connection_refused;

  /// No description provided for @router_connection_timeout.
  ///
  /// In en, this message translates to:
  /// **'Connection timed out'**
  String get router_connection_timeout;

  /// No description provided for @router_socket_error.
  ///
  /// In en, this message translates to:
  /// **'Unable to establish connection'**
  String get router_socket_error;

  /// No description provided for @router_authentication_failed.
  ///
  /// In en, this message translates to:
  /// **'Invalid credentials'**
  String get router_authentication_failed;

  /// No description provided for @router_login_failed.
  ///
  /// In en, this message translates to:
  /// **'Router login failed'**
  String get router_login_failed;

  /// No description provided for @router_unknown_error.
  ///
  /// In en, this message translates to:
  /// **'Router connection error'**
  String get router_unknown_error;

  /// No description provided for @router_network_unreachable.
  ///
  /// In en, this message translates to:
  /// **'Network unreachable'**
  String get router_network_unreachable;

  /// No description provided for @router_host_unreachable.
  ///
  /// In en, this message translates to:
  /// **'Router unreachable'**
  String get router_host_unreachable;

  /// No description provided for @router_host_lookup_failed.
  ///
  /// In en, this message translates to:
  /// **'Router not found'**
  String get router_host_lookup_failed;

  /// No description provided for @router_verification_failed.
  ///
  /// In en, this message translates to:
  /// **'Router verification failed'**
  String get router_verification_failed;

  /// No description provided for @router_subscription_verification_error.
  ///
  /// In en, this message translates to:
  /// **'Unable to verify subscription'**
  String get router_subscription_verification_error;

  /// No description provided for @router_line_quality.
  ///
  /// In en, this message translates to:
  /// **'Line Quality'**
  String get router_line_quality;

  /// No description provided for @router_line_data.
  ///
  /// In en, this message translates to:
  /// **'Current line connection data'**
  String get router_line_data;

  /// No description provided for @router_reading_router_data.
  ///
  /// In en, this message translates to:
  /// **'Reading router data...'**
  String get router_reading_router_data;

  /// No description provided for @router_reading_statistics.
  ///
  /// In en, this message translates to:
  /// **'Reading statistics...'**
  String get router_reading_statistics;

  /// No description provided for @router_current_connection_speed.
  ///
  /// In en, this message translates to:
  /// **'Current Connection Speed'**
  String get router_current_connection_speed;

  /// No description provided for @router_download.
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get router_download;

  /// No description provided for @router_upload.
  ///
  /// In en, this message translates to:
  /// **'Upload'**
  String get router_upload;

  /// No description provided for @router_snr_download.
  ///
  /// In en, this message translates to:
  /// **'SNR Download'**
  String get router_snr_download;

  /// No description provided for @router_snr_upload.
  ///
  /// In en, this message translates to:
  /// **'SNR Upload'**
  String get router_snr_upload;

  /// No description provided for @router_attenuation_download.
  ///
  /// In en, this message translates to:
  /// **'Download Attenuation'**
  String get router_attenuation_download;

  /// No description provided for @router_attenuation_upload.
  ///
  /// In en, this message translates to:
  /// **'Upload Attenuation'**
  String get router_attenuation_upload;

  /// No description provided for @router_crc_errors.
  ///
  /// In en, this message translates to:
  /// **'CRC Errors'**
  String get router_crc_errors;

  /// No description provided for @router_change_wifi_password.
  ///
  /// In en, this message translates to:
  /// **'Change Wi-Fi Password'**
  String get router_change_wifi_password;

  /// No description provided for @router_change_wifi_password_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Change the Wi-Fi password of your router.'**
  String get router_change_wifi_password_subtitle;

  /// No description provided for @router_select_band.
  ///
  /// In en, this message translates to:
  /// **'Network Band'**
  String get router_select_band;

  /// No description provided for @router_24ghz.
  ///
  /// In en, this message translates to:
  /// **'2.4 GHz'**
  String get router_24ghz;

  /// No description provided for @router_5ghz.
  ///
  /// In en, this message translates to:
  /// **'5 GHz'**
  String get router_5ghz;

  /// No description provided for @router_better_coverage.
  ///
  /// In en, this message translates to:
  /// **'Better Coverage'**
  String get router_better_coverage;

  /// No description provided for @router_higher_speed.
  ///
  /// In en, this message translates to:
  /// **'Higher Speed'**
  String get router_higher_speed;

  /// No description provided for @router_new_password.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get router_new_password;

  /// No description provided for @router_enter_new_password.
  ///
  /// In en, this message translates to:
  /// **'Enter the new password'**
  String get router_enter_new_password;

  /// No description provided for @router_password_required.
  ///
  /// In en, this message translates to:
  /// **'Please enter the new password.'**
  String get router_password_required;

  /// No description provided for @router_password_min_length.
  ///
  /// In en, this message translates to:
  /// **'The password must be at least 8 characters long.'**
  String get router_password_min_length;

  /// No description provided for @router_password_no_spaces.
  ///
  /// In en, this message translates to:
  /// **'The password cannot contain spaces.'**
  String get router_password_no_spaces;

  /// No description provided for @router_password_hint.
  ///
  /// In en, this message translates to:
  /// **'Use a strong password with at least 8 characters and avoid spaces.'**
  String get router_password_hint;

  /// No description provided for @router_change_password.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get router_change_password;

  /// No description provided for @router_changing_password.
  ///
  /// In en, this message translates to:
  /// **'Changing password...'**
  String get router_changing_password;

  /// No description provided for @router_password_changed_successfully.
  ///
  /// In en, this message translates to:
  /// **'The Wi-Fi password was changed successfully.'**
  String get router_password_changed_successfully;

  /// No description provided for @router_devices_reconnect.
  ///
  /// In en, this message translates to:
  /// **'Reconnect devices using the new password'**
  String get router_devices_reconnect;

  /// No description provided for @router_prepare_settings.
  ///
  /// In en, this message translates to:
  /// **'Preparing settings...'**
  String get router_prepare_settings;

  /// No description provided for @router_connecting_fetching_data.
  ///
  /// In en, this message translates to:
  /// **'Connecting and fetching data...'**
  String get router_connecting_fetching_data;

  /// No description provided for @router_unable_connect.
  ///
  /// In en, this message translates to:
  /// **'Unable to connect'**
  String get router_unable_connect;

  /// No description provided for @router_unexpected_error.
  ///
  /// In en, this message translates to:
  /// **'An unexpected error occurred.'**
  String get router_unexpected_error;

  /// No description provided for @router_unable_load_data.
  ///
  /// In en, this message translates to:
  /// **'Unable to load router data'**
  String get router_unable_load_data;

  /// No description provided for @router_unable_load_commands.
  ///
  /// In en, this message translates to:
  /// **'Unable to load router commands'**
  String get router_unable_load_commands;

  /// No description provided for @router_unable_change_password.
  ///
  /// In en, this message translates to:
  /// **'Unable to change password'**
  String get router_unable_change_password;

  /// No description provided for @router_commands_error.
  ///
  /// In en, this message translates to:
  /// **'Failed to load router commands.'**
  String get router_commands_error;

  /// No description provided for @router_password_change_error.
  ///
  /// In en, this message translates to:
  /// **'Failed to change the Wi-Fi password.'**
  String get router_password_change_error;

  /// No description provided for @router_current_connection_data.
  ///
  /// In en, this message translates to:
  /// **'Current connection data'**
  String get router_current_connection_data;

  /// No description provided for @router_downstream_snr.
  ///
  /// In en, this message translates to:
  /// **'Downstream SNR'**
  String get router_downstream_snr;

  /// No description provided for @router_upstream_snr.
  ///
  /// In en, this message translates to:
  /// **'Upstream SNR'**
  String get router_upstream_snr;

  /// No description provided for @router_downstream_attenuation.
  ///
  /// In en, this message translates to:
  /// **'Downstream Attenuation'**
  String get router_downstream_attenuation;

  /// No description provided for @router_upstream_attenuation.
  ///
  /// In en, this message translates to:
  /// **'Upstream Attenuation'**
  String get router_upstream_attenuation;

  /// No description provided for @router_select_network_band.
  ///
  /// In en, this message translates to:
  /// **'Select Network Band'**
  String get router_select_network_band;

  /// No description provided for @router_password_security_hint.
  ///
  /// In en, this message translates to:
  /// **'The new password will be applied directly to the router. Make sure to save it before continuing.'**
  String get router_password_security_hint;

  /// No description provided for @router_loading_settings.
  ///
  /// In en, this message translates to:
  /// **'Loading Router Settings'**
  String get router_loading_settings;

  /// No description provided for @router_connecting_loading_data.
  ///
  /// In en, this message translates to:
  /// **'Connecting to the router and reading data...'**
  String get router_connecting_loading_data;

  /// No description provided for @router_router_data_error.
  ///
  /// In en, this message translates to:
  /// **'Failed to load router data.'**
  String get router_router_data_error;

  /// No description provided for @loading_payment_data.
  ///
  /// In en, this message translates to:
  /// **'Loading payment data...'**
  String get loading_payment_data;

  /// No description provided for @router_choose_device.
  ///
  /// In en, this message translates to:
  /// **'Choose Router'**
  String get router_choose_device;

  /// No description provided for @router_choose_brand.
  ///
  /// In en, this message translates to:
  /// **'Choose Brand'**
  String get router_choose_brand;

  /// No description provided for @router_choose_model.
  ///
  /// In en, this message translates to:
  /// **'Choose Model'**
  String get router_choose_model;

  /// No description provided for @router_choose_model_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose a model to continue'**
  String get router_choose_model_subtitle;

  /// No description provided for @router_no_brands.
  ///
  /// In en, this message translates to:
  /// **'No Brands'**
  String get router_no_brands;

  /// No description provided for @router_manufacturer.
  ///
  /// In en, this message translates to:
  /// **'Router manufacturer'**
  String get router_manufacturer;

  /// No description provided for @available_router_models.
  ///
  /// In en, this message translates to:
  /// **'available models'**
  String get available_router_models;

  /// No description provided for @router_no_brands_message.
  ///
  /// In en, this message translates to:
  /// **'Unable to load router brands'**
  String get router_no_brands_message;

  /// No description provided for @router_loading_connection.
  ///
  /// In en, this message translates to:
  /// **'Preparing connection...'**
  String get router_loading_connection;

  /// No description provided for @router_loading_brands.
  ///
  /// In en, this message translates to:
  /// **'Loading brands...'**
  String get router_loading_brands;

  /// No description provided for @router_models_unavailable.
  ///
  /// In en, this message translates to:
  /// **'No models available'**
  String get router_models_unavailable;

  /// No description provided for @router_brands_load_failed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load router brands'**
  String get router_brands_load_failed;

  /// No description provided for @invalid_login_credentials.
  ///
  /// In en, this message translates to:
  /// **'Invalid login credentials'**
  String get invalid_login_credentials;

  /// No description provided for @router_login_token_not_found.
  ///
  /// In en, this message translates to:
  /// **'Login token was not found'**
  String get router_login_token_not_found;

  /// No description provided for @router_login_data_read_failed.
  ///
  /// In en, this message translates to:
  /// **'Unable to read login information'**
  String get router_login_data_read_failed;

  /// No description provided for @router_server_response_invalid.
  ///
  /// In en, this message translates to:
  /// **'Invalid response from the server'**
  String get router_server_response_invalid;

  /// No description provided for @router_brands_data_invalid.
  ///
  /// In en, this message translates to:
  /// **'Invalid router brands data'**
  String get router_brands_data_invalid;

  /// No description provided for @router_brands_load_error.
  ///
  /// In en, this message translates to:
  /// **'An error occurred while loading router brands'**
  String get router_brands_load_error;

  /// No description provided for @router_models_load_failed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load router models'**
  String get router_models_load_failed;

  /// No description provided for @router_models_data_invalid.
  ///
  /// In en, this message translates to:
  /// **'Invalid router models data'**
  String get router_models_data_invalid;

  /// No description provided for @router_models_load_error.
  ///
  /// In en, this message translates to:
  /// **'An error occurred while loading router models'**
  String get router_models_load_error;

  /// No description provided for @session_expired_title.
  ///
  /// In en, this message translates to:
  /// **'Session Expired'**
  String get session_expired_title;

  /// No description provided for @session_expired_message.
  ///
  /// In en, this message translates to:
  /// **'Your session has expired. Please log in again.'**
  String get session_expired_message;

  /// No description provided for @update_now.
  ///
  /// In en, this message translates to:
  /// **'Update Now'**
  String get update_now;

  /// No description provided for @details.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get details;

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @total_fees.
  ///
  /// In en, this message translates to:
  /// **'Total_fees'**
  String get total_fees;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
