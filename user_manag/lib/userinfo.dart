import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:user_manag/login.dart';
import './main.dart';

class UserPage extends StatefulWidget {
  const UserPage({super.key});

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  final User? user = supabase.auth.currentUser;
  String name = "";

  bool loading = true;

  Future<void> signOut() async {
    try {
      await supabase.auth.signOut();
    } on AuthException catch (error) {
      SnackBar(
        content: Text(error.message),
        backgroundColor: Colors.red,
      );
    } catch (error) {
      const SnackBar(
        content: Text('Unexpected Error'),
      );
    } finally {
      if (mounted) {
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => const LoginPage()));
      }
    }
  }

  Future<void> getUserData() async {
    loading = true;
    final User? user = supabase.auth.currentUser;
    try {
      if (user == null) {
        return;
      }
      final data =
          await supabase.from('profiles').select().eq('id', user.id).single();
      name = (data['full_name'] ?? '') as String;
    } on PostgrestException catch (err) {
      SnackBar(
        content: Text(err.message),
      );
    } finally {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    getUserData();
  }

  @override
  Widget build(BuildContext context) {
    return loading
        ? const Center(
            child: CircularProgressIndicator.adaptive(),
          )
        : Scaffold(
            appBar: AppBar(
                title: Row(
                  children: [
                    const CircleAvatar(
                      radius: 50,
                      backgroundImage: NetworkImage(
                          'https://th.bing.com/th/id/OIP.wBMp4cKdcuUYNQpa332M1QHaHl?rs=1&pid=ImgDetMain'),
                    ),
                    Text('Welcome $name')
                  ],
                ),
                actions: <Widget>[
                  IconButton(
                    icon: const Icon(Icons.logout),
                    onPressed: () {
                      signOut();
                    },
                  )
                ]),
            body: const Center(
              child: Text('User information'),
            ),
          );
  }
}
