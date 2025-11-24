import 'package:flutter/material.dart';
import 'common/constants/constants.dart';
import 'features/dashboard/main_scaffold.dart';
import 'features/break_feature/views/break_screen.dart';

void main() {
     runApp(MyApp());
   }

   class MyApp extends StatelessWidget {
     @override
     Widget build(BuildContext context) {
       return MaterialApp(
         home: BreakScreen(), // Set sebagai home sementara
       );
     }
   }