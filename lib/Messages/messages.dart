import 'package:adhara_socket_io/adhara_socket_io.dart';
import 'package:flutter/material.dart';
import '../node_connection.dart';
import './message.dart';
import './input_message.dart';
import '../Welcome/welcome.dart';

class Messages extends StatefulWidget {
  final NodeConnection nodeConnection;

  Messages(this.nodeConnection);

  @override
  _MessagesState createState() => _MessagesState();
}

class _MessagesState extends State<Messages> {
  SocketIOManager manager;
  SocketIO socketIO;
  String sessionId;
  List messages = [];

  bool endingConversation = false;
  bool errorEndingConversation = false;
  bool confirmEndConversation = false;

  @override
  void initState() {
    sessionId = widget.nodeConnection.getSessionId();

    _fetchInitialMessages();
    _handleSocket();

    super.initState();
  }

  void _handleEvent(data) async {
    if (data['type'] == 'newMessage' &&
        data['session_id'].toString() == sessionId) {
      setState(() {
        messages.add(data);
      });
      // _sortMessages();
    }
    if (data['type'] == 'deletedSession' &&
        data['session_id'].toString() == sessionId) {
      await widget.nodeConnection.deleteUser();
      _sendBackToWelcome();
    }
  }

  void _handleSocket() async {
    String serverUrl = widget.nodeConnection.getServerUrl();

    manager = SocketIOManager();
    socketIO = await manager.createInstance('$serverUrl/');

    socketIO.on("$sessionId", _handleEvent);

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

  void _sortMessages() {
    setState(() {
      messages
          .sort((message1, message2) => message2['time'] - message1['time']);
    });
  }

  void _fetchInitialMessages() async {
    List initialMessages = await widget.nodeConnection.getInitialMessages();

    if (initialMessages == null) return;

    setState(() {
      messages = new List.from(messages)..addAll(initialMessages);
    });
    _sortMessages();
  }

  void _sendBackToWelcome() async {
    await manager.clearInstance(socketIO);

    // create new empty node connection
    NodeConnection nodeConnection = new NodeConnection();
    Navigator.of(context).pushAndRemoveUntil(
        new MaterialPageRoute(
            builder: (context) => new Welcome(nodeConnection)),
        ModalRoute.withName('/'));
  }

  void _endConversation() async {
    if (!confirmEndConversation) {
      setState(() {
        confirmEndConversation = true;
      });
      return;
    }
    setState(() {
      endingConversation = true;
      errorEndingConversation = false;
    });

    bool userDeleted = await widget.nodeConnection.deleteUser();

    if (userDeleted) {
      setState(() {
        endingConversation = false;
        errorEndingConversation = false;
      });

      // Map<String, dynamic> payload = {
      //   'type': 'deletedSession',
      //   'session_id': sessionId.toString()
      // };

      // socketIO.emit('$sessionId', [payload]);

      _sendBackToWelcome();
    } else {
      setState(() {
        endingConversation = false;
        errorEndingConversation = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Talking to ${widget.nodeConnection.getFriendName()} '),
          actions: <Widget>[
            FlatButton(
              padding: EdgeInsets.all(1.0),
              color: Colors.red[600],
              child: endingConversation
                  ? CircularProgressIndicator()
                  : Text(confirmEndConversation ? 'Confirm' : 'End'),
              onPressed: _endConversation,
            )
          ],
        ),
        body: Container(
            color: Color.fromARGB(255, 43, 66, 81),
            child: Column(
              children: <Widget>[
                Container(
                    height: MediaQuery.of(context).size.height * 0.80,
                    child: ListView.builder(
                      itemCount: messages == null ? 0 : messages.length,
                      itemBuilder: (context, index) {
                        final message = messages[index];

                        return Message(message);
                      },
                    )),
                InputMessage(widget.nodeConnection)
              ],
            )));
  }
}
