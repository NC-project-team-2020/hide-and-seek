import 'package:flutter/material.dart';

card(chat, bool myself) {
  return Card(
    child: Column(
      children: <Widget>[
        Container(
          decoration: BoxDecoration(
              color: myself ? Colors.blue[200] : Colors.white,
              boxShadow: [
                BoxShadow(
                    blurRadius: .5,
                    spreadRadius: 1.0,
                    color: Colors.black.withOpacity(.12))
              ],
              borderRadius: myself
                  ? BorderRadius.only(
                      topLeft: Radius.circular(5.0),
                      bottomLeft: Radius.circular(5.0),
                      bottomRight: Radius.circular(10.0))
                  : BorderRadius.only(
                      topRight: Radius.circular(5.0),
                      bottomLeft: Radius.circular(10.0),
                      bottomRight: Radius.circular(5.0),
                    )),
          child: Row(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text(chat['msg']),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
