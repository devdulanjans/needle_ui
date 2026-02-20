import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:needle2/model/friend_request_model.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../../controller/api/api_controller.dart';
import '../../../controller/auth_controller.dart';
import '../../../controller/config/image_path_setter.dart';
import '../../../controller/friend_api.dart';

class FriendsPage extends StatefulWidget {
  @override
  State<FriendsPage> createState() => _FriendsPageState();
}

class _FriendsPageState extends State<FriendsPage> {
  // List<FriendRequest> data = await
  // // friendRequests = [
  // //   {
  // //     'name': 'John Doe',
  // //     'image': 'https://randomuser.me/api/portraits/men/1.jpg',
  // //     'date': 'Requested on: Oct 10, 2023',
  // //   },
  // //   {
  // //     'name': 'Jane Smith',
  // //     'image': 'https://randomuser.me/api/portraits/women/2.jpg',
  // //     'date': 'Requested on: Oct 12, 2023',
  // //   },
  // // ];

  bool _isLoading = false;
  List<FriendRequest>? friendRequest;
  List<FriendRequest>? blockUsers;
  bool isBlockPage = false;
  String loggedUserId = "";

  Future<void> callFriendRequestApi() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final requests = await getAllPendingRequest();
      setState(() {
        friendRequest = requests.isNotEmpty ? requests : [];
        _isLoading = false;
      });
    } catch (e) {
      print("Error fetching friend requests: $e");
      setState(() {
        friendRequest = [];
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching friend requests: $e')),
      );
    }
  }

  Future<void> friendRequestApprove(String id) async{
    setState(() {
      _isLoading = true;
    });
    var responseData = await API_V1_call(
      url: "/api/friend-request/status/${id}?status=ACCEPTED",
      method: "PUT",
      isHeader: true,
    );
    setState(() {
      _isLoading = false;
    });
    if (responseData.statusCode == 200) {
      final data = jsonDecode(responseData.body)['data'] == null
          ? []
          : jsonDecode(responseData.body)['data'];
      print(responseData);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Friend request approved successfully!')),
      );
      // Refresh the list after approval
      callFriendRequestApi();
    } else {
      // Handle error
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to approve friend request: ${responseData.body}')));
    }
  }

  Future<void> friendRequestDelete(String id) async{

    print("ID: ${id}");
    print("URL: /api/friend-request/status/${id}?status=ACCEPTED");

    setState(() {
      _isLoading = true;
    });
    var responseData = await API_V1_call(
      url: "/api/friend-request/${id}",
      method: "DELETE",
      isHeader: true,
    );
    setState(() {
      _isLoading = false;
    });
    print('asd - Response: ${responseData.statusCode}');
    print('asd - Response: ${responseData.body}');

    if (responseData.statusCode == 200) {
      final data = jsonDecode(responseData.body)['data'] == null
          ? []
          : jsonDecode(responseData.body)['data'];
      print(responseData);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Friend request deleted successfully!')),
      );
      // Refresh the list after deletion
      callFriendRequestApi();
    } else {
      // Handle error
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to delete friend request: ${responseData.body}')));
    }
  }

  Future<void> getBlockUsers() async {
    loggedUserId = await getProfileUserId() ?? "";
    setState(() {
      _isLoading = true;
    });
    try {
      final requests = await getAllBlockUsers(loggedUserId);
      setState(() {
        blockUsers = requests.isNotEmpty ? requests : [];
        _isLoading = false;
      });
    } catch (e) {
      print("Error fetching friend requests: $e");
      setState(() {
        blockUsers = [];
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching friend requests: $e')),
      );
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    callFriendRequestApi();
    getBlockUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
       leading: null,
        title: Text(isBlockPage ? "Block Users" : 'Friends', style: TextStyle(color: Colors.black,fontWeight: FontWeight.w700),),
        actions: [
          Row(
            children: [
              IconButton(
                icon: Icon(isBlockPage ? Icons.block : Icons.person, color: Colors.black), // Right icon (Chat icon)
                onPressed: () {
                  setState(() {
                    isBlockPage = !isBlockPage;

                  });
                },
              ),

            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
        child: CircularProgressIndicator(),
      )
          : isBlockPage
          ? buildBlockedUsers()
          : buildFriendRequests(),
    );
  }



Widget buildFriendRequests() {
  if (friendRequest == null ||
      friendRequest!.isEmpty) {
    return const Center(
      child: Text(
        'No pending friend requests',
        style: TextStyle(color: Colors.black54),
      ),
    );
  }

  return ListView.builder(
    itemCount: friendRequest!.length,
    itemBuilder: (context, index) {
      final request = friendRequest![index];
      final DateTime postDate =
      DateTime.parse(request.createdAt.toString());
      final String formattedDate =
      timeago.format(postDate);

      return Padding(
        padding:
        const EdgeInsets.only(bottom: 8.0),
        child: ListTile(
          leading: CircleAvatar(
            radius: 30,
            backgroundImage:
            (request.profileUrl != null &&
                request.profileUrl
                    .isNotEmpty)
                ? CachedNetworkImageProvider(
                request.profileUrl)
                : const AssetImage(
                "assets/profile_images.png")
            as ImageProvider,
          ),
          title: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              Text(
                request.displayName ??
                    'Unknown',
                style: GoogleFonts.poppins(
                  fontWeight:
                  FontWeight.w500,
                  fontSize: 16,
                  color: Colors.black,
                ),
              ),
              Text(
                formattedDate,
                style:
                const TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  SizedBox(
                    width: 120,
                    height: 35,
                    child:
                    ElevatedButton(
                      onPressed: () {
                        friendRequestApprove(
                            request.id
                                .toString());
                      },
                      style:
                      ElevatedButton
                          .styleFrom(
                        backgroundColor:
                        Colors.purple,
                        shape:
                        RoundedRectangleBorder(
                          borderRadius:
                          BorderRadius
                              .circular(
                              12),
                        ),
                      ),
                      child:
                      const Text(
                        "Confirm",
                        style: TextStyle(
                            color: Colors
                                .white),
                      ),
                    ),
                  ),
                  const SizedBox(
                      width: 8),
                  SizedBox(
                    width: 120,
                    height: 35,
                    child:
                    OutlinedButton(
                      onPressed: () {
                        friendRequestDelete(
                            request.id
                                .toString());
                      },
                      child:
                      const Text(
                        "Delete",
                        style: TextStyle(
                            color: Colors
                                .black),
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      );
    },
  );
}

// ================= BLOCK USERS VIEW =================

Widget buildBlockedUsers() {
  if (blockUsers == null || (blockUsers ?? []).isEmpty) {
    return const Center(
      child: Text(
        'No blocked users',
        style: TextStyle(color: Colors.black54),
      ),
    );
  }

  return ListView.builder(
    itemCount: blockUsers!.length,
    itemBuilder: (context, index) {
      final user = blockUsers![index];

      return ListTile(
        leading: CircleAvatar(
          backgroundImage:
          (user.profileUrl != null &&
              user.profileUrl
                  .isNotEmpty)
              ? CachedNetworkImageProvider(
              user.profileUrl)
              : const AssetImage(
              "assets/profile_images.png")
          as ImageProvider,
        ),
        title: Text(
          user.displayName ?? "Unknown",
          style: TextStyle(color: Colors.black),
        ),
        trailing:
        ElevatedButton(
          onPressed: () async{
            bool result = await unBlockUser((user.id ?? "").toString(), loggedUserId);
            if(result){
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('User unblocked successfully.',style: TextStyle(color: Colors.black),),backgroundColor: Colors.purple.shade100,),);
              getBlockUsers();
            }else{
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('User unblocked failed.',style: TextStyle(color: Colors.black),),backgroundColor: Colors.red.shade100,),);
            }

          },
          style:
          ElevatedButton
              .styleFrom(
            backgroundColor:
            Colors.red,
          ),
          child: const Text(
            "Unblock",
            style: TextStyle(
                color: Colors.white),
          ),
        ),
      );
    },
  );
}

}