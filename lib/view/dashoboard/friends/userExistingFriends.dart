import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../../controller/api/api_controller.dart';
import '../../../controller/auth_controller.dart';
import '../../../controller/config/image_path_setter.dart';
import '../../widget/CommonText.datrt.dart';

class UserExistingFriends extends StatefulWidget {
  final userId;
  const UserExistingFriends({super.key,this.userId});

  @override
  State<UserExistingFriends> createState() => _UserExistingFriendsState();
}

class _UserExistingFriendsState extends State<UserExistingFriends> {
  List<Map<String, String>> _myFriends = [];
  List<Map<String, String>> _mutualFriends = [];
  bool isLoading = false;
  List <dynamic> _pageTab = ['All', 'Mutual'];
  int selectedIndex = 0;

  Future<void> _fetchFriendDetails() async {
    await getUserName();
    var _userId = await getUserId();
    await getUserProfilePicture();

    setState(() {
      isLoading = true;
    });

    print("API : /api/friend/friends/${widget.userId}");

    var responseData = await API_V1_call(
      url: "/api/friend/friends/${widget.userId}",
      method: "GET",
    );

    print("responseData.body: ${responseData.body}");

    if (responseData.statusCode == 200) {
      final data = jsonDecode(responseData.body)['data'] ?? {};
      setState(() {
        _myFriends =
            data.map<Map<String, String>>((friend) {
              return {
                "id": friend['id'].toString(),
                "displayName": friend['displayName']?.toString() ?? "",
                "image": friend['profilePicture']?.toString() ?? "",
                "email": friend['email']?.toString() ?? "",
              };
            }).toList();
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error fetching stories')));
    }
  }

  Future<void> _fetchMutualFriendDetails() async {
    await getUserName();
    var _userId = await getUserId();
    await getUserProfilePicture();

    setState(() {
      isLoading = true;
    });

    print("Mutual API : /api/friend/friends/${_userId}/${widget.userId}");

    var responseData = await API_V1_call(
      url: "/api/friend/mutual-friends/${_userId}/${widget.userId}",
      method: "GET",
    );

    print("Mutual responseData.body: ${responseData.body}");

    if (responseData.statusCode == 200) {
      final decodedResponse = jsonDecode(responseData.body);
      final data = decodedResponse['data'];

      if (data is List) {
        setState(() {
          _mutualFriends = data.map<Map<String, String>>((friend) {
            return {
              "id": friend['id'].toString(),
              "displayName": friend['displayName']?.toString() ?? "",
              "image": friend['profilePicture']?.toString() ?? "",
              "email": friend['email']?.toString() ?? "",
            };
          }).toList();
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } else {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: CommonText(message: "Error Fetching Mutual Friends",)),
      );
    }
  }

  Widget _buildSelectedTabView() {
    switch (selectedIndex) {
      case 0:
        return Padding(padding: EdgeInsets.all(16), child: FriendsWidget());
      case 1:
        return Padding(padding: EdgeInsets.all(16), child: MutualFriendsWidget());
      default:
        return SizedBox();
    }
  }

  Widget FriendsWidget(){
    return  isLoading == true
        ? Center(child: CircularProgressIndicator())
        : SizedBox(
      height: MediaQuery.of(context).size.height,
          child: ListView.builder(
                itemCount: _myFriends!.length,
                itemBuilder: (context, index) {
          final request = _myFriends![index];
          // final DateTime postDate = DateTime.parse(request['createdAt'].toString());
          // final String formattedDate = timeago.format(postDate);

          return Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: ListTile(
              leading: CircleAvatar(
                radius: 40,
                backgroundImage: (request['profileUrl'] != null && request['profileUrl'] != "")
                    ? CachedNetworkImageProvider(
                  imagePathSetter(
                    imageName: request['profileUrl'],
                    imageSize: "FULL",
                    requestingImageType: "PROFILE",
                    setUserId: request['senderUserId'].toString(),
                  ),
                )
                    : AssetImage("assets/profile_images.png") as ImageProvider,
              ),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    request["displayName"] ?? 'Unknown',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                  // Text(
                  //   formattedDate ?? "",
                  //   style: TextStyle(
                  //     color: Colors.grey,
                  //     fontSize: 12,
                  //   ),
                  // ),
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.start,
                  //   children: [
                  //     SizedBox(
                  //       width: 130, // Reduced width
                  //       height: 35, // Reduced height
                  //       child: ElevatedButton(
                  //         onPressed: () {
                  //           // Handle confirm action
                  //           // friendRequestApprove(request.id.toString());
                  //         },
                  //         style: ElevatedButton.styleFrom(
                  //           shape: RoundedRectangleBorder(
                  //             borderRadius: BorderRadius.circular(12),
                  //           ),
                  //           backgroundColor: Colors.purple,
                  //         ),
                  //         child: Text(
                  //           'Confirm',
                  //           style: TextStyle(color: Colors.white),
                  //         ),
                  //       ),
                  //     ),
                  //     SizedBox(width: 8),
                  //     SizedBox(
                  //       width: 130, // Reduced width
                  //       height: 35, // Reduced height
                  //       child: OutlinedButton(
                  //         onPressed: () {
                  //           // Handle delete action
                  //           // friendRequestDelete(request.id.toString());
                  //         },
                  //         style: ElevatedButton.styleFrom(
                  //           shape: RoundedRectangleBorder(
                  //             borderRadius: BorderRadius.circular(12),
                  //           ),
                  //           backgroundColor: Colors.black12,
                  //         ),
                  //         child: Text(
                  //           'Delete',
                  //           style: TextStyle(color: Colors.black),
                  //         ),
                  //       ),
                  //     ),
                  //   ],
                  // ),
                ],
              ),
            ),
          );
                },
              ),
        );
  }

  Widget MutualFriendsWidget(){
    return  isLoading == true
        ? Center(child: CircularProgressIndicator())
        : SizedBox(
      height: MediaQuery.of(context).size.height,
      child: ListView.builder(
        itemCount: _mutualFriends!.length,
        itemBuilder: (context, index) {
          final request = _mutualFriends![index];
          // final DateTime postDate = DateTime.parse(request['createdAt'].toString());
          // final String formattedDate = timeago.format(postDate);

          return Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: ListTile(
              leading: CircleAvatar(
                radius: 40,
                backgroundImage: (request['profileUrl'] != null && request['profileUrl'] != "")
                    ? CachedNetworkImageProvider(
                  imagePathSetter(
                    imageName: request['profileUrl'],
                    imageSize: "FULL",
                    requestingImageType: "PROFILE",
                    setUserId: request['senderUserId'].toString(),
                  ),
                )
                    : AssetImage("assets/profile_images.png") as ImageProvider,
              ),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    request["displayName"] ?? 'Unknown',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                  // Text(
                  //   formattedDate ?? "",
                  //   style: TextStyle(
                  //     color: Colors.grey,
                  //     fontSize: 12,
                  //   ),
                  // ),
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.start,
                  //   children: [
                  //     SizedBox(
                  //       width: 130, // Reduced width
                  //       height: 35, // Reduced height
                  //       child: ElevatedButton(
                  //         onPressed: () {
                  //           // Handle confirm action
                  //           // friendRequestApprove(request.id.toString());
                  //         },
                  //         style: ElevatedButton.styleFrom(
                  //           shape: RoundedRectangleBorder(
                  //             borderRadius: BorderRadius.circular(12),
                  //           ),
                  //           backgroundColor: Colors.purple,
                  //         ),
                  //         child: Text(
                  //           'Confirm',
                  //           style: TextStyle(color: Colors.white),
                  //         ),
                  //       ),
                  //     ),
                  //     SizedBox(width: 8),
                  //     SizedBox(
                  //       width: 130, // Reduced width
                  //       height: 35, // Reduced height
                  //       child: OutlinedButton(
                  //         onPressed: () {
                  //           // Handle delete action
                  //           // friendRequestDelete(request.id.toString());
                  //         },
                  //         style: ElevatedButton.styleFrom(
                  //           shape: RoundedRectangleBorder(
                  //             borderRadius: BorderRadius.circular(12),
                  //           ),
                  //           backgroundColor: Colors.black12,
                  //         ),
                  //         child: Text(
                  //           'Delete',
                  //           style: TextStyle(color: Colors.black),
                  //         ),
                  //       ),
                  //     ),
                  //   ],
                  // ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _fetchFriendDetails();
    _fetchMutualFriendDetails();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton.outlined(onPressed: (){Navigator.pop(context);}, icon: Icon(Icons.arrow_back_ios,color: Colors.black,)),
        title: Text('Friends', style: TextStyle(color: Colors.black,fontWeight: FontWeight.w700),),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width,
              height: 55,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _pageTab.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedIndex = index;
                        });
                      },
                      child: Container(
                        padding: EdgeInsets.all(10.0),
                        margin: EdgeInsets.only(left: 5.0),
                        decoration: BoxDecoration(
                          color: selectedIndex == index ? Colors.purple.shade50 : Colors.white,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Center(
                          child: Text(
                            _pageTab[index],
                            style: TextStyle(color:  selectedIndex == index ? Colors.purpleAccent:Colors.black,fontSize: 14, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            _buildSelectedTabView()
          ],
        ),
      ),
    );
  }
}
