import 'package:flutter/material.dart';

card(chat, bool myself) {
  return Card(
    child: Column(
      children: <Widget>[
        Container(
          decoration: BoxDecoration(
              color: myself
                  ? Color(int.parse("0xff272744"))
                  : Color(int.parse("0xfff2d3ab")),
              boxShadow: [
                BoxShadow(
                    blurRadius: .5,
                    spreadRadius: 1.0,
                    color: Colors.black.withOpacity(.12))
              ],
              borderRadius: myself
                  ? BorderRadius.only(
                      topLeft: Radius.circular(5.0),
                      topRight: Radius.circular(5.0),
                      bottomLeft: Radius.circular(5.0),
                      bottomRight: Radius.circular(5.0))
                  : BorderRadius.only(
                      topLeft: Radius.circular(5.0),
                      topRight: Radius.circular(5.0),
                      bottomLeft: Radius.circular(5.0),
                      bottomRight: Radius.circular(5.0))),
          child: Column(
            children: <Widget>[
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Text(chat['written_by'],
                        style: TextStyle(
                            color: myself ? Colors.white : Colors.black))),
                Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Text(chat['created_at'],
                        style: TextStyle(
                            color: myself ? Colors.white : Colors.black)))
              ]),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Text(chat['msg'],
                        style: TextStyle(
                            color: myself ? Colors.white : Colors.black))),
              ])
            ],
          ),
        )
      ],
    ),
  );
}
