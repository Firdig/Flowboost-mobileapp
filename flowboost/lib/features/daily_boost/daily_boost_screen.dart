import 'package:flutter/material.dart';
import '../../common/constants/constants.dart';

class DailyBoostScreen extends StatelessWidget {
  const DailyBoostScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Daily Boost"), leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context))),
      body: const Center(child: Text("Coming Soon", style: TextStyle(fontSize: 18, color: kTextColor))),
    );
  }
}