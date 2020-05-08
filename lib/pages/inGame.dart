import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hideandseek/pages/components/chat/chat.component.dart';
import 'package:hideandseek/pages/components/clues/Clues.component.dart';
import 'package:location/location.dart';
import 'package:badges/badges.dart';
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
<<<<<<< HEAD
          '{ "user_name": $userName, "user_id": $userID, "longitude": $hidingLon, "latitude": $hidingLat", roomPass": "$roomPass"}');
=======
          '{ "user_name": "$userName", "user_id": "$userID", "longitude": "$hidingLon", "latitude": "$hidingLat", "roomPass": "$roomPass"}');
>>>>>>> 2ccad04c94ed441eabf7a18b4658a55771bd6eb7
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
          if (_current < 1) {
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

  setShowFindButton(bool boolean){
    setState((){
      showFindButton = boolean;
    });
  }

  @override
  void initState() {
    SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.bottom]);
    super.initState();
  }

  void dispose() {
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
    });
    if (!hiderTimeStart) {
      hiderTimeStart = true;
      startTimer(hiderTime);
    }
  }

  getHidingPoint(dynamic data) {
<<<<<<< HEAD
    print('Hejehej funkar detta?');
    try {
      final Map body = convert.jsonDecode(data);
      double hidingLat = double.parse(body["latitude"]);
      double hidingLon = double.parse(body["longitude"]);
      hidingPoint = LatLng(hidingLat, hidingLon);
      print('vi kom hit');
      print(body);
      print(hidingPoint);
    } catch (err) {
      print(err);
    }
=======
    final Map body = convert.jsonDecode(data);
    double hidingLat = double.parse(body["latitude"]);
    double hidingLon = double.parse(body["longitude"]);
    hidingPoint = LatLng(hidingLat, hidingLon);
>>>>>>> 2ccad04c94ed441eabf7a18b4658a55771bd6eb7
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
              selectedHider: selectedHider
              setShowFindButton: setShowFindButton),
          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                children: <Widget>[
                  InGameTimer(
                      turn: turn,
                      elapsedTime: elapsedTime,
                      elapsedTimeSeek: elapsedTimeSeek),
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
                        child: Text('Set Your Hiding Point'),
                        color: Colors.yellow[600],
                        onPressed: () {
                          socketIO.sendMessage("startSeek",
                              '{ "seekTime": $seekerTime, "roomPass": "$roomPass"}');
                        }),
                  ),
                )
              : Container(),
          userName != selectedHider && showFindButton ? Align(
            alignment: Alignment.bottomLeft,
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: RaisedButton(
                        child: Text('Found Hider'),
                        color: Colors.yellow[600],
                        onPressed: () {
                          print("found");
                          // socketIO.sendMessage("startSeek",
                          //     '{ "seekTime": $seekerTime, "roomPass": "$roomPass"}');
                        }),
                  ),) : Container(),
          Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: FloatingActionButton(
                heroTag: 'getLocation',
                child: Icon(Icons.location_on),
                backgroundColor:
                    followWithCamera ? Colors.blue : Colors.blue.withAlpha(30),
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
          } else if (value == 1) {
            _clueCounterValue(context);
          } else if (value == 2) {
            _chatCounterValue(context);
          }
        },
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            title: Text('Lobby'),
          ),
          BottomNavigationBarItem(
            icon: Badge(
              showBadge: true,
              badgeContent: Text(
                '${_clueCounter.toString()}',
                style: TextStyle(color: Colors.white),
              ),
              child: Icon(Icons.search),
            ),
            title: Text('Clues'),
          ),
          BottomNavigationBarItem(
            icon: Badge(
              showBadge: true,
              badgeContent: Text(
                '${_chatCounter.toString()}',
                style: TextStyle(color: Colors.white),
              ),
              child: Icon(
                Icons.chat,
              ),
            ),
            title: Text('Chat'),
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
              roomPass: roomPass),
        ));
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
