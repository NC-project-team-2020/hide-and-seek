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

Future<http.Response> uploadImage(
    String imageFile, String userId, String token) async {
  String url = 'https://peekaboo-be.herokuapp.com/api/users/profile';
  var uri = Uri.parse(url);
  var request = new http.MultipartRequest("PATCH", uri);
  Map<String, String> headers = {"Authorization": "Bearer $token"};

  var multipartFile = await http.MultipartFile.fromPath("avatar", imageFile);
  request.headers.addAll(headers);
  request.fields['user_id'] = userId;
  request.files.add(multipartFile);
  var response = await request.send();
  return http.Response.fromStream(response);
}
