import 'dart:convert';
import 'package:http/http.dart' as http;
import '../auth_controller.dart';
import '../config/helper.dart';
import 'dart:io';

String $baseUrl = $BASE_URL;

Future<dynamic> API_V1_call({
  String? url,
  String? method,
  Map<String, dynamic>? body,
  bool isHeader = true,
}) async {

  final setUrl = "${$baseUrl}${url}";
  Map<String, String>? headers = await header(isHeader: isHeader);
  var response;

  if (method == "POST") {
    response = await http.post(
      Uri.parse(setUrl),
      body: jsonEncode(body),
      headers: headers,
    );
  } else if (method == "GET") {
    response = await http.get(Uri.parse(setUrl), headers: headers);
  }
  return response;
}

Future<dynamic> API_V1_Multipart_call({
  required String url,
  required String method,
  Map<String, dynamic>? body,
  bool isHeader = true,
  List<String>? filePaths,
  List<String?>? mediaTypes
}) async {

  final setUrl = "${$baseUrl}${url}";
  Map<String, String>? headers = await header(isHeader: isHeader);
  print("setUrl: ${setUrl}");

  var request = http.MultipartRequest(method, Uri.parse(setUrl));

  // Add fields to the request
  if (body != null) {
    request.fields.addAll(body.map((key, value) => MapEntry(key, value.toString())));
    print("Request Body Fields: ${request.fields}");
  }

  print("ESP BODY: ${body}");
  print("FILE PATH: ${filePaths}");

  // Add files to the request
  if (filePaths != null) {
    for (int i = 0; i < filePaths.length; i++) {
      final path = filePaths[i];
      final mediaKey = 'media[$i].media';
      final mediaTypeKey = 'media[$i].mediaType';

      if (File(path).existsSync()) {
        request.files.add(await http.MultipartFile.fromPath(mediaKey, path));
        if (mediaTypes != null && i < mediaTypes.length) {
          request.fields[mediaTypeKey] = mediaTypes[i]!;
        }
      } else {
        print("File does not exist: $path");
      }
    }
  }

  print('ALL request DATA: ${request}');

  request.headers.addAll(headers!);

  print("Final request fields: ${request.fields}");
  print("Final headers: ${request.headers}");

  var response = await request.send();

  print("Response Status: ${response.statusCode}");
  print("Response Reason: ${response.reasonPhrase}");

  // Read and return response body
  final responseBody = await response.stream.bytesToString();
  return responseBody;
}

void checkFilePath(String path) {
  if (File(path).existsSync()) {
    print("File exists at: $path");
  } else {
    print("File does not exist at: $path");
  }
}

Future<Map<String, String>?> header({bool isHeader = true}) async {
  if (isHeader == true) {
    // SharedPreferences prefs = await SharedPreferences.getInstance();
    String? accessToken = await getAccessToken();
    String? refreshToken = await getRefreshToken();
    String? userId = await getUserId();

    print("userId: $userId");

    return {
      'Content-Type': 'application/json',
      'access_token': accessToken ?? '',
      'user_id': userId ?? '',
    };
  }

  return {'Content-Type': 'application/json'};
}

Future<bool> refreshAccessToken({String? method, String? url}) async {
  final refreshToken = await getRefreshToken();
  final userId = await getUserId();
  String? accessToken = await getAccessToken();

  print("refreshToken: $refreshToken");
  print("accessToken: $accessToken");
  print("userId: $userId");

  if (refreshToken == null || userId == null) {
    return false; // No refresh token means user hasn’t logged in before
  }

  var body = {
    "userId":userId,
    "refreshToken": refreshToken
  };

  final response = await API_V1_call(
    method: method,
    url: url,
    body: body,
    isHeader:true
  );

  // print('REFRESH TOKEN CALL: ${response.statusCode}');
  // print('REFRESH TOKEN CALL: ${response.body}');

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    // await saveTokens(data['access_token'], refreshToken!); // Use old refresh_token if new not sent
    return true;
  } else {
    return false;
  }
}

