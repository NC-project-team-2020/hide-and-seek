import 'package:flutter/material.dart';
import 'package:hideandseek/pages/inGame.dart';
import 'pages/HomePage.dart';
import 'pages/Register.dart';
import 'pages/LobbyPage.dart';
import 'pages/Lobby.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';

void main() async {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  // This widget is the root of your application.
  const MyApp({Key key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _initialRoute = '/';
  Future<void> _navigateUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var status = prefs.getBool('isLoggedIn') ?? false;
    if (!status) {
      _initialRoute = '/login';
    }
  }

  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.bottom]);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _navigateUser(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Peekaboo',
            theme: ThemeData(
              fontFamily: 'RobotoCondensed',
              backgroundColor: Color(int.parse('0xffb8b8b8')),
              primaryColor: Color(
                int.parse('0xff433a60'),
              ),
            ),
            initialRoute: _initialRoute,
            routes: {
              '/': (context) => LobbyPage(),
              '/login': (context) => HomePage(),
              '/register': (context) => Register(),
              '/lobby-room': (context) => Lobby(),
              '/in-game': (context) => MapPage()
            },
          );
        }
        return CircularProgressIndicator();
      },
    );
  }
}
