import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PostIt extends StatelessWidget {
  const PostIt({super.key});

  // TODO: Use this to make a draggable https://docs.flutter.dev/cookbook/animation/physics-simulation

  @override
  Widget build(BuildContext context) {
    return Card(
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
                  "I love pineapple on pizza",
                  style: TextStyle(fontSize: 30),
                ),
              ),
            ),
          ],
        ),
    );
  }
}
