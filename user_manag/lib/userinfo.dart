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
  late final String nameHead;
  String avatar = "";
  String website = "";
  String mobile = "";
  bool loading = true;
  bool clicked = false;

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
    try {
      if (user == null) {
        return;
      }
      final data =
          await supabase.from('profiles').select().eq('id', user!.id).single();
      name = (data['full_name'] ?? '') as String;
      nameHead = name;
      avatar = (data['avatar_url'] ?? '') as String;
      website = (data['website'] ?? '') as String;
      mobile = (data['mobile'] ?? '') as String;
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

  Future<void> updateUser() async {
    setState(() {
      loading = true;
    });
    final updates = {
      'id': user!.id,
      'full_name': name,
      'avatar_url': avatar,
      'website': website,
      'mobile': mobile,
    };
    try {
      await supabase.from('profiles').upsert(updates);
      if (mounted) {
        const SnackBar(content: Text('Profile Updated'));
      }
    } on PostgrestException catch (error) {
      SnackBar(content: Text(error.message));
    } catch (error) {
      const SnackBar(content: Text('Unexpected Error'));
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
                    CircleAvatar(
                      radius: 27,
                      backgroundImage: NetworkImage(avatar,
                          scale: 1.0, headers: <String, String>{}),
                    ),
                    Text('Welcome $nameHead')
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
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                      initialValue: name,
                      decoration: const InputDecoration(
                        labelText: 'Full Name',
                      ),
                      onChanged: (value) {
                        setState(() {
                          name = value;
                        });
                      }),
                  const SizedBox(height: 20),
                  TextFormField(
                    initialValue: avatar,
                    decoration: const InputDecoration(labelText: 'Avatar URL'),
                    onChanged: (value) {
                      setState(() {
                        avatar = value;
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    initialValue: website,
                    decoration: const InputDecoration(
                      labelText: "Website",
                    ),
                    onTap: () => {},
                    onChanged: (value) {
                      setState(() {
                        website = value;
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    initialValue: mobile,
                    decoration:
                        const InputDecoration(labelText: "Mobile Number"),
                    onTap: () => {},
                    onChanged: (value) {
                      setState(() {
                        mobile = value;
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: loading ? null : updateUser,
                    child: loading
                        ? const Row(
                            children: [
                              CircularProgressIndicator(),
                              SizedBox(width: 10),
                              Text('Updating...'),
                            ],
                          )
                        : const Text('Update Info'),
                  ),
                ],
              ),
            ));
  }
}
