import 'package:flutter/material.dart';

import 'router.dart';
import 'theme.dart';

class JualBeliApp extends StatelessWidget {
  const JualBeliApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'JualBeli',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: AppRouter.router,
    );
  }
}