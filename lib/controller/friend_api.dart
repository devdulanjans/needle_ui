import 'dart:convert';

import '../model/friend_request_model.dart';
import 'api/api_controller.dart';

Future<List<FriendRequest>> getAllPendingRequest() async {
  var responseData = await API_V1_call(
    url: "/api/friend-request/received?status=PENDING",
    method: "GET",
  );

  if (responseData.statusCode == 200) {
    final data = jsonDecode(responseData.body)['data'] as List?;
    return data?.map((item) => FriendRequest.fromJson(item)).toList() ?? [];
  }

  // Return an empty list if the response status is not 200
  return [];
}



Future<List<FriendRequest>> getAllBlockUsers(String userId) async {
  var responseData = await API_V1_call(
    url: "/api/user/blocked-users/$userId",
    method: "GET",
  );

  if (responseData.statusCode == 200) {
    print("CheckResponseBlock:${responseData.body}");
    final data = jsonDecode(responseData.body)['data'] as List?;
    return data?.map((item) => FriendRequest.fromJson(item,isBlockUsers: true)).toList() ?? [];
  }

  // Return an empty list if the response status is not 200
  return [];
}


Future<bool> blockUser(String blockId,String userId) async {
  var responseData = await API_V1_call(
    url: "/api/user/${userId}/block/$blockId",
    method: "GET",
  );

  if (responseData.statusCode == 200) {
    print("CheckResponseBlock:${responseData.body}");
    final data = jsonDecode(responseData.body)['status'] ?? "";
    return (data == 1) ? true : false;
  }

  // Return an empty list if the response status is not 200
  return false;
}


Future<bool> unBlockUser(String blockId,String userId) async {
  var responseData = await API_V1_call(
    url: "/api/user/${userId}/unblock/$blockId",
    method: "DELETE",
  );

  print("CheckResponse:${responseData.body}");
  if (responseData.statusCode == 200) {
    print("CheckResponseBlock:${responseData.body}");
    final data = jsonDecode(responseData.body)['status'] ?? "";
    return (data == 1) ? true : false;
  }

  // Return an empty list if the response status is not 200
  return false;
}