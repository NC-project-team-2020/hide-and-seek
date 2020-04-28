import 'package:flutter/material.dart';
import 'package:hideandseek/pages/LobbyPage.dart';
import 'dart:convert' as convert;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _formKey = GlobalKey<FormState>();

  String _username;
  String _password;

  validateAndSave() async {
    if (_formKey.currentState.validate()) {
      // String url = 'https://peekaboo-be.herokuapp.com/api/users/login';
      // var response = await http
      //     .post(url, body: {"user_name": "hannes", "password": "test"});
      // var body = convert.jsonDecode(response.body);
      // print(body);

      if (1 == 1) {
        SharedPreferences prefs = await SharedPreferences.getInstance();

        prefs?.setBool('isLoggedIn', true);
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (BuildContext context) => LobbyPage()),
          ModalRoute.withName("/"),
        );
      } else {}
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
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
                      initialValue: _username,
                      onChanged: (text) {
                        setState(() {
                          _username = text;
                        });
                      },
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
                      initialValue: _password,
                      onChanged: (text) {
                        setState(() {
                          _password = text;
                        });
                      },
                      obscureText: true,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Password',
                      ),
                      validator: (value) =>
                          value.isEmpty ? 'The field can\'t be empty' : null,
                    ),
                    RaisedButton(
                      onPressed: validateAndSave,
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
