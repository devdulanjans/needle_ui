// import 'dart:convert';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:http/http.dart' as http;
//
// import 'config/helper.dart';
//
// class AuthService {
//   static String baseUrl = $BASE_URL;
//
//   Future<bool> checkLoginStatus() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     String? accessToken = prefs.getString('accessToken');
//     String? refreshToken = prefs.getString('refreshToken');
//
//     if (accessToken == null || refreshToken == null) {
//       // No tokens found, user needs to log in
//       return false;
//     }
//
//     // Validate the access token
//     bool isAccessTokenValid = await _validateAccessToken(accessToken);
//
//     if (isAccessTokenValid) {
//       return true;
//     } else {
//       // Access token is invalid, try refreshing it
//       return await _refreshAccessToken(refreshToken);
//     }
//   }
//
//   Future<bool> _validateAccessToken(String accessToken) async {
//     try {
//       var response = await http.get(
//         Uri.parse("$baseUrl/api/validate-token"),
//         headers: {
//           'Authorization': 'Bearer $accessToken',
//         },
//       );
//
//       if (response.statusCode == 200) {
//         // Token is valid
//         return true;
//       } else {
//         // Token is invalid or expired
//         return false;
//       }
//     } catch (e) {
//       print("Error validating access token: $e");
//       return false;
//     }
//   }
//
//   Future<bool> _refreshAccessToken(String refreshToken) async {
//     try {
//       var response = await http.post(
//         Uri.parse("$baseUrl/api/refresh-token"),
//         body: jsonEncode({'refreshToken': refreshToken}),
//         headers: {
//           'Content-Type': 'application/json',
//         },
//       );
//
//       if (response.statusCode == 200) {
//         var data = jsonDecode(response.body);
//         String newAccessToken = data['accessToken'];
//         String newRefreshToken = data['refreshToken'];
//
//         // Save the new tokens
//         SharedPreferences prefs = await SharedPreferences.getInstance();
//         await prefs.setString('accessToken', newAccessToken);
//         await prefs.setString('refreshToken', newRefreshToken);
//
//         return true;
//       } else {
//         // Refresh token is invalid or expired
//         return false;
//       }
//     } catch (e) {
//       print("Error refreshing access token: $e");
//       return false;
//     }
//   }
// }