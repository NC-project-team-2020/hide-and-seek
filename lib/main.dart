import 'package:flutter/material.dart';
import 'pages/HomePage.dart';
import 'pages/Register.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Peekaboo',
      initialRoute: '/',
      routes: {
        '/': (context) => HomePage(),
        '/register': (context) => Register(),
      },
    );
  }
}
