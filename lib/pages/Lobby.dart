import 'package:flutter/material.dart';
import 'package:hideandseek/pages/components/Lobby.components.dart';
import 'package:quiver/async.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_socket_io/flutter_socket_io.dart';
import 'package:location/location.dart';
import 'dart:convert' as convert;

class Lobby extends StatefulWidget {
  const Lobby({Key key}) : super(key: key);

  @override
  _LobbyState createState() => _LobbyState();
}

class _LobbyState extends State<Lobby> with SingleTickerProviderStateMixin {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  var _players;
  int hideTime;
  int seekTime;
  int radiusMeterage;
  String elapsedTime = '';
  String selectedHider;
  String winner = null;
  bool host = false;
  bool startStop = false;
  String userName;
  String userID;
  String roomPass;
  SocketIO socketIO;
  var radiusLat;
  var radiusLon;
  bool setArgsFlag = true;

  Future<void> getSharedPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userName = prefs.getString("user_name");
    userID = prefs.getString("user_id");
    roomPass = prefs.getString("roomPass");
    host = prefs.getBool("host");
    _players = convert.jsonDecode(prefs.getString("users"));

    if (host) {
      Location _locationTracker = Location();
      var location = await _locationTracker.getLocation();
      radiusLat = location.latitude;
      radiusLon = location.longitude;
    }
  }

  void _handleUpdate(dynamic data) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final Map body = convert.jsonDecode(data);
    prefs.setString('users', convert.jsonEncode(body["users"]));
    setState(() {
      _players = body["users"];
    });
  }

  void launchGame(dynamic data) {
    try {
      final Map body = convert.jsonDecode(data);
      Map<String, dynamic> arguments = {
        'socketIO': socketIO,
        "seekTime": seekTime,
        "hideTime": body["hideTime"],
        "radiusMeterage": body["radiusMetres"],
        "radiusLat": body["latitude"],
        "radiusLon": body["longitude"],
        "selectedHider": selectedHider
      };
      Navigator.pushNamed(context, '/in-game', arguments: arguments);
    } catch (err) {
      print(err);
    }
  }

  setArgs(args) {
    setState(() {
      socketIO = args["socketIO"];
      socketIO.subscribe("usersUpdate", _handleUpdate);
      socketIO.subscribe("startGame", launchGame);
      winner = args["winner"];
    });
  }

  @override
  Widget build(BuildContext context) {
    if (setArgsFlag) {
      setArgsFlag = false;
      setArgs(ModalRoute.of(context).settings.arguments);
    }
    String color = "0xffb8b8b8";

    return FutureBuilder(
      future: getSharedPrefs(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return new Scaffold(
            key: _scaffoldKey,
            appBar: new AppBar(
              backgroundColor: Color(int.parse("0xff272744")),
              title: Text('Lobby'),
              actions: <Widget>[
                PopupMenuButton<String>(
                  onSelected: handleClick,
                  itemBuilder: (_) => <PopupMenuItem<String>>[
                    new PopupMenuItem<String>(
                        child: const Text('Leave lobby'), value: 'Leave lobby'),
                  ],
                ),
              ],
            ),
            backgroundColor: Color(int.parse(color)),
            body: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(
                        top: 35.0, left: 8.0, right: 8.0, bottom: 20.0),
                    child: Text('Room Password: $roomPass',
                        style: TextStyle(
                            fontSize: 25.0, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center),
                  ),
                  Text(
                    'Players:',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 25.0),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(
                    width: 150,
                    height: 300,
                    child: ListView.builder(
                        itemCount: _players?.length ?? 0,
                        itemBuilder: (context, index) {
                          final playerIndex = _players[index];
                          final userName = playerIndex['user_name'];
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  top: 20.0, left: 20.0, right: 20.0),
                              child: ListTile(
                                  title: RichText(
                                    text: TextSpan(
                                      style: Theme.of(context).textTheme.body1,
                                      children: [
                                        winner == userName
                                            ? WidgetSpan(
                                                child: Padding(
                                                  padding: const EdgeInsets
                                                          .symmetric(
                                                      horizontal: 2.0),
                                                  child: Icon(
                                                    Icons.stars,
                                                    color: Colors.yellow[700],
                                                  ),
                                                ),
                                              )
                                            : TextSpan(text: ' '),
                                        TextSpan(
                                            text: userName,
                                            style: TextStyle(fontSize: 25.0)),
                                      ],
                                    ),
                                  ),
                                  onTap: () {
                                    _showcontent(context);
                                  }),
                            ),
                          );
                        }),
                  ),
                  host
                      ? SizedBox(
                          height: 120.0,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: RaisedButton(
                              onPressed: () {
                                if (hideTime == null ||
                                    seekTime == null ||
                                    radiusMeterage == null ||
                                    selectedHider == null) {
                                  final failedSnackBar = SnackBar(
                                    backgroundColor: Colors.red[500],
                                    content: Text(
                                        'Complete Game Settings To Proceed.'),
                                  );
                                  _scaffoldKey.currentState
                                      .showSnackBar(failedSnackBar);
                                  return null;
                                }
                                socketIO.sendMessage("startGame",
                                    '{ "hideTime": "$hideTime", "roomPass": "$roomPass", "latitude": "$radiusLat", "longitude": "$radiusLon", "radiusMetres": "$radiusMeterage" }');
                              },
                              child: Text(
                                "Go Hide",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 30.0,
                                ),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10)),
                                side: BorderSide(
                                  width: 3,
                                  color: Color(int.parse('0xff65738c')),
                                ),
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
            ),
            bottomNavigationBar: host
                ? BottomNavigationBar(
                    backgroundColor: Color(int.parse('0xff433a60')),
                    selectedItemColor: Color(int.parse('0xff7c94a1')),
                    unselectedItemColor: Color(int.parse('0xfffbf5ef')),
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
        return new Scaffold(
          key: _scaffoldKey,
          appBar: new AppBar(
            backgroundColor: Color(int.parse("0xff272744")),
            title: Text('Lobby'),
            actions: <Widget>[
              PopupMenuButton<String>(
                onSelected: handleClick,
                itemBuilder: (_) => <PopupMenuItem<String>>[
                  new PopupMenuItem<String>(
                      child: const Text('Leave lobby'), value: 'Leave lobby'),
                ],
              ),
            ],
          ),
          backgroundColor: Color(int.parse(color)),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SizedBox(
                  height: 200,
                  width: 200,
                  child: CircularProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation(Color(int.parse('0xff433a60'))),
                    strokeWidth: 5.0,
                  ),
                ),
              ],
            ),
          ),
          bottomNavigationBar: host
              ? BottomNavigationBar(
                  backgroundColor: Color(int.parse('0xff433a60')),
                  selectedItemColor: Color(int.parse('0xff7c94a1')),
                  unselectedItemColor: Color(int.parse('0xfffbf5ef')),
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
      },
    );
  }

  transformSeconds(int seconds) {
    int minutes = (seconds / 60).truncate();

    String minutesStr = (minutes % 60).toString().padLeft(2, '0');
    String secondsStr = (seconds % 60).toString().padLeft(2, '0');

    return "$minutesStr:$secondsStr";
  }

  void handleClick(String value) async {
    if (value == 'Leave lobby') {
      socketIO.sendMessage("leaveRoom", null);
      Navigator.pushNamed(context, '/');
    }
  }

  gameSettings(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Game Settings'),
          content: settingsSelect(),
        );
      },
    );
  }

  settingsSelect() {
    TextEditingController _c = new TextEditingController(text: '5');
    TextEditingController _g = new TextEditingController(text: '10');
    TextEditingController _radius = new TextEditingController(text: '300');
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
              decoration: new InputDecoration(labelText: 'Hide Time (Minutes)'),
            ),
            TextField(
              keyboardType: TextInputType.number,
              controller: _g,
              decoration: new InputDecoration(labelText: 'Seek Time (Minutes)'),
            ),
            TextField(
              keyboardType: TextInputType.number,
              controller: _radius,
              decoration: new InputDecoration(labelText: 'Radius (Metres)'),
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
