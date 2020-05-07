import 'package:flutter/material.dart';
import 'package:quiver/async.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_socket_io/flutter_socket_io.dart';
import 'dart:convert' as convert;

class Lobby extends StatefulWidget {
  const Lobby({Key key}) : super(key: key);

  @override
  _LobbyState createState() => _LobbyState();
}

class _LobbyState extends State<Lobby> with SingleTickerProviderStateMixin {
  var _players;
  int hideTime;
  int seekTime;
  int radiusMeterage;
  String elapsedTime = '';
  String selectedHider;
  bool host = false;
  bool startStop = false;
  String userName;
  String userID;
  String roomPass;
  SocketIO socketIO;

  Future<Null> getSharedPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userName = prefs.getString("user_name");
    userID = prefs.getString("user_id");
    roomPass = prefs.getString("roomPass");
    host = prefs.getBool("host");
    _players = convert.jsonDecode(prefs.getString("users"));
  }

  void _handleUpdate(dynamic data) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final Map body = convert.jsonDecode(data);
    prefs.setString('users', convert.jsonEncode(body["users"]));
    setState(() {
      _players = body["users"];
    });
    print("Socket info: " + data);
  }

  void launchGame(dynamic data) {
    try {
      final Map body = convert.jsonDecode(data);
      Map<String, dynamic> arguments = {
        'socketIO': socketIO,
        "seekTime": seekTime,
        "hideTime": body["hideTime"],
        "radiusMeterage": radiusMeterage,
        "selectedHider": selectedHider
      };
      Navigator.pushNamed(context, '/in-game', arguments: arguments);
    } catch (err) {
      print(err);
    }
  }

  @override
  Widget build(BuildContext context) {
    socketIO = ModalRoute.of(context).settings.arguments;
    socketIO.subscribe("usersUpdate", _handleUpdate);
    socketIO.subscribe("startGame", launchGame);

    return FutureBuilder(
        future: getSharedPrefs(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return new Scaffold(
              appBar: new AppBar(
                title: Text('Lobby'),
                actions: <Widget>[
                  PopupMenuButton<String>(
                    onSelected: handleClick,
                    itemBuilder: (_) => <PopupMenuItem<String>>[
                      new PopupMenuItem<String>(
                          child: const Text('Leave lobby'),
                          value: 'Leave lobby'),
                    ],
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
                  SizedBox(
                    width: 150,
                    height: 300,
                    child: ListView.builder(
                        itemCount: _players?.length ?? 0,
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
                  host
                      ? SizedBox(
                          height: 80.0,
                          child: RaisedButton(
                            onPressed: () => startStop
                                ? null
                                : socketIO.sendMessage("startGame",
                                    '{ "hideTime": "$hideTime", "roomPass": "$roomPass"}'),
                            child: Text(
                              "Go Hide",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 30.0,
                              ),
                            ),
                          ),
                        )
                      : Text(
                          "Waiting for the host to start the game!",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 30.0,
                          ),
                        ),
                ],
              ),
              bottomNavigationBar: host
                  ? BottomNavigationBar(
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
                    )
                  : null,
            );
          }
          ;
          return CircularProgressIndicator();
        });
  }

  transformSeconds(int seconds) {
    int minutes = (seconds / 60).truncate();

    String minutesStr = (minutes % 60).toString().padLeft(2, '0');
    String secondsStr = (seconds % 60).toString().padLeft(2, '0');

    return "$minutesStr:$secondsStr";
  }

  void handleClick(String value) async {
    if (value == 'Leave lobby') {
      print('leaving the lobby');
      socketIO.sendMessage("leaveRoom", null);
      Navigator.pushNamed(context, '/');
    }
  }

  gameSettings(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Set number of minutes for hide and seek time'),
          content: settingsSelect(),
        );
      },
    );
  }

  settingsSelect() {
    TextEditingController _c = new TextEditingController(text: '1');
    TextEditingController _g = new TextEditingController(text: '10');
    TextEditingController _radius = new TextEditingController(text: '100');
    String hiderSelected = selectedHider;
    return StatefulBuilder(
        builder: (BuildContext context, StateSetter setLocalState) {
      return Container(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            TextField(
              keyboardType: TextInputType.number,
              controller: _c,
              decoration: new InputDecoration(labelText: 'Hide Time'),
            ),
            TextField(
              keyboardType: TextInputType.number,
              controller: _g,
              decoration: new InputDecoration(labelText: 'Seek Time'),
            ),
            TextField(
              keyboardType: TextInputType.number,
              controller: _radius,
              decoration: new InputDecoration(labelText: 'Radius Meterage'),
            ),
            DropdownButton(
              value: hiderSelected,
              hint: Text('Choose who will hide'),
              items: _players.map<DropdownMenuItem<String>>((value) {
                final playerName = value["user_name"];
                return new DropdownMenuItem<String>(
                  value: playerName,
                  child: new Text(playerName),
                );
              }).toList(),
              onChanged: (String val) {
                setLocalState(() {
                  hiderSelected = val;
                });
              },
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
                        this.hideTime = int.parse(_c.text);
                        this.seekTime = int.parse(_g.text);
                        this.radiusMeterage = int.parse(_radius.text);
                        this.selectedHider = hiderSelected;
                      });
                      Navigator.of(context).pop();
                    }),
              ],
            ),
          ],
        ),
      );
    });
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
