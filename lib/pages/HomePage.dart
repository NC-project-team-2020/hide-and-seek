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

  bool isLoading = false;

  validateAndSave() async {
    setState(() {
      isLoading = true;
    });
    if (_formKey.currentState.validate()) {
      String body = convert.jsonEncode(<String, dynamic>{
        'user_name': _username.text,
        'password': _password.text
      });
      http.Response response = await userReq('login', body);
      if (response.statusCode == 200) {
        final Map body = convert.jsonDecode(response.body);
        final Map user = body['user'];
        SharedPreferences prefs = await SharedPreferences.getInstance();
        List<dynamic> avatarDyn = user['avatar']['data'];
        List<dynamic> avatar = avatarDyn.cast<int>();
        List<String> avatarStrList = avatar.map((i) => i.toString()).toList();
        prefs?.setBool('isLoggedIn', true);
        prefs.setString('token', user['token']);
        prefs.setString('user_id', user['id']);
        prefs.setString('user_name', user['user_name']);
        prefs.setString('first_name', user['first_name']);
        prefs.setString('last_name', user['last_name']);
        prefs.setStringList('avatar', avatarStrList);
        prefs.setString('chatList', "[]");
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (BuildContext context) => LobbyPage()),
          ModalRoute.withName("/"),
        );
      } else {
        final Map body = convert.jsonDecode(response.body);
        final failedSnackBar = SnackBar(
          backgroundColor: Colors.red[500],
          content: Text(body['msg']),
        );
        _scaffoldKey.currentState.showSnackBar(failedSnackBar);
      }
    }
    setState(() {
      isLoading = false;
    });
  }

  final _scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    print(_password);
    return new Scaffold(
      key: _scaffoldKey,
      appBar: new AppBar(
        title: Text('Peekaboo'),
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.only(left: 18.0, right: 18.0),
          child: SingleChildScrollView(
            child: _form(),
          ),
        ),
      ),
    );
  }

  _form() {
    return Form(
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
                return 'Please enter your username';
              }
              return null;
            },
          ),
          SizedBox(height: 25.0),
          TextFormField(
            controller: _password,
            obscureText: true,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Password',
            ),
            validator: (value) =>
                value.isEmpty ? 'Please enter your password' : null,
          ),
          SizedBox(height: 15.0),
          SizedBox(
            height: 50.0,
            width: double.infinity,
            child: RaisedButton(
              color: Colors.blue,
              onPressed: () {
                if (isLoading) {
                  return null;
                }
                validateAndSave();
              },
              child: isLoading
                  ? CircularProgressIndicator(
                      valueColor:
                          new AlwaysStoppedAnimation<Color>(Colors.black),
                    )
                  : Text('Login'),
            ),
          ),
          SizedBox(height: 10.0),
          SizedBox(
            height: 50.0,
            width: double.infinity,
            child: RaisedButton(
              onPressed: () {
                if (isLoading) {
                  return null;
                }
                Navigator.pushNamed(context, '/register');
              },
              child: Text('Register Here'),
            ),
          ),
        ],
      ),
    );
  }
}
