import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'providers/place_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home/home_screen.dart';
import 'splash/splash_screen.dart'; // Pastikan path ini sesuai

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => PlaceProvider(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Cloud Computing',
        theme: ThemeData(
          primaryColor: const Color(0xFF185FA5),
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF185FA5),
            primary: const Color(0xFF185FA5),
          ),
          useMaterial3: true,
        ),
        // 1. Jadikan SplashScreen sebagai rute utama saat aplikasi pertama kali dijalankan
        home: const SplashScreen(),
      ),
    );
  }
}

// 2. Buat widget khusus untuk membungkus StreamBuilder pemantau sesi Firebase Anda
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Jika Firebase masih memeriksa sesi
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        // Jika terdeteksi ada user yang sedang login
        if (snapshot.hasData) {
          return const HomeScreen();
        }
        // Jika tidak ada user (belum login atau sudah logout)
        return const LoginScreen();
      },
    );
  }
}