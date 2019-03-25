import 'package:flutter/material.dart';

import './Welcome/welcome.dart';
import './EnterCode/enter_code.dart';

import './node_connection.dart';

void main() {
  // debugPaintSizeEnabled =true;
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  MyApp({Key key}) : super(key: key);

  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  NodeConnection nodeConnection = new NodeConnection();

  // @override
  // void initState() {
  //   nodeConnection.getAttributesFromSharedPreferences();
  //   super.initState();
  // }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
          fontFamily: 'Raleway',
          primarySwatch: Colors.grey,
          hintColor: Colors.white70,
          textTheme: TextTheme(
              body1: TextStyle(color: Colors.white),
              body2: TextStyle(color: Colors.white),
              title: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 32,
                  color: Colors.white),
              overline: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 50,
                  color: Colors.white),
              subtitle: TextStyle(
                  fontStyle: FontStyle.italic,
                  fontSize: 15,
                  color: Colors.grey),
              button:
                  TextStyle(fontWeight: FontWeight.bold, color: Colors.white))),
      home: Welcome(nodeConnection),
    );
  }
}
