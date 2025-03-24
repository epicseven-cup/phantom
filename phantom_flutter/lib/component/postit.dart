import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:phantom_flutter/component/postit.dart';

import 'package:phantom_flutter/router.dart' as router;

class PostIt extends StatelessWidget {
  final String content;
  const PostIt({required this.content, super.key});


  factory PostIt.fromJson(Map<String, dynamic> json) {
    return switch (json) {
      {'content': String content} =>
        PostIt(content: content.replaceAll("&", "&amp").replaceAll("<", "&lt").replaceAll(">", "&gt")),
    _ => throw const FormatException("Incorrect format for PostIt"),
    };
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 600,
      width: 600,
      child: Center(
        child: Column(
          // mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const ListTile(
              leading: Icon(Icons.account_box_rounded),
              title: Text("Anonymous"),
              subtitle: Text("anonymous user's comment"),
            ),
            Expanded(
              child: Center(
                child: Text(
                  content,
                  style: TextStyle(fontSize: 30),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
