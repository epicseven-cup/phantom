import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PostIt extends StatelessWidget {
  final String content;
  const PostIt({required this.content, super.key});


  factory PostIt.fromJson(Map<String, dynamic> json) {
    return switch (json) {
      {'content': String content} => PostIt(content: content),
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
              title: Text("This is a user account"),
              subtitle: Text("This is user's secert"),
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
