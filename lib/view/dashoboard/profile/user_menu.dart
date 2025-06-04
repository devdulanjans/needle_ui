import 'package:flutter/material.dart';

import '../../../controller/auth_controller.dart';
import '../../../controller/config/image_path_setter.dart';

class UserMenu extends StatefulWidget {
  const UserMenu({super.key});

  @override
  State<UserMenu> createState() => _UserMenuState();
}

class _UserMenuState extends State<UserMenu> {
  String _profileImage = "";
  String _userName = "";

  Future<void> profileData()async{
    var _userId = await getUserId();
    var _imageUrl = await getUserProfilePicture();

    setState(() {

      if(_imageUrl != null && _imageUrl.isNotEmpty){
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

  setProfileName()async{
    var _getUserName = await getUserName();
    setState(() {
      if(_getUserName != null){
        _userName = _getUserName;
      } else {
        _userName = "";
      }
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    profileData();
    setProfileName();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Menu", style: TextStyle(fontWeight: FontWeight.bold,color: Colors.black)),
        actions: const [
          Icon(Icons.settings,color: Colors.black),
          SizedBox(width: 16),
          Icon(Icons.search,color: Colors.black),
          SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
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
      // bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildProfileSection() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          CircleAvatar(
            backgroundImage: (_profileImage.isNotEmpty && Uri.tryParse(_profileImage)?.hasAbsolutePath == true)
                ? NetworkImage(_profileImage)
                : AssetImage("assets/profile_images.png") as ImageProvider,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: GestureDetector(onTap: (){
            // Navigate to profile page
            Navigator.pushNamed(context, '/profile');
            }, child: Text(_userName, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16,color: Colors.black))),
          ),
          // Stack(
          //   alignment: Alignment.center,
          //   children: [
          //     const Icon(Icons.circle, size: 28, color: Colors.grey),
          //     const Text("9+", style: TextStyle(fontSize: 12, color: Colors.white)),
          //   ],
          // ),
        ],
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
      {'icon': Icons.people, 'label': 'Friends', 'colors': Colors.purple},
      // {'icon': Icons.dashboard, 'label': 'Professional dashboard', 'colors': Colors.blueAccent},
      {'icon': Icons.feed, 'label': 'Feeds', 'colors': Colors.red},
      {'icon': Icons.group, 'label': 'Groups', 'colors': Colors.deepPurpleAccent},
      {'icon': Icons.store, 'label': 'Marketplace', 'colors': Colors.deepPurple},
      {'icon': Icons.video_collection, 'label': 'Video', 'colors': Colors.purple},
      {'icon': Icons.history, 'label': 'Memories', 'colors': Colors.orange},
      {'icon': Icons.bookmark, 'label': 'Saved', 'colors': Colors.brown},
      {'icon': Icons.support_agent, 'label': 'Support', 'colors': Colors.cyanAccent},
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
                  child: Text(item['label']!.toString(), style: const TextStyle(fontSize: 14, color: Colors.black)),
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
        BottomNavigationBarItem(icon: Icon(Icons.video_collection), label: 'Video'),
        BottomNavigationBarItem(icon: Icon(Icons.store), label: 'Marketplace'),
        BottomNavigationBarItem(icon: Icon(Icons.notifications), label: 'Notifications'),
        BottomNavigationBarItem(
          icon: CircleAvatar(radius: 12, backgroundImage: AssetImage('assets/profile.jpg')),
          label: 'Menu',
        ),
      ],
    );
  }
}