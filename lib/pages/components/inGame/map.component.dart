import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'dart:ui' as ui;

class InGameMap extends StatefulWidget {
  InGameMap({Key key, this.followWithCamera, this.radiusMeterage})
      : super(key: key);

  final bool followWithCamera;
  final int radiusMeterage;

  @override
  _InGameMapState createState() => _InGameMapState();
}

class _InGameMapState extends State<InGameMap> {
  Marker hider;
  Marker seeker;
  Circle circle;
  GoogleMapController _controller;
  String _mapStyle;

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
          radius: widget.radiusMeterage.toDouble(),
          zIndex: 1,
          strokeColor: Colors.red,
          center: LatLng(54.882690, -2.930539),
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
    getCurrentLocation();
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
