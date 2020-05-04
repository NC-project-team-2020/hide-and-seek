import 'package:flutter/material.dart';
import 'package:hideandseek/pages/components/chat/chatCard.dart';

chatHistory(List chatHistory) {
  return ListView.builder(
    itemCount: chatHistory.length,
    itemBuilder: (context, index) {
      final chat = chatHistory[index];
      return Row(
        children: <Widget>[
          Expanded(
              flex: chat['written_by'] == 'User1' ? 2 : 8,
              child: chat['written_by'] == 'User1'
                  ? Container()
                  : card(chat, false)),
          Expanded(
            flex: chat['written_by'] == 'User1' ? 8 : 2,
            child:
                chat['written_by'] == 'User1' ? card(chat, true) : Container(),
          )
        ],
      );
    },
  );
}
