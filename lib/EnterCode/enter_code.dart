import 'package:flutter/material.dart';
import '../node_connection.dart';
import '../WaitingToConnect/waiting_to_connect.dart';

class EnterCode extends StatefulWidget {
  final NodeConnection nodeConnection;

  EnterCode(this.nodeConnection);

  @override
  _EnterCodeState createState() => _EnterCodeState();
}

class _EnterCodeState extends State<EnterCode> {
  bool _isCreator = false;
  bool _hasAnsweredIfCreator = false;

  bool _generatingCode = false;
  bool _codeGenerated = false;
  bool _codeGenerateError = false;

  String _code = '';

  _setCode(String code) {
    setState(() {
      _code = code;
    });
  }

  _generateCode() async {
    if (_codeGenerated) return;
    setState(() {
      _generatingCode = true;
      _codeGenerateError = false;
    });

    String codeGenerated = await widget.nodeConnection.createSession();

    print(codeGenerated);

    if (codeGenerated != null) {
      setState(() {
        _codeGenerated = true;
        _generatingCode = false;
        _codeGenerateError = false;
      });

      Navigator.push(
          context,
          new MaterialPageRoute(
              builder: (context) =>
                  new WaitingToConnect(widget.nodeConnection)));
    } else {
      setState(() {
        _codeGenerated = false;
        _generatingCode = false;
        _codeGenerateError = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget _buildAskIfCreator() {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
              margin: EdgeInsets.symmetric(horizontal: 35.0, vertical: 20.0),
              child: Text(
                'Do you have a code?',
                style: Theme.of(context).textTheme.title,
              )),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 40.0, vertical: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                RaisedButton(
                  color: Color.fromARGB(255, 46, 50, 60),
                  child: Text(
                    'Yes',
                    style: Theme.of(context).textTheme.button,
                  ),
                  onPressed: () {
                    setState(() {
                      _isCreator = false;
                      _hasAnsweredIfCreator = true;
                    });
                  },
                ),
                RaisedButton(
                  color: Color.fromARGB(255, 46, 50, 60),
                  child: Text(
                    'No',
                    style: Theme.of(context).textTheme.button,
                  ),
                  onPressed: () {
                    setState(() {
                      _isCreator = true;
                      _hasAnsweredIfCreator = true;
                    });
                  },
                )
              ],
            ),
          )
        ],
      );
    }

    Widget _buildEnterCode() {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
              margin: EdgeInsets.symmetric(horizontal: 35.0, vertical: 20.0),
              child: Text(
                'Enter code',
                style: Theme.of(context).textTheme.title,
              )),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 40.0, vertical: 20.0),
            child: TextField(
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(labelText: "Code"),
                onChanged: (String name) => _setCode(name),
                onSubmitted: (String name) => _setCode(name)),
          ),
          _code.length >= 3
              ? Container(
                  margin:
                      EdgeInsets.symmetric(horizontal: 40.0, vertical: 20.0),
                  padding: EdgeInsets.all(8.0),
                  child: RaisedButton(
                    color: Color.fromARGB(255, 46, 50, 60),
                    child: Text(
                      'Continue',
                      style: Theme.of(context).textTheme.button,
                    ),
                    onPressed: () {},
                  ),
                )
              : Container()
        ],
      );
    }

    Widget _buildGenerateCode() {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
              margin: EdgeInsets.symmetric(horizontal: 35.0, vertical: 20.0),
              child: Text(
                'Generate code?',
                style: Theme.of(context).textTheme.title,
              )),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 40.0, vertical: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                RaisedButton(
                  color: Color.fromARGB(255, 46, 50, 60),
                  child: _generatingCode
                      ? Container(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(),
                        )
                      : Text(
                          'Yes',
                          style: Theme.of(context).textTheme.button,
                        ),
                  onPressed: _generateCode,
                ),
                RaisedButton(
                  color: Color.fromARGB(255, 46, 50, 60),
                  child: Text(
                    'No',
                    style: Theme.of(context).textTheme.button,
                  ),
                  onPressed: () => Navigator.pop(context),
                )
              ],
            ),
          )
        ],
      );
    }

    Widget _buildView() {
      if (!_hasAnsweredIfCreator) {
        return _buildAskIfCreator();
      } else if (_hasAnsweredIfCreator && _isCreator) {
        return _buildGenerateCode();
      } else if (_hasAnsweredIfCreator && !_isCreator) {
        return _buildEnterCode();
      }
    }

    return Scaffold(
        body: Container(
      color: Color.fromARGB(255, 43, 66, 81),
      child: Center(child: _buildView()),
    ));
  }
}