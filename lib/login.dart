import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:my_docs/home_page.dart';
import 'image_strings.dart';

class LoginApp extends StatefulWidget {
  const LoginApp({super.key});

  @override
  State<LoginApp> createState() => _LoginAppState();
}

class _LoginAppState extends State<LoginApp> {
  final LocalAuthentication auth = LocalAuthentication();
  _SupportState _supportState = _SupportState.unknown;
  bool? _canCheckBiometrics;
  List<BiometricType>? _availableBiometrics;
  String _authorized = 'Not Authorized';
  bool _isAuthenticating = false;

  @override
  void initState() {
    super.initState();
    _checkDeviceSupport();
    _checkBiometrics();
    _getAvailableBiometrics();
  }

  Future<void> _checkDeviceSupport() async {
    bool isSupported = await auth.isDeviceSupported();
    setState(() {
      _supportState = isSupported ? _SupportState.supported : _SupportState.unsupported;
    });
  }

  Future<void> _checkBiometrics() async {
    try {
      _canCheckBiometrics = await auth.canCheckBiometrics;
    } on PlatformException catch (e) {
      _canCheckBiometrics = false;
      print(e);
    }
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _getAvailableBiometrics() async {
    try {
      _availableBiometrics = await auth.getAvailableBiometrics();
    } on PlatformException catch (e) {
      _availableBiometrics = <BiometricType>[];
      print(e);
    }
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _authenticate() async {
    bool authenticated = false;
    try {
      setState(() {
        _isAuthenticating = true;
        _authorized = 'Authenticating';
      });
      authenticated = await auth.authenticate(
        localizedReason: 'Let OS determine authentication method',
        options: const AuthenticationOptions(stickyAuth: true),
      );
      setState(() {
        _isAuthenticating = false;
      });
    } on PlatformException catch (e) {
      setState(() {
        _isAuthenticating = false;
        _authorized = 'Error - ${e.message}';
      });
      _showErrorDialog(e.message);
      return;
    }

    setState(() => _authorized = authenticated ? 'Authorized' : 'Not Authorized');

    if (authenticated) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MyHomePage(title: "My Documents")),
      );
    }
  }

  void _showErrorDialog(String? message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message ?? 'An unknown error occurred.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage(tLoginHome),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Column to align button at the bottom
          Column(
            mainAxisAlignment: MainAxisAlignment.end, // Align items to the bottom
            children: [
              Padding( // Add padding for better spacing
                padding: const EdgeInsets.all(16.0), // Padding around the button
                child: SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white, backgroundColor: Colors.red, // Text color
                      elevation: 5, // Optional: elevation of the button
                    ),
                    onPressed: _isAuthenticating ? null : _authenticate,
                    child: _isAuthenticating
                        ? const CircularProgressIndicator() // Show loading indicator when authenticating
                        : const Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text('Login with Biometric ', style: TextStyle(fontSize: 18)),
                        Icon(Icons.fingerprint),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }


}

enum _SupportState {
  unknown,
  supported,
  unsupported,
}
