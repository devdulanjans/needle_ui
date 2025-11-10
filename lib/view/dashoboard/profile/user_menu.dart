import 'dart:convert';
import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../controller/api/api_controller.dart';
import '../../../controller/auth_controller.dart';
import '../../../controller/config/image_path_setter.dart';
import '../../main_screen.dart';
import '../../needle_page/page_type.dart';
import '../../needle_page/swiitch_page.dart';
import '../../settings/settings_and_privacy.dart';
import '../post/save_post.dart';
import 'profile.dart';

class UserMenu extends StatefulWidget {
  const UserMenu({super.key});

  @override
  State<UserMenu> createState() => _UserMenuState();
}

class _UserMenuState extends State<UserMenu> {
  String _profileImage = "";
  String _userName = "";
  String _getUserId = "";
  bool isLoading = false;
  String profileType = "USER";

  List<dynamic> pageList = [];

  Future<void> profileData() async {
    var _userId = await getProfileUserId();
    var requestImageType = await getImageRequestType();
    var _imageUrl = await getUserProfilePicture();
    profileType = await getProfileType() ?? "USER";

    setState(() {
      if (_imageUrl != null && _imageUrl.isNotEmpty) {
        _profileImage = imagePathSetter(
          imageName: _imageUrl,
          imageSize: "THUMBNAIL",
          requestingImageType: requestImageType ?? "PROFILE",
          setUserId: _userId,
        );
      } else {
        _profileImage = "";
      }
    });

    print("PROFILE IMAGE: $_profileImage");
  }

  setProfileName() async {
    var _getUserName = await getUserName();
    var _userId = await getUserId();
    setState(() {
      if (_getUserName != null) {
        _userName = _getUserName;
        _getUserId = _userId!;
      } else {
        _userName = "";
        _getUserId = "";
      }
    });
  }

  Future<void> _fetchFriendDetails() async {
    var userName = await getUserName();
    var _userId = await getProfileUserId();
    var userProfile = await getUserProfilePicture();


    setState(() {
      isLoading = true;
    });

    var responseData = await API_V1_call(
      url: "/api/page/${_userId}?type=OWNERANDADMIN",
      method: "GET",
    );

    print("responseData.body: ${responseData.body}");
    print("Page Calling API: /api/page/${_userId}?type=OWNER");

    if (responseData.statusCode == 200) {
      final decodedResponse = jsonDecode(responseData.body);
      final data = decodedResponse['data'];



      if (data is Iterable) {
        setState(() {
          pageList = List<dynamic>.from(data);
          isLoading = false;
        });
      } else if (data is Map) {
        setState(() {
          pageList = List<dynamic>.from(
            data.values,
          ); // Convert Map values to List
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Unexpected data format')));
      }
    } else {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error fetching stories')));
    }
  }

  void callSwitchPage(dynamic pageDetails) async {

    final profile = await getActiveProfile();


    print("Logged in as ${profile['name']} - isPage: ${profile['isPage']}");
    log("CheckPageDetaild:${pageDetails.toString()}");
    bool isPage =(pageDetails['ownerId'] ?? "").toString() != "" ? true : false;
    log("CheckIsPage:$isPage -- ${""}");


    if(isPage){
      //Switch to page
      await savePage(
        userId: (pageDetails['id'] ?? "").toString(),
        displayName: pageDetails['displayName'] ?? "",
        email: pageDetails['email'] ?? "",
        bio: pageDetails['bio'] ?? "",
        profilePicture: pageDetails['profilePicture'] ?? "",
        coverImage:pageDetails['coverPicture'] ?? "",
        mobileNo: (pageDetails['contactNumber'] ?? "").toString(),
        isPage: true
      );
    }else{
      //Re-switch to profile

      await savePage(
        userId: (pageDetails['userId'] ?? "").toString(),
        displayName: pageDetails['displayName'] ?? "",
        email: pageDetails['email'] ?? "",
        bio: pageDetails['bio'] ?? "",
        profilePicture: pageDetails['profilePicture'] ?? "",
        coverImage:pageDetails['coverPicture'] ?? "",
        mobileNo: (pageDetails['mobileNo'] ?? "").toString(),
        isPage:false
      );
    }



    Navigator.of(context).pop();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => MainScreen(screenIndex: 4),
      ),
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    profileData();
    setProfileName();
    _fetchFriendDetails();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Menu",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.settings, color: Colors.black),
            onPressed: () {
              print("Click");
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SettingsPrivacyPage()),
              );
            },
          ),
          SizedBox(width: 16),
          Icon(Icons.search, color: Colors.black),
          SizedBox(width: 16),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProfileSection(),
                  // const SizedBox(height: 10),
                  // _buildShortcutsSection(),
                  const SizedBox(height: 10),
                  _buildMenuGridSection(),
                ],
              ),
            ),
          ),
          _buildSeeAllProfileButton(),
        ],
      ),
      // bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildProfileSection() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          CircleAvatar(
            backgroundImage:
                (_profileImage.isNotEmpty &&
                        Uri.tryParse(_profileImage)?.hasAbsolutePath == true)
                    ? NetworkImage(_profileImage)
                    : AssetImage("assets/profile_images.png") as ImageProvider,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => ProfileScreen(userId: _getUserId,profileType: profileType),
                  ),
                );
              },
              child: Text(
                _userName,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.black,
                ),
              ),
            ),
          ),
          Stack(
            alignment: Alignment.center,
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: Colors.grey[300],
                // Added a background color for visibility
                child: Center(
                  // Ensures the IconButton is centered
                  child: IconButton(
                    color: Colors.grey,
                    onPressed: () {
                      _existingPageListShowModalBottomSheet();
                    },
                    icon: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 28,
                      color: Colors.black, // Changed icon color for contrast
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSeeAllProfileButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.purple,
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          onPressed: () {
            _existingPageListShowModalBottomSheet();
          },
          child: const Text(
            "See all profiles",
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
      ),
    );
  }

  Future<dynamic> _existingPageListShowModalBottomSheet() {
    return showModalBottomSheet(
      isScrollControlled: true, // Allow dynamic height based on content
      context: context,
      builder: (BuildContext context) {
        // Get 75% of the screen height
        double height = MediaQuery.of(context).size.height * 0.75;

        return Container(
          height: height, // Set the fixed height for the bottom sheet
          margin: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20.0),
              topRight: Radius.circular(20.0),
            ),
            border: Border.all(color: Colors.grey, width: 0.5),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min, // Prevents the column from taking up more space than necessary
            children: [
              if (isLoading)
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(),
                )
              else if (pageList.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    "No pages found.",
                    style: TextStyle(color: Colors.black),
                  ),
                )
              else
              // Wrapping ListView in Expanded to make it scrollable
                Expanded(
                  child: FutureBuilder<Map<String, String?>>(
                    future: getUserData(), // Fetch all user data from SharedPreferences
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        // Show a loading spinner while fetching the data
                        return Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        // Handle errors (optional)
                        return Center(child: Text('Error loading user data'));
                      } else if (!snapshot.hasData || snapshot.data == null) {
                        // Handle empty or null data
                        return Center(child: Text('No user data available'));
                      }

                      // Get the user data from the snapshot
                      var userData = snapshot.data!;
                      String tempUserPPic = userData['profilePicture'] ?? "";
                      String finalProfileImage = imagePathSetter(
                        imageName: tempUserPPic,
                        imageSize: "THUMBNAIL",
                        requestingImageType: "PROFILE",
                        setUserId: userData['userId'] ?? "",
                      );
                      print("CheckUserProfilePicture:${tempUserPPic}");

                      return Column(
                        children: [
                          // Top profile details section
                          GestureDetector(
                            onTap:(){
                              if(_getUserId == userData['userId']){
                                print("sameprofile");
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Profile already selected!',
                                      style: TextStyle(
                                        color: Colors.white, // Text color
                                        fontWeight: FontWeight.bold, // Optional, for emphasis
                                      ),
                                    ),
                                    backgroundColor: Colors.purple, // Background color
                                    duration: Duration(seconds: 2), // Duration for the SnackBar to show
                                    behavior: SnackBarBehavior.fixed, // Optional: To make the SnackBar floating
                                  ),
                                );

                                Navigator.of(context).pop();
                              }
                              else{
                                callSwitchPage(userData);
                              }

                            },
                            child: Container(
                              padding: const EdgeInsets.all(16.0),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade100, // Background color for the profile section
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                children: [
                                  // Profile picture
                                  CircleAvatar(
                                    radius:40,
                                    backgroundImage:
                                    (finalProfileImage.isNotEmpty &&
                                        Uri.tryParse(finalProfileImage)?.hasAbsolutePath == true)
                                        ? NetworkImage(finalProfileImage)
                                        : AssetImage("assets/profile_images.png") as ImageProvider,
                                  ),
                                  const SizedBox(width: 16),
                                  // User name and email
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        userData['displayName'] ?? "Unknown", // Display name from SharedPreferences
                                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                                      ),
                                      Text(
                                        userData['email'] ?? "No email", // Email from SharedPreferences
                                        style: const TextStyle(color: Colors.white70, fontSize: 14),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // List of pages (existing ListView)
                          Expanded(
                            child: ListView.builder(
                              physics: const BouncingScrollPhysics(),
                              itemCount: pageList.length,
                              itemBuilder: (context, index) {
                                print("pageList[index]: ${pageList[index]}");
                                return ListTile(
                                  leading: CircleAvatar(
                                    radius: 20,
                                    backgroundImage: (pageList[index]["profilePicture"] != null && pageList[index]["profilePicture"].isNotEmpty)
                                        ? CachedNetworkImageProvider(
                                      imagePathSetter(
                                        imageName: pageList[index]["profilePicture"],
                                        imageSize: "FULL",
                                        requestingImageType: "PAGEPROFILE",
                                        setUserId: int.tryParse(pageList[index]["ownerId"].toString())?.toString(),
                                      ),
                                      errorListener: (e) {
                                        print("Error loading image: $e");
                                      },
                                    )
                                        : AssetImage("assets/profile_images.png") as ImageProvider,
                                  ),
                                  title: Text(
                                    pageList[index]["displayName"],
                                    style: const TextStyle(color: Colors.black),
                                  ),
                                  onTap: () {

                                    if(_getUserId == (pageList[index]['id'].toString())){
                                      print("samepage");
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Page already selected!',
                                            style: TextStyle(
                                              color: Colors.white, // Text color
                                              fontWeight: FontWeight.bold, // Optional, for emphasis
                                            ),
                                          ),
                                          backgroundColor: Colors.purple, // Background color
                                          duration: Duration(seconds: 2), // Duration for the SnackBar to show
                                          behavior: SnackBarBehavior.fixed, // Optional: To make the SnackBar floating
                                        ),
                                      );

                                      Navigator.of(context).pop();
                                    }
                                    else{
                                      callSwitchPage(pageList[index]);
                                    }

                                  },
                                );
                              },
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),


              _buildBottomSheetButton(
                context,
                "Create Needle Profile",
                Icons.add_circle,
                    () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => ProfileSelectionPage(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }


  Widget _buildBottomSheetButton(
    BuildContext context,
    String text,
    IconData icon,
    VoidCallback onPressed,
  ) {
    return GestureDetector(
      onTap: onPressed,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: ListTile(
          title: Text(
            text,
            style: const TextStyle(color: Colors.black, fontSize: 16),
          ),
          leading: Icon(icon, color: Colors.grey, size: 30),
        ),
      ),
    );
  }

  Widget _buildShortcutsSection() {
    final shortcuts = [
      {'icon': 'assets/profile_images.png', 'label': 'Prestige Auto Car'},
      {'icon': 'assets/profile_images.png', 'label': 'Pizza italiano'},
      {'icon': 'assets/profile_images.png', 'label': 'Nipuni Nirma'},
      {'icon': 'assets/profile_images.png', 'label': 'Sumal Shasheema'},
      {'icon': 'assets/profile_images.png', 'label': 'SL Developer'},
    ];

    return SizedBox(
      height: 90,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: shortcuts.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final item = shortcuts[index];
          return Column(
            children: [
              CircleAvatar(
                backgroundImage: AssetImage(item['icon']!),
                radius: 28,
              ),
              const SizedBox(height: 4),
              SizedBox(
                width: 70,
                child: Text(
                  item['label']!,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 12, color: Colors.black),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMenuGridSection() {
    final items = [
      {'icon': Icons.people, 'label': 'Friends', 'colors': Colors.purple, "navigateId":2},
      // {'icon': Icons.dashboard, 'label': 'Professional dashboard', 'colors': Colors.blueAccent},
      // {'icon': Icons.feed, 'label': 'Reels', 'colors': Colors.red},
      {
        'icon': Icons.video_collection,
        'label': 'Vivid',
        'colors': Colors.purple,
        "navigateId":1
      },
      {
        'icon': Icons.how_to_vote,
        'label': 'Votes',
        'colors': Colors.deepPurpleAccent,
        "navigateId":3
      },
      // {
      //   'icon': Icons.store,
      //   'label': 'High Street',
      //   'colors': Colors.deepPurple,
      // },
      // {'icon': Icons.history, 'label': 'Memories', 'colors': Colors.orange},
      {'icon': Icons.bookmark, 'label': 'Saved', 'colors': Colors.brown, "navigateId":5},
      {
        'icon': Icons.support_agent,
        'label': 'Support',
        'colors': Colors.cyanAccent,
        "navigateId":6
      },
      // {'icon': Icons.campaign, 'label': 'Ad Centre', 'colors': Colors.green},
      {'icon': Icons.flag, 'label': 'Pages', 'colors': Colors.yellow,"navigateId":7},
      // {'icon': Icons.movie, 'label': 'Reels', 'colors': Colors.blueAccent},
    ];

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: items.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 3.5,
        ),
        itemBuilder: (context, index) {
          final item = items[index];
          return GestureDetector(
            onTap: (){
              if(item['navigateId'] == 6){
                print("ID");
              } else if(item['navigateId'] == 7){
                _existingPageListShowModalBottomSheet();
              } else if(item['navigateId'] == 5){
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => SavePost(),
                  ),
                );
              } else {
                print(item['navigateId']);
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => MainScreen(screenIndex: item['navigateId'] as int? ?? 0),
                  ),
                );
              }
            },
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(item['icon'] as IconData, color: item['colors'] as Color),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      item['label']!.toString(),
                      style: const TextStyle(fontSize: 14, color: Colors.black),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _getMyCreatedPages() {
    final items = [
      {'icon': Icons.people, 'label': 'Friends', 'colors': Colors.purple},
      // {'icon': Icons.dashboard, 'label': 'Professional dashboard', 'colors': Colors.blueAccent},
      {'icon': Icons.feed, 'label': 'Feeds', 'colors': Colors.red},
      {
        'icon': Icons.group,
        'label': 'Groups',
        'colors': Colors.deepPurpleAccent,
      },
      {
        'icon': Icons.store,
        'label': 'Marketplace',
        'colors': Colors.deepPurple,
      },
      {
        'icon': Icons.video_collection,
        'label': 'Video',
        'colors': Colors.purple,
      },
      {'icon': Icons.history, 'label': 'Memories', 'colors': Colors.orange},
      {'icon': Icons.bookmark, 'label': 'Saved', 'colors': Colors.brown},
      {
        'icon': Icons.support_agent,
        'label': 'Support',
        'colors': Colors.cyanAccent,
      },
      {'icon': Icons.campaign, 'label': 'Ad Centre', 'colors': Colors.green},
      {'icon': Icons.flag, 'label': 'Pages', 'colors': Colors.yellow},
      {'icon': Icons.movie, 'label': 'Reels', 'colors': Colors.blueAccent},
    ];

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: items.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 3.5,
        ),
        itemBuilder: (context, index) {
          final item = items[index];
          return Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(item['icon'] as IconData, color: item['colors'] as Color),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    item['label']!.toString(),
                    style: const TextStyle(fontSize: 14, color: Colors.black),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildBottomNavBar() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: 5,
      selectedItemColor: Colors.blue,
      unselectedItemColor: Colors.grey,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Friends'),
        BottomNavigationBarItem(
          icon: Icon(Icons.video_collection),
          label: 'Video',
        ),
        BottomNavigationBarItem(icon: Icon(Icons.store), label: 'Marketplace'),
        BottomNavigationBarItem(
          icon: Icon(Icons.notifications),
          label: 'Notifications',
        ),
        BottomNavigationBarItem(
          icon: CircleAvatar(
            radius: 12,
            backgroundImage: AssetImage('assets/profile.jpg'),
          ),
          label: 'Menu',
        ),
      ],
    );
  }
}
