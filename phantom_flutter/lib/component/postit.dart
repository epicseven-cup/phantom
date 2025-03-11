import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PostIt extends StatelessWidget {
  const PostIt({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const ListTile(
              leading: Icon(Icons.account_box_rounded),
              title: Text("This is a user account"),
              subtitle: Text("This is user's secert"),
            ),
            Text("I love pinapple on pizza")
          ],
        ),
      );
  }
}