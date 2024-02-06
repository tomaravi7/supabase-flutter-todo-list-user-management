import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:user_manag/main.dart';
import './userinfo.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late String userEmail;
  late String userPassword;
  bool isloading = false;
  bool redirecting = false;
  late final StreamSubscription<AuthState> authStateSub;

  Future<void> signIn() async {
    try {
      setState(() {
        isloading = true;
      });
      if (userEmail.isEmpty || userPassword.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Email and password are required'),
          ),
        );
        return;
      }
      final AuthResponse res = await supabase.auth.signInWithPassword(
        email: userEmail,
        password: userPassword,
      );
      final User? user = res.user;
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Signed in as ${user!.email}'),
          ),
        );
      }
    } on AuthException catch (err) {
      setState(() {
        isloading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(err.message),
        ),
      );
    } finally {
      setState(() {
        isloading = false;
      });
    }
  }

  @override
  void initState() {
    authStateSub = supabase.auth.onAuthStateChange.listen((data) {
      if (redirecting) return;
      final session = data.session;
      if (session != null) {
        redirecting = true;
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => const UserPage()));
      }
    });
    super.initState();
  }

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
              onChanged: (value) => userEmail = value,
            ),
            // const SizedBox(height: 10),
            TextField(
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Password',
              ),
              onChanged: (value) => userPassword = value,
            ),
            ElevatedButton(
              onPressed: isloading ? null : signIn,
              child: Text(isloading ? 'Loading' : 'Login'),
            ),
          ]
              .map((e) => Padding(padding: const EdgeInsets.all(16), child: e))
              .toList(),
        )));
  }
}
