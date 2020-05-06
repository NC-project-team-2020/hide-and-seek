import 'package:flutter/material.dart';
import 'package:quiver/async.dart';
import 'package:hideandseek/pages/HomePage.dart';
import 'package:hideandseek/pages/LobbyPage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_socket_io/flutter_socket_io.dart';
import 'package:flutter_socket_io/socket_io_manager.dart';

import 'dart:convert' as convert;

class Lobby extends StatefulWidget {
  const Lobby({Key key}) : super(key: key);

  @override
  _LobbyState createState() => _LobbyState();
}

class _LobbyState extends State<Lobby> with SingleTickerProviderStateMixin {
  var _players;
  int _start;
  int _current;
  int _gameTime;
  String _gameTimeText;
  String elapsedTime = '';
  String selectedHider;
  bool startStop = false;
  String userName;
  String userID;
  String roomPass;
  String usersArr;
  SocketIO socketIO;

  Future<void> getSharedPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userName = prefs.getString("user_name");
    userID = prefs.getString("user_id");
    roomPass = prefs.getString("roomPass");
    usersArr = prefs.getString("users");
    _players = convert.jsonDecode(usersArr);
  }

  _handleUpdate(dynamic data) async {
    print("Socket info: " + data);
  }

  void startTimer() {
    CountdownTimer countDownTimer = new CountdownTimer(
      new Duration(seconds: _start),
      new Duration(seconds: 1),
    );

    var sub = countDownTimer.listen(null);
    sub.onData((duration) {
      setState(() {
        _current = _start - duration.elapsed.inSeconds;
        elapsedTime = transformSeconds(_current);
        startStop = true;
      });
    });

    sub.onDone(() {
      //LAUNCH THE GAME
      sub.cancel();
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
      //This is currently navigating to the Homepage but will need to redirect to launch of MAP
    });
  }

  @override
  Widget build(BuildContext context) {
    socketIO = ModalRoute.of(context).settings.arguments;
    socketIO.subscribe("usersUpdate", _handleUpdate);

    return FutureBuilder(
        future: getSharedPrefs(),
        builder: (context, snapshot) {
          return new Scaffold(
            appBar: new AppBar(
              title: Text('Lobby'),
              actions: <Widget>[
                PopupMenuButton<String>(
                  onSelected: handleClick,
                  itemBuilder: (BuildContext context) {
                    const PopupMenuItem<String>(
                      value: 'Leave lobby',
                      child: Text('Leave lobby'),
                    );
                  },
                ),
              ],
            ),
            body: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('Room Password: $roomPass',
                      style: TextStyle(fontSize: 25.0),
                      textAlign: TextAlign.center),
                ),
                _gameTimeText == null
                    ? Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Set the seek time',
                          style: TextStyle(fontSize: 25.0),
                          textAlign: TextAlign.center,
                        ),
                      )
                    : Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text('Seek Time: $_gameTimeText',
                            style: TextStyle(fontSize: 25.0),
                            textAlign: TextAlign.center),
                      ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('Time left to hide: $elapsedTime',
                      style: TextStyle(fontSize: 25.0),
                      textAlign: TextAlign.center),
                ),
                SizedBox(
                  width: 150,
                  height: 300,
                  child: ListView.builder(
                      itemCount: _players.length,
                      itemBuilder: (context, index) {
                        final playerIndex = _players[index];
                        final userName = playerIndex['user_name'];
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ListTile(
                              title: Text(
                                playerIndex == selectedHider
                                    ? "$userName is the hider"
                                    : userName,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 30.0,
                                ),
                              ),
                              onTap: () {
                                _showcontent(context);
                              }),
                        );
                      }),
                ),
                SizedBox(
                  height: 80.0,
                  child: RaisedButton(
                    onPressed: () => startStop ? null : startTimer(),
                    child: Text(
                      "Go Hide",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 30.0,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            bottomNavigationBar: BottomNavigationBar(
              items: const <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  title: Text('Room'),
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.settings),
                  title: Text('Game Settings'),
                )
              ],
              onTap: (value) {
                if (value == 1) {
                  gameSettings(context);
                }
              },
            ),
          );
        });
  }

  transformSeconds(int seconds) {
    int minutes = (seconds / 60).truncate();

    String minutesStr = (minutes % 60).toString().padLeft(2, '0');
    String secondsStr = (seconds % 60).toString().padLeft(2, '0');

    return "$minutesStr:$secondsStr";
  }

  void handleClick(String value) async {
    socketIO.sendMessage("leaveRoom", null);
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (BuildContext context) => LobbyPage()),
        ModalRoute.withName("/LobbyPage"));
  }

  gameSettings(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Set number of minutes for hunt and seek time'),
          content: settingsSelect(),
        );
      },
    );
  }

  settingsSelect() {
    TextEditingController _c = new TextEditingController();
    TextEditingController _g = new TextEditingController();
    return Container(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          TextField(
            keyboardType: TextInputType.number,
            controller: _c,
            decoration: new InputDecoration(labelText: 'Hunt Time'),
          ),
          TextField(
            keyboardType: TextInputType.number,
            controller: _g,
            decoration: new InputDecoration(labelText: 'Seek Time'),
          ),
          DropdownButton(
            hint: Text('Choose who will hide'),
            onChanged: (String val) {
              setState(() {
                selectedHider = val;
              });
            },
            value: this.selectedHider,
            items: _players.map<DropdownMenuItem<String>>((value) {
              final playerName = value["user_name"];
              print(value);
              print(playerName);
              return new DropdownMenuItem<String>(
                value: playerName,
                child: new Text(playerName),
              );
            }).toList(),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              MaterialButton(
                  elevation: 5.0,
                  child: Text('Close'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  }),
              MaterialButton(
                  elevation: 5.0,
                  child: Text('Set'),
                  onPressed: () {
                    setState(() {
                      this._start = int.parse(_c.text) * 60;
                      this._current = int.parse(_c.text) * 60;
                      this._gameTime = int.parse(_g.text) * 60;
                      this._gameTimeText =
                          transformSeconds(int.parse(_g.text) * 60);
                    });
                    Navigator.of(context).pop();
                  }),
            ],
          ),
        ],
      ),
    );
  }

  void _showcontent(BuildContext context) {
    showDialog<Null>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return new AlertDialog(
          title: new Text('USER PROFILE NAME'),
          content: new SingleChildScrollView(
            child: new ListBody(
              children: <Widget>[
                new Text('AVATAR : X - show image'),
                new Text('Wins : X '),
                new Text('Loses : X'),
              ],
            ),
          ),
          actions: <Widget>[
            new FlatButton(
              child: new Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
