import 'package:flutter/material.dart';
import 'package:hideandseek/pages/LobbyPage.dart';
import 'dart:convert' as convert;
import 'package:http/http.dart' as http;
import '../requests.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _username = TextEditingController();
  final TextEditingController _password = TextEditingController();

  validateAndSave() async {
    if (_formKey.currentState.validate()) {
      String body = convert.jsonEncode(<String, String>{
        'user_name': _username.text,
        'password': _password.text
      });
      http.Response response = await validateLogin(body);
      if (response.statusCode == 200) {
        final Map body = convert.jsonDecode(response.body);
        final Map user = body['user'];
        SharedPreferences prefs = await SharedPreferences.getInstance();

        prefs?.setBool('isLoggedIn', true);
        prefs.setString('token', user['token']);
        prefs.setString('user_id', user['id']);
        prefs.setString('user_name', user['user_name']);
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (BuildContext context) => LobbyPage()),
          ModalRoute.withName("/"),
        );
      } else {
        final failedSnackBar = SnackBar(
          backgroundColor: Colors.red[500],
          content: Text(
            'Invalid login',
          ),
        );
        _scaffoldKey.currentState.showSnackBar(failedSnackBar);
      }
    }
  }

  final _scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  void dispose() {
    // Clean up the controller when the widget is removed from the
    // widget tree.
    _username.dispose();
    _password.dispose();
    super.dispose();
  }

  Widget build(BuildContext context) {
    return new Scaffold(
      key: _scaffoldKey,
      appBar: new AppBar(
        title: Text('Peekaboo'),
      ),
      body: Padding(
        padding: EdgeInsets.all(18.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Center(
              child: Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    TextFormField(
                      controller: _username,
                      decoration: const InputDecoration(
                        labelText: 'Username',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Please enter some text';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _password,
                      obscureText: true,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Password',
                      ),
                      validator: (value) =>
                          value.isEmpty ? 'The field can\'t be empty' : null,
                    ),
                    RaisedButton(
                      onPressed: () {
                        validateAndSave();
                      },
                      child: Text('Login'),
                    ),
                  ],
                ),
              ),
            ),
            RaisedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/register');
              },
              child: Text('Register Here'),
            ),
          ],
        ),
      ),
    );
  }
}
