import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import './splash.dart';

void main() async {
  await Supabase.initialize(
    url: 'https://bhasfzhuyhccroeprjux.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJoYXNmemh1eWhjY3JvZXByanV4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE2OTI2NzY1MDAsImV4cCI6MjAwODI1MjUwMH0.X4llboJVIiSMNwjGFbJdcEMhgt2HEuDvAdxCv4v1lWo',
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: MyHomePage(),
    );
  }
}
