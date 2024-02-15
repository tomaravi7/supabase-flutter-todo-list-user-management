import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:user_manag/login.dart';
import 'package:user_manag/todolist.dart';
import './main.dart';

class UserPage extends StatefulWidget {
  const UserPage({super.key});

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  final User? user = supabase.auth.currentUser;
  String name = "";
  late String nameHead;
  String avatar = "";
  String website = "";
  late int mobile;
  bool loading = true;
  bool clicked = false;

  Future<void> signOutConfirm() async {
    setState(() {
      showAdaptiveDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('SignOut Confirmation'),
              content: Column(mainAxisSize: MainAxisSize.min, children: [
                const Text('Are you sure you want to sign out?'),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        signOut();
                      },
                      child: const Text('Sign Out'),
                    ),
                  ],
                ),
              ]),
            );
          });
    });
  }

  Future<void> signOut() async {
    try {
      Navigator.of(context).popUntil((route) => route.isFirst);
      await supabase.auth.signOut();
    } on AuthException catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.message),
          backgroundColor: Colors.red,
        ),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unexpected Error'),
        ),
      );
    } finally {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => const LoginPage()));
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
      mobile = (data['mobile'] ?? 0) as int;
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
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Profile Updated')));
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
                backgroundColor: Colors.black,
                bottomOpacity: 20,
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
                  Tooltip(
                    richMessage: const TextSpan(
                      text: 'Todo List',
                    ),
                    child: IconButton(
                        onPressed: () => Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const TodoPage())),
                        icon: const Icon(Icons.list)),
                  ),
                  Tooltip(
                    richMessage: const TextSpan(
                      text: 'Sign Out',
                    ),
                    child: IconButton(
                      onPressed: () {
                        signOutConfirm();
                      },
                      icon: const Icon(Icons.logout),
                    ),
                  ),
                ]),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Email ID: ${user!.email}'),
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
                    onChanged: (value) {
                      setState(() {
                        website = value;
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    initialValue: (mobile).toString(),
                    decoration:
                        const InputDecoration(labelText: "Mobile Number"),
                    onChanged: (value) {
                      setState(() {
                        mobile = int.tryParse(value) ?? 0;
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
