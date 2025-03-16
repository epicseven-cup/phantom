import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:phantom_flutter/component/DraggableComponent.dart';
import 'package:phantom_flutter/component/postit.dart';
import 'package:phantom_flutter/router.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'component/createPostit.dart';

void main() {
  runApp(const Phantom());
}

class Phantom extends StatelessWidget {
  const Phantom({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Phantom',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.amber),
      ),
      home: const HomePage(title: 'Phantom'),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _visable = false;

  final _channel = WebSocketChannel.connect(
    Uri.parse(WebSocketRouter.websocket),
  );

  void _changeVisable() {
    setState(() {
      _visable = !_visable;
    });
  }

  late var _post = <Widget>[
    Dismissible(
      key: UniqueKey(),
      child: DraggableCard(child: PostIt(content: "Hello world")),
    ),
  ];

  @override
  void initState() {
    super.initState();

    _channel.stream.listen((message) {
      setState(() {
        _post =
            _post +
            [
              Dismissible(
                key: UniqueKey(),
                onDismissed: (DismissDirection direction) {
                  _channel.sink.add(jsonEncode({"request_post": 1}));
                },
                child: DraggableCard(
                  child: PostIt.fromJson(jsonDecode(message)),
                ),
              ),
            ];
      });
    });

    _channel.sink.add(jsonEncode({"request_post": 3}));
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Builder(
        builder: (context) {
          if (_visable) {
            return CreatePostIt();
          }

          return Stack(children: _post);
        },
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: this._changeVisable,
        tooltip: 'Create new post-it',
        child: const Icon(Icons.add), // icon used
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
