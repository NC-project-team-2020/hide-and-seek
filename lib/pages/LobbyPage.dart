import 'package:flutter/material.dart';
import 'package:hideandseek/pages/HomePage.dart';
import 'package:hideandseek/pages/inGame.dart';
import 'package:shared_preferences/shared_preferences.dart';
import './components/LoobyPage.components.dart';
import 'package:flutter_socket_io/flutter_socket_io.dart';
import 'package:flutter_socket_io/socket_io_manager.dart';
import 'dart:convert' as convert;

class LobbyPage extends StatefulWidget {
  const LobbyPage({Key key}) : super(key: key);

  @override
  _LobbyPageState createState() => _LobbyPageState();
}

class _LobbyPageState extends State<LobbyPage> {
  SocketIO socketIO;
  String userName;
  String userID;

  Future<Null> getSharedPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userName = prefs.getString("user_name");
    userID = prefs.getString("user_id");
  }

  @override
  void initState() {
    //Creating the socket
    socketIO = SocketIOManager().createSocketIO(
      'https://peekaboo-be.herokuapp.com/',
      '/',
    );
    //Call init before doing anything with socket
    socketIO.init();
    socketIO.subscribe("createRoom", _handleRoom);
    socketIO.subscribe("joinRoom", _handleRoom);

    //Connect to the socket
    socketIO.connect();
    getSharedPrefs();
    super.initState();
  }

  _handleRoom(dynamic data) async {
    print("Socket info: " + data);
    print(socketIO);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final Map body = convert.jsonDecode(data);
    prefs.setString('roomPass', body["roomPassword"]);
    prefs.setString('users', convert.jsonEncode(body["users"]));
    Navigator.pushNamed(context, '/lobby-room', arguments: socketIO);
  }

  @override
  Widget build(BuildContext context) {
    void handleClick(String value) async {
      if (value == 'Logout') {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs?.clear();
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (BuildContext context) => HomePage()),
          ModalRoute.withName("/register"),
        );
      } else if (value == 'Map') {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (BuildContext context) => InGame()),
          ModalRoute.withName("/in-game"),
        );
      }
    }

    return Scaffold(
      appBar: new AppBar(
        title: Text('Lobby'),
        backgroundColor: Color(0xff05668D),
        actions: <Widget>[
          PopupMenuButton<String>(
            onSelected: handleClick,
            itemBuilder: (BuildContext context) {
              return {'Logout', 'Map'}.map((String choice) {
                return PopupMenuItem<String>(
                  value: choice,
                  child: Text(choice),
                );
              }).toList();
            },
          ),
        ],
      ),
      backgroundColor: Color(0xffEBF2FA),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(18.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              RaisedButton(
                onPressed: () {
                  createRoomDialog(context).then((roomName) {
                    if (roomName.toString().length > 0 && roomName != null) {
                      String jsonData =
                          '{"user_name":"$userName","user_id":"$userID", "room":"$roomName"}';
                      socketIO.sendMessage("createRoom", jsonData);
                      print(roomName);
                    }
                  });
                },
                child: Text('Create Room'),
              ),
              RaisedButton(
                onPressed: () {
                  joinRoomDialog(context).then((roomID) {
                    if (roomID.toString().length > 0 && roomID != null) {
                      print(roomID);
                      String jsonData =
                          '{"user_name":"$userName","user_id":"$userID", "roomPass":"$roomID"}';
                      socketIO.sendMessage("joinRoom", jsonData);
                    }
                  });
                },
                child: Text('Join Room'),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        onTap: (value) {
          if (value == 1) {
            Navigator.of(context).push(new MaterialPageRoute<Null>(
                builder: (BuildContext context) {
                  return userProfile();
                },
                fullscreenDialog: true));
          }
        },
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            title: Text('Lobby'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            title: Text('User Profile'),
          )
        ],
      ),
    );
  }
}
