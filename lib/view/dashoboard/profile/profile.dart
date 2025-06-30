import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
import 'package:needle2/view/dashoboard/profile/user_profile_details.dart';

import '../../../controller/api/api_controller.dart';
import '../../../controller/auth_controller.dart';
import '../../../controller/config/image_path_setter.dart';
import '../../../model/logged_user_profile_model.dart';
import '../widget/common_seperator.dart';
import 'profile_details/user_post_tab/about_us_section.dart';
import 'profile_details/user_post_tab/user_photos.dart';
import 'profile_details/user_post_tab/view_post_section.dart';

class ProfileScreen extends StatefulWidget {
  final LoggedUserProfile? userProfile;
  final String? userId;

  ProfileScreen({this.userProfile, this.userId});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool isLoading = false;
  bool isFriend = false;
  String? userId = "";
  String? userName = "";
  File? _selectedCoverImage;
  File? _selectedImage;
  String loggedUserId = "";
  LoggedUserProfile? fetchedUserData;
  List <dynamic> _pageTab = ['Post', 'About', 'Videos', 'Photos'];
  int selectedIndex = 0;

  Future<void> _handleAddFriend() async {
    setState(() {
      isLoading = true;
    });

    String? userId = await getUserId();

    try {
      Map<String, dynamic>? body = {
        "senderUserId": userId,
        "receiverUserId": widget.userProfile?.id,
      };

      final response = await API_V1_call(
        url: "/api/friend-request",
        method: "POST",
        body: body,
        isHeader: true,
      );

      if (response.statusCode == 200) {
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

  Future<void> callLocalData() async {
    var _userIdVal = await getUserId();
    var _userNameVal = await getUserName();
    setState(() {
      userName = _userNameVal;
      userId = _userIdVal;
    });
  }

  Future<void> _pickCoverImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedCoverImage = File(pickedFile.path);
        // Here you would typically upload the image to your server
        // and update the user's cover image URL in your database.
      });
    }
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
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> profileData() async {
    loggedUserId = (await getUserId())!;
    await getUserProfilePicture();
  }

  Future<void> _fetchUserDetails() async {
    await getUserName();
    await getUserId();
    await getUserProfilePicture();

    setState(() {
      isLoading = true;
    });

    var responseData = await API_V1_call(
      url: "/api/user/details/${widget.userId}",
      method: "GET",
    );

    if (responseData.statusCode == 200) {
      final data = jsonDecode(responseData.body)['data'] ?? {};
      setState(() {
        fetchedUserData = LoggedUserProfile.fromJson(data);
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching stories')),
      );
    }
  }

  Widget loggedUserData() {
    return Row(
      children: [
        ElevatedButton(
          onPressed: (){},
          // onPressed: isLoading ? null : _handleAddFriend,
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
              : Row(
            children: [
              Icon(Icons.dashboard, color: Colors.white),
              SizedBox(width: 4),
              Text('Professional dashboard', style: TextStyle(color: Colors.white)),
            ],
          ),
        ),
        SizedBox(width: 4),
        ElevatedButton(
          onPressed: (){},
          // onPressed: isLoading ? null : _handleAddFriend,
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
              : Row(
            children: [
              Icon(Icons.post_add, color: Colors.white),
              SizedBox(width: 4),
              Text('Create Post', style: TextStyle(color: Colors.white)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSelectedTabView() {
    switch (selectedIndex) {
      case 0:
        return Padding(padding: EdgeInsets.all(16), child: ViewPostDetails(userName: fetchedUserData?.displayName,userId: fetchedUserData?.id,));
      case 1:
        return Padding(padding: EdgeInsets.all(16), child: UserAboutDetails(userName: fetchedUserData?.displayName,userId: fetchedUserData?.id,));
      case 2:
        return Padding(padding: EdgeInsets.all(16), child: Center(child: Text('Videos are not Showing yet', style: TextStyle(color: Colors.black),)));
      case 3:
        return Padding(padding: EdgeInsets.all(16), child: UserPhotos(userDisplayName: fetchedUserData?.displayName, userId: fetchedUserData?.id,));
      case 4:
        return Padding(padding: EdgeInsets.all(16), child: Text('Event Section', style: TextStyle(color: Colors.black),));
      default:
        return SizedBox();
    }
  }

  @override
  void initState() {
    super.initState();
    callLocalData();
    profileData();
    _fetchUserDetails();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: fetchedUserData == null
          ? Center(child: CircularProgressIndicator())
          : CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 200,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  _selectedCoverImage != null
                      ? Image.file(
                    _selectedCoverImage!,
                    fit: BoxFit.cover,
                  )
                      : (fetchedUserData?.coverImage?.isNotEmpty ?? false)
                      ? Image(
                    image: CachedNetworkImageProvider(
                      imagePathSetter(
                        imageName: fetchedUserData?.coverImage,
                        imageSize: "THUMBNAIL",
                        requestingImageType: "COVER",
                        setUserId: fetchedUserData?.id.toString(),
                      ),
                    ),
                    fit: BoxFit.cover,
                  )
                      : Image.asset("assets/default_cover.png", fit: BoxFit.cover),
                  if (loggedUserId == fetchedUserData!.id.toString())
                  Positioned(
                    bottom: 10,
                    right: 10,
                    child: IconButton(
                      icon: Icon(Icons.camera_alt, color: Colors.white),
                      onPressed: _pickCoverImage,
                    ),
                  ),
                ],
              ),
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
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            CircleAvatar(
                              radius: 60,
                              backgroundImage: _selectedImage != null
                                  ? FileImage(_selectedImage!)
                                  : (fetchedUserData?.profilePicture?.isNotEmpty ?? false)
                                      ? CachedNetworkImageProvider(
                                          imagePathSetter(
                                            imageName: fetchedUserData?.profilePicture,
                                            imageSize: "THUMBNAIL",
                                            requestingImageType: "PROFILE",
                                            setUserId: fetchedUserData?.id.toString(),
                                          ),
                                        )
                                  : AssetImage("assets/profile_images.png") as ImageProvider,
                            ),
                            if (loggedUserId == fetchedUserData!.id.toString())
                              Positioned(
                                right: 0,
                                bottom: 0,
                                child: GestureDetector(
                                  onTap: _pickProfileImage,
                                  child: CircleAvatar(
                                    radius: 20,
                                    backgroundColor: Colors.grey.shade300,
                                    child: Icon(Icons.camera_alt, color: Colors.black, size: 20),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        Spacer(),
                      ],
                    ),
                    SizedBox(height: 16),
                    Text(
                      fetchedUserData!.displayName,
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 20),
                    ),
                    fetchedUserData?.bio?.isNotEmpty ?? false
                        ? Text(fetchedUserData?.bio ?? '', style: TextStyle(color: Colors.black))
                        : SizedBox.shrink(),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        loggedUserId == fetchedUserData!.id.toString()
                            ? loggedUserData()
                            : Expanded(
                          child: ElevatedButton(
                            onPressed: isLoading ? null : _handleAddFriend,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isFriend ? Colors.red : Colors.purple,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: isLoading
                                ? SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                                : Text(
                              isFriend ? 'Unfriend' : 'Add As Friend',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                        SizedBox(width: 8),
                        loggedUserId == fetchedUserData!.id.toString()
                            ? SizedBox.shrink()
                            : ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => UserListPage(
                                  userDisplayName: fetchedUserData?.displayName ?? 'Unknown User',
                                ),
                              ),
                            );
                          },
                          child: Icon(Icons.menu, color: Colors.black),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Separator(),
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
              _buildSelectedTabView(),
            ]),
          ),
        ],
      ),
    );
  }
}