import 'package:flutter/material.dart';
import 'package:quiver/async.dart';
import 'package:hideandseek/pages/HomePage.dart';
import 'package:hideandseek/pages/LobbyPage.dart';

class Lobby extends StatefulWidget {
  const Lobby({Key key}) : super(key: key);

  @override
  _LobbyState createState() => _LobbyState();
}

class _LobbyState extends State<Lobby> with SingleTickerProviderStateMixin {
  var _players = ['player 1', 'player 2', 'player 3', 'player 4'];

  int _start = 10;
  int _current = 10;
  //Need a way to get input from user to set time....
  String elapsedTime = '';
  bool startStop = false;

  void startTimer() {
    CountdownTimer countDownTimer = new CountdownTimer(
      new Duration(seconds: _start),
      new Duration(seconds: 1),
    );

    var sub = countDownTimer.listen(null);
    sub.onData((duration) {
      setState(() {
        _current = _start - duration.elapsed.inSeconds;
        elapsedTime = transformSeconds(_current);
        startStop = true;
      });
    });

    sub.onDone(() {
//LAUNCH THE GAME
      sub.cancel();
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
      //This is currently navigating to the Homepage but will need to redirect to launch of MAP
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: Text('Lobby'),
        actions: <Widget>[
          PopupMenuButton<String>(
            onSelected: handleClick,
            itemBuilder: (BuildContext context) {
              return {'Leave lobby', 'Settings'}.map((String choice) {
                return PopupMenuItem<String>(
                  value: choice,
                  child: Text(choice),
                );
              }).toList();
            },
          ),
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(elapsedTime,
              style: TextStyle(fontSize: 25.0), textAlign: TextAlign.center),
          SizedBox(
            width: 150,
            height: 300,
            child: ListView.builder(
                itemCount: _players.length,
                itemBuilder: (context, index) {
                  final player = _players[index];
                  return ListTile(
                      title: Text(
                        player,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 30.0,
                        ),
                      ),
                      onTap: () {
                        _showcontent(context);
                      });
                }),
          ),
          SizedBox(
            height: 80.0,
            child: RaisedButton(
              onPressed: () => startStop ? null : startTimer(),
              child: Text(
                "Go Hide",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 30.0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  transformSeconds(int seconds) {
    int minutes = (seconds / 60).truncate();

    String minutesStr = (minutes % 60).toString().padLeft(2, '0');
    String secondsStr = (seconds % 60).toString().padLeft(2, '0');

    return "$minutesStr:$secondsStr";
  }

  void handleClick(String value) async {
    if (value == 'Leave lobby') {
      print('leaving the lobby');
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (BuildContext context) => LobbyPage()),
          ModalRoute.withName("/LobbyPage"));
    } else if (value == 'Settings') {
      print('Settings');
    }
  }

  void _showcontent(BuildContext context) {
    showDialog<Null>(
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
}
