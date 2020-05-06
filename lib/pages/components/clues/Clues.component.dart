import 'package:flutter/material.dart';
import 'package:hideandseek/pages/components/clues/cluesList.component.dart';

class Clues extends StatefulWidget {
  Clues({Key key}) : super(key: key);

  @override
  _CluesState createState() => _CluesState();
}

class _CluesState extends State<Clues> {
  final TextEditingController _clue = TextEditingController();
  int _countOfUnreadClues;
  String user = 'Hannes';
  String _msgSender = 'Hannes';
  @override
  void initState() {
    _countOfUnreadClues = 0;
    clues = [];

    super.initState();
    print("open");
  }

  List<Map<String, String>> clues = [];
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Expanded(flex: 8, child: cluesList(clues)),
          user == _msgSender
              ? Expanded(
                  flex: 1,
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        flex: 9,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: TextField(
                            controller: _clue,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: RaisedButton(
                          color: Colors.blue[200],
                          disabledColor: Colors.red[200],
                          onPressed: () {
                            String clue = _clue.text;
                            if (clue.length > 0 && clues.length < 3) {
                              setState(() {
                                clues.add({'clue': clue});
                                _countOfUnreadClues = _countOfUnreadClues + 1;
                              });
                              _clue.clear();
                            } else {
                              return null;
                            }
                          },
                          child: Icon(Icons.send),
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: RaisedButton(
                            color: Colors.blue[200],
                            onPressed: () {
                              if (user != _msgSender) {
                                unreadMessageCounter(context);
                              } else
                                Navigator.pop(context);
                            },
                            // add functionality here to say in user != user then run unread messagecounter
                            child: Icon(Icons.close),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : Expanded(
                  flex: 1,
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        flex: 3,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: RaisedButton(
                            color: Colors.blue[200],
                            onPressed: () {
                              setState(() {
                                clues.add({'clue': "I'm on the hunt"});
                              });
                            },
                            // add functionality here to say in user != user then run unread messagecounter
                            child: Text("I'm on the hunt"),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: RaisedButton(
                            color: Colors.blue[200],
                            onPressed: () {
                              setState(() {
                                clues.add({'clue': "C'mon another clue"});
                              });
                            },
                            // add functionality here to say in user != user then run unread messagecounter
                            child: Text("C'mon another clue"),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
        ],
      ),
    );
  }

  unreadMessageCounter(BuildContext context) {
    int result = _countOfUnreadClues;
    Navigator.pop(context, result);
  }
}
