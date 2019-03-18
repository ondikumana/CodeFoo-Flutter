import 'package:flutter/material.dart';
import '../node_connection.dart';
import '../WaitingToConnect/waiting_to_connect.dart';

class Messages extends StatefulWidget {
  final NodeConnection nodeConnection;

  Messages(this.nodeConnection);

  @override
  _MessagesState createState() => _MessagesState();
}

class _MessagesState extends State<Messages> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Messages'),
        ),
        body: Container(
          color: Color.fromARGB(255, 43, 66, 81),
          child: Center(
              child: Column(
            children: <Widget>[],
          )),
        ));
  }
}
