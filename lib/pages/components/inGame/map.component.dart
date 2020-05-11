import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_socket_io/flutter_socket_io.dart';
import 'dart:ui' as ui;
import 'dart:convert' as convert;

class InGameMap extends StatefulWidget {
  InGameMap(
      {Key key,
      this.followWithCamera,
      this.radiusMeterage,
      this.radiusLatLng,
      this.hidingPoint,
      this.userName,
      this.userID,
      this.selectedHider,
      this.setShowFindButton,
      this.socketIO,
      this.roomPass})
      : super(key: key);

  final bool followWithCamera;
  final double radiusMeterage;
  final LatLng radiusLatLng;
  final LatLng hidingPoint;
  final String userName;
  final String userID;
  final String selectedHider;
  final Function setShowFindButton;
  final SocketIO socketIO;
  final String roomPass;
  @override
  _InGameMapState createState() => _InGameMapState();
}

class _InGameMapState extends State<InGameMap> {
  Marker hider;
  Marker seeker;
  Circle circle;
  GoogleMapController _controller;
  String _mapStyle;
  double radiusMeterage;
  LatLng radiusLatLng;
  double distanceInMeters;

  StreamSubscription _locationSubscription;
  Location _locationTracker = Location();

  static final CameraPosition initialLocation = CameraPosition(
    target: LatLng(55.3780518, -3.4359729),
    zoom: 4,
    tilt: 70.0,
  );

  void updateMarkerAndCircle(
      LocationData newLocalData, Uint8List hiderImage, Uint8List seekerImage) {
    LatLng latlng = LatLng(newLocalData.latitude, newLocalData.longitude);
    this.setState(() {
      circle = Circle(
          circleId: CircleId("hiding-area"),
          radius: widget.radiusMeterage,
          zIndex: 1,
          strokeColor: Colors.red,
          center: widget.radiusLatLng,
          fillColor: Colors.red.withAlpha(30));
    });
  }

  Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))
        .buffer
        .asUint8List();
  }

  void getCurrentLocation() async {
    try {
      var location = await _locationTracker.getLocation();
      print("widget.radiusMeterage");
      print(widget.radiusMeterage);

      Uint8List hiderImage =
          await getBytesFromAsset('assets/hider_marker.png', 100);
      Uint8List seekerImage =
          await getBytesFromAsset('assets/seeker_marker.png', 100);
      updateMarkerAndCircle(location, hiderImage, seekerImage);

      if (_locationSubscription != null) {
        _locationSubscription.cancel();
      }

      _locationSubscription =
          _locationTracker.onLocationChanged().listen((newLocalData) async {
        if (_controller != null) {
          if (widget.followWithCamera) {
            _controller.animateCamera(
              CameraUpdate.newCameraPosition(
                new CameraPosition(
                    bearing: 190,
                    // bearing: newLocalData.heading,
                    target:
                        LatLng(newLocalData.latitude, newLocalData.longitude),
                    tilt: 70,
                    zoom: 17.00),
              ),
            );
          }
          updateMarkerAndCircle(newLocalData, hiderImage, seekerImage);

          if (widget.selectedHider != widget.userName) {
            double curLat = newLocalData.latitude;
            double curLon = newLocalData.longitude;
            String userID = widget.userID;
            String userName = widget.userName;
            String roomPass = widget.roomPass;
            widget.socketIO.sendMessage("seekerPosition",
                '{ "user_id": "$userID", "user_name": "$userName", "roomPass": "$roomPass", "latitude": "$curLat", "longitude": "$curLon"}');
            double hidingLat = widget.hidingPoint.latitude;
            double hidingLon = widget.hidingPoint.longitude;
            distanceInMeters = await Geolocator()
                .distanceBetween(curLat, curLon, hidingLat, hidingLon);
            print(distanceInMeters);
            if (distanceInMeters < 20) {
              widget.setShowFindButton(true);
            } else {
              widget.setShowFindButton(false);
            }
          }
        }
      });
    } on PlatformException catch (e) {
      if (e.code == 'PERMISSION_DENIED') {
        debugPrint("Permission Denied");
      }
    }
  }

  handleSeekerPosition(dynamic data) async {
    try {
      Uint8List seekerImage =
          await getBytesFromAsset('assets/seeker_marker.png', 100);
      final Map body = convert.jsonDecode(data);
      double seekerLat = double.parse(body['latitude']);
      double seekerLon = double.parse(body['longitude']);
      setState(() {
        seeker = Marker(
            markerId: MarkerId("seeker"),
            position: LatLng(seekerLat, seekerLon),
            draggable: false,
            zIndex: 2,
            anchor: Offset(0.5, 0.5),
            icon: BitmapDescriptor.fromBytes(seekerImage));
      });
    } catch (err) {
      print(err);
    }
  }

  @override
  void initState() {
    rootBundle.loadString('assets/map_style.txt').then((string) {
      _mapStyle = string;
    });
    if (widget.selectedHider == widget.userName) {}
    radiusMeterage = widget.radiusMeterage;
    radiusLatLng = widget.radiusLatLng;
    getCurrentLocation();
    super.initState();
  }

  @override
  void didUpdateWidget(InGameMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.radiusMeterage != oldWidget.radiusMeterage) {
      widget.socketIO.subscribe("seekerPosition", handleSeekerPosition);
      setState(() {
        radiusMeterage = widget.radiusMeterage;
        radiusLatLng = widget.radiusLatLng;
      });
    }
  }

  void dispose() {
    if (_locationSubscription != null) {
      _locationSubscription.cancel();
    }
    _controller = null;
    widget.socketIO.unSubscribe("seekerPosition");

    super.dispose();
  }

  Widget build(BuildContext context) {
    return GoogleMap(
      mapType: MapType.normal,
      initialCameraPosition: initialLocation,
      myLocationButtonEnabled: false,
      myLocationEnabled: true,
      zoomControlsEnabled: false,
      markers: Set.of((seeker != null) ? [seeker] : []),
      circles: Set.of((circle != null) ? [circle] : []),
      onMapCreated: (GoogleMapController controller) {
        _controller = controller;
        controller.setMapStyle(_mapStyle);
      },
    );
  }
}
