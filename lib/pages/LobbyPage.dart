import 'package:flutter/material.dart';
import 'package:hideandseek/pages/HomePage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LobbyPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    void handleClick(String value) async {
      if (value == 'Logout') {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs?.clear();
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (BuildContext context) => HomePage()),
          ModalRoute.withName("/register"),
        );
      } else if (value == 'Settings') {
        print('Settings');
      }
    }

    return Scaffold(
      appBar: new AppBar(
        title: Text('Lobby'),
        backgroundColor: Color(0xff05668D),
        actions: <Widget>[
          PopupMenuButton<String>(
            onSelected: handleClick,
            itemBuilder: (BuildContext context) {
              return {'Logout', 'Settings'}.map((String choice) {
                return PopupMenuItem<String>(
                  value: choice,
                  child: Text(choice),
                );
              }).toList();
            },
          ),
        ],
      ),
      backgroundColor: Color(0xffEBF2FA),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(18.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              RaisedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/lobby-room');
                },
                child: Text('Create Room'),
              ),
              RaisedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/register');
                },
                child: Text('Join Room'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
