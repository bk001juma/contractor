import 'package:contractor/app/routes/app_route.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Contractor',
      debugShowCheckedModeBanner: false,

      // Initial route
      initialRoute: AppRoutes.initial,

      // GetX pages
      getPages: AppRoutes.pages,

      // Theme aligned with your UI
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.white,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.orange,
          primary: Colors.orange,
        ),
      ),

      // Fallback for unknown routes
      unknownRoute: GetPage(
        name: '/not-found',
        page: () => const Scaffold(body: Center(child: Text('Page not found'))),
      ),
    );
  }
}
