import 'package:flutter/material.dart';

card(chat, bool myself) {
  return Card(
    color: myself ? Colors.blue[200] : Colors.white,
    child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(chat['msg']),
    ),
  );
}
