import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';
import 'package:geolocator/geolocator.dart';
import './LobbyPage.dart';
import 'package:flutter/services.dart' show rootBundle;

class InGame extends StatefulWidget {
  InGame({Key key}) : super(key: key);

  @override
  _InGameState createState() => _InGameState();
}

class _InGameState extends State<InGame> {
  GlobalKey<ScaffoldState> _drawerKey = GlobalKey();
  Completer<GoogleMapController> _controller = Completer();
  Position position;

  Future<void> _getCurrentPosition() async {
    position = await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  }

  String _mapStyle;
  @override
  void initState() {
    super.initState();

    rootBundle.loadString('assets/map_style.txt').then((string) {
      _mapStyle = string;
    });
  }

  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _getCurrentPosition(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          var geolocator = Geolocator();
          var locationOptions = LocationOptions(
              accuracy: LocationAccuracy.high, distanceFilter: 2);

          geolocator
              .getPositionStream(locationOptions)
              .listen((Position pos) async {
            final GoogleMapController controller = await _controller.future;
            controller.moveCamera(
              CameraUpdate.newCameraPosition(
                new CameraPosition(
                  target: LatLng(pos.latitude, pos.longitude),
                  bearing: 90.0,
                  zoom: 17,
                  tilt: 45,
                ),
              ),
            );
          });
          return _body();
        }
        return CircularProgressIndicator();
      },
    );
  }

  _body() {
    return new Scaffold(
      key: _drawerKey,
      body: GoogleMap(
        myLocationEnabled: true,
        zoomControlsEnabled: false,
        mapType: MapType.normal,
        initialCameraPosition: CameraPosition(
          target: LatLng(position.latitude, position.longitude),
          bearing: 90.0,
          zoom: 17,
          tilt: 45,
        ),
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
          controller.setMapStyle(_mapStyle);
        },
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
            _drawerKey.currentState.openEndDrawer();
          }
        },
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            title: Text('Lobby'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            title: Text('Chat'),
          )
        ],
      ),
      drawerEdgeDragWidth: 0,
      endDrawer: Drawer(
        child: Text('Chat Here'),
      ),
    );
  }
}
