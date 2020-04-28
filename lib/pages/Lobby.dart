import 'package:flutter/material.dart';
import 'dart:async';

class Lobby extends StatefulWidget {
  const Lobby({Key key}) : super(key: key);

  @override
  _LobbyState createState() => _LobbyState();
}

class _LobbyState extends State<Lobby> {
  var _players = ['player 1', 'player 2', 'player 3', 'player 4'];

  Timer _timer;
  int _start = 300;

  void startTimer() {
    const oneSec = const Duration(seconds: 1);
    _timer = new Timer.periodic(
      oneSec,
      (Timer timer) => setState(
        () {
          if (_start < 1) {
            timer.cancel();
          } else {
            _start = _start - 1;
          }
        },
      ),
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: Text('Lobby'),
      ),
      body: Column(
        children: <Widget>[
          SizedBox(
            width: 50,
            height: 100,
            child: ListView.builder(
                itemCount: _players.length,
                itemBuilder: (context, index) {
                  final player = _players[index];
                  return ListTile(
                    title: Text(player),
                  );
                }),
          ),
          RaisedButton(
            onPressed: () {
              startTimer();
            },
            child: Text("Go Hide"),
          ),
          Text("$_start")
        ],
      ),
    );
  }
}
