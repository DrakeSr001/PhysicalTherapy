import 'package:flutter/material.dart';
// import 'screens/login_screen.dart';
// import 'screens/kiosk_screen.dart';
// import 'screens/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Attendance System',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      // Instead of hardcoding Scaffold here, just point to a start page:
      initialRoute: '/login',
      // routes: {
      //   '/login': (context) => const LoginScreen(),
      //   '/home': (context) => const HomeScreen(),
      //   '/kiosk': (context) => const KioskScreen(),
      // },
    );
  }
}
