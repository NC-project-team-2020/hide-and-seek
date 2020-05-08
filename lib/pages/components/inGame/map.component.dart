import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:ui' as ui;

class InGameMap extends StatefulWidget {
  InGameMap(
      {Key key,
      this.followWithCamera,
      this.radiusMeterage,
      this.radiusLatLng,
      this.hidingPoint,
      this.userName,
      this.selectedHider,
      this.setShowFindButton})
      : super(key: key);

  final bool followWithCamera;
  final double radiusMeterage;
  final LatLng radiusLatLng;
  final LatLng hidingPoint;
  final String userName;
  final String selectedHider;
  final Function setShowFindButton;
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
            double hidingLat = widget.hidingPoint.latitude;
            double hidingLon = widget.hidingPoint.longitude;
            distanceInMeters = await Geolocator().distanceBetween(
                newLocalData.latitude,
                newLocalData.longitude,
                hidingLat,
                hidingLon);
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

  @override
  void initState() {
    super.initState();
    rootBundle.loadString('assets/map_style.txt').then((string) {
      _mapStyle = string;
    });
    radiusMeterage = widget.radiusMeterage;
    radiusLatLng = widget.radiusLatLng;
    getCurrentLocation();
  }

  @override
  void didUpdateWidget(InGameMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.radiusMeterage != oldWidget.radiusMeterage) {
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
    super.dispose();
  }

  Widget build(BuildContext context) {
    return GoogleMap(
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
    );
  }
}
