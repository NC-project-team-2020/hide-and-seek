import 'package:flutter/material.dart';

clueCard(clue, bool myself) {
  return Card(
    child: Column(
      children: <Widget>[
        Container(
          color: myself ? Colors.blue[200] : Colors.white,
          child: Row(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  clue['written_by'],
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
        ),
        Container(
          color: myself ? Colors.blue[200] : Colors.white,
          child: Row(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(clue['clue']),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
