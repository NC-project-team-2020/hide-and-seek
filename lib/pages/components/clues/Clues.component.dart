import 'package:flutter/material.dart';
import 'package:hideandseek/pages/components/clues/clueHistory.component.dart';
import 'package:flutter_socket_io/flutter_socket_io.dart';
import 'dart:convert' as convert;

class Clues extends StatefulWidget {
  SocketIO socketIO;
  String userName;
  String hiderID;
  String roomPass;

  Clues(
      {Key key,
      @required this.socketIO,
      this.userName,
      this.hiderID,
      this.roomPass})
      : super(key: key);

  @override
  _CluesState createState() => _CluesState();
}

class _CluesState extends State<Clues> {
  final TextEditingController _clue = TextEditingController();
  int _countOfUnreadClues;
  SocketIO socketIO;
  String user_name;
  String hider;
  String roomPass;

  @override
  void initState() {
    _countOfUnreadClues = 0;
    clues = [];
    socketIO = widget.socketIO;
    socketIO.subscribe("sendClue", _handleClues);
    user_name = widget.userName;
    hider = widget.hiderID;
    roomPass = widget.roomPass;
    super.initState();
  }

  void _sendChatClue(String msg) async {
    socketIO.sendMessage("sendClue",
        '{"msg":"$msg", "user_name":"$user_name", "roomPass":"$roomPass"}');
  }

  void sendClue() {
    String msg = _clue.text;
    if (msg.isNotEmpty) {
      setState(() {
        clues.add({
          'clue': _clue.text,
          'written_by': user_name,
          'created_at': new DateTime.now().toString()
        });
      });
      _sendChatClue(_clue.text);
      _clue.clear();
    }
  }

  void sendClueResponse(msg) {
    setState(() {
      clues.add({
        'clue': msg,
        'written_by': user_name,
        'created_at': new DateTime.now().toString()
      });
    });
    _sendChatClue(msg);
  }

  void _handleClues(dynamic event) async {
    final Map msg = convert.jsonDecode(event);
    setState(() {
      clues.add({
        'clue': convert.jsonEncode(msg["msg"]),
        'written_by': convert.jsonEncode(msg["user_name"]),
        'created_at': convert.jsonEncode(msg["date"])
      });
    });
  }

  List<Map<String, String>> clues = [];

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Expanded(flex: 8, child: clueHistory(clues, user_name)),
          user_name == hider
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
                              sendClue();
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
                              if (user_name != hider) {
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
                              sendClueResponse("I'm on the hunt");
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
                              sendClueResponse('Can i have another clue');
                            },
                            child: Text("Can i have another clue"),
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
