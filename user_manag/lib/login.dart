import 'package:flutter/material.dart';
import './userinfo.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('User management')),
        body: Center(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Welcome to Supabase Flutter'),
            // const SizedBox(height: 10),
            TextField(
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Email',
              ),
            ),
            // const SizedBox(height: 10),
            TextField(
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Password',
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                    context, //replacement because we dont want user to go back to login page after they have logged in
                    MaterialPageRoute(builder: (context) => const UserPage()));
              },
              child: const Text('Login'),
            ),
          ]
              .map((e) => Padding(padding: const EdgeInsets.all(16), child: e))
              .toList(),
        )));
  }
}
