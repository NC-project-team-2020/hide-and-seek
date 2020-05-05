import 'package:flutter/material.dart';

cluesList(List cluesList) {
  return ListView.builder(
    itemCount: cluesList.length,
    itemBuilder: (context, index) {
      final clue = cluesList[index];
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(14.0),
          child: Text(clue['clue']),
        ),
      );
    },
  );
}
