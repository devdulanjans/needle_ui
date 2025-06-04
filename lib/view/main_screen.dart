import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../controller/auth_controller.dart';
import '../controller/config/image_path_setter.dart';
import 'dashoboard/friends/friends.dart';
import 'dashoboard/home_feed.dart';
import 'dashoboard/pooling.dart';
import 'dashoboard/post/create_post.dart';
import 'dashoboard/profile/profile.dart';
import 'dashoboard/profile/user_menu.dart';
import 'dashoboard/video/video_feed.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}


class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  String _profileImage = "";
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    profileData();
  }

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

  final List<Widget> _screens = [
    HomeFeed(),
    VideoFeed(),
    FriendsPage(),
    PollsScreen(),
    // ProfileScreen(),
    UserMenu()
  ];

  Future<bool> _onWillPop() async {
    return await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm Exit'),
        content: Text('Are you sure you want to go back?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false), // Stay on the page
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true), // Exit the page
            child: Text('Yes'),
          ),
        ],
      ),
    ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool, result) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Confirm Exit',style: TextStyle(color: Colors.black),),
            content: Text('Are you sure you want to go back?',style: TextStyle(color: Colors.black)),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false), // Stay on the page
                child: Text('Cancel',style: TextStyle(color: Colors.black)),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true), // Exit the page
                child: Text('Yes',style: TextStyle(color: Colors.black)),
              ),
            ],
          ),
        ).then((value) {
          if (value == true) {
            SystemNavigator.pop();
          }
        });
        // return false; // Prevent immediate pop
      },
      child: Scaffold(
        body: _screens[_currentIndex],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          fixedColor: Colors.black,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          selectedFontSize: 12,
          selectedLabelStyle: TextStyle(color: Colors.black),
          unselectedItemColor: Theme.of(context).colorScheme.primary,
          items: [
            BottomNavigationBarItem(icon: Icon(Icons.home,color: Theme.of(context).colorScheme.primary), label: 'Home',),
            BottomNavigationBarItem(icon: Icon(Icons.video_library,color: Theme.of(context).colorScheme.primary), label: 'Reels'),
            BottomNavigationBarItem(icon: Icon(Icons.people,color: Theme.of(context).colorScheme.primary), label: 'Friends'),
            BottomNavigationBarItem(icon: Icon(Icons.poll,color: Theme.of(context).colorScheme.primary), label: 'Polls'),
            BottomNavigationBarItem(
              icon: CircleAvatar(
                radius: 13,
                backgroundImage: (_profileImage.isNotEmpty && Uri.tryParse(_profileImage)?.hasAbsolutePath == true)
                    ? NetworkImage(_profileImage)
                    : AssetImage("assets/profile_images.png") as ImageProvider,
              ),
              label: 'Menu',
            ),
            // BottomNavigationBarItem(icon: Icon(Icons.add_circle,color: Theme.of(context).colorScheme.primary), label: 'Profile'),
          ],
        ),
      ),
    );
  }
}

