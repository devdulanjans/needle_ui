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
  int type = 0,
  String oldAccessToken = ""// 0 for normal header, 1 for refresh header
}) async {

  final setUrl = "${$baseUrl}${url}";
  Map<String, String>? headers = await header(isHeader: isHeader,oldAccessToken: oldAccessToken, type: type);
  var response;
  print("NAW setUrl: ${setUrl} - $method");

  if (method == "POST") {
    response = await http.post(
      Uri.parse(setUrl),
      body: jsonEncode(body),
      headers: headers,
    );

  } else if (method == "GET") {

    response = await http.get(Uri.parse(setUrl), headers: headers);

  } else if (method == "PUT") {
    response = await http.put(
      Uri.parse(setUrl),
      headers: headers,
    );
  } else if (method == "DELETE") {
    response = await http.delete(
      Uri.parse(setUrl),
      headers: headers,
    );
  }
  return response;
}

Future<dynamic> API_V1_Multipart_call({
  required String url,
  required String method,
  Map<String, dynamic>? body,
  bool isHeader = true,
  List<String>? filePaths,
  List<String?>? mediaTypes// If true, only one image will be sent
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

      print("In loop - path: $path");
      print("In loop - mediaKey: $mediaKey");
      print("In loop - mediaTypeKey: $mediaTypeKey");

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

  return;

  var response = await request.send();

  print("Response Status: ${response.statusCode}");
  print("Response Reason: ${response.reasonPhrase}");

  // Read and return response body
  final responseBody = await response.stream.bytesToString();
  return responseBody;
}

Future<dynamic> API_V1_Multipart_call_Story({
  required String url,
  required String method,
  Map<String, dynamic>? body,
  bool isHeader = true,
  String? filePaths,
  String? mediaTypes// If true, only one image will be sent
}) async {

  print("filePaths: ${filePaths.toString()}");
  print("mediaTypes: ${File(filePaths!).existsSync()}");

  if (filePaths == null || filePaths.isEmpty) {
    throw ArgumentError("filePaths cannot be null or empty");
  }

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
  print("FILE PATH: ${filePaths.toString()}");

  // Ensure filePath is a valid path string and the file exists
  if (filePaths != null && File(filePaths).existsSync()) {
    request.files.add(await http.MultipartFile.fromPath('file', filePaths));
  } else {
    print("File does not exist or path is invalid: $filePaths");
    // Handle the error appropriately, maybe return an error response or throw an exception
  }

  request.headers.addAll(headers!);

  var response = await request.send();

  print("Response Status: ${response.statusCode}");
  print("Response Reason: ${response.reasonPhrase}");

  // Read and return response body
  final responseBody = await response.stream.bytesToString();
  return responseBody;
}

// Page Image Upload
Future<dynamic> API_V1_Multipart_call_Page({
  required String url,
  required String method,
  Map<String, dynamic>? body,
  bool isHeader = true,
  String? filePaths,
  String? mediaTypes// If true, only one image will be sent
}) async {

  print("filePaths: ${filePaths.toString()}");
  print("mediaTypes: ${File(filePaths!).existsSync()}");
  print("url: ${url}");

  if (filePaths == null || filePaths.isEmpty) {
    throw ArgumentError("filePaths cannot be null or empty");
  }

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
  print("FILE PATH: ${filePaths.toString()}");

  // Ensure filePath is a valid path string and the file exists
  if (filePaths != null && File(filePaths).existsSync()) {
    request.files.add(await http.MultipartFile.fromPath('file', filePaths));
  } else {
    print("File does not exist or path is invalid: $filePaths");
    // Handle the error appropriately, maybe return an error response or throw an exception
  }

  request.headers.addAll(headers!);

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

Future<Map<String, String>?> header({bool isHeader = true,int type = 0,String oldAccessToken = ""}) async { //type 0 for normal header, type 1 for refresh header
  if (isHeader == true) {

    String? accessToken = type == 1 ? oldAccessToken : await getAccessToken();
    String? refreshToken = await getRefreshToken();
    dynamic userId = await getUserId();

    // print("userId: $userId");
    // print("accessToken: "+accessToken!);

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
  String? accessToken = await getAccessTokenOld(); //get the old access token for refresh

  print("refreshToken: $refreshToken");
  print("accessToken: $accessToken");
  print("userId: $userId");

  if (refreshToken == null || userId == null) {
    return false; // No refresh token means user hasn’t logged in before
  }

  var body = {
    "userId":int.tryParse(userId.toString()), //i got invalid input because this is a string
    "refreshToken": refreshToken,
    "accessToken":accessToken // add accessToken to the body as a new field
  };

  final response = await API_V1_call(
    method: method,
    url: url,
    body: body,
    isHeader:true,
    type: 1,
    oldAccessToken: accessToken ?? ""
  );

   print('REFRESH TOKEN CALL: ${response.statusCode}');
   print('REFRESH TOKEN CALL: ${response.body}');

  if (response.statusCode == 200 || response.statusCode == 201) {
    final data = json.decode(response.body);
    final String newAccessToken = data['data']['accessToken'];
    final String apiRefreshToken = data['data']['refreshToken'] ?? ""; // Use old refresh_token if new not sent
     var newRefreshToken = apiRefreshToken != "" ? apiRefreshToken : refreshToken ; // Use old refresh_token if new not sent
     await saveRefreshTokens(accessToken: newAccessToken, refreshToken: newRefreshToken,rTokenExpDate: getExpiryTimeString()); // Use old refresh_token if new not sent
    return true;
  } else {
    return false;
  }
}

