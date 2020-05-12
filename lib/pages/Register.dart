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
  bool isLoading = false;

  validateAndSave() async {
    FocusScope.of(context).unfocus();
    setState(() {
      isLoading = true;
    });
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
        Map<String, dynamic> body = convert.jsonDecode(res.body);
        final failedSnackBar = SnackBar(
          backgroundColor: Colors.red[500],
          content: Text(
            body['msg'],
          ),
        );
        _scaffoldKey.currentState.showSnackBar(failedSnackBar);
      }
    }
    setState(() {
      isLoading = false;
    });
  }

  bool validatePassword(String value) {
    String pattern =
        r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$';
    RegExp regExp = new RegExp(pattern);
    return regExp.hasMatch(value);
  }

  bool validateUsername(String value) {
    String pattern = r'^(?=[a-zA-Z0-9._]{4,20}$)(?!.*[_.]{2})[^_.].*[^_.]$';
    RegExp regExp = new RegExp(pattern);
    return regExp.hasMatch(value);
  }

  bool validateEmail(String value) {
    String pattern = r'^[^@]+@[^@]+\.[^@]+$';
    RegExp regExp = new RegExp(pattern);
    return regExp.hasMatch(value);
  }

  final _scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    String color = "0xffb8b8b8";

    return new Scaffold(
      backgroundColor: Color(int.parse(color)),
      key: _scaffoldKey,
      appBar: new AppBar(
        backgroundColor: Color(int.parse("0xff272744")),
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

  formFieldDecoration(inputName) {
    return InputDecoration(
      fillColor: Color(int.parse("0xfffbf5ef")),
      filled: true,
      labelText: inputName,
      errorStyle: TextStyle(fontWeight: FontWeight.bold),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(5.0)),
    );
  }

  _form() {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            child: TextFormField(
              readOnly: isLoading,
              controller: _username,
              decoration: formFieldDecoration('Username'),
              validator: (value) {
                return !validateUsername(value)
                    ? 'Please enter a valid username'
                    : null;
              },
            ),
          ),
          SizedBox(height: 25.0),
          Container(
            child: TextFormField(
              readOnly: isLoading,
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              decoration: formFieldDecoration("Email"),
              validator: (value) {
                return !validateEmail(value)
                    ? 'Please enter a valid email'
                    : null;
              },
            ),
          ),
          SizedBox(height: 25.0),
          Container(
            child: TextFormField(
              readOnly: isLoading,
              controller: _firstName,
              decoration: formFieldDecoration("First name"),
              validator: (value) {
                if (value.isEmpty) {
                  return 'Please enter your first name';
                }
                return null;
              },
            ),
          ),
          SizedBox(height: 25.0),
          Container(
            child: TextFormField(
              readOnly: isLoading,
              controller: _lastName,
              decoration: formFieldDecoration("Last name"),
              validator: (value) {
                if (value.isEmpty) {
                  return 'Please enter your last name';
                }
                return null;
              },
            ),
          ),
          SizedBox(height: 25.0),
          Container(
            child: TextFormField(
                readOnly: isLoading,
                controller: _password,
                obscureText: true,
                decoration: formFieldDecoration("Password"),
                validator: (value) {
                  return !validatePassword(value)
                      ? 'The password is not strong enough'
                      : null;
                }),
          ),
          SizedBox(height: 25.0),
          Container(
            child: TextFormField(
              readOnly: isLoading,
              controller: _repeatPassword,
              obscureText: true,
              decoration: formFieldDecoration("Repeat password"),
              validator: (value) => _password.text != _repeatPassword.text
                  ? 'The passwords are not matching'
                  : null,
            ),
          ),
          SizedBox(height: 25.0),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: RaisedButton(
              color: Color(int.parse("0xff65738c")),
              onPressed: validateAndSave,
              child: isLoading
                  ? CircularProgressIndicator()
                  : Text(
                      'Submit',
                      style: TextStyle(fontSize: 22),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
