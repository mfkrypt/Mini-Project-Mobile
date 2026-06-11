import 'package:flutter/material.dart';

import 'pages/exhibition_list_page.dart';
import 'utils/app_route_observer.dart';

void main() {
  runApp(const ExhibitionApp());
}

class ExhibitionApp extends StatelessWidget {
  const ExhibitionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Exhibition App',
      navigatorObservers: [appRouteObserver],
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.black),
        fontFamily: 'Arial',
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const ExhibitionListPage(),
    );
  }
}
