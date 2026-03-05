import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // ⚡ NEW: Supabase import

import 'auth/login_screen.dart';
// ✨ FIX: We import main_navigation here instead of home_screen!
import 'discovery/main_navigation.dart';
import 'features/onboarding/onboarding_screen.dart'; 

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // ⚡ NEW: Initialize Supabase instead of Firebase
  await Supabase.initialize(
    url: 'https://diynsibfbcemkzmzjhqr.supabase.co', // 👈 Paste your Project URL here
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImRpeW5zaWJmYmNlbWt6bXpqaHFyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzIyMDI5OTgsImV4cCI6MjA4Nzc3ODk5OH0.fCdNpiF_DopYJ4SImkEzY8O3j10P2erO_boaLkeGYY4', // 👈 Paste your Anon Key here
  );

  runApp(const FirstDateApp());
}

class FirstDateApp extends StatelessWidget {
  const FirstDateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'First Date',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFFF4081)),
        useMaterial3: true,
      ),
      routerConfig: _router,
    );
  }
}

final GoRouter _router = GoRouter(
  initialLocation: '/home', // Keeping it on Home for testing the swiper
  routes: [
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => const MainNavigation(), // ✨ Uses our new Root Layout!
    ),
  ],
);