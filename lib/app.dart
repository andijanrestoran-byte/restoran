import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';

part 'models/restaurant_models.dart';
part 'services/restaurant_api_client.dart';
part 'screens/restaurant_home_page.dart';
part 'screens/auth_screen.dart';
part 'screens/waiter_screens.dart';
part 'screens/director_screens.dart';
part 'widgets/common_widgets.dart';

const backendApiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'https://kassa-production.up.railway.app/api',
);

class AndijanFlutterApp extends StatelessWidget {
  const AndijanFlutterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DASTURXON',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF8A4B2A),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF7F1E8),
      ),
      home: const RestaurantHomePage(),
    );
  }
}
