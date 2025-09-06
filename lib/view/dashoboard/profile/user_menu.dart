import 'dart:convert';

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
    var _userId = await getUserId();
    var _imageUrl = await getUserProfilePicture();

    setState(() {
      if (_imageUrl != null && _imageUrl.isNotEmpty) {
        _profileImage = imagePathSetter(
          imageName: _imageUrl,
          imageSize: "THUMBNAIL",
          requestingImageType: "PROFILE",
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
    var _userId = await getUserId();
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

    await savePageProfile(
      pageId: int.parse(pageDetails["id"].toString()).toString(),
      pageName: pageDetails["displayName"],
      profilePicture: pageDetails["profilePicture"],
      coverImage: pageDetails["coverPicture"]
    );

    print("Logged in as ${profile['name']} - isPage: ${profile['isPage']}");
    // Navigator.of(context).push(
    //   MaterialPageRoute(
    //     builder:
    //         (context) => SwitchPage(
    //       pageName: pageList[index]["displayName"],
    //       profileImage: "",
    //     ),
    //   ),
    // );
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
      isScrollControlled: true,
      context: context,
      builder: (BuildContext context) {
        return SingleChildScrollView(
          child: Container(
            // Adjust height based on content or use constraints
            // height: pageList.isEmpty ? 250.00 : MediaQuery.of(context).size.height * 0.7, // Example height
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
              mainAxisSize: MainAxisSize.min,
              // Important for SingleChildScrollView
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
                  ListView.builder(
                    shrinkWrap: true,
                    // Important for ListView inside SingleChildScrollView
                    physics: const NeverScrollableScrollPhysics(),
                    // To prevent nested scrolling
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
                                    // Handle image loading errors, e.g., show a placeholder
                                    print("Error loading image: $e");
                                    // You can set a flag or update state to show a placeholder
                                    // For simplicity, returning a placeholder directly here might not be ideal
                                    // depending on how CachedNetworkImageProvider handles errors.
                                    // Consider using CachedNetworkImage widget for more control.
                                  },
                                )
                              : AssetImage("assets/profile_images.png") as ImageProvider,
                        ),
                        title: Text(
                          pageList[index]["displayName"],
                          style: const TextStyle(color: Colors.black),
                        ),
                        onTap: () {
                          callSwitchPage(pageList[index]);
                        },
                      );
                    },
                  ),
                _buildBottomSheetButton(
                  context,
                  "Create Needle Profile",
                  Icons.add_circle,
                  () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder:
                            (context) =>
                                ProfileSelectionPage(), // Assuming ProfileSelectionPage is a const constructor
                      ),
                    );
                  },
                ),
                // _buildBottomSheetButton(context, "Another Button", Icons.info_outline, () {
                //   // Handle another button tap
                //   print("Another button tapped");
                // }),
                const SizedBox(height: 20),
              ],
            ),
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
        'label': 'Reels',
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
