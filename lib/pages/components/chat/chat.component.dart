import 'package:flutter/material.dart';
import 'package:hideandseek/pages/components/chat/chatHistory.component.dart';

class Chat extends StatefulWidget {
  Chat({Key key}) : super(key: key);

  @override
  _ChatState createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  final TextEditingController _message = TextEditingController();
  List<Map<String, String>> chatList = [
    {
      'msg':
          'This is the first message, Isn\'t that exciting. Hopefully this will get another line to see how wide this box is....',
      'written_by': 'User1',
      'created_at': '12:40'
    },
    {
      'msg': 'This is the second message',
      'written_by': 'User1',
      'created_at': '12:40'
    },
    {
      'msg': 'Hello there, how are you?',
      'written_by': 'User2',
      'created_at': '12:43'
    },
    {'msg': 'I can\'t find you', 'written_by': 'User1', 'created_at': '12:44'}
  ];
  @override
  Widget build(BuildContext context) {
    sendMessage() {
      String msg = _message.text;
      if (msg.isNotEmpty) {
        setState(() {
          chatList
              .add({'msg': msg, 'written_by': 'User1', 'created_at': '14.35'});
        });
        _message.clear();
      }
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Expanded(flex: 8, child: chatHistory(chatList)),
        Expanded(
          flex: 1,
          child: Row(
            children: <Widget>[
              Expanded(
                flex: 9,
                child: Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: TextField(
                    controller: _message,
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: RaisedButton(
                  color: Colors.blue[200],
                  onPressed: sendMessage,
                  child: Text('Send'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
