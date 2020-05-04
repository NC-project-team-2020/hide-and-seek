import 'package:flutter/material.dart';

class LobbyFunc {
  static transformSeconds(int seconds) {
    int minutes = (seconds / 60).truncate();

    String minutesStr = (minutes % 60).toString().padLeft(2, '0');
    String secondsStr = (seconds % 60).toString().padLeft(2, '0');

    return "$minutesStr:$secondsStr";
  }
}

showContent(BuildContext context) {
  return showDialog<Null>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return new AlertDialog(
        title: new Text('USER PROFILE NAME'),
        content: new SingleChildScrollView(
          child: new ListBody(
            children: <Widget>[
              new Text('AVATAR : X - show image'),
              new Text('Wins : X '),
              new Text('Loses : X'),
            ],
          ),
        ),
        actions: <Widget>[
          new FlatButton(
            child: new Text('Close'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}
