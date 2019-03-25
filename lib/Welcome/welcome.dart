import 'package:flutter/material.dart';
import '../node_connection.dart';
import '../EnterCode/enter_code.dart';

class Welcome extends StatefulWidget {
  final NodeConnection nodeConnection;

  Welcome(this.nodeConnection);

  @override
  _WelcomeState createState() => _WelcomeState();
}

class _WelcomeState extends State<Welcome> {
  @override
  void initState() {
    _checkIfAlreadyGivenName();
    super.initState();
  }

  final GlobalKey<NavigatorState> navigatorKey =
      new GlobalKey<NavigatorState>();

  String _name = '';
  bool _submittingName = false;
  bool _nameSubmitted = false;
  bool _errorSubmittingName = false;

  _setName(String name) {
    setState(() {
      _name = name;
    });
  }

  _checkIfAlreadyGivenName() async {
    await widget.nodeConnection.getAttributesFromSharedPreferences();

    if (widget.nodeConnection.getUserId() != null) {
      Navigator.pushReplacement(
          context,
          new MaterialPageRoute(
              builder: (context) => new EnterCode(widget.nodeConnection)));
    }
  }

  _submitName() async {
    if (_nameSubmitted) return;
    setState(() {
      _submittingName = true;
      _errorSubmittingName = false;
    });

    widget.nodeConnection.setName(_name);

    bool accountCreated = await widget.nodeConnection.createUser();

    if (accountCreated) {
      setState(() {
        _nameSubmitted = true;
        _submittingName = false;
        _errorSubmittingName = false;
      });

      Navigator.push(
          context,
          new MaterialPageRoute(
              builder: (context) => new EnterCode(widget.nodeConnection)));
    } else {
      setState(() {
        _nameSubmitted = false;
        _submittingName = false;
        _errorSubmittingName = true;
      });
    }
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
                margin: EdgeInsets.symmetric(horizontal: 35.0, vertical: 20.0),
                child: Text(
                  'What is your name?',
                  style: Theme.of(context).textTheme.title,
                )),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 40.0, vertical: 20.0),
              child: TextField(
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                      labelText: "Name",
                      helperText:
                          _errorSubmittingName ? 'Unable to set name' : ''),
                  onChanged: (String name) => _setName(name),
                  onSubmitted: (String name) => _submitName()),
            ),
            _name.length >= 3
                ? Container(
                    margin:
                        EdgeInsets.symmetric(horizontal: 40.0, vertical: 20.0),
                    padding: EdgeInsets.all(8.0),
                    child: RaisedButton(
                      color: Color.fromARGB(255, 46, 50, 60),
                      child: _submittingName
                          ? Container(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(),
                            )
                          : Text(
                              'Continue',
                              style: Theme.of(context).textTheme.button,
                            ),
                      onPressed: _submitName,
                    ))
                : Container(
                    margin:
                        EdgeInsets.symmetric(horizontal: 40.0, vertical: 20.0),
                    child: SizedBox(
                      height: 64,
                    ),
                  )
          ],
        ),
      ),
    ));
  }
}
