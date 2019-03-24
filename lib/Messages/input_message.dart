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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3.0, vertical: 8.0),
      child: Flex(
        direction: Axis.horizontal,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Container(
            width: MediaQuery.of(context).size.width * 0.77,
            child: TextField(
              controller: inputController,
            ),
          ),
          FlatButton(
            
            child: sendingMessage ? CircularProgressIndicator() : Text('Send'),
            onPressed: _sendMessage,
          )
        ],
      ),
    );
  }
}
