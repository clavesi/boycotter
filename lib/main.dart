import 'package:flutter/material.dart';
import 'brand_cards.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Boycotter',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: BrandCards(),
      debugShowCheckedModeBanner: false,
    );
  }
}
