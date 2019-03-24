import 'package:flutter/material.dart';
import '../node_connection.dart';

class Message extends StatelessWidget {
  final Map message;
  final NodeConnection nodeConnection;

  Message(this.message, this.nodeConnection);

  @override
  Widget build(BuildContext context) {
    String senderId = message['sender_id'].toString();
    String senderName = nodeConnection.getSenderName(senderId);

    String userId = nodeConnection.getUserId();
    bool isSender = userId == senderId;

    return Container(
        margin: const EdgeInsets.symmetric(vertical: 18.0, horizontal: 10.0),
        child: new Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment:
              isSender ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: <Widget>[
            new Container(
              margin: const EdgeInsets.only(right: 16.0),
              child: new CircleAvatar(
                child: new Image.network(
                    'https://ui-avatars.com/api/?rounded=true&length=1&name=${senderName}'),
              ),
            ),
            new Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                new Text(
                  senderName ?? 'Friend',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                new Container(
                  constraints: BoxConstraints.loose(
                      Size(MediaQuery.of(context).size.width * 0.65, 20)),
                  margin: const EdgeInsets.only(top: 5.0),
                  child: new Text(message['body']),
                )
              ],
            )
          ],
        ));
  }
}
