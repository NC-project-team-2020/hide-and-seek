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

class MapPage extends StatefulWidget {
  MapPage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
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

  Future<void> setHidingPoint() async {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                '05:39',
                style: TextStyle(fontSize: 25.0, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomLeft,
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: RaisedButton(
                child: Text('Set Your Hiding Point'),
                color: Colors.yellow[600],
                onPressed: setHidingPoint,
              ),
            ),
          ),
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
              MaterialPageRoute(builder: (BuildContext context) => LobbyPage()),
              ModalRoute.withName("/"),
            );
          } else if (value == 1) {
            // _drawerKey.currentState.openDrawer();
            _clueCounterValue(context);
          } else if (value == 2) {
            // _drawerKey.currentState.openEndDrawer();
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
            title: Text(
              'Clues',
            ),
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
      drawerEdgeDragWidth: 10,
      // endDrawer: Drawer(
      //   child: Chat(),
      // ),
      drawer: Drawer(child: Clues()),
    );
  }

  _chatCounterValue(BuildContext context) async {
    final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Chat(),
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
          builder: (context) => Clues(),
        ));
    if (result != null) {
      setState(() {
        _clueCounter = result;
      });
    }
  }
}
