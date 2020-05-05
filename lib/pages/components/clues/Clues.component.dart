import 'package:flutter/material.dart';
import 'package:hideandseek/pages/components/clues/cluesList.component.dart';

class Clues extends StatefulWidget {
  Clues({Key key}) : super(key: key);

  @override
  _CluesState createState() => _CluesState();
}

class _CluesState extends State<Clues> {
  final TextEditingController _clue = TextEditingController();
  List<Map<String, String>> clues = [];
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Expanded(flex: 8, child: cluesList(clues)),
        Expanded(
          flex: 1,
          child: Row(
            children: <Widget>[
              Expanded(
                flex: 9,
                child: Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: TextField(
                    controller: _clue,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Expanded(
                  flex: 3,
                  child: RaisedButton(
                    color: Colors.blue[200],
                    disabledColor: Colors.red[200],
                    onPressed: () {
                      String clue = _clue.text;
                      if (clue.length > 0 && clues.length < 3) {
                        setState(() {
                          clues.add({'clue': clue});
                        });
                        _clue.clear();
                      } else {
                        return null;
                      }
                    },
                    child: Text('Add Clue'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
