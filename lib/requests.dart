import 'package:http/http.dart' as http;

Future<http.Response> userReq(String endpoint, String body) {
  String url = 'https://peekaboo-be.herokuapp.com/api/users/$endpoint';
  return http.post(
    url,
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: body,
  );
}
