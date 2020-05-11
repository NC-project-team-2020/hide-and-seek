import 'package:flutter/material.dart';

class InGameTimer extends StatefulWidget {
  InGameTimer(
      {Key key,
      this.turn,
      this.elapsedTime,
      this.elapsedTimeSeek,
      this.selectedHider,
      this.userName})
      : super(key: key);

  final String turn;
  final String elapsedTime;
  final String elapsedTimeSeek;
  final String selectedHider;
  final String userName;

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
    String title;
    if (widget.turn == "hide") {
      widget.selectedHider == widget.userName
          ? title = "Quick, Hide!"
          : title = "Wait for hider";
    } else {
      widget.selectedHider == widget.userName
          ? title = "Time To Chill"
          : title = "Time To Hunt!";
    }
    return Column(
      children: <Widget>[
        Text(
          title,
          style: TextStyle(
              fontSize: 25.0,
              fontWeight: FontWeight.bold,
              fontFamily: 'Ringbearer'),
        ),
        Text(
          widget.turn == "hide" ? widget.elapsedTime : widget.elapsedTimeSeek,
          style: TextStyle(
              fontSize: 25.0,
              fontWeight: FontWeight.bold,
              fontFamily: 'Ringbearer'),
        ),
      ],
    );
  }
}
