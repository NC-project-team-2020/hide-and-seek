import 'package:flutter/material.dart';

class Register extends StatefulWidget {
  const Register({Key key}) : super(key: key);

  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final _formKey = GlobalKey<FormState>();

  String _username;
  String _email;
  String _firstName;
  String _lastName;
  String _password;
  String _repeatPassword;

  validateAndSave() async {
    if (_formKey.currentState.validate()) {
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
        title: Text('Register New User'),
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
                      initialValue: _email,
                      onChanged: (text) {
                        setState(() {
                          _email = text;
                        });
                      },
                      decoration: const InputDecoration(
                        labelText: 'Email...',
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
                      initialValue: _firstName,
                      onChanged: (text) {
                        setState(() {
                          _firstName = text;
                        });
                      },
                      decoration: const InputDecoration(
                        labelText: 'First name',
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
                      initialValue: _lastName,
                      onChanged: (text) {
                        setState(() {
                          _lastName = text;
                        });
                      },
                      decoration: const InputDecoration(
                        labelText: 'Second name',
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
                    TextFormField(
                      initialValue: _repeatPassword,
                      onChanged: (text) {
                        setState(() {
                          _repeatPassword = text;
                        });
                      },
                      obscureText: true,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Repeat password',
                      ),
                      validator: (value) => _password != _repeatPassword
                          ? 'The passwords are not matching'
                          : null,
                    ),
                    RaisedButton(
                      onPressed: validateAndSave,
                      child: Text('Register now'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
