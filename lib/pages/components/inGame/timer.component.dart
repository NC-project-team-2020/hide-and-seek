import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_socket_io/flutter_socket_io.dart';

class InGameTimer extends StatefulWidget {
  InGameTimer({
    Key key,
    this.turn,
    this.elapsedTime,
    this.elapsedTimeSeek,
  }) : super(key: key);

  final String turn;
  final String elapsedTime;
  final String elapsedTimeSeek;

  @override
  _InGameTimerState createState() => _InGameTimerState();
}

class _InGameTimerState extends State<InGameTimer> {
  String turn;

  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    String turn = widget.turn;
    return Column(
      children: <Widget>[
        Text(
          "Turn: $turn",
          style: TextStyle(fontSize: 25.0, fontWeight: FontWeight.bold),
        ),
        Text(
          turn == "hide" ? widget.elapsedTime : widget.elapsedTimeSeek,
          style: TextStyle(fontSize: 25.0, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
