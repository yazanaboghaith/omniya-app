
class TelnetConstants {
  static const Duration pollDelay = Duration(milliseconds: 40);
  static const Duration packetDelay = Duration(milliseconds: 100);
  static const Duration promptSettleTime = Duration(milliseconds: 180);
  static const Duration loginTimeout = Duration(seconds: 15);
  static const Duration commandTimeout = Duration(seconds: 15);

  static const int iac = 255;
  static const int will = 251;
  static const int wont = 252;
  static const int doCommand = 253;
  static const int dont = 254;
  static const int sb = 250;
  static const int se = 240;

  static const int binary = 0;
  static const int echo = 1;
  static const int suppressGoAhead = 3;

  static const List<String> promptCharacters = <String>[
    '#',
    '>',
    '\$',
    '%',
  ];

  static const List<String> usernamePatterns = <String>[
    'login:',
    'login :',
    'username:',
    'username :',
    'user name:',
    'user name :',
    'user:',
    'user :',
    'account:',
    'account :',
    'user id:',
    'userid:',
  ];

  static const List<String> passwordPatterns = <String>[
    'password:',
    'password :',
    'passwd:',
    'passwd :',
    'pass:',
    'pass :',
    'pwd:',
    'pwd :',
  ];

  static const List<String> loginFailurePatterns = <String>[
    'incorrect username or password',
    'incorrect password',
    'login failed',
    'authentication failed',
    'authentication failure',
    'invalid username',
    'invalid password',
    'invalid user',
    'invalid login',
    'access denied',
    'bad password',
    'wrong password',
    'wrong username',
    'permission denied',
  ];
}
