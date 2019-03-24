import 'package:flutter/material.dart';
import '../node_connection.dart';

class InputMessage extends StatefulWidget {
  final NodeConnection nodeConnection;

  InputMessage(this.nodeConnection);
  @override
  _InputMessageState createState() => _InputMessageState();
}

class _InputMessageState extends State<InputMessage> {
  final inputController = TextEditingController();
  bool sendingMessage = false;
  bool errorSendingMessage = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    // Clean up the controller when the Widget is removed from the Widget tree
    // This also removes the _printLatestValue listener
    inputController.dispose();
    super.dispose();
  }

  // _printLatestValue() {
  //   print("Second text field: ${inputController.text}");
  // }

  void _sendMessage() async {
    if (inputController.text.trim() == '' || sendingMessage) return;

    setState(() {
      sendingMessage = true;
      errorSendingMessage = false;
    });

    bool messageWasSent =
        await widget.nodeConnection.sendMessage(inputController.text, 'text');

    if (messageWasSent) {
      setState(() {
        sendingMessage = false;
        errorSendingMessage = false;
      });
      inputController.clear();
    } else {
      setState(() {
        sendingMessage = false;
        errorSendingMessage = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      color: Color.fromARGB(255, 43, 66, 81),
      child: new Row(
        children: <Widget>[
          new Flexible(
            child: new TextField(
              style: TextStyle(color: Colors.white),
              decoration:
                  new InputDecoration.collapsed(hintText: "Enter message ..."),
              controller: inputController,
              onSubmitted: (String val) => _sendMessage,
            ),
          ),
          new Container(
            margin: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 5.0),
            child: new IconButton(
              icon:
                  new Icon(Icons.send, color: Colors.white),
              onPressed: _sendMessage,
            ),
          )
        ],
      ),
    );
  }
}
