import 'package:flutter/material.dart';
import 'home_page.dart';
import '../main.dart';
import 'account_creation.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  //testing login
  final String _validEmail = 'test';
  final String _validPassword = 'test';

  void _login() {
    if (_formKey.currentState!.validate()) {
      String email = _emailController.text.trim();
      String password = _passwordController.text.trim();

      if (email == _validEmail && password == _validPassword) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MainPage()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid email or password')),
        );
      }
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

              //username entry
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Username or Email',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                value == null || value.isEmpty ? 'Enter your email or username' : null,
              ),
              const SizedBox(height: 16),

              //password entry
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                validator: (value) =>
                value == null || value.isEmpty ? 'Enter your password' : null,
              ),
              const SizedBox(height: 24),

              //submission button
              ElevatedButton(
                onPressed: _login,
                child: const Text('Submit'),
              ),
              const SizedBox(height: 16),

              //button to send to account creation
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


