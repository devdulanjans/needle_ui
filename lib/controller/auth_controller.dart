import 'package:shared_preferences/shared_preferences.dart';

import 'api/api_controller.dart';
import 'package:intl/intl.dart';


Future<void> saveTokens(
{String? accessToken,
  String? refreshToken,
  String? userId,
  String? displayName,
  String? email,
  String? bio,
  String? profilePicture,
  String? coverImage,
  String? mobileNo,
  String? rTokenExpDate
}) async {

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
  await prefs.setString('refreshTokenExpireDate', rTokenExpDate ?? "");
}



Future<void> saveRefreshTokens(
    {String? accessToken,
      String? refreshToken,
      String? rTokenExpDate
    }) async {

  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('accessToken', accessToken ?? "");
  await prefs.setString('refreshToken', refreshToken ?? "");
  await prefs.setString('refreshTokenExpireDate', rTokenExpDate ?? "");
}


Future<String?> getAccessTokenOld() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('accessToken');
}

Future<void> logeOut() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove('accessToken');
  await prefs.remove('refreshToken');
  await prefs.remove('userId');
  await prefs.remove('displayName');
  await prefs.remove('email');
  await prefs.remove('bio');
  await prefs.remove('profilePicture');
  await prefs.remove('coverImage');
  await prefs.remove('mobileNo');
  await prefs.remove('refreshTokenExpireDate');
}

Future<String?> getAccessToken() async {
  final prefs = await SharedPreferences.getInstance();

  int refreshTokenStatus = await isRefreshTokenExpired();

  print("CheckRefreshTokenStatus:${refreshTokenStatus}");
  if(refreshTokenStatus == 0){
    return prefs.getString('accessToken');
  }else if(refreshTokenStatus == 1 || refreshTokenStatus == 3){ //should be refresh

    await refreshAccessToken(url: "/api/access/refresh", method: "POST"); // Try getting a new access token using refresh_token
    return prefs.getString('accessToken');
  }

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
 // print("CheckRefreshToken:${refreshToken}");
  if (refreshToken == null) {
    return false; // No token means user hasn’t logged in before
  }

 //final success = await refreshAccessToken(url: "/api/access/refresh", method: "POST"); // Try getting a new access token using refresh_token
  //if not directly returning success, we can check if the access token is valid when we call another api and refresh it if needed
  return true; // true = valid session, false = show login screen
}

Future<int> isRefreshTokenExpired() async {
  final prefs = await SharedPreferences.getInstance();
  final rTokenExpDateStr = prefs.getString('refreshTokenExpireDate');
  print("Refresh Token Expiry Date: $rTokenExpDateStr");
  if (rTokenExpDateStr == null || rTokenExpDateStr.isEmpty) {
    return 2; // Not set: maybe not logged in
  }

  try {
    DateTime rTokenExpDate = DateFormat('yyyy-MM-dd HH:mm:ss').parse(rTokenExpDateStr);

    if (DateTime.now().isAfter(rTokenExpDate)) {
      return 1; // Token expired
    } else {
      return 0; // Token is still valid
    }
  } catch (e) {
    print("Invalid date format: $e");
    return 3; // Parsing error
  }
}



//add 25 min to to the current time to set a refreshToken Expire
String getExpiryTimeString() {
  DateTime now = DateTime.now();
  DateTime expiryTime = now.add(Duration(minutes: 25)); //make it 25 minutes or adjust based on your requirement
  return DateFormat('yyyy-MM-dd HH:mm:ss').format(expiryTime);
}
