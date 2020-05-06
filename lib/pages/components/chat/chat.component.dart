import 'package:flutter/material.dart';
import 'package:hideandseek/pages/components/chat/chatHistory.component.dart';

class Chat extends StatefulWidget {
  Chat({Key key}) : super(key: key);

  @override
  _ChatState createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  final TextEditingController _message = TextEditingController();

  int _countOfUnreadMessages;
  String user = 'Hannes';
  String _msgSender = 'Steven';
  @override
  void initState() {
    _countOfUnreadMessages = 0;
    chatList = [];

    super.initState();
    print("open");
  }

  List<Map<String, String>> chatList = [];
  @override
  Widget build(BuildContext context) {
    sendMessage() {
      String msg = _message.text;
      if (msg.isNotEmpty) {
        setState(() {
          chatList
              .add({'msg': msg, 'written_by': 'User1', 'created_at': '14.35'});
          _countOfUnreadMessages = _countOfUnreadMessages + 1;
        });
        _message.clear();
      }
    }

    return new Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Expanded(flex: 8, child: chatHistory(chatList)),
          Expanded(
            flex: 1,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Expanded(
                  flex: 8,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: TextField(
                      controller: _message,
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
                          sendMessage();
                        },
                        child: Icon(Icons.send)),
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
          ),
        ],
      ),
    );
  }

  unreadMessageCounter(BuildContext context) {
    int result = _countOfUnreadMessages;
    Navigator.pop(context, result);
  }
}
