

import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:phantom_flutter/component/postit.dart';

import 'package:phantom_flutter/router.dart' as router;

class CreatePostIt extends StatelessWidget {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController tc = TextEditingController();

  Future<PostIt> createPostIt(String content) async {
    // Process data.
    print("Hit");
    final response = await http.post(
        Uri.parse(router.ApiRouter().createPostItUrl),
        body: jsonEncode({"content": content})
    );
    if (response.statusCode == 201) {
      return PostIt(content: content);
    } else {
      throw Exception("Fail to create a Post");
    }

  }



  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          TextFormField(
            controller: tc,
            decoration: const InputDecoration(hintText: 'Enter your notes'),
            validator: (String? value) {
              if (value == null || value.isEmpty) {
                return 'Please enter some text';
              }
              return null;
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  createPostIt(tc.text);
                  tc.clear();
                }

              },
              child: const Text('Submit'),
            ),
          ),
        ],
      ),
    );
  }


}