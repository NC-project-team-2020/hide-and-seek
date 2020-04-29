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

    createRoomDialog(BuildContext context) {
      TextEditingController customController = TextEditingController();

      return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Name for your room'),
            content: TextField(
              controller: customController,
            ),
            actions: <Widget>[
              MaterialButton(
                  elevation: 5.0,
                  child: Text('Close'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  }),
              MaterialButton(
                  elevation: 5.0,
                  child: Text('Create Room'),
                  onPressed: () {
                    Navigator.of(context).pop(customController.text.toString());
                  })
            ],
          );
        },
      );
    }

    joinRoomDialog(BuildContext context) {
      TextEditingController customController = TextEditingController();

      return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Room ID'),
            content: TextField(
              controller: customController,
            ),
            actions: <Widget>[
              MaterialButton(
                  elevation: 5.0,
                  child: Text('Close'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  }),
              MaterialButton(
                  elevation: 5.0,
                  child: Text('Join Room'),
                  onPressed: () {
                    Navigator.of(context).pop(customController.text.toString());
                  }),
            ],
          );
        },
      );
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
                  createRoomDialog(context).then((roomName) {
                    if (roomName.toString().length > 0 && roomName != null) {
                      //Logic for creating room goes here
                      print(roomName);
                    }
                  });
                },
                child: Text('Create Room'),
              ),
              RaisedButton(
                onPressed: () {
                  joinRoomDialog(context).then((roomID) {
                    if (roomID.toString().length > 0 && roomID != null) {
                      //Logic for joining room goes here
                      print(roomID);
                      Navigator.pushNamed(context, '/lobby-room');
                    }
                  });
                },
                child: Text('Join Room'),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            title: Text('Lobby'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            title: Text('User Profile'),
          )
        ],
      ),
    );
  }
}
