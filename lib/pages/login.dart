import 'package:flutter/material.dart';
import '../main.dart';
import 'account_creation.dart';
import 'package:finalproject/notifications.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  void _login() {
    if (_formKey.currentState!.validate()) {
      final email = _emailController.text.trim();

      // Simple "student project" login: any non-empty credentials are accepted
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Welcome, $email!'),
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
        ),
      );

      // Delay navigation slightly so the snackbar can appear first
      Future.delayed(const Duration(milliseconds: 500), () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MainPage()),
        );
      });
    }
  }

  void _goToAccountCreation() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AccountCreationPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(height: 50),

              // username entry
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Username or Email',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value == null || value.isEmpty
                        ? 'Enter your email or username'
                        : null,
              ),
              const SizedBox(height: 16),

              // password entry
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                validator: (value) =>
                    value == null || value.isEmpty
                        ? 'Enter your password'
                        : null,
              ),
              const SizedBox(height: 24),

              // submission button
              ElevatedButton(
                onPressed: () async {
                  // Try to show a notification, but don't break login if it fails
                  try {
                    await Notifications().showNoti(
                      title: 'Login',
                      body: 'You have logged in successfully',
                    );
                  } catch (e) {
                    debugPrint('Notification error: $e');
                  }

                  _login();
                },
                child: const Text('Submit'),
              ),
              const SizedBox(height: 16),

              // button to send to account creation
              TextButton(
                onPressed: _goToAccountCreation,
                child: const Text(
                  'Create Account',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
