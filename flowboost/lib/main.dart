import 'package:flutter/material.dart';
import 'common/constants/constants.dart';
import 'package:provider/provider.dart';
import 'features/dashboard/main_scaffold.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'features/authentication/register/views/register.dart';
import 'features/authentication/login/views/login.dart';
import 'features/Pomodoro/provider/pomodoro_provider.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
 Widget build(BuildContext context) {
    // ✅ BUNGKUS DENGAN MULTIPROVIDER DI SINI
   return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PomodoroProvider()),
        // Anda juga bisa mendaftarkan AuthService sebagai provider jika diperlukan
        Provider(create: (_) => AuthService()),
      ],
      child: MaterialApp(
        title: 'Flowboost',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          scaffoldBackgroundColor: kBackgroundColor,
          appBarTheme: const AppBarTheme(
            backgroundColor: kAppBarColor,
            foregroundColor: kTextColor,
            elevation: 0,
            centerTitle: true,
            titleTextStyle: TextStyle(color: kTextColor, fontSize: 24, fontWeight: FontWeight.w500),
            iconTheme: IconThemeData(color: kTextColor),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade400)),
          ),
        ),
        // PERBAIKAN: Gunakan StreamBuilder untuk mengecek status login
        home: StreamBuilder<User?>(
          stream: AuthService().authStateChanges(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              // Tampilan Loading yang sesuai tema
              return Scaffold(
                backgroundColor: const Color.fromARGB(248, 250, 232, 197), // Gunakan warna krem
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Tampilkan Logo Aplikasi
                      Image.asset(
                        'assets/images/flowboost_logo4.png',
                        width: 150,
                      ),
                      const SizedBox(height: 200),
                      // Loading indicator dengan warna hijau sage
                      const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(kAppBarColor),
                      ),
                    ],
                  ),
                ),
              );
            }
            
            if (snapshot.hasData) {
              return const MainScaffold();
            }
            
            return const FlowboostLoginScreen();
          },
        ),
      ),
    );
  }
}