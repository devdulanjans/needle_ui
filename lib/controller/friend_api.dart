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