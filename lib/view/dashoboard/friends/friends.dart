import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:needle2/model/friend_request_model.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../../controller/api/api_controller.dart';
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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    callFriendRequestApi();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton.outlined(onPressed: (){Navigator.pop(context);}, icon: Icon(Icons.arrow_back_ios,color: Colors.black,)),
        title: Text('Friends', style: TextStyle(color: Colors.black,fontWeight: FontWeight.w700),),
      ),
      body: _isLoading || friendRequest == null
          ? Center(child: CircularProgressIndicator())
          : friendRequest!.isEmpty
          ? Center(child: Text('No pending friend requests'))
          : ListView.builder(
        itemCount: friendRequest!.length,
        itemBuilder: (context, index) {
          final request = friendRequest![index];
          final DateTime postDate = DateTime.parse(request.createdAt.toString());
          final String formattedDate = timeago.format(postDate);

          return Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: ListTile(
              leading: CircleAvatar(
                radius: 40,
                backgroundImage: (request.profileUrl != null && request.profileUrl.isNotEmpty)
                    ? CachedNetworkImageProvider(
                  imagePathSetter(
                    imageName: request.profileUrl,
                    imageSize: "FULL",
                    requestingImageType: "PROFILE",
                    setUserId: request.senderUserId.toString(),
                  ),
                )
                    : AssetImage("assets/profile_images.png") as ImageProvider,
              ),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    request.displayName ?? 'Unknown',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                Text(
                  formattedDate ?? "",
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 130, // Reduced width
                      height: 35, // Reduced height
                      child: ElevatedButton(
                        onPressed: () {
                          // Handle confirm action
                          friendRequestApprove(request.id.toString());
                        },
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          backgroundColor: Colors.purple,
                        ),
                        child: Text(
                          'Confirm',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    SizedBox(
                      width: 130, // Reduced width
                      height: 35, // Reduced height
                      child: OutlinedButton(
                        onPressed: () {
                          // Handle delete action
                          friendRequestDelete(request.id.toString());
                        },
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          backgroundColor: Colors.black12,
                        ),
                        child: Text(
                          'Delete',
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                    ),
                  ],
                ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}