import 'package:shared_preferences/shared_preferences.dart';

import 'api/api_controller.dart';

Future<void> saveTokens(
{String? accessToken,
  String? refreshToken,
  String? userId,
  String? displayName,
  String? email,
  String? bio,
  String? profilePicture,
  String? coverImage,
  String? mobileNo}) async {

  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('accessToken', accessToken!);
  await prefs.setString('refreshToken', refreshToken!);
  await prefs.setString('userId', userId!);
  await prefs.setString('displayName', displayName!);
  await prefs.setString('email', email!);
  await prefs.setString('bio', bio!);
  await prefs.setString('profilePicture', profilePicture!);
  await prefs.setString('coverImage', coverImage!);
  await prefs.setString('mobileNo', mobileNo!);
}

Future<String?> getAccessToken() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('accessToken');
}

Future<String?> getRefreshToken() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('refreshToken');
}

Future<String?> getUserId() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('userId');
}

Future<String?> getUserName() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('displayName');
}

Future<String?> getUserEmail() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('email');
}

Future<String?> getUserBio() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('bio');
}

Future<String?> getUserProfilePicture() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('profilePicture');
}

Future<String?> getUserCoverImage() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('coverImage');
}

Future<String?> getUserMobileNo() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('mobileNo');
}

Future<bool> tryAutoLogin() async {
  final refreshToken = await getRefreshToken(); // Check if a refresh_token is saved

  if (refreshToken == null) {
    return false; // No token means user hasn’t logged in before
  }

  final success = await refreshAccessToken(url: "/api/access/refresh", method: "POST"); // Try getting a new access token using refresh_token

  return success; // true = valid session, false = show login screen
}
