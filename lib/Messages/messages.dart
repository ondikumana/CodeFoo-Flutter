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
  String friendName = 'Friend';

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
        messages.insert(0, data);
        // _sortMessages();
      });
      
    }
    if (data['type'] == 'deletedSession' &&
        data['session_id'].toString() == sessionId) {
      await widget.nodeConnection.deleteUser();
      _sendBackToWelcome();
    }
  }

  void _handleSocket() async {
    String serverUrl = widget.nodeConnection.getServerUrl();
    friendName = await widget.nodeConnection.getFriendName();

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
      messages.sort((message1, message2) =>
          message2['creation_date'].compareTo(message1['creation_date']));
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
      await Future.delayed(const Duration(seconds: 4), () {
        setState(() {
          confirmEndConversation = false;
        });
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
          title: Text('Messages'),
          actions: <Widget>[
            new Container(
              margin:
                  const EdgeInsets.symmetric(horizontal: 4.0, vertical: 5.0),
              child: endingConversation
                  ? CircularProgressIndicator()
                  : new IconButton(
                      icon: new Icon(Icons.delete,
                          color: confirmEndConversation
                              ? Colors.red
                              : Colors.black),
                      onPressed: _endConversation,
                    ),
            )
          ],
        ),
        body: Container(
          color: Color.fromARGB(255, 43, 66, 81),
          child: Column(
            children: <Widget>[
              new Flexible(
                child: ListView.builder(
                  padding: new EdgeInsets.all(8.0),
                  reverse: true,
                  itemBuilder: (context, index) {
                    final message = messages[index];

                    return Message(message, widget.nodeConnection);
                  },
                  itemCount: messages.length,
                ),
              ),
              new Divider(
                height: 1.0,
              ),
              new Container(
                  decoration: new BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey[900],
                        blurRadius:
                            20.0, // has the effect of softening the shadow
                        spreadRadius:
                            5.0, // has the effect of extending the shadow
                        offset: Offset(
                          0.0, // horizontal, move right 10
                          -10.0, // vertical, move down 10
                        ),
                      )
                    ],
                  ),
                  child: InputMessage(widget.nodeConnection))
            ],
          ),
        ));
  }
}
