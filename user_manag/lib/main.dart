import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import './splash.dart';
import './color_scheme.dart';

void main() async {
  await Supabase.initialize(
    url: 'https://bhasfzhuyhccroeprjux.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJoYXNmemh1eWhjY3JvZXByanV4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE2OTI2NzY1MDAsImV4cCI6MjAwODI1MjUwMH0.X4llboJVIiSMNwjGFbJdcEMhgt2HEuDvAdxCv4v1lWo',
  );
  runApp(const MyApp());
}

final SupabaseClient supabase = Supabase.instance.client;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: darkColorScheme,
        textTheme: TextTheme(
          displayLarge: const TextStyle(
            fontSize: 72,
            fontWeight: FontWeight.bold,
          ),
          titleLarge: GoogleFonts.oswald(
            fontSize: 30,
            fontStyle: FontStyle.italic,
          ),
          bodyMedium: GoogleFonts.merriweather(),
          displaySmall: GoogleFonts.pacifico(),
        ),
        // pageTransitionsTheme: PageTransitionsTheme(builders: {
        //   TargetPlatform.android: CupertinoPageTransitionsBuilder(),
        // })
      ),
      home: const MyHomePage(),
    );
  }
}
