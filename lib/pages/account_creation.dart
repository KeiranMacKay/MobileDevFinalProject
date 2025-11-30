import 'package:flutter/material.dart';

class AccountCreationPage extends StatefulWidget {
  const AccountCreationPage({super.key});

  @override
  State<AccountCreationPage> createState() => _AccountCreationPageState();
}

class _AccountCreationPageState extends State<AccountCreationPage> {
  final _formKey = GlobalKey<FormState>();

  //text field controllers
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  //add people to account, starts with 2
  final List<TextEditingController> _personControllers = [
    TextEditingController(),
    TextEditingController(),
  ];

  void _addPersonField() {
    if (_personControllers.length < 6) {
      setState(() {
        _personControllers.add(TextEditingController());
      });
    }
  }

  void _createAccount() {
    if (_formKey.currentState!.validate()) {

      //doesnt do anything at the moment, needs to be hooked up to backend
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Account created successfully!')),
      );

      //return to login screen
      Future.delayed(const Duration(seconds: 1), () {
        Navigator.pop(context);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Account'),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 30),

              //add email
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                //checking for valid email by watching for @
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Enter your email';
                  } else if (!value.contains('@')) {
                    return 'Enter a valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              //add username
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                value == null || value.isEmpty ? 'Enter your username' : null,
              ),
              const SizedBox(height: 16),

              //add password
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                value == null || value.isEmpty ? 'Enter your password' : null,
              ),
              const SizedBox(height: 16),

              //add new person entry field, then move button down, MAX:6
              Column(
                children: [
                  for (int i = 0; i < _personControllers.length; i++)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: TextFormField(
                        controller: _personControllers[i],
                        decoration: InputDecoration(
                          labelText: 'Person ${i + 1} Name',
                          border: const OutlineInputBorder(),
                        ),
                        validator: (value) =>
                        value == null || value.isEmpty
                            ? 'Enter Person ${i + 1} name'
                            : null,
                      ),
                    ),

                  if (_personControllers.length < 6)
                    TextButton(
                      onPressed: _addPersonField,
                      child: const Text("Add Person"),
                    ),
                ],
              ),

              const SizedBox(height: 30),

              ElevatedButton(
                onPressed: _createAccount,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text(
                  'Create Account',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    for (var controller in _personControllers) {
      controller.dispose();
    }
    super.dispose();
  }
}
