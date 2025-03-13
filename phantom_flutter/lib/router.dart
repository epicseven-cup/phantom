class ApiRouter {
  static final ApiRouter _router = ApiRouter._internal();

  static final String apiBase = "http://localhost:3000";
  String createPostItUrl = "$apiBase/create";


  factory ApiRouter() {
    return _router;
  }

  ApiRouter._internal();

}


class WebSocketRouter {
  static final WebSocketRouter _router = WebSocketRouter._internal();

  static final String websocket = "ws://localhost:3001/postit";



  factory WebSocketRouter() {
    return _router;
  }

  WebSocketRouter._internal();
}