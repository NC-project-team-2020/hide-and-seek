import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:hideandseek/requests.dart';
import 'package:http/http.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

userProfile() {
  return new Scaffold(
    appBar: new AppBar(
      title: Text(
        'User Profile',
      ),
    ),
    body: _UserProfileBody(),
  );
}

class _UserProfileBody extends StatefulWidget {
  _UserProfileBody({Key key}) : super(key: key);

  @override
  __UserProfileBodyState createState() => __UserProfileBodyState();
}

class __UserProfileBodyState extends State<_UserProfileBody> {
  var avatar;
  SharedPreferences preferences;
  bool isLoading = false;
  String userName;
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getAvatar(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 30.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  CircleAvatar(
                    radius: 50.0,
                    backgroundImage: !isLoading ? MemoryImage(avatar) : null,
                    child: isLoading ? CircularProgressIndicator() : null,
                    // child: Text(
                    //   'HT',
                    //   style: TextStyle(
                    //       fontSize: 40.0,
                    //       fontWeight: FontWeight.bold,
                    //       color: Colors.white,
                    //       letterSpacing: 4.0),
                    // ),
                  ),
                  //Need to add if statement here
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      RaisedButton(
                        onPressed: () {
                          if (isLoading) {
                            return null;
                          }
                          setAvatar('camera');
                        },
                        child: Text(
                          'Take Photo',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      SizedBox(
                        width: 10.0,
                      ),
                      RaisedButton(
                        onPressed: () {
                          if (isLoading) {
                            return null;
                          }
                          setAvatar('gallery');
                        },
                        child: Text(
                          'Upload Avatar',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20.0),
                  Text(
                    userName,
                    style: TextStyle(fontSize: 20, letterSpacing: 2.0),
                  ),
                ],
              ),
            ),
          );
        }
        return CircularProgressIndicator();
      },
    );
  }

  Future setAvatar(typePhoto) async {
    setState(() {
      isLoading = true;
    });
    var imagePath;
    if (typePhoto == 'gallery') {
      imagePath = await ImagePicker.pickImage(source: ImageSource.gallery);
    } else {
      imagePath = await ImagePicker.pickImage(source: ImageSource.camera);
    }
    String userId = preferences.getString('user_id');
    String token = preferences.getString('token');
    Response response = await uploadImage(imagePath.path, userId, token);
    final Map body = jsonDecode(response.body);
    final Map user = body['user'];
    List<dynamic> avatarDyn = user['avatar']['data'];
    List<dynamic> avatar = avatarDyn.cast<int>();
    List<String> avatarStrList = avatar.map((i) => i.toString()).toList();
    preferences.setStringList('avatar', avatarStrList);
    setState(() {
      isLoading = false;
    });
    getAvatar();
  }

  Future<void> getAvatar() async {
    preferences = await SharedPreferences.getInstance();
    List<String> avatarStrList = preferences.getStringList('avatar');
    userName = preferences.getString('user_name');
    List<int> avatarListInt = avatarStrList.map(int.parse).toList();
    avatar = Uint8List.fromList(avatarListInt);
  }
}
