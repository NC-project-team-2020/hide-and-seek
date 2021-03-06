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
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  SocketIO socketIO;
  String userName;
  String userID;
  String roomPass;
  var avatar;
  bool setArgsFlag = true;

  void getSharedPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString("user_name");
      userID = prefs.getString("user_id");
    });
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
    socketIO.subscribe("createRoom", (data) => _handleRoom(data, true));
    socketIO.subscribe("joinRoom", (data) => _handleRoom(data, false));

    //Connect to the socket
    socketIO.connect();
    super.initState();
  }

  _handleRoom(dynamic data, bool host) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final Map body = convert.jsonDecode(data);
    prefs.setString('roomPass', host ? body["roomPassword"] : roomPass);
    prefs.setString('users', convert.jsonEncode(body["users"]));
    prefs.setBool('host', host);
    Map<String, dynamic> arguments = {'socketIO': socketIO, 'winner': null};
    Navigator.pushNamed(context, '/lobby-room', arguments: arguments);
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
      }
    }

    if (setArgsFlag) {
      setArgsFlag = false;
      getSharedPrefs();
    }
    String color = "0xffb8b8b8";

    return Scaffold(
      key: _scaffoldKey,
      appBar: new AppBar(
        title: Text('Home'),
        backgroundColor: Color(int.parse("0xff272744")),
        actions: <Widget>[
          PopupMenuButton<String>(
            onSelected: handleClick,
            itemBuilder: (BuildContext context) {
              return {'Logout'}.map((String choice) {
                return PopupMenuItem<String>(
                  value: choice,
                  child: Text(choice),
                );
              }).toList();
            },
          ),
        ],
      ),
      backgroundColor: Color(int.parse(color)),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text(
                'Welcome $userName',
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 40),
              ),
              Padding(
                padding: const EdgeInsets.only(
                  left: 40,
                  top: 60,
                  right: 40,
                  bottom: 60,
                ),
                child: Image(image: AssetImage('assets/logo.png')),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    width: 180.0,
                    height: 140.0,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: RaisedButton(
                        onPressed: () {
                          createRoomDialog(context).then((roomName) {
                            if (roomName.toString().length > 0 &&
                                roomName != null) {
                              String jsonData =
                                  '{"user_name":"$userName","user_id":"$userID", "room":"$roomName"}';
                              socketIO.sendMessage("createRoom", jsonData);
                            } else {
                              final failedSnackBar = SnackBar(
                                backgroundColor: Colors.red[500],
                                content:
                                    Text('Room name required to create room!'),
                              );
                              _scaffoldKey.currentState
                                  .showSnackBar(failedSnackBar);
                              return null;
                            }
                          });
                        },
                        child: Text(
                          'Create Room',
                          style: TextStyle(fontSize: 22),
                          textAlign: TextAlign.center,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(40),
                              bottomLeft: Radius.circular(40)),
                          side: BorderSide(
                            width: 3,
                            color: Color(int.parse('0xff65738c')),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    width: 180.0,
                    height: 140.0,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: RaisedButton(
                        onPressed: () {
                          joinRoomDialog(context).then((roomID) {
                            setState(() {
                              roomPass = roomID;
                            });
                            if (roomID.toString().length > 0 &&
                                roomID != null) {
                              String jsonData =
                                  '{"user_name":"$userName","user_id":"$userID", "roomPass":"$roomID"}';
                              socketIO.sendMessage("joinRoom", jsonData);
                            } else {
                              final failedSnackBar = SnackBar(
                                backgroundColor: Colors.red[500],
                                content:
                                    Text('Room ID required to create room!'),
                              );
                              _scaffoldKey.currentState
                                  .showSnackBar(failedSnackBar);
                              return null;
                            }
                          });
                        },
                        child: Text(
                          'Join Room',
                          style: TextStyle(fontSize: 22),
                          textAlign: TextAlign.center,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                              topRight: Radius.circular(40),
                              bottomRight: Radius.circular(40)),
                          side: BorderSide(
                            width: 3,
                            color: Color(int.parse('0xff65738c')),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Color(int.parse('0xff433a60')),
        selectedItemColor: Color(int.parse('0xff7c94a1')),
        unselectedItemColor: Color(int.parse('0xfffbf5ef')),
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
            title: Text('Home'),
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
