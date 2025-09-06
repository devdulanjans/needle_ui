import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../controller/api/api_controller.dart';
import '../../controller/auth_controller.dart';
import '../../controller/config/image_path_setter.dart';
import '../../model/logged_user_profile_model.dart';
import 'page_invite_friends.dart';

class PageProfileImageSet extends StatefulWidget {
  int page_id;
  String page_name;
  String selectedCategory;
  String bio;

  PageProfileImageSet({
    super.key,
    required this.page_id,
    required this.page_name,
    required this.selectedCategory,
    required this.bio
  });

  @override
  State<PageProfileImageSet> createState() => _PageProfileImageSetState();
}

class _PageProfileImageSetState extends State<PageProfileImageSet> {
  File? _selectedCoverImage;
  File? _selectedImage;
  String loggedUserId = "";
  String? userId = "";
  String? userName = "";
  LoggedUserProfile? fetchedUserData;

  Future<void> ProfileImageUploader() async {
    print("page_id: ${widget.page_id}");

    var responseData = await API_V1_Multipart_call_Page(
      url: "/api/page/profile/${widget.page_id}",
      method: "PUT",
      isHeader: true,
      filePaths: _selectedImage?.path
    );
    //
    // return;
    //
    // print("Page PROF responseData.statusCode: ${responseData.body}");
    // print("Page PROF responseData.statusCode 1: ${responseData.statusCode}");
    //
    // if (responseData.statusCode == 201) {
    //   final data =
    //       jsonDecode(responseData.body)['data'] == null
    //           ? []
    //           : jsonDecode(responseData.body)['data'];
    //   print("1122 - responseData: $responseData");
    //   // Navigator.of(context).push(
    //   //   MaterialPageRoute(
    //   //     builder: (context) => FinishPage(page_id: 1,page_name: widget.pageName,page_details: data,),
    //   //   ),
    //   // );
    //
    //   // ScaffoldMessenger.of(
    //   //   context,
    //   // ).showSnackBar(SnackBar(content: Text('Error fetching stories')));
    // } else {
    //   // Handle error
    //   setState(() {
    //     // _isLoading = false;
    //   });
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     SnackBar(
    //       content: Text(
    //         'error storing data',
    //         style: TextStyle(color: Colors.red),
    //       ),
    //     ),
    //   );
    // }
  }

  Future<void> callLocalData() async {
    var _userIdVal = await getUserId();
    var _userNameVal = await getUserName();
    setState(() {
      userName = _userNameVal;
      userId = _userIdVal;
    });
  }

  Future<void> profileData() async {
    loggedUserId = (await getUserId())!;
    await getUserProfilePicture();
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

  Future<void> _pickProfileImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: Icon(Icons.arrow_back_ios, color: Colors.black),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight:
                    MediaQuery.of(
                      context,
                    ).size.height, // Ensures the Column has a minimum height
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Text(
                      "Customise your page",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Text(
                      "Your profile image and cover photo will help people recognize your page. Try using your business logo or a photo that represents your business.",
                      style: TextStyle(color: Colors.black54, fontSize: 16),
                    ),
                  ),
                  SizedBox(height: 20),

                  Container(
                    padding: EdgeInsets.only(left: 10, right: 10),
                    height: 200,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(15),
                            topLeft: Radius.circular(15),
                          ),
                          // Adjust the radius as needed
                          child:
                              _selectedCoverImage != null
                                  ? Image.file(
                                    _selectedCoverImage!,
                                    fit: BoxFit.cover,
                                  )
                                  : Image.asset(
                                    "assets/default_cover.png",
                                    fit: BoxFit.cover,
                                  ),
                        ),
                        Positioned(
                          bottom: 10,
                          right: 10,
                          child: CircleAvatar(
                            radius: 20,
                            backgroundColor: Colors.grey.shade300,
                            child: IconButton(
                              icon: Icon(Icons.camera_alt, color: Colors.black),
                              onPressed: _pickCoverImage,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Center(
                    child: Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.blue,
                              // Specify your border color here
                              width: 2.0, // Specify the border width
                            ),
                          ),
                          child: CircleAvatar(
                            radius: 100,
                            backgroundImage:
                                _selectedImage != null
                                    ? FileImage(_selectedImage!)
                                    : (fetchedUserData
                                            ?.profilePicture
                                            ?.isNotEmpty ??
                                        false)
                                    ? CachedNetworkImageProvider(
                                      imagePathSetter(
                                        imageName:
                                            fetchedUserData?.profilePicture,
                                        imageSize: "THUMBNAIL",
                                        requestingImageType: "PROFILE",
                                        setUserId:
                                            fetchedUserData?.id.toString(),
                                      ),
                                    )
                                    : AssetImage("assets/profile_images.png")
                                        as ImageProvider,
                          ),
                        ),
                        // if (loggedUserId == fetchedUserData!.id.toString())
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: GestureDetector(
                            onTap: _pickProfileImage,
                            child: CircleAvatar(
                              radius: 20,
                              backgroundColor: Colors.grey.shade300,
                              child: Icon(
                                Icons.camera_alt,
                                color: Colors.black,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: 120,
              width: MediaQuery.of(context).size.width - 30,
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 15, right: 15.0),
                    child: Text(
                      "By Creating a page, you agree to our Terms, Data Policy and Cookies Policy. You may receive SMS notifications from us and can opt out at any time.",
                      style: TextStyle(color: Colors.black54, fontSize: 12),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20.0),
                    // Add some padding at the bottom
                    child: Center(
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width,
                        child: ElevatedButton(
                          onPressed: () {
                            ProfileImageUploader();
                            // Navigator.of(context).push(
                            //   MaterialPageRoute(
                            //     builder: (context) => PageInviteFriends(),
                            //   ),
                            // );
                          },
                          child: Text(
                            'Next',
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Colors.purple, // Button background color
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
