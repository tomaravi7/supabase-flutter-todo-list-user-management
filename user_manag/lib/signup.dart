import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:user_manag/login.dart';
import 'package:user_manag/main.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  late String userEmail = '';
  late String userPassword = '';
  late String userFullName = '';
  late String userAvatar = '';
  bool isloading = false;
  bool redirecting = false;
  bool hasError = false;
  late final StreamSubscription<AuthState> authStateSub;
  Future<void> signUp() async {
    try {
      setState(() {
        isloading = true;
      });
      if (userEmail.isEmpty || userPassword.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Enter email and password")));
        return;
      }
      final AuthResponse res = await supabase.auth
          .signUp(email: userEmail, password: userPassword, data: {
        'full_name': userFullName,
        'avatar_url': userAvatar,
        
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Signed Up as ${res.user!.email}')));
        if (res.user != null) {
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => const LoginPage()));
        }
      }
    } on AuthException catch (err) {
      setState(() {
        hasError = true;
        isloading = false;
      });
      SnackBar(content: Text(err.message));
    } finally {
      setState(() {
        isloading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(title: const Text('Sign Up')),
      body: SingleChildScrollView(
        child: Column(
            children: [
          TextField(
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                labelText: 'Email',
                errorText: hasError ? 'Invalid Input' : null,
              ),
              onChanged: (value) => setState(() {
                    userEmail = value;
                  })),
          TextField(
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                labelText: 'Password',
                errorText: hasError ? 'Invalid Input' : null,
              ),
              onChanged: (value) => setState(() {
                    userPassword = value;
                  })),
          TextField(
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Enter Full Name',
              ),
              onChanged: (val) => setState(() {
                    userFullName = val;
                  })),
          TextField(
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Enter Avatar URL',
              ),
              onChanged: (value) => setState(() {
                    userAvatar = value;
                  })),
          ElevatedButton(
            onPressed: isloading ? null : signUp,
            child: isloading
                ? const CircularProgressIndicator()
                : const Text('Register'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => const LoginPage()));
            },
            child: const Text('Login Instead?'),
          ),
        ]
                .map((e) => Padding(
                      padding: const EdgeInsets.all(16),
                      child: e,
                    ))
                .toList()),
      ),
    );
  }
}
