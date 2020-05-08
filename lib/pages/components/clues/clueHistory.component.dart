import 'package:flutter/material.dart';
import 'package:hideandseek/pages/components/clues/cluesList.component.dart';

clueHistory(List clueHistory, user_name) {
  return ListView.builder(
    itemCount: clueHistory.length,
    itemBuilder: (context, index) {
      final clue = clueHistory[index];
      print(clue);
      return Row(
        children: <Widget>[
          Expanded(
              flex: clue['written_by'] == user_name ? 2 : 8,
              child: clue['written_by'] == user_name
                  ? Container()
                  : clueCard(clue, false)),
          Expanded(
            flex: clue['written_by'] == user_name ? 8 : 2,
            child: clue['written_by'] == user_name
                ? clueCard(clue, true)
                : Container(),
          )
        ],
      );
    },
  );
}
