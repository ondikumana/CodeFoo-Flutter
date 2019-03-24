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
  SocketIO socketIO;

  @override
  void initState() {
    _checkIfIsAlreadyConnected();
    super.initState();
  }

  _checkIfIsAlreadyConnected() async {
    bool isFriendConnected = widget.nodeConnection.getIsFriendConnected();
    print('is friend connected? $isFriendConnected');
    // delay otherwise it's created before build and it crashes
    await Future.delayed(const Duration(milliseconds: 10));
    if (isFriendConnected) {
      Navigator.pushReplacement(
          context,
          new MaterialPageRoute(
              builder: (context) => new Messages(widget.nodeConnection)));
    } else {
      _handleSocket();
    }
  }

  void _friendConnected(data) async {
    String userId = widget.nodeConnection.getUserId();

    if (data['type'] == 'friendConnected' &&
        data['creator_id'].toString() == userId &&
        data['friend_id'] != null) {
      widget.nodeConnection.setFriendId(data['friend_id'].toString());

      await manager.clearInstance(socketIO);

      Navigator.pushReplacement(
          context,
          new MaterialPageRoute(
              builder: (context) => new Messages(widget.nodeConnection)));
    }
  }

  void _handleSocket() async {
    String sessionId = widget.nodeConnection.getSessionId();
    String serverUrl = widget.nodeConnection.getServerUrl();

    manager = SocketIOManager();
    socketIO = await manager.createInstance('$serverUrl/');

    socketIO.on("$sessionId", _friendConnected);

    socketIO.onConnect((data) {
      print("connected...");
      // print(data);
    });
    // socketIO.onConnectError(pprint);
    // socketIO.onConnectTimeout(pprint);
    // socketIO.onError(pprint);
    // socketIO.onDisconnect(pprint);

    socketIO.connect();
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
