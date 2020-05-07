import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hideandseek/pages/components/chat/chat.component.dart';
import 'package:hideandseek/pages/components/clues/Clues.component.dart';
import 'package:location/location.dart';
import 'package:badges/badges.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:ui' as ui;
import './LobbyPage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_socket_io/flutter_socket_io.dart';
import 'dart:convert' as convert;
import 'package:quiver/async.dart';

class MapPage extends StatefulWidget {
  MapPage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  var _players;
  GlobalKey<ScaffoldState> _drawerKey = GlobalKey();
  StreamSubscription _locationSubscription;
  Location _locationTracker = Location();
  Marker hider;
  Marker seeker;
  Circle circle;
  GoogleMapController _controller;
  bool followWithCamera = true;
  int _chatCounter = 0;
  int _clueCounter = 0;
  SocketIO socketIO;
  String userName;
  String userID;
  String roomPass;
  String hiderID;
  bool host;

  // timer - setup
  int hiderTime = 0;
  int _current = 0;
  String elapsedTime = '';
  bool startStop = false;

  //GameData
  LatLng hidingPoint;

  static final CameraPosition initialLocation = CameraPosition(
    target: LatLng(55.3780518, -3.4359729),
    zoom: 4,
    tilt: 70.0,
  );

  Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))
        .buffer
        .asUint8List();
  }

  Future<Null> getSharedPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userName = prefs.getString("user_name");
    userID = prefs.getString("user_id");
    roomPass = prefs.getString("roomPass");
    hiderID = prefs.getString("hiderID");
    var hide = DateTime.parse(prefs.getString("hideTime"));
    var now = new DateTime.now();
    var difTime = hide.difference(now);
    hiderTime = difTime.inSeconds;
    _current = difTime.inSeconds;
    host = prefs.getBool("host");
    _players = convert.jsonDecode(prefs.getString("users"));
    print("time");
    print(hiderTime);
    startTimer(hiderTime);
  }

  void updateMarkerAndCircle(
      LocationData newLocalData, Uint8List hiderImage, Uint8List seekerImage) {
    LatLng latlng = LatLng(newLocalData.latitude, newLocalData.longitude);
    this.setState(() {
      hider = Marker(
          markerId: MarkerId("hider"),
          position: latlng,
          draggable: false,
          zIndex: 2,
          anchor: Offset(0.5, 0.5),
          icon: BitmapDescriptor.fromBytes(hiderImage));

      seeker = Marker(
          markerId: MarkerId("seeker"),
          position: LatLng(54.883211, -2.928458),
          draggable: false,
          zIndex: 2,
          anchor: Offset(0.5, 0.5),
          icon: BitmapDescriptor.fromBytes(seekerImage));

      circle = Circle(
          circleId: CircleId("hiding-area"),
          radius: 300,
          zIndex: 1,
          strokeColor: Colors.red,
          center: LatLng(54.882690, -2.930539),
          fillColor: Colors.red.withAlpha(30));
    });
  }

  Future<void> setHidingPoint(dynamic data) async {
    print(data);
    final Map body = convert.jsonDecode(data);
    var seek = DateTime.parse(body["seekTime"]);
    var now = new DateTime.now();
    var difference = seek.difference(now);
    print(difference.inSeconds);

    LocationData hidingLocation = await _locationTracker.getLocation();
    setState(() {
      hidingPoint = LatLng(hidingLocation.latitude, hidingLocation.longitude);
    });
  }

  void getCurrentLocation() async {
    try {
      Uint8List hiderImage =
          await getBytesFromAsset('assets/hider_marker.png', 100);
      Uint8List seekerImage =
          await getBytesFromAsset('assets/seeker_marker.png', 100);
      var location = await _locationTracker.getLocation();
      updateMarkerAndCircle(location, hiderImage, seekerImage);

      if (_locationSubscription != null) {
        _locationSubscription.cancel();
      }

      _locationSubscription =
          _locationTracker.onLocationChanged().listen((newLocalData) {
        if (_controller != null) {
          if (followWithCamera) {
            _controller.animateCamera(
              CameraUpdate.newCameraPosition(
                new CameraPosition(
                    bearing: newLocalData.heading,
                    target:
                        LatLng(newLocalData.latitude, newLocalData.longitude),
                    tilt: 70,
                    zoom: 17.00),
              ),
            );
          }
          updateMarkerAndCircle(newLocalData, hiderImage, seekerImage);
        }
      });
    } on PlatformException catch (e) {
      if (e.code == 'PERMISSION_DENIED') {
        debugPrint("Permission Denied");
      }
    }
  }

  String _mapStyle;
  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.bottom]);
    rootBundle.loadString('assets/map_style.txt').then((string) {
      _mapStyle = string;
    });
    getCurrentLocation();
  }

  void dispose() {
    if (_locationSubscription != null) {
      _locationSubscription.cancel();
    }
    super.dispose();
  }

  void startTimer(time) {
    CountdownTimer countDownTimer = new CountdownTimer(
      new Duration(seconds: time),
      new Duration(seconds: 1),
    );

    var sub = countDownTimer.listen(null);
    sub.onData((duration) {
      setState(() {
        _current = time - duration.elapsed.inSeconds;
        elapsedTime = transformSeconds(_current);
        startStop = true;
      });
    });

    sub.onDone(() {
//LAUNCH THE GAME
      sub.cancel();
    });
  }

  transformSeconds(int seconds) {
    int minutes = (seconds / 60).truncate();

    String minutesStr = (minutes % 60).toString().padLeft(2, '0');
    String secondsStr = (seconds % 60).toString().padLeft(2, '0');

    return "$minutesStr:$secondsStr";
  }

  @override
  Widget build(BuildContext context) {
    socketIO = ModalRoute.of(context).settings.arguments;
    socketIO.subscribe("startSeek", setHidingPoint);

    return FutureBuilder(
        future: getSharedPrefs(),
        builder: (context, snapshot) {
          print(roomPass);
          return new Scaffold(
            key: _drawerKey,
            body: Stack(
              children: <Widget>[
                GoogleMap(
                  mapType: MapType.normal,
                  initialCameraPosition: initialLocation,
                  myLocationButtonEnabled: false,
                  myLocationEnabled: true,
                  zoomControlsEnabled: false,
                  markers: Set.of((hider != null) ? [seeker] : []),
                  circles: Set.of((circle != null) ? [circle] : []),
                  onMapCreated: (GoogleMapController controller) {
                    _controller = controller;
                    controller.setMapStyle(_mapStyle);
                  },
                ),
                Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Text(
                      elapsedTime,
                      style: TextStyle(
                          fontSize: 25.0, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                userName == hiderID
                    ? Align(
                        alignment: Alignment.bottomLeft,
                        child: Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: RaisedButton(
                              child: Text('Set Your Hiding Point'),
                              color: Colors.yellow[600],
                              onPressed: () {
                                socketIO.sendMessage("startSeek",
                                    '{ "seekTime": 10, "roomPass": "$roomPass"}');
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
                          ? Colors.blue
                          : Colors.blue.withAlpha(30),
                      onPressed: () {
                        getCurrentLocation();
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
                    MaterialPageRoute(
                        builder: (BuildContext context) => LobbyPage()),
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
        });
  }

  _chatCounterValue(BuildContext context) async {
    final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Chat(
              socketIO: socketIO,
              userName: userName,
              hiderID: hiderID,
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
              hiderID: hiderID,
              roomPass: roomPass),
        ));
    if (result != null) {
      setState(() {
        _clueCounter = result;
      });
    }
  }
}
