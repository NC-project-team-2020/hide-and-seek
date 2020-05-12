import 'package:flutter/material.dart';
import 'package:hideandseek/pages/components/chat/chatCard.dart';

chatHistory(List chatHistory, user_name) {
  return ListView.builder(
    itemCount: chatHistory.length,
    itemBuilder: (context, index) {
      final chat = chatHistory[index];
      return Row(
        children: <Widget>[
          Expanded(
              flex: chat['written_by'] == user_name ? 2 : 8,
              child: chat['written_by'] == user_name
                  ? Container()
                  : card(chat, false)),
          Expanded(
            flex: chat['written_by'] == user_name ? 8 : 2,
            child: chat['written_by'] == user_name
                ? card(chat, true)
                : Container(),
          )
        ],
      );
    },
  );
}
