import 'package:flutter/material.dart';
import 'package:kaiquecortes/auth.dart';
import 'package:kaiquecortes/root_page.dart';


void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Kaique Cortes',
      debugShowCheckedModeBanner: false,
      theme: new ThemeData(
        primaryColor: Colors.black,
      ),
      //home: HomePageUser(auth: new Auth()),
      home: new RootPage(auth: new Auth()),
    );
  }
}