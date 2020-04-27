import 'package:flutter/material.dart';
import 'dart:convert' as convert;
import 'package:http/http.dart' as http;

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
      if (_username == 'test' && _password == 'hello123') {
        _formKey.currentState.save();
      } else {}
      // String url = 'https://hannes-be-nc-news.herokuapp.com/api/articles';
      // var response = await http.get(url);
      // if (response.statusCode == 200) {
      //   var jsonBody = convert.jsonDecode(response.body);
      //   print(jsonBody);
      // }
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
