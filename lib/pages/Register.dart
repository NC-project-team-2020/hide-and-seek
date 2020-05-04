import 'package:flutter/material.dart';
import 'dart:convert' as convert;
import 'package:http/http.dart' as http;
import '../requests.dart';

class Register extends StatefulWidget {
  const Register({Key key}) : super(key: key);

  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _username = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _firstName = TextEditingController();
  final TextEditingController _lastName = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _repeatPassword = TextEditingController();

  validateAndSave() async {
    print(_password.text);
    print(_repeatPassword.text);
    if (_formKey.currentState.validate()) {
      String body = convert.jsonEncode(<String, String>{
        'user_name': _username.text,
        'first_name': _firstName.text,
        'last_name': _lastName.text,
        'email': _email.text,
        'password': _password.text
      });
      http.Response res = await userReq('register', body);
      if (res.statusCode == 201) {
        print('success');
        Navigator.pushNamed(context, '/login');
      } else {
        print('fail');
        final failedSnackBar = SnackBar(
          backgroundColor: Colors.red[500],
          content: Text(
            'Something went wrong',
          ),
        );
        _scaffoldKey.currentState.showSnackBar(failedSnackBar);
      }
    }
  }

  final _scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      key: _scaffoldKey,
      appBar: new AppBar(
        title: Text('Register New User'),
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
        mainAxisSize: MainAxisSize.min,
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
          SizedBox(height: 25.0),
          TextFormField(
            controller: _email,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'Email',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value.isEmpty) {
                return 'Please enter some text';
              }
              return null;
            },
          ),
          SizedBox(height: 25.0),
          TextFormField(
            controller: _firstName,
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
          SizedBox(height: 25.0),
          TextFormField(
            controller: _lastName,
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
          SizedBox(height: 25.0),
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
          SizedBox(height: 25.0),
          TextFormField(
            controller: _repeatPassword,
            obscureText: true,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Repeat password',
            ),
            validator: (value) => _password.text != _repeatPassword.text
                ? 'The passwords are not matching'
                : null,
          ),
          SizedBox(height: 25.0),
          SizedBox(
            width: double.infinity,
            child: RaisedButton(
              onPressed: validateAndSave,
              child: Text('Register now'),
            ),
          ),
        ],
      ),
    );
  }
}
