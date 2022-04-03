import 'package:flutter/material.dart';
import 'package:flutter_contactlist/homepage.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Contact List',
      theme: ThemeData(
        primaryColor: Colors.greenAccent,
        scaffoldBackgroundColor: Color.fromARGB(255, 1, 86, 132),
      ),
      home: const Homepage(),
    );
  }
}
