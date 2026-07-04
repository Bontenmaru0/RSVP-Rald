import 'package:flutter/material.dart';

import 'features/home/presentation/home_page.dart';
import 'theme/app_theme.dart';

class WeddingRsvpApp extends StatelessWidget {
  const WeddingRsvpApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Gerald and Mervielynn RSVP',
      theme: AppTheme.light(),
      home: const HomePage(),
    );
  }
}
