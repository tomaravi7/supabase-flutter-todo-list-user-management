import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:user_manag/main.dart';
import './userinfo.dart';
import './signup.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late String userEmail = '';
  late String userPassword = '';
  bool isloading = false;
  bool redirecting = false;
  late final StreamSubscription<AuthState> authStateSub;
  bool obscure = true;
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
      final Session? session = res.session;
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
        appBar: AppBar(
          title: const Text('User management',
              style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.w500,
                  decorationStyle: TextDecorationStyle.solid,
                  decoration: TextDecoration.underline)),
          // add a bottom border to the app bar
        ),
        body: SingleChildScrollView(
            child: Column(
          children: [
            const Align(
                alignment: Alignment.topLeft,
                child: Text('Welcome to Supabase Flutter',
                    style: TextStyle(
                      fontSize: 24,
                    ))),
            const SizedBox(height: 7),
            const Text(
              'SignIn',
              style: TextStyle(fontSize: 24),
            ),
            TextField(
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Email',
              ),
              onChanged: (value) => userEmail = value,
            ),
            TextFormField(
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Password',
                hintText: 'Enter your password',
              ),
              onChanged: (value) => userPassword = value,
            ),
            ElevatedButton(
              onPressed: isloading ? null : signIn,
              child: Text(isloading ? 'Loading' : 'Login'),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const SignUpPage()));
              },
              child: const Text('Create an account'),
            ),
          ]
              .map((e) => Padding(padding: const EdgeInsets.all(16), child: e))
              .toList(),
        )));
  }
}
