import 'package:flutter/material.dart';
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
  SharedPreferences preferences;
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
                    backgroundColor: Colors.blueGrey,
                    child: Text(
                      'HT',
                      style: TextStyle(
                          fontSize: 40.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 4.0),
                    ),
                  ),
                  //Need to add if statement here
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      RaisedButton(
                        onPressed: cameraImage,
                        child: Text(
                          'Take Photo',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      SizedBox(
                        width: 10.0,
                      ),
                      RaisedButton(
                        onPressed: galleryImage,
                        child: Text(
                          'Upload Avatar',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20.0),
                  Text(
                    'hannes.tagerud',
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

  Future galleryImage() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);
    print(image);
  }

  Future cameraImage() async {
    var image = await ImagePicker.pickImage(source: ImageSource.camera);
    print(image);
  }

  Future<void> getAvatar() async {
    preferences = await SharedPreferences.getInstance();
  }
}
