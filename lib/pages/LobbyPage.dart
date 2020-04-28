import 'package:flutter/material.dart';
import 'package:hideandseek/pages/HomePage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LobbyPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    void logoutUser() async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs?.clear();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (BuildContext context) => HomePage()),
        ModalRoute.withName("/register"),
      );
    }

    return Container(
      child: RaisedButton(
        onPressed: logoutUser,
        child: Text('Logout'),
      ),
    );
  }
}
