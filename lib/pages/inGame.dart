import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hideandseek/pages/components/chat/chat.component.dart';
import 'package:hideandseek/pages/components/clues/Clues.component.dart';
import 'package:location/location.dart';
import './LobbyPage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_socket_io/flutter_socket_io.dart';
import 'dart:convert' as convert;
import './components/inGame/map.component.dart';
import './components/inGame/timer.component.dart';

class MapPage extends StatefulWidget {
  MapPage({Key key}) : super(key: key);

  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  var _players;
  GlobalKey<ScaffoldState> _drawerKey = GlobalKey();
  bool followWithCamera = true;
  Location _locationTracker = Location();
  int _chatCounter = 0;
  int _clueCounter = 0;
  SocketIO socketIO;
  String userName;
  String userID;
  String roomPass;
  String selectedHider;
  bool host;
  String turn = "hide";
  Timer _startTimer;
  bool setArgsFlag = true;
  // timer - setup
  int hiderTime = 0;
  String seekerInitTime;
  int seekerTime = 0;
  bool hiderTimeStart = false;

  int _current = 0;
  String elapsedTime = '';
  bool startStop = false;

  int _currentSeek = 0;
  String elapsedTimeSeek = '';
  bool startStopSeek = false;

  //GameData
  LatLng hidingPoint = LatLng(55.3780518, -3.4359729);
  double radiusMeterage = 1;
  LatLng radiusLatLng = LatLng(55.3780518, -3.4359729);
  bool showFindButton = false;
  String confirmFindMsg;
  bool showConfirmPopup;
  bool waitingForRes = false;

  Future<void> setHidingPoint(dynamic data) async {
    _startTimer.cancel();
    print(data);
    final Map body = convert.jsonDecode(data);
    var seek = DateTime.parse(body["seekTime"]);
    var now = new DateTime.now();
    var difTime = seek.difference(now);

    LocationData hidingLocation = await _locationTracker.getLocation();
    var hidingLat = hidingLocation.latitude;
    var hidingLon = hidingLocation.longitude;
    if (selectedHider == userName) {
      socketIO.sendMessage("hiderPosition",
          '{ "user_name": "$userName", "user_id": "$userID", "longitude": "$hidingLon", "latitude": "$hidingLat", "roomPass": "$roomPass"}');
    }
    if (userName != selectedHider) {
      timeToHunt(context);
    }
    setState(() {
      hidingPoint = LatLng(hidingLocation.latitude, hidingLocation.longitude);
      seekerTime = difTime.inSeconds;
      _currentSeek = difTime.inSeconds;
      turn = "seek";
    });

    startTimerSeek(seekerTime);
  }

  void startTimer(time) {
    const oneSec = const Duration(seconds: 1);
    _startTimer = new Timer.periodic(
      oneSec,
      (Timer timer) => setState(
        () {
          if (_current < 1) {
            if (turn == "hide") {
              socketIO.sendMessage("startSeek",
                  '{ "seekTime": $seekerTime, "roomPass": "$roomPass"}');
            }
          } else if (turn == "seek") {
            timer.cancel();
          } else {
            _current = _current - 1;
            elapsedTime = transformSeconds(_current);
          }
        },
      ),
    );
  }

  void startTimerSeek(time) {
    const oneSec = const Duration(seconds: 1);
    _startTimer = new Timer.periodic(
      oneSec,
      (Timer timer) => setState(
        () {
          if (_currentSeek < 1) {
            print("less than 1");
            if (host) {
              print("host");
              socketIO.sendMessage("endGame",
                  '{ "winner": "$selectedHider", "roomPass": "$roomPass"}');
            }
            timer.cancel();
          } else {
            _currentSeek = _currentSeek - 1;
            elapsedTimeSeek = transformSeconds(_currentSeek);
          }
        },
      ),
    );
  }

  transformSeconds(int seconds) {
    int minutes = (seconds / 60).truncate();

    String minutesStr = (minutes % 60).toString().padLeft(2, '0');
    String secondsStr = (seconds % 60).toString().padLeft(2, '0');

    return "$minutesStr:$secondsStr";
  }

  setShowFindButton(bool boolean) {
    setState(() {
      showFindButton = boolean;
    });
  }

  @override
  void initState() {
    SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.bottom]);
    super.initState();
  }

  void dispose() {
    socketIO.unSubscribe("startSeek");
    socketIO.unSubscribe("hiderPosition");
    socketIO.unSubscribe("confirmFind");
    socketIO.unSubscribe("endGame");
    socketIO.unSubscribe("confirmFindReply");
    _startTimer.cancel();
    super.dispose();
  }

  setArgs(dynamic args) async {
    print(args);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString("user_name");
      userID = prefs.getString("user_id");
      roomPass = prefs.getString("roomPass");
      host = prefs.getBool("host");
      _players = convert.jsonDecode(prefs.getString("users"));
      seekerTime = args['seekTime'];
      radiusMeterage = double.parse(args['radiusMeterage']);
      print(radiusMeterage);
      double radiusLat = double.parse(args['radiusLat']);
      double radiusLon = double.parse(args['radiusLon']);
      radiusLatLng = LatLng(radiusLat, radiusLon);
      selectedHider = args['selectedHider'];
      socketIO = args['socketIO'];
      var hide = DateTime.parse(args['hideTime']);
      var now = new DateTime.now();
      var difTime = hide.difference(now);
      hiderTime = difTime.inSeconds;
      _current = difTime.inSeconds;
      socketIO.subscribe("startSeek", setHidingPoint);
      socketIO.subscribe("hiderPosition", getHidingPoint);
      socketIO.subscribe("confirmFind", confirmFind);
      socketIO.subscribe("endGame", endGame);
      socketIO.subscribe("confirmFindReply", confirmFindReply);
    });
    if (!hiderTimeStart) {
      hiderTimeStart = true;
      startTimer(hiderTime);
    }
  }

  endGame(dynamic data) {
    final Map body = convert.jsonDecode(data);
    Map<String, dynamic> arguments = {
      'socketIO': socketIO,
      'winner': body['winner']
    };
    Navigator.pushNamed(context, '/lobby-room', arguments: arguments);
  }

  confirmFindReply(dynamic data) {
    if (userName != selectedHider) {
      confirmFindReplyDialog(context);
    }
  }

  confirmFind(dynamic data) {
    if (userName == selectedHider) {
      final Map body = convert.jsonDecode(data);

      confirmFindMsg = body['msg'];
      String seeker = body['userName'];
      showConfirmPopup = true;
      confirmFindDialog(context).then((value) {
        if (value == true) {
          socketIO.sendMessage(
              "endGame", '{ "winner": $seeker, "roomPass": "$roomPass"}');
        } else if (value == false) {
          socketIO.sendMessage("confirmFindReply",
              '{ "confirm": $value, "roomPass": "$roomPass"}');
        }
      });
    }
  }

  timeToHunt(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Now it's time to hunt!"),
          actions: <Widget>[
            MaterialButton(
                elevation: 5.0,
                child: Text('Go!'),
                onPressed: () {
                  Navigator.of(context).pop();
                }),
          ],
        );
      },
    );
  }

  confirmFindDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(confirmFindMsg),
          actions: <Widget>[
            MaterialButton(
                elevation: 5.0,
                child: Text('Deny'),
                onPressed: () {
                  Navigator.of(context).pop(false);
                }),
            MaterialButton(
                elevation: 5.0,
                child: Text('Confirm'),
                onPressed: () {
                  Navigator.of(context).pop(true);
                }),
          ],
        );
      },
    );
  }

  confirmFindReplyDialog(BuildContext context) {
    setState(() {
      waitingForRes = false;
    });
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('You did not find the hider...'),
          actions: <Widget>[
            MaterialButton(
                elevation: 5.0,
                child: Text('Keep on hunting!'),
                onPressed: () {
                  Navigator.of(context).pop();
                }),
          ],
        );
      },
    );
  }

  getHidingPoint(dynamic data) {
    final Map body = convert.jsonDecode(data);
    double hidingLat = double.parse(body["latitude"]);
    double hidingLon = double.parse(body["longitude"]);
    hidingPoint = LatLng(hidingLat, hidingLon);
  }

  @override
  Widget build(BuildContext context) {
    if (setArgsFlag) {
      setArgsFlag = false;
      setArgs(ModalRoute.of(context).settings.arguments);
    }
    return new Scaffold(
      key: _drawerKey,
      body: Stack(
        children: <Widget>[
          InGameMap(
              followWithCamera: followWithCamera,
              radiusMeterage: radiusMeterage,
              radiusLatLng: radiusLatLng,
              hidingPoint: hidingPoint,
              userName: userName,
              userID: userID,
              selectedHider: selectedHider,
              setShowFindButton: setShowFindButton,
              socketIO: socketIO,
              roomPass: roomPass),
          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                children: <Widget>[
                  InGameTimer(
                      turn: turn,
                      elapsedTime: elapsedTime,
                      elapsedTimeSeek: elapsedTimeSeek,
                      selectedHider: selectedHider,
                      userName: userName),
                ],
              ),
            ),
          ),
          userName == selectedHider && turn == "hide"
              ? Align(
                  alignment: Alignment.bottomLeft,
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: RaisedButton(
                        child: Text(
                          'Set Your Hiding Point',
                          style: TextStyle(color: Colors.white),
                        ),
                        color: Color(int.parse('0xff7c94a1')),
                        onPressed: () {
                          socketIO.sendMessage("startSeek",
                              '{ "seekTime": $seekerTime, "roomPass": "$roomPass"}');
                        }),
                  ),
                )
              : Container(),
          userName != selectedHider && showFindButton
              ? Align(
                  alignment: Alignment.bottomLeft,
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: RaisedButton(
                        child: Text(
                          !waitingForRes
                              ? 'Found Hider'
                              : 'Waiting for response',
                          style: TextStyle(color: Colors.white),
                        ),
                        color: Color(int.parse('0xff7c94a1')),
                        onPressed: () {
                          if (waitingForRes) {
                            return null;
                          }
                          setState(() {
                            waitingForRes = true;
                          });
                          socketIO.sendMessage("confirmFind",
                              '{ "userName": "$userName", "roomPass": "$roomPass"}');
                        }),
                  ),
                )
              : Container(),
          Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: FloatingActionButton(
                heroTag: 'getLocation',
                child: Icon(Icons.location_on),
                backgroundColor: followWithCamera
                    ? Color(int.parse("0xff272744"))
                    : Color(int.parse("0xff272744")).withAlpha(20),
                onPressed: () {
                  // getCurrentLocation();
                  setState(() {
                    followWithCamera = !followWithCamera;
                  });
                },
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        onTap: (value) {
          if (value == 0) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (BuildContext context) => LobbyPage()),
              ModalRoute.withName("/"),
            );
          } else if (value == 0) {
            _chatCounterValue(context);
          } else if (value == 1) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (BuildContext context) => LobbyPage()),
              ModalRoute.withName("/"),
            );
          }
        },
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(
              Icons.chat,
            ),
            title: Text('Chat'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.exit_to_app),
            title: Text('Leave Game'),
          )
        ],
      ),
    );
  }

  _chatCounterValue(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Chat(
          socketIO: socketIO,
          userName: userName,
          hiderID: selectedHider,
          roomPass: roomPass,
        ),
      ),
    );
    if (result != null) {
      setState(() {
        _chatCounter = result;
      });
    }
  }

  _clueCounterValue(BuildContext context) async {
    final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Clues(
              socketIO: socketIO,
              userName: userName,
              hiderID: selectedHider,
              roomPass: roomPass),
        ));
    if (result != null) {
      setState(() {
        _clueCounter = result;
      });
    }
  }
}
