// import 'dart:async';
// import 'dart:convert';
// import 'dart:io';

// import 'package:flutter/foundation.dart';

// class RouterTelnetService {
//   Socket? _socket;
//   StreamSubscription<List<int>>? _subscription;
//   final StreamController<String> _outputController =
//       StreamController<String>.broadcast();
//   Stream<String> get outputStream => _outputController.stream;
//   String _buffer = '';
//   final List<int> _pendingTelnetBytes = <int>[];
//   bool _disposed = false;
//   bool _isLoggingIn = false;
//   bool _isExecuting = false;
//   bool get isConnected => _socket != null;
//   Future<void>? _operationLock;
//   Future<T> _withLock<T>(Future<T> Function() operation) async {
//     while (_operationLock != null) {
//       try {
//         await _operationLock;
//       } catch (_) {}
//     }
//     final completer = Completer<void>();
//     _operationLock = completer.future;
//     try {
//       return await operation();
//     } finally {
//       if (!completer.isCompleted) {
//         completer.complete();
//       }

//       if (identical(_operationLock, completer.future)) {
//         _operationLock = null;
//       }
//     }
//   }

//   Timer? _idleTimer;
//   static const Duration _pollDelay = Duration(milliseconds: 40);
//   static const Duration _packetDelay = Duration(milliseconds: 100);
//   static const Duration _promptSettleTime = Duration(milliseconds: 180);
//   static const Duration _loginTimeout = Duration(seconds: 15);
//   static const Duration _commandTimeout = Duration(seconds: 15);
//   static const int _iac = 255;
//   static const int _will = 251;
//   static const int _wont = 252;
//   static const int _do = 253;
//   static const int _dont = 254;
//   static const int _sb = 250;
//   static const int _se = 240;
//   static const int _binary = 0;
//   static const int _echo = 1;
//   static const int _suppressGoAhead = 3;
//   static const List<String> _promptCharacters = <String>[
//     '#',
//     '>',
//     '\$',
//     '%',
//   ];
//   static const List<String> _usernamePatterns = <String>[
//     'login:',
//     'login :',
//     'username:',
//     'username :',
//     'user name:',
//     'user name :',
//     'user:',
//     'user :',
//     'account:',
//     'account :',
//     'user id:',
//     'userid:'
//   ];

//   static const List<String> _passwordPatterns = <String>[
//     'password:',
//     'password :',
//     'passwd:',
//     'passwd :',
//     'pass:',
//     'pass :',
//     'pwd:',
//     'pwd :'
//   ];
//   static const List<String> _loginFailurePatterns = <String>[
//     'incorrect username or password',
//     'incorrect password',
//     'login failed',
//     'authentication failed',
//     'authentication failure',
//     'invalid username',
//     'invalid password',
//     'invalid user',
//     'invalid login',
//     'access denied',
//     'bad password',
//     'wrong password',
//     'wrong username',
//     'permission denied',
//   ];

//   void _resetIdleTimer() {
//     _idleTimer?.cancel();
//     if (!isConnected || _disposed) {
//       return;
//     }
//     _idleTimer = Timer(
//       const Duration(minutes: 3),
//       () async {
//         await disconnect();
//       },
//     );
//   }

//   Future<void> connect({
//     required String host,
//     required int port,
//     Duration timeout = const Duration(seconds: 10),
//   }) async {
//     if (_disposed) {
//       throw StateError(
//         'RouterTelnetService has already been disposed.',
//       );
//     }
//     if (isConnected) {
//       return;
//     }
//     final socket = await Socket.connect(
//       host,
//       port,
//       timeout: timeout,
//     );
//     _socket = socket;
//     _buffer = '';
//     _pendingTelnetBytes.clear();
//     _subscription = socket.listen(
//       _handleIncomingData,
//       onError: (
//         Object error,
//         StackTrace stackTrace,
//       ) {
//         if (!_outputController.isClosed) {
//           _outputController.addError(
//             error,
//             stackTrace,
//           );
//         }
//       },
//       onDone: () {
//         _socket = null;
//         _idleTimer?.cancel();
//         _idleTimer = null;
//       },
//       cancelOnError: false,
//     );
//     _resetIdleTimer();
//     await Future.delayed(
//       const Duration(milliseconds: 150),
//     );
//   }

//   void _handleIncomingData(
//     List<int> data,
//   ) {
//     if (_disposed) {
//       return;
//     }
//     if (data.isEmpty) {
//       return;
//     }
//     final bytes = List<int>.from(data);
//     final cleanedBytes = _processTelnetBytes(
//       bytes,
//     );
//     if (cleanedBytes.isEmpty) {
//       return;
//     }
//     final text = latin1.decode(
//       cleanedBytes,
//       allowInvalid: true,
//     );
//     _buffer += text;
//     if (_buffer.length > 200000) {
//       _buffer = _buffer.substring(
//         _buffer.length - 100000,
//       );
//     }
//     if (!_outputController.isClosed) {
//       _outputController.add(text);
//     }
//   }

//   List<int> _processTelnetBytes(
//     List<int> input,
//   ) {
//     final bytes = <int>[
//       ..._pendingTelnetBytes,
//       ...input,
//     ];
//     _pendingTelnetBytes.clear();
//     final output = <int>[];
//     int i = 0;
//     while (i < bytes.length) {
//       final byte = bytes[i];
//       if (byte != _iac) {
//         output.add(byte);
//         i++;
//         continue;
//       }
//       if (i + 1 >= bytes.length) {
//         _pendingTelnetBytes.add(
//           bytes[i],
//         );
//         break;
//       }
//       final command = bytes[i + 1];
//       if (command == _iac) {
//         output.add(_iac);
//         i += 2;
//         continue;
//       }
//       if (command == _will ||
//           command == _wont ||
//           command == _do ||
//           command == _dont) {
//         if (i + 2 >= bytes.length) {
//           _pendingTelnetBytes.addAll(
//             bytes.sublist(i),
//           );
//           break;
//         }
//         final option = bytes[i + 2];
//         _handleTelnetNegotiation(
//           command,
//           option,
//         );

//         i += 3;

//         continue;
//       }
//       if (command == _sb) {
//         int endIndex = -1;
//         for (int j = i + 2; j < bytes.length - 1; j++) {
//           if (bytes[j] == _iac && bytes[j + 1] == _se) {
//             endIndex = j;
//             break;
//           }
//         }
//         if (endIndex == -1) {
//           _pendingTelnetBytes.addAll(
//             bytes.sublist(i),
//           );
//           break;
//         }
//         i = endIndex + 2;
//         continue;
//       }
//       i += 2;
//     }
//     return output;
//   }

//   void _handleTelnetNegotiation(
//     int command,
//     int option,
//   ) {
//     final socket = _socket;
//     if (socket == null) {
//       return;
//     }
//     if (command == _will) {
//       if (option == _echo || option == _suppressGoAhead) {
//         _sendTelnet(
//           _dont,
//           option,
//         );
//         return;
//       }
//       _sendTelnet(
//         _dont,
//         option,
//       );
//       return;
//     }
//     if (command == _wont) {
//       return;
//     }
//     if (command == _do) {
//       if (option == _binary) {
//         _sendTelnet(
//           _wont,
//           option,
//         );
//         return;
//       }
//       _sendTelnet(
//         _wont,
//         option,
//       );
//       return;
//     }
//     if (command == _dont) {
//       return;
//     }
//   }

//   void _sendTelnet(
//     int command,
//     int option,
//   ) {
//     final socket = _socket;

//     if (socket == null) {
//       return;
//     }
//     try {
//       socket.add(
//         <int>[
//           _iac,
//           command,
//           option,
//         ],
//       );
//     } catch (e) {}
//   }

//   String _debugBytes(
//     List<int> bytes,
//   ) {
//     final result = StringBuffer();
//     for (final byte in bytes) {
//       switch (byte) {
//         case _iac:
//           result.write('IAC ');
//           break;
//         case _will:
//           result.write('WILL ');
//           break;
//         case _wont:
//           result.write('WONT ');
//           break;
//         case _do:
//           result.write('DO ');
//           break;
//         case _dont:
//           result.write('DONT ');
//           break;
//         case _sb:
//           result.write('SB ');
//           break;
//         case _se:
//           result.write('SE ');
//           break;
//         case 13:
//           result.write(r'\r ');
//           break;
//         case 10:
//           result.write(r'\n ');
//           break;
//         case 0:
//           result.write(r'\0 ');
//           break;
//         default:
//           if (byte >= 32 && byte <= 126) {
//             result.write(
//               '${String.fromCharCode(byte)} ',
//             );
//           } else {
//             result.write(
//               '<$byte> ',
//             );
//           }
//       }
//     }
//     return result.toString().trim();
//   }

//   String _debugText(
//     String text,
//   ) {
//     return text
//         .replaceAll(
//           '\r',
//           r'\r',
//         )
//         .replaceAll(
//           '\n',
//           r'\n',
//         )
//         .replaceAll(
//           '\x00',
//           r'\0',
//         );
//   }

//   Future<void> send(
//     String command, {
//     bool enter = true,
//   }) async {
//     final socket = _socket;
//     if (socket == null) {
//       throw StateError(
//         'Telnet connection is not established.',
//       );
//     }
//     final value = enter ? '$command\r\n' : command;
//     socket.add(
//       latin1.encode(value),
//     );
//     await socket.flush();
//     _resetIdleTimer();
//     await Future.delayed(
//       const Duration(milliseconds: 80),
//     );
//   }

//   void clearBuffer() {
//     _buffer = '';
//   }

//   String get currentBuffer => _buffer;
//   Future<String> _waitForLoginToken({
//     Duration timeout = _loginTimeout,
//   }) async {
//     final start = DateTime.now();
//     while (DateTime.now().difference(start) < timeout) {
//       if (_buffer.isNotEmpty) {
//         final clean = _clean(
//           _buffer,
//         );
//         if (clean.isNotEmpty) {
//           return clean;
//         }
//       }
//       await Future.delayed(
//         _pollDelay,
//       );
//     }
//     return '';
//   }

//   Future<String> waitForText({
//     required List<String> patterns,
//     Duration timeout = const Duration(seconds: 8),
//   }) async {
//     final start = DateTime.now();
//     while (DateTime.now().difference(start) < timeout) {
//       if (_buffer.isNotEmpty) {
//         final cleaned = _clean(
//           _buffer,
//         );
//         final lower = cleaned.toLowerCase();
//         for (final pattern in patterns) {
//           if (lower.contains(
//             pattern.toLowerCase(),
//           )) {
//             final result = _buffer;
//             _buffer = '';
//             return result;
//           }
//         }
//       }
//       await Future.delayed(
//         _pollDelay,
//       );
//     }
//     return '';
//   }

//   Future<String> waitForOutput({
//     Duration timeout = const Duration(seconds: 10),
//     Duration settleTime = const Duration(milliseconds: 300),
//   }) async {
//     final start = DateTime.now();
//     while (DateTime.now().difference(start) < timeout) {
//       if (_buffer.isNotEmpty) {
//         break;
//       }
//       await Future.delayed(
//         _pollDelay,
//       );
//     }
//     if (_buffer.isEmpty) {
//       return '';
//     }
//     var lastLength = _buffer.length;
//     while (DateTime.now().difference(start) < timeout) {
//       await Future.delayed(
//         _packetDelay,
//       );
//       if (_buffer.length != lastLength) {
//         lastLength = _buffer.length;
//         continue;
//       }
//       await Future.delayed(
//         settleTime,
//       );
//       if (_buffer.length == lastLength) {
//         final result = _buffer;
//         _buffer = '';
//         return result;
//       }
//       lastLength = _buffer.length;
//     }
//     final result = _buffer;
//     _buffer = '';
//     return result;
//   }

//   Future<String> waitForPrompt({
//     Duration timeout = const Duration(seconds: 10),
//     String? prompt,
//   }) async {
//     final start = DateTime.now();
//     while (DateTime.now().difference(start) < timeout) {
//       if (_buffer.isEmpty) {
//         await Future.delayed(
//           _pollDelay,
//         );
//         continue;
//       }
//       final cleaned = _clean(
//         _buffer,
//       );
//       if (cleaned.isEmpty) {
//         await Future.delayed(
//           _pollDelay,
//         );
//         continue;
//       }
//       if (prompt != null && cleaned.contains(prompt)) {
//         final result = _buffer;
//         _buffer = '';
//         return result;
//       }
//       if (_hasPrompt(cleaned)) {
//         await Future.delayed(
//           _promptSettleTime,
//         );
//         final result = _buffer;
//         _buffer = '';
//         return result;
//       }
//       await Future.delayed(
//         _pollDelay,
//       );
//     }
//     if (_buffer.isNotEmpty) {
//       final result = _buffer;
//       _buffer = '';
//       return result;
//     }
//     return '';
//   }

//   Future<void> login({
//     required String username,
//     required String password,
//   }) async {
//     if (!isConnected) {
//       throw StateError(
//         'Telnet connection is not established.',
//       );
//     }
//     if (_isLoggingIn) {
//       throw StateError(
//         'A Telnet login operation is already running.',
//       );
//     }
//     _isLoggingIn = true;
//     try {
//       await _loginInternal(
//         username: username,
//         password: password,
//       );
//     } finally {
//       _isLoggingIn = false;
//     }
//   }

//   Future<void> _loginInternal({
//     required String username,
//     required String password,
//   }) async {
//     debugPrint('--- [Telnet] بدء عملية تسجيل الدخول ---');

//     String initial = await _waitForLoginToken(
//       timeout: _loginTimeout,
//     );

//     debugPrint('[Telnet] الاستجابة الأولية للراوتر: ${_clean(initial)}');

//     if (_hasPrompt(_clean(initial))) {
//       debugPrint(
//           '[Telnet]  تم العثور على محث (Prompt) مباشر. الراوتر مفتوح بدون مصادقة.');
//       clearBuffer();
//       return;
//     }

//     bool usernameSent = false;
//     bool passwordSent = false;
//     int passwordAttempts = 0;
//     int emptyBufferCount = 0;

//     final loginStart = DateTime.now();
//     while (
//         DateTime.now().difference(loginStart) < const Duration(seconds: 20)) {
//       final snapshot = _clean(_buffer);
//       final lower = snapshot.toLowerCase();
//       if (snapshot.isNotEmpty) {
//         debugPrint('[Telnet] المخزن (Buffer) الحالي: $snapshot');
//       }

//       if (_hasPrompt(snapshot)) {
//         debugPrint('[Telnet]  تم تسجيل الدخول بنجاح (تم رصد علامة الأوامر # أو >)');
//         clearBuffer();
//         return;
//       }

//       if (_containsPasswordPrompt(lower)) {
//         debugPrint('[Telnet]  الراوتر يطلب كلمة المرور صراحةً...');
//         if (passwordAttempts >= 3) {
//           clearBuffer();
//           debugPrint(
//               '[Telnet]  فشل تسجيل الدخول: تم تجاوز الحد الأقصى لمحاولات كلمة المرور (3).');
//           throw StateError('بيانات تسجيل الدخول إلى الراوتر غير صحيحة');
//         }
//         passwordAttempts++;
//         clearBuffer();
//         debugPrint(
//             '[Telnet] جاري إرسال كلمة المرور (المحاولة $passwordAttempts)...');
//         await send(password);
//         passwordSent = true;
//         await Future.delayed(const Duration(milliseconds: 500));
//         continue;
//       }

//       if (_containsUsernamePrompt(lower)) {
//         debugPrint('[Telnet]  الراوتر يطلب اسم المستخدم صراحةً...');
//         if (!usernameSent) {
//           clearBuffer();
//           debugPrint('[Telnet] جاري إرسال اسم المستخدم...');
//           await send(username);
//           usernameSent = true;
//           await Future.delayed(const Duration(milliseconds: 500));
//           continue;
//         } else {
//           debugPrint(
//               '[Telnet] ⚠️ الراوتر طلب اسم المستخدم مرة أخرى بالرغم من إرساله!');
//           await Future.delayed(const Duration(milliseconds: 500));
//         }
//       }

//       if (_isLoginFailure(lower)) {
//         debugPrint('[Telnet]  الراوتر أبلغ عن فشل المصادقة (بيانات خاطئة).');
//         clearBuffer();
//         await Future.delayed(const Duration(milliseconds: 100));
//         continue;
//       }

//       if (snapshot.isEmpty) {
//         emptyBufferCount++;
//         if (emptyBufferCount % 5 == 0) {
//           debugPrint(
//               '[Telnet]  لا يوجد استجابة في المخزن، إرسال أمر تنبيه (Wake) للراوتر...');
//           await _wakeRouter();
//         }
//         await Future.delayed(const Duration(milliseconds: 200));
//         continue;
//       }

//       if (passwordSent) {
//         await Future.delayed(const Duration(milliseconds: 200));
//         continue;
//       }

//       if (_looksLikePasswordRequest(lower)) {
//         debugPrint(
//             '[Telnet]  (بناءً على التنسيق) يبدو أن الراوتر يطلب كلمة المرور...');
//         clearBuffer();
//         debugPrint('[Telnet] جاري إرسال كلمة المرور...');
//         await send(password);
//         passwordSent = true;
//         await Future.delayed(const Duration(milliseconds: 500));
//         continue;
//       }

//       if (_looksLikeUsernameRequest(lower)) {
//         debugPrint(
//             '[Telnet] 👤 (بناءً على التنسيق) يبدو أن الراوتر يطلب اسم المستخدم...');
//         if (!usernameSent) {
//           clearBuffer();
//           debugPrint('[Telnet] جاري إرسال اسم المستخدم...');
//           await send(username);
//           usernameSent = true;
//           await Future.delayed(const Duration(milliseconds: 500));
//           continue;
//         }
//       }
//       debugPrint(
//           '[Telnet]  استجابة غير معروفة أو رسالة ترحيب قيد الإرسال، جاري الانتظار...');
//       await Future.delayed(const Duration(milliseconds: 300));
//     }
//     final finalOutput = _clean(_buffer);
//     debugPrint(
//         '[Telnet] انتهى وقت محاولة تسجيل الدخول (Timeout 20s). المخرجات النهائية: $finalOutput');

//     if (_hasPrompt(finalOutput)) {
//       debugPrint('[Telnet]  تم العثور على علامة الأوامر في اللحظة الأخيرة.');
//       clearBuffer();
//       return;
//     }

//     if (_isLoginFailure(finalOutput.toLowerCase())) {
//       clearBuffer();
//       debugPrint(
//           '[Telnet]  تم التأكد من فشل تسجيل الدخول من خلال المخرجات النهائية.');
//       throw StateError('بيانات تسجيل الدخول إلى الراوتر غير صحيحة');
//     }

//     debugPrint(
//         '[Telnet]  لم يتمكن الكود من تجاوز شاشة الدخول. الرجاء مراجعة المخرجات النهائية لمعرفة السبب.');
//     throw StateError(
//         'تعذر التأكد من نجاح تسجيل الدخول إلى الراوتر. المخرجات: $finalOutput');
//   }

//   Future<void> _wakeRouter() async {
//     final socket = _socket;
//     if (socket == null) {
//       return;
//     }
//     try {
//       socket.add(
//         latin1.encode('\r\n'),
//       );

//       await socket.flush();
//     } catch (e) {}
//   }

//   bool _containsUsernamePrompt(
//     String text,
//   ) {
//     final lower = text.toLowerCase();
//     for (final pattern in _usernamePatterns) {
//       if (lower.contains(pattern)) {
//         return true;
//       }
//     }
//     return false;
//   }

//   bool _containsPasswordPrompt(
//     String text,
//   ) {
//     final lower = text.toLowerCase();
//     for (final pattern in _passwordPatterns) {
//       if (lower.contains(pattern)) {
//         return true;
//       }
//     }
//     return false;
//   }

//   bool _looksLikePasswordRequest(
//     String text,
//   ) {
//     final lines = text
//         .split('\n')
//         .map(
//           (e) => e.trim(),
//         )
//         .where(
//           (e) => e.isNotEmpty,
//         )
//         .toList();

//     if (lines.isEmpty) {
//       return false;
//     }
//     final last = lines.last.toLowerCase();
//     return last == 'password' || last == 'passwd' || last == 'pass';
//   }

//   bool _looksLikeUsernameRequest(
//     String text,
//   ) {
//     final lines = text
//         .split('\n')
//         .map(
//           (e) => e.trim(),
//         )
//         .where(
//           (e) => e.isNotEmpty,
//         )
//         .toList();
//     if (lines.isEmpty) {
//       return false;
//     }
//     final last = lines.last.toLowerCase();
//     return last == 'login' || last == 'username' || last == 'user';
//   }

//   bool _isLoginFailure(
//     String text,
//   ) {
//     final lower = text.toLowerCase();
//     for (final pattern in _loginFailurePatterns) {
//       if (lower.contains(pattern)) {
//         return true;
//       }
//     }
//     return false;
//   }

//   bool _hasPrompt(
//     String text,
//   ) {
//     final cleaned = _clean(text);
//     if (cleaned.isEmpty) {
//       return false;
//     }
//     final lines = cleaned
//         .split('\n')
//         .map(
//           (e) => e.trim(),
//         )
//         .where(
//           (e) => e.isNotEmpty,
//         )
//         .toList();
//     if (lines.isEmpty) {
//       return false;
//     }
//     final last = lines.last.trim();
//     if (last.isEmpty) {
//       return false;
//     }
//     if (last == '#' || last == '>' || last == '\$' || last == '%') {
//       return true;
//     }
//     if (RegExp(
//       r'^[^\r\n]{0,120}[#>%\$]$',
//     ).hasMatch(last)) {
//       return true;
//     }
//     final trimmed = last.trimRight();
//     for (final character in _promptCharacters) {
//       if (trimmed.endsWith(
//         character,
//       )) {
//         return true;
//       }
//     }
//     return false;
//   }

//   Future<String> execute(
//     String command, {
//     Duration timeout = _commandTimeout,
//     bool waitForPrompt = true,
//   }) async {
//     return _withLock<String>(
//       () async {
//         if (!isConnected) {
//           throw StateError(
//             'Telnet connection is not established.',
//           );
//         }
//         if (_isLoggingIn) {
//           throw StateError(
//             'Cannot execute a command while logging in.',
//           );
//         }
//         if (_isExecuting) {
//           throw StateError(
//             'A Telnet command is already executing.',
//           );
//         }
//         _isExecuting = true;
//         try {
//           clearBuffer();
//           await send(
//             command,
//           );
//           if (waitForPrompt) {
//             final output = await this.waitForPrompt(
//               timeout: timeout,
//             );
//             return output;
//           }
//           return await waitForOutput(
//             timeout: timeout,
//           );
//         } finally {
//           _isExecuting = false;
//         }
//       },
//     );
//   }

//   Future<String> getLineStatistics(
//     String command, {
//     Duration timeout = const Duration(seconds: 15),
//   }) async {
//     if (!isConnected) {
//       throw StateError(
//         'Telnet غير متصل بالراوتر',
//       );
//     }
//     final output = await execute(
//       command,
//       timeout: timeout,
//       waitForPrompt: true,
//     );
//     return output;
//   }

//   Future<String> changeWifiPassword(
//     String command, {
//     Duration timeout = const Duration(seconds: 15),

//     /// إذا كان الراوتر يحتاج أمراً بعد تغيير كلمة المرور
//     /// مثل:
//     /// config wlan restart
//     String? restartCommand,
//   }) async {
//     if (!isConnected) {
//       throw StateError(
//         'Telnet غير متصل بالراوتر',
//       );
//     }

//     debugPrint(
//       '[Telnet] ===============================',
//     );
//     debugPrint(
//       '[Telnet] CHANGE WIFI PASSWORD',
//     );
//     debugPrint(
//       '[Telnet] Command: ${_hideSensitiveCommand(command)}',
//     );

//     // ============================================================
//     // المرحلة الأولى:
//     // نحاول تنفيذ أمر تغيير كلمة المرور مباشرة.
//     // ============================================================

//     String output = await execute(
//       command,
//       timeout: timeout,
//       waitForPrompt: true,
//     );

//     String cleanedOutput = _clean(output);
//     String lowerOutput = cleanedOutput.toLowerCase();

//     debugPrint(
//       '[Telnet] WIFI PASSWORD DIRECT RESPONSE:',
//     );
//     debugPrint(
//       cleanedOutput,
//     );

//     // ============================================================
//     // المرحلة الثانية:
//     // تحقق هل الراوتر رفض الأمر لأنه يحتاج shell (sh)
//     // ============================================================

//     final bool shellRequired = _isShellRequiredResponse(
//       lowerOutput,
//     );

//     if (shellRequired) {
//       debugPrint(
//         '[Telnet] ⚠️ الراوتر رفض الأمر من الـ prompt الحالي.',
//       );

//       debugPrint(
//         '[Telnet] 🔧 سيتم الدخول إلى shell باستخدام: sh',
//       );

//       // ------------------------------------------------------------
//       // تنظيف أي بيانات قديمة قبل إرسال sh
//       // ------------------------------------------------------------

//       clearBuffer();

//       final shellOutput = await execute(
//         'sh',
//         timeout: timeout,
//         waitForPrompt: true,
//       );

//       final cleanedShellOutput = _clean(
//         shellOutput,
//       );

//       debugPrint(
//         '[Telnet] SHELL RESPONSE:',
//       );
//       debugPrint(
//         cleanedShellOutput,
//       );

//       // ------------------------------------------------------------
//       // تحقق أن sh لم يفشل
//       // ------------------------------------------------------------

//       final shellLower = cleanedShellOutput.toLowerCase();

//       if (_isCommandFailure(shellLower)) {
//         throw StateError(
//           'فشل الدخول إلى shell في الراوتر.',
//         );
//       }

//       debugPrint(
//         '[Telnet] ✅ تم الدخول إلى shell.',
//       );

//       // ------------------------------------------------------------
//       // الآن نعيد تنفيذ أمر تغيير كلمة المرور
//       // ------------------------------------------------------------

//       debugPrint(
//         '[Telnet] 🔐 إعادة تنفيذ أمر تغيير كلمة المرور داخل shell:',
//       );

//       debugPrint(
//         '[Telnet] ${_hideSensitiveCommand(command)}',
//       );

//       output = await execute(
//         command,
//         timeout: timeout,
//         waitForPrompt: true,
//       );

//       cleanedOutput = _clean(output);
//       lowerOutput = cleanedOutput.toLowerCase();

//       debugPrint(
//         '[Telnet] WIFI PASSWORD SHELL RESPONSE:',
//       );

//       debugPrint(
//         cleanedOutput,
//       );

//       // ------------------------------------------------------------
//       // إذا فشل الأمر داخل shell فعلاً
//       // ------------------------------------------------------------

//       if (_isCommandFailure(lowerOutput)) {
//         debugPrint(
//           '[Telnet] ❌ تغيير كلمة المرور فشل داخل shell.',
//         );

//         throw StateError(
//           'فشل تغيير كلمة مرور Wi-Fi داخل shell.',
//         );
//       }

//       debugPrint(
//         '[Telnet] ✅ تم تنفيذ تغيير كلمة المرور داخل shell.',
//       );
//     } else {
//       // ============================================================
//       // الراوتر لا يحتاج sh
//       // ============================================================

//       if (_isCommandFailure(lowerOutput)) {
//         debugPrint(
//           '[Telnet] ❌ أمر تغيير كلمة المرور فشل.',
//         );

//         throw StateError(
//           'فشل تغيير كلمة مرور Wi-Fi. '
//           'الراوتر رفض الأمر.',
//         );
//       }

//       debugPrint(
//         '[Telnet] ✅ تم تنفيذ أمر تغيير كلمة المرور مباشرة.',
//       );
//     }

//     // ============================================================
//     // المرحلة الثالثة:
//     // restart اختياري
//     //
//     // بعض الراوترات تحتاج:
//     //
//     // config wlan restart
//     //
//     // وبعضها لا تحتاجه.
//     // ============================================================

//     if (restartCommand != null && restartCommand.trim().isNotEmpty) {
//       debugPrint(
//         '[Telnet] 🔄 يوجد أمر restart مطلوب.',
//       );

//       debugPrint(
//         '[Telnet] Restart Command: $restartCommand',
//       );

//       final restartOutput = await execute(
//         restartCommand,
//         timeout: timeout,
//         waitForPrompt: true,
//       );

//       final cleanedRestartOutput = _clean(
//         restartOutput,
//       );

//       final lowerRestartOutput = cleanedRestartOutput.toLowerCase();

//       debugPrint(
//         '[Telnet] WIFI RESTART RESPONSE:',
//       );

//       debugPrint(
//         cleanedRestartOutput,
//       );

//       if (_isCommandFailure(lowerRestartOutput)) {
//         debugPrint(
//           '[Telnet] ❌ تغيير كلمة المرور تم، '
//           'لكن restart فشل.',
//         );

//         throw StateError(
//           'تم تغيير كلمة مرور Wi-Fi، '
//           'لكن فشل تنفيذ أمر إعادة تشغيل Wi-Fi.',
//         );
//       }

//       debugPrint(
//         '[Telnet] ✅ تم تنفيذ restart بنجاح.',
//       );
//     } else {
//       debugPrint(
//         '[Telnet] ℹ️ هذا الراوتر لا يحتاج أمر restart.',
//       );
//     }

//     debugPrint(
//       '[Telnet] ===============================',
//     );

//     return cleanedOutput;
//   }

//   bool _isShellRequiredResponse(
//     String output,
//   ) {
//     final lower = output.toLowerCase();

//     // الراوتر أعاد قائمة أوامر Looking for
//     if (lower.contains('looking for :')) {
//       return true;
//     }

//     // بعض الراوترات قد تستخدم صيغة مختلفة
//     if (lower.contains('looking for:')) {
//       return true;
//     }

//     // في بعض الأجهزة يظهر هذا النص عند محاولة تنفيذ
//     // أمر يحتاج shell.
//     if (lower.contains('available commands')) {
//       return true;
//     }

//     return false;
//   }

//   bool _isCommandFailure(
//     String output,
//   ) {
//     final lower = output.toLowerCase();

//     const failurePatterns = <String>[
//       'unknown command',
//       'unknown',
//       'invalid command',
//       'invalid argument',
//       'invalid parameter',
//       'command not found',
//       'error',
//       'failed',
//       'failure',
//       'syntax error',
//       'parameter error',
//       'usage:',
//       'permission denied',
//       'access denied',
//     ];

//     for (final pattern in failurePatterns) {
//       if (lower.contains(pattern)) {
//         return true;
//       }
//     }

//     return false;
//   }

//   String _clean(
//     String text,
//   ) {
//     var result = text;
//     result = result.replaceAll(
//       RegExp(
//         r'\x1B\[[0-?]*[ -/]*[@-~]',
//       ),
//       '',
//     );
//     result = result.replaceAll(
//       RegExp(
//         r'\x1B\][^\x07]*(?:\x07|\x1B\\)',
//       ),
//       '',
//     );
//     result = result.replaceAll(
//       '\r\n',
//       '\n',
//     );
//     result = result.replaceAll(
//       '\r',
//       '\n',
//     );
//     result = result.replaceAll(
//       '\x00',
//       '',
//     );
//     result = result.replaceAll(
//       '\b',
//       '',
//     );
//     result = result.replaceAll(
//       '\t',
//       ' ',
//     );
//     result = result.replaceAll(
//       RegExp(
//         r'[\x01-\x08\x0B\x0C\x0E-\x1F]',
//       ),
//       '',
//     );
//     result = result.replaceAll(
//       RegExp(
//         r'\n{3,}',
//       ),
//       '\n\n',
//     );
//     return result.trim();
//   }

//   String _hideSensitiveCommand(
//     String command,
//   ) {
//     final tpLinkRegex = RegExp(
//       r'(wlctl\s+set\s+(?:2g|5g)\s+--sec\s+psk\s+wpa2\s+aes\s+)(.+)$',
//       caseSensitive: false,
//     );
//     final tpLinkMatch = tpLinkRegex.firstMatch(
//       command,
//     );
//     if (tpLinkMatch != null) {
//       return '${tpLinkMatch.group(1)}********';
//     }
//     final passphaseRegex = RegExp(
//       r'(passphase\s+)(.+)$',
//       caseSensitive: false,
//     );
//     final passphaseMatch = passphaseRegex.firstMatch(
//       command,
//     );
//     if (passphaseMatch != null) {
//       return '${passphaseMatch.group(1)}********';
//     }
//     final passwordRegex = RegExp(
//       r'(password\s*[=:]\s*)(.+)$',
//       caseSensitive: false,
//     );
//     final passwordMatch = passwordRegex.firstMatch(
//       command,
//     );
//     if (passwordMatch != null) {
//       return '${passwordMatch.group(1)}********';
//     }
//     final pskRegex = RegExp(
//       r'(psk\s*[=:]\s*)(.+)$',
//       caseSensitive: false,
//     );
//     final pskMatch = pskRegex.firstMatch(
//       command,
//     );
//     if (pskMatch != null) {
//       return '${pskMatch.group(1)}********';
//     }
//     return command;
//   }

//   Future<void> disconnect() async {
//     _idleTimer?.cancel();
//     _idleTimer = null;
//     final subscription = _subscription;
//     final socket = _socket;
//     _subscription = null;
//     _socket = null;
//     _buffer = '';
//     _pendingTelnetBytes.clear();
//     try {
//       await subscription?.cancel();
//     } catch (_) {}
//     try {
//       await socket?.flush();
//     } catch (_) {}
//     try {
//       await socket?.close();
//     } catch (_) {}
//   }

//   Future<void> dispose() async {
//     if (_disposed) {
//       return;
//     }
//     _disposed = true;
//     _idleTimer?.cancel();
//     _idleTimer = null;
//     await disconnect();
//     if (!_outputController.isClosed) {
//       await _outputController.close();
//     }
//   }
// }
