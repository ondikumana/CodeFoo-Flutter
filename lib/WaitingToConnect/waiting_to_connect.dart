import 'package:flutter/material.dart';
import '../node_connection.dart';

class WaitingToConnect extends StatefulWidget {
  final NodeConnection nodeConnection;

  WaitingToConnect(this.nodeConnection);

  @override
  _WaitingToConnectState createState() => _WaitingToConnectState();
}

class _WaitingToConnectState extends State<WaitingToConnect> {
  // @override
  // void initState() {
  //   _checkIfAlreadyGivenName();
  //   super.initState();
  // }

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
                  style: Theme.of(context).textTheme.title,
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
