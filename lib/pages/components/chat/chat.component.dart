import 'package:flutter/material.dart';
import 'package:flutter_socket_io/flutter_socket_io.dart';
import 'package:hideandseek/pages/components/chat/chatHistory.component.dart';
import 'dart:convert' as convert;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class Chat extends StatefulWidget {
  SocketIO socketIO;
  String userName;
  String hiderID;
  String roomPass;

  Chat(
      {Key key,
      @required this.socketIO,
      this.userName,
      this.hiderID,
      this.roomPass})
      : super(key: key);

  @override
  _ChatState createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  final TextEditingController _message = TextEditingController();
  int _countOfUnreadMessages;
  SocketIO socketIO;
  String user_name;
  String hider;
  String roomPass;
  List<dynamic> chatList = [];

  @override
  void initState() {
    socketIO = widget.socketIO;
    socketIO.subscribe("sendMsg", _handleMsg);
    _countOfUnreadMessages = 0;
    chatList = [];
    user_name = widget.userName;
    hider = widget.hiderID;
    roomPass = widget.roomPass;
    super.initState();
  }

  void dispose() {
    socketIO.unSubscribe("sendMsg");
    super.dispose();
  }

  unreadMessageCounter(BuildContext context) {
    int result = _countOfUnreadMessages;
    Navigator.pop(context, result);
  }

  void _sendChatMessage(String msg) async {
    socketIO.sendMessage("sendMsg",
        '{"msg":"$msg", "user_name":"$user_name", "roomPass":"$roomPass"}');
  }

  void _handleMsg(dynamic event) async {
    print('i am an alien');
    final Map msg = convert.jsonDecode(event);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String chatListStr = prefs.getString("chatList");
    chatList = convert.jsonDecode(chatListStr);
    setState(() {
      chatList.add({
        'msg': msg["msg"],
        'written_by': msg["user_name"],
        'created_at': msg["date"]
      });
      _countOfUnreadMessages = _countOfUnreadMessages + 1;
    });
    chatListStr = convert.jsonEncode(chatList);
    prefs.setString("chatList", chatListStr);
  }

  void sendMessage() async {
    try {
      String msg = _message.text;
      if (msg.isNotEmpty) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        String chatListStr = prefs.getString("chatList");
        chatList = convert.jsonDecode(chatListStr);
        setState(() {
          chatList.add({
            'msg': _message.text,
            'written_by': user_name,
            'created_at':
                new DateFormat("dd/MM/yyyy HH:mm:ss").format(new DateTime.now())
          });
        });
        chatListStr = convert.jsonEncode(chatList);
        prefs.setString("chatList", chatListStr);
        _sendChatMessage(_message.text);

        _message.clear();
      }
    } catch (err) {
      print(err);
    }
  }

  Future<void> getMessages() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String chatListStr = prefs.getString("chatList");
    chatList = convert.jsonDecode(chatListStr);
  }

  @override
  Widget build(BuildContext context) {
    print(chatList);
    return FutureBuilder(
      future: getMessages(),
      builder: (context, snapshot) {
        return Scaffold(
          backgroundColor: Color(int.parse("0xffb8b8b8")),
          body: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Expanded(flex: 8, child: chatHistory(chatList, user_name)),
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
                            color: Color(int.parse("0xff272744")),
                            onPressed: () {
                              sendMessage();
                            },
                            child: Icon(
                              Icons.send,
                              color: Colors.white,
                            )),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: RaisedButton(
                          color: Color(int.parse("0xff272744")),
                          onPressed: () {
                            if (user_name != hider) {
                              unreadMessageCounter(context);
                            } else
                              Navigator.pop(context);
                          },
                          // add functionality here to say in user != user then run unread messagecounter
                          child: Icon(
                            Icons.close,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
