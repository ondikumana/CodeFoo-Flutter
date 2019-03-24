import 'package:flutter/material.dart';

class Message extends StatelessWidget {
  final Map message;

  Message(this.message);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          Text(message['body'])
        ],
      ),
    );
  }
}