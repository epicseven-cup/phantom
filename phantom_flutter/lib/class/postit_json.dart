import 'package:http/http.dart' as http;
import 'package:phantom_flutter/router.dart';

class PostItJson {
  final String content;

  const PostItJson({required this.content});

  factory PostItJson.fromJson(Map<String, dynamic> json) {
    return switch (json) {
      {'content': String content} =>
          PostItJson(content: content),
      _ => throw const FormatException("Incorrect format for PostIt"),
    };
  }

}
