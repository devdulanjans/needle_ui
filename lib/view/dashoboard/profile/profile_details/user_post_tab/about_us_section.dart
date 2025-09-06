import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../../controller/api/api_controller.dart';
import '../../../../../controller/auth_controller.dart';
import '../../../../../controller/config/image_path_setter.dart';
import '../../../../widget/CommonText.datrt.dart';
import '../../../friends/friends.dart';
import '../../../friends/userExistingFriends.dart';
import '../../../widget/common_seperator.dart';

class UserAboutDetails extends StatefulWidget {
  final userName;
  final userId;

  const UserAboutDetails({this.userName, this.userId, super.key});

  @override
  State<UserAboutDetails> createState() => _UserAboutDetailsState();
}

class _UserAboutDetailsState extends State<UserAboutDetails> {
  List<Map<String, String>> _myFriends = [];
  List<Map<String, String>> _mutualFriends = [];
  bool isLoading = false;

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

  @override
  void initState() {
    // TODO: implement initState
    _fetchFriendDetails();
    _fetchMutualFriendDetails();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 8, right: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Details",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 20),
          Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info, size: 25, color: Colors.purple),
                  SizedBox(width: 10),
                  Text(
                    "Profile. ",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "Entrepreneur",
                    style: TextStyle(fontSize: 16, color: Colors.black),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.link, size: 25, color: Colors.purple),
                  SizedBox(width: 10),
                  CommonText(
                    message: "Website. ",
                    fontSize: 16,
                    setFontWeight: FontWeight.bold,
                  ),
                  CommonText(
                    message: "sample.com",
                    fontSize: 16,
                  ),
                ],
              ),
              SizedBox(height: 20),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.more_horiz, size: 25, color: Colors.purple),
                  SizedBox(width: 10),
                  CommonText(
                    message: "See more ${widget.userName} About info",
                    fontSize: 16,
                  ),
                ],
              ),
              SizedBox(height: 20),
              Separator(),
            ],
          ),
          SizedBox(height: 20),
          GestureDetector(
            onTap: (){
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => UserExistingFriends(userId: widget.userId),
                ),
              );
            },
            child: CommonText(
              message: "Friends",
              fontSize: 20,
              setFontWeight: FontWeight.bold,
            ),
          ),
          _mutualFriends.length != 0 ? Text(
            "${_mutualFriends.length} Mutual Friends",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black38,
            ),
          ):SizedBox(width: 0,),
          // SizedBox(height: 10),
          GridView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: _myFriends.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8.0,
              mainAxisSpacing: 16.0, // Increased spacing for display name
              childAspectRatio: 100/150, // Adjust as needed, made it square for image and text below
            ),
            itemBuilder: (context, index) {
              final friend = _myFriends[index];
              return Container(
                padding: EdgeInsets.only(top: 10, bottom: 10),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey), // Added border here
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Column(
                  // Changed to Column to place text below image
                  children: [
                    Expanded(
                      // Use Expanded to make the image take available space
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        // Adjust corner radius as needed
                        child: Container(
                          // Added BoxDecoration for the border
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: friend['profileImage'] != null
                                  ? CachedNetworkImageProvider(
                                imagePathSetter(
                                  imageName: friend['profileImage'],
                                  imageSize: "PROFILE",
                                  requestingImageType: "COVER",
                                  setUserId: friend['id'].toString(),
                                ),
                              )
                                  : AssetImage("assets/profile_images.png")
                              as ImageProvider,
                              fit: BoxFit
                                  .fitHeight, // Optional: Adjust the fit as needed
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 4), // Spacing between image and text
                    Container(
                      color: Colors.white,
                      height: 50,
                      width: double.infinity,
                      child: CommonText(
                        message: friend['displayName']!,
                        fontSize: 15,
                        isTextAlignCenter: true,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
