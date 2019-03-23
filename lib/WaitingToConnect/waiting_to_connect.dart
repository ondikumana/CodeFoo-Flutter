import 'dart:convert';

import 'package:flutter/material.dart';
// import 'package:flutter_socket_io/socket_io_manager.dart';
import '../node_connection.dart';
import '../Messages/messages.dart';

import 'package:adhara_socket_io/adhara_socket_io.dart';

class WaitingToConnect extends StatefulWidget {
  final NodeConnection nodeConnection;

  WaitingToConnect(this.nodeConnection);

  @override
  _WaitingToConnectState createState() => _WaitingToConnectState();
}

class _WaitingToConnectState extends State<WaitingToConnect> {
  SocketIOManager manager;
  SocketIO _socketIO;

  @override
  void initState() {
    _handleSocket();

    super.initState();
  }

  void _friendConnected(data) {

    print('friendConnected Data $data');

    String userId = widget.nodeConnection.getUserId();
    // Map<String, dynamic> message = json.decode(data);

    // print('decoded message $message');

    if (data['type'] == 'friendConnected' &&
        data['creator_id'].toString() == userId &&
        data['friend_id'] != null) {
      Navigator.push(
          context,
          new MaterialPageRoute(
              builder: (context) => new Messages(widget.nodeConnection)));
    }
  }

  void _handleSocket() async {
    String sessionId = widget.nodeConnection.getSessionId();
    String serverUrl = widget.nodeConnection.getServerUrl();

    manager = SocketIOManager();
    _socketIO = await manager.createInstance('$serverUrl/');

    _socketIO.on("$sessionId", _friendConnected);

    _socketIO.onConnect((data) {
      print("connected...");
      // print(data);
    });
    // _socketIO.onConnectError(pprint);
    // _socketIO.onConnectTimeout(pprint);
    // _socketIO.onError(pprint);
    // _socketIO.onDisconnect(pprint);

    _socketIO.connect();
  }

  void pprint(data) {
    print(data);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
      color: Color.fromARGB(255, 43, 66, 81),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
                margin: EdgeInsets.symmetric(horizontal: 35.0, vertical: 5.0),
                child: Text(
                  widget.nodeConnection.getCode(),
                  style: Theme.of(context).textTheme.overline,
                )),
            Container(
                margin: EdgeInsets.symmetric(horizontal: 35.0, vertical: 5.0),
                child: Text(
                  'Waiting for friend to connect...',
                  style: Theme.of(context).textTheme.subtitle,
                ))
          ],
        ),
      ),
    ));
  }
}
