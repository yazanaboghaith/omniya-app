import 'dart:io';

import 'package:flutter/material.dart';
import 'package:omniya/l10n/app_localizations.dart';
import 'package:omniya/view/auth/services/auth_storage.dart';
import 'package:omniya/view/home/home.dart';

class PinScreen extends StatefulWidget {
  const PinScreen({super.key});

  @override
  State<PinScreen> createState() => _PinScreenState();
}

class _PinScreenState extends State<PinScreen> {
  final TextEditingController pinController = TextEditingController();
  final AuthStorage storage = AuthStorage();

  String error = "";
  bool isLoading = false;

  Future<void> checkPin() async {
    setState(() {
      error = "";
      isLoading = true;
    });

    final hasInternet = await _hasInternet();

    if (!hasInternet) {
      setState(() {
        isLoading = false;
        error = AppLocalizations.of(context)!.no_Internet;
      });
      return;
    }

    String? savedPin = await storage.storage.read(key: "user_pin");

    await Future.delayed(const Duration(milliseconds: 500));

    if (pinController.text == savedPin) {
      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const Home()),
        (route) => false,
      );
    } else {
      setState(() {
        error = AppLocalizations.of(context)!.invalid_code;
        isLoading = false;
        pinController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock_outline, size: 80, color: Colors.blueGrey),
              const SizedBox(height: 20),
              Text(
                AppLocalizations.of(context)!.enter_pin,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 30),
              TextField(
                controller: pinController,
                keyboardType: TextInputType.number,
                obscureText: true,
                maxLength: 4,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 24, letterSpacing: 8),
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  hintText: "****",
                  counterText: "",
                ),
                onChanged: (value) {
                  if (error.isNotEmpty) setState(() => error = "");
                },
              ),
              const SizedBox(height: 15),
              if (error.isNotEmpty)
                Text(
                  error,
                  style: TextStyle(
                    color: Colors.red.withValues(alpha: 0.6),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: isLoading ? null : checkPin,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(AppLocalizations.of(context)!.login,
                          style: TextStyle(fontSize: 18)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> _hasInternet() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException {
      return false;
    }
  }
}
