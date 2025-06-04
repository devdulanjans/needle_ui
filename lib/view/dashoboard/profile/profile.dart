import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
import 'package:needle2/view/dashoboard/profile/user_profile_details.dart';

import '../../../controller/api/api_controller.dart';
import '../../../controller/auth_controller.dart';
import '../../../model/logged_user_profile_model.dart';

class ProfileScreen extends StatefulWidget {
  final LoggedUserProfile? userProfile;

  ProfileScreen({this.userProfile});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool isLoading = false;
  bool isFriend = false;
  String? userId = "";
  String? userName = "";
  File? _selectedImage;
  File? _selectedProfileImage;

  Future<void> _handleAddFriend() async {
    setState(() {
      isLoading = true;
    });

    String? userId = await getUserId();

    print('userId $userId');
    return;

    try {
      // Simulate API call
      Map<String, dynamic>? body = {
        "senderUserId": userId,
        "receiverUserId": widget.userProfile?.id,
      };

      final response = await API_V1_call(
        url: "/api/friend-request",
        method: "POST",
        body: body,
        isHeader: true
      );

      print("body: $body");
      print("response.statusCode: ${response.statusCode}");
      print("RESPONSE DATA: ${response.body}");

      if (response.statusCode == 200) {
        print("RESPONSE DATA: ${response.body}");
        // final data = (jsonDecode(response.body)['data'] as List<dynamic>)
        //     .cast<Map<String, dynamic>>();
        // Update friendship state
        setState(() {
          isFriend = !isFriend;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching search results')),
        );
      }

    } catch (e) {
      print("Error calling API: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    callLocalData();
  }

  Future<void> callLocalData() async {
    var _userId = await getUserId();
    var _userName = await getUserName();
    setState(() {
      userName = _userName;
      _userId = _userId;
    });
    print('userId $userId');
    return;
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _pickProfileImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedProfileImage = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // SliverAppBar(
          //   expandedHeight: 200,
          //   flexibleSpace: FlexibleSpaceBar(
          //     background: widget.userProfile?.profilePicture != null
          //         ? Image.asset(
          //       "assets/default_cover.png",
          //       fit: BoxFit.cover,
          //     )
          //         : CachedNetworkImage(
          //       imageUrl: 'https://picsum.photos/800/600',
          //       fit: BoxFit.cover,
          //     ),
          //   ),
          // ),
          SliverAppBar(
            expandedHeight: 200,
            flexibleSpace: _selectedImage != null
                ? Image.file(
              _selectedImage!,
              fit: BoxFit.cover,
            )
                : CachedNetworkImage(
              imageUrl: 'https://picsum.photos/800/600',
              fit: BoxFit.cover,
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 60,
                          backgroundImage: _selectedProfileImage != null
                              ? FileImage(_selectedProfileImage!)
                              : CachedNetworkImageProvider('https://randomuser.me/api/portraits/men/75.jpg') as ImageProvider,
                        ),
                        Spacer(),
                        Column(
                          children: [
                            Text('1,234', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
                            Text('Posts'),
                          ],
                        ),
                        SizedBox(width: 20),
                        Column(
                          children: [
                            Text('12.3K', style: TextStyle(fontWeight: FontWeight.bold)),
                            Text('Followers'),
                          ],
                        ),
                        SizedBox(width: 20),
                        Column(
                          children: [
                            Text('456', style: TextStyle(fontWeight: FontWeight.bold)),
                            Text('Following'),
                          ],
                        ),
                        Spacer(),
                      ],
                    ),
                    SizedBox(height: 16),
                    Text(
                      userName!,
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 20),
                    ),
                    Text(widget.userProfile?.bio?.toString() ?? 'Unknown User', style: TextStyle(color: Colors.black)),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: isLoading ? null : _handleAddFriend,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isFriend ? Colors.red : Colors.purple,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: isLoading
                                ? SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text(
                                    isFriend ? 'Unfriend' : 'Add As Friend',
                                    style: TextStyle(color: Colors.white),
                                  ),
                          ),
                        ),
                        SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => UserListPage(
                                    userDisplayName: widget.userProfile?.displayName?.toString() ?? 'Unknown User',
                                ),
                              ),
                            );
                          },
                          child: Icon(Icons.menu,color: Colors.black,),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              GridView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 2,
                  mainAxisSpacing: 2,
                ),
                itemCount: 15,
                itemBuilder: (context, index) => CachedNetworkImage(
                  imageUrl: 'https://picsum.photos/300/300?random=$index',
                  fit: BoxFit.cover,
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }
}