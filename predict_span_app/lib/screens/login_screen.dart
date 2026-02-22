import 'package:flutter/material.dart';
import 'package:predict_span_app/Authentication.dart';
import 'package:predict_span_app/BackgroundService.dart';
import 'package:predict_span_app/local_notification_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _loading = false;

  Future<void> _handleGoogleSignIn() async {
    setState(() => _loading = true);

    try {
      final account = await signIn();

      if (account == null) {
        _showError('Falha no login');
        return;
      }

      await LocalNotificationService.requestPermissions();
      await registerEmailCheckTask();

      if (mounted) {
        Navigator.pushReplacementNamed(context, '/analysis');
      }
    } catch (e) {
      _showError(e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: _loading ? null : _handleGoogleSignIn,
          child: _loading
              ? const CircularProgressIndicator()
              : const Text('Entrar com Google'),
        ),
      ),
    );
  }
}