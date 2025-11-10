// import 'package:shared_preferences/shared_preferences.dart';
//
// import 'api/api_controller.dart';
// import 'package:intl/intl.dart';
//
//
// Future<void> saveTokens(
// {String? accessToken,
//   String? refreshToken,
//   String? userId,
//   String? displayName,
//   String? email,
//   String? bio,
//   String? profilePicture,
//   String? coverImage,
//   String? mobileNo,
//   String? rTokenExpDate
// }) async {
//
//   final prefs = await SharedPreferences.getInstance();
//   await prefs.setString('accessToken', accessToken!);
//   await prefs.setString('refreshToken', refreshToken!);
//   await prefs.setString('userId', userId!);
//   await prefs.setString('displayName', displayName!);
//   await prefs.setString('email', email!);
//   await prefs.setString('bio', bio!);
//   await prefs.setString('profilePicture', profilePicture!);
//   await prefs.setString('coverImage', coverImage!);
//   await prefs.setString('mobileNo', mobileNo!);
//   await prefs.setString('refreshTokenExpireDate', rTokenExpDate ?? "");
// }
//
//
//
// Future<void> saveRefreshTokens(
//     {String? accessToken,
//       String? refreshToken,
//       String? rTokenExpDate
//     }) async {
//
//   final prefs = await SharedPreferences.getInstance();
//   await prefs.setString('accessToken', accessToken ?? "");
//   await prefs.setString('refreshToken', refreshToken ?? "");
//   await prefs.setString('refreshTokenExpireDate', rTokenExpDate ?? "");
// }
//
//
// Future<String?> getAccessTokenOld() async {
//   final prefs = await SharedPreferences.getInstance();
//   return prefs.getString('accessToken');
// }
//
// Future<void> logeOut() async {
//   final prefs = await SharedPreferences.getInstance();
//   await prefs.remove('accessToken');
//   await prefs.remove('refreshToken');
//   await prefs.remove('userId');
//   await prefs.remove('displayName');
//   await prefs.remove('email');
//   await prefs.remove('bio');
//   await prefs.remove('profilePicture');
//   await prefs.remove('coverImage');
//   await prefs.remove('mobileNo');
//   await prefs.remove('refreshTokenExpireDate');
// }
//
// Future<String?> getAccessToken() async {
//   final prefs = await SharedPreferences.getInstance();
//
//   int refreshTokenStatus = await isRefreshTokenExpired();
//
//   print("CheckRefreshTokenStatus:${refreshTokenStatus}");
//   if(refreshTokenStatus == 0){
//     return prefs.getString('accessToken');
//   }else if(refreshTokenStatus == 1 || refreshTokenStatus == 3){ //should be refresh
//
//     await refreshAccessToken(url: "/api/access/refresh", method: "POST"); // Try getting a new access token using refresh_token
//     return prefs.getString('accessToken');
//   }
//
//   return prefs.getString('accessToken');
// }
//
//
// Future<String?> getRefreshToken() async {
//   final prefs = await SharedPreferences.getInstance();
//   return prefs.getString('refreshToken');
// }
//
// Future<String?> getUserId() async {
//   final prefs = await SharedPreferences.getInstance();
//   return prefs.getString('userId');
// }
//
// Future<String?> getUserName() async {
//   final prefs = await SharedPreferences.getInstance();
//   return prefs.getString('displayName');
// }
//
// Future<String?> getUserEmail() async {
//   final prefs = await SharedPreferences.getInstance();
//   return prefs.getString('email');
// }
//
// Future<String?> getUserBio() async {
//   final prefs = await SharedPreferences.getInstance();
//   return prefs.getString('bio');
// }
//
// Future<String?> getUserProfilePicture() async {
//   final prefs = await SharedPreferences.getInstance();
//   return prefs.getString('profilePicture');
// }
//
// Future<String?> getUserCoverImage() async {
//   final prefs = await SharedPreferences.getInstance();
//   return prefs.getString('coverImage');
// }
//
// Future<String?> getUserMobileNo() async {
//   final prefs = await SharedPreferences.getInstance();
//   return prefs.getString('mobileNo');
// }
//
// Future<bool> tryAutoLogin() async {
//   final refreshToken = await getRefreshToken(); // Check if a refresh_token is saved
//  // print("CheckRefreshToken:${refreshToken}");
//   if (refreshToken == null) {
//     return false; // No token means user hasn’t logged in before
//   }
//
//  //final success = await refreshAccessToken(url: "/api/access/refresh", method: "POST"); // Try getting a new access token using refresh_token
//   //if not directly returning success, we can check if the access token is valid when we call another api and refresh it if needed
//   return true; // true = valid session, false = show login screen
// }
//
// Future<int> isRefreshTokenExpired() async {
//   final prefs = await SharedPreferences.getInstance();
//   final rTokenExpDateStr = prefs.getString('refreshTokenExpireDate');
//   print("Refresh Token Expiry Date: $rTokenExpDateStr");
//   if (rTokenExpDateStr == null || rTokenExpDateStr.isEmpty) {
//     return 2; // Not set: maybe not logged in
//   }
//
//   try {
//     DateTime rTokenExpDate = DateFormat('yyyy-MM-dd HH:mm:ss').parse(rTokenExpDateStr);
//
//     if (DateTime.now().isAfter(rTokenExpDate)) {
//       return 1; // Token expired
//     } else {
//       return 0; // Token is still valid
//     }
//   } catch (e) {
//     print("Invalid date format: $e");
//     return 3; // Parsing error
//   }
// }
//
//
//
// //add 25 min to to the current time to set a refreshToken Expire
// String getExpiryTimeString() {
//   DateTime now = DateTime.now();
//   DateTime expiryTime = now.add(Duration(minutes: 25)); //make it 25 minutes or adjust based on your requirement
//   return DateFormat('yyyy-MM-dd HH:mm:ss').format(expiryTime);
// }

import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

import 'api/api_controller.dart';

/// -------------------- SAVE USER DATA ---------------------
Future<void> saveTokens({
  String? accessToken,
  String? refreshToken,
  String? userId,
  String? displayName,
  String? email,
  String? bio,
  String? profilePicture,
  String? coverImage,
  String? mobileNo,
  String? rTokenExpDate,
}) async {
  final prefs = await SharedPreferences.getInstance();

  // Save the current user data
  await prefs.setString('accessToken', accessToken ?? "");
  await prefs.setString('refreshToken', refreshToken ?? "");
  await prefs.setString('userId', userId ?? "");
  await prefs.setString('displayName', displayName ?? "");
  await prefs.setString('email', email ?? "");
  await prefs.setString('bio', bio ?? "");
  await prefs.setString('profilePicture', profilePicture ?? "");
  await prefs.setString('coverImage', coverImage ?? "");
  await prefs.setString('mobileNo', mobileNo ?? "");
  await prefs.setString('refreshTokenExpireDate', rTokenExpDate ?? "");
  await prefs.setBool('isPageMode', false); // Default to user mode

  // Duplicate the data for the original user (using "originalUserId")
  await prefs.setString('originalUserId', userId ?? "");  // Store the original user ID
  await prefs.setString('originalDisplayName', displayName ?? "");
  await prefs.setString('originalEmail', email ?? "");
  await prefs.setString('originalBio', bio ?? "");
  await prefs.setString('originalProfilePicture', profilePicture ?? "");
  await prefs.setString('originalCoverImage', coverImage ?? "");
  await prefs.setString('originalMobileNo', mobileNo ?? "");

}

Future<void> savePage({
  String? userId,
  String? displayName,
  String? email,
  String? bio,
  String? profilePicture,
  String? coverImage,
  String? mobileNo,
  bool? isPage
}) async {
  final prefs = await SharedPreferences.getInstance();

  // Save the current user data

  await prefs.setString('userId', userId ?? "");
  await prefs.setString('displayName', displayName ?? "");
  await prefs.setString('email', email ?? "");
  await prefs.setString('bio', bio ?? "");
  await prefs.setString('profilePicture', profilePicture ?? "");
  await prefs.setString('coverImage', coverImage ?? "");
  await prefs.setString('mobileNo', mobileNo ?? "");
  await prefs.setBool('isPageMode', isPage ?? false); // Default to user mode

}


Future<void> setProfileImage(String profileImage)async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('profilePicture', profileImage!);
}

Future<void> setCoverImage(String coverImage)async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('coverImage', coverImage!);
}

/// -------------------- SAVE PAGE PROFILE ---------------------
Future<void> savePageProfile({
  required String pageId,
  required String pageName,
  required String profilePicture,
  required String coverImage
}) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('pageId', pageId);
  await prefs.setString('pageName', pageName);
  await prefs.setString('pageProfilePicture', profilePicture);
  await prefs.setString('pageCoverImage', coverImage);
  await prefs.setBool('isPageMode', true); // Switch to page mode
}

/// -------------------- REFRESH TOKEN SAVE ---------------------
Future<void> saveRefreshTokens({
  String? accessToken,
  String? refreshToken,
  String? rTokenExpDate,
}) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('accessToken', accessToken ?? "");
  await prefs.setString('refreshToken', refreshToken ?? "");
  await prefs.setString('refreshTokenExpireDate', rTokenExpDate ?? "");
}

/// -------------------- GETTERS ---------------------
Future<String?> getAccessTokenOld() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('accessToken');
}

Future<String?> getAccessToken() async {
  final prefs = await SharedPreferences.getInstance();

  int refreshTokenStatus = await isRefreshTokenExpired();
  print("CheckRefreshTokenStatus: $refreshTokenStatus");

  if (refreshTokenStatus == 0) {
    return prefs.getString('accessToken');
  } else if (refreshTokenStatus == 1 || refreshTokenStatus == 3) {
    await refreshAccessToken(url: "/api/access/refresh", method: "POST");
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

Future<String?> getProfileUserId() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('originalUserId');
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

///image request type based on profile / page

Future<String?> getImageRequestType() async {
  final prefs = await SharedPreferences.getInstance();
  bool isPage =  prefs.getBool('isPageMode') ?? false;
  return isPage ? "PAGEPROFILE" : "PROFILE";
}

Future<String?> getProfileType({int type = 1}) async {
  final prefs = await SharedPreferences.getInstance();
  bool isPage =  prefs.getBool('isPageMode') ?? false;
  return type == 1 ? (isPage ? "PAGE" : "USER") : (isPage ? "page" : "user");
}


/// -------------------- PAGE GETTERS ---------------------
Future<String?> getPageId() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('pageId');
}

Future<String?> getPageName() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('pageName');
}

Future<String?> getPageProfilePicture() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('pageProfilePicture');
}

Future<String?> getPageCoverImage() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('pageCoverImage');
}

Future<String?> getPageToken() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('pageToken');
}


///get Original logged in user data

Future<Map<String, String?>> getUserData() async {
  final prefs = await SharedPreferences.getInstance();

  // Retrieve all user-related data from SharedPreferences
  String? userId = prefs.getString('originalUserId');
  String? displayName = prefs.getString('originalDisplayName');
  String? email = prefs.getString('originalEmail');
  String? bio = prefs.getString('originalBio');
  String? profilePicture = prefs.getString('originalProfilePicture');
  String? coverImage = prefs.getString('originalCoverImage');
  String? mobileNo = prefs.getString('originalMobileNo');
  bool? isPageMode = false;

  // Return all data as a Map
  return {
    'userId': userId,
    'displayName': displayName,
    'email': email,
    'bio': bio,
    'profilePicture': profilePicture,
    'coverImage': coverImage,
    'mobileNo': mobileNo,
    'isPageMode': isPageMode?.toString(), // Converting bool to string if necessary
  };
}




/// -------------------- SWITCH MODE ---------------------
Future<void> setActiveProfileType(bool isPage) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool('isPageMode', isPage);
}

Future<bool> isPageMode() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool('isPageMode') ?? false;
}

/// -------------------- GET ACTIVE PROFILE ---------------------
Future<Map<String, String?>> getActiveProfile() async {
  final prefs = await SharedPreferences.getInstance();
  final isPage = prefs.getBool('isPageMode') ?? false;

  if (isPage) {
    return {
      'id': prefs.getString('pageId'),
      'name': prefs.getString('pageName'),
      'profilePicture': prefs.getString('pageProfilePicture'),
      'coverImage': prefs.getString('pageCoverImage'),
      'token': prefs.getString('pageToken'),
      'isPage': 'true',
    };
  } else {
    return {
      'id': prefs.getString('userId'),
      'name': prefs.getString('displayName'),
      'profilePicture': prefs.getString('profilePicture'),
      'coverImage': prefs.getString('coverImage'),
      'token': prefs.getString('accessToken'),
      'isPage': 'false',
    };
  }
}

/// -------------------- LOGOUT ---------------------
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
  await prefs.remove('isPageMode');

  await prefs.remove('pageId');
  await prefs.remove('pageName');
  await prefs.remove('pageProfilePicture');
  await prefs.remove('pageCoverImage');
  await prefs.remove('pageToken');
}

/// -------------------- AUTO LOGIN ---------------------
Future<bool> tryAutoLogin() async {
  final refreshToken = await getRefreshToken();
  if (refreshToken == null) return false;
  return true;
}

/// -------------------- TOKEN EXPIRATION CHECK ---------------------
Future<int> isRefreshTokenExpired() async {
  final prefs = await SharedPreferences.getInstance();
  final rTokenExpDateStr = prefs.getString('refreshTokenExpireDate');
  print("Refresh Token Expiry Date: $rTokenExpDateStr");

  if (rTokenExpDateStr == null || rTokenExpDateStr.isEmpty) return 2;

  try {
    DateTime rTokenExpDate = DateFormat('yyyy-MM-dd HH:mm:ss').parse(rTokenExpDateStr);
    if (DateTime.now().isAfter(rTokenExpDate)) return 1;
    return 0;
  } catch (e) {
    print("Invalid date format: $e");
    return 3;
  }
}

/// -------------------- SET EXPIRY ---------------------
String getExpiryTimeString() {
  DateTime now = DateTime.now();
  DateTime expiryTime = now.add(Duration(minutes: 25));
  return DateFormat('yyyy-MM-dd HH:mm:ss').format(expiryTime);
}
