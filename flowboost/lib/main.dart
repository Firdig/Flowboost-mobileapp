import 'package:flutter/material.dart';
import 'common/constants/constants.dart';
import 'features/dashboard/main_scaffold.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
      home: const MainScaffold(),
    );
  }
}