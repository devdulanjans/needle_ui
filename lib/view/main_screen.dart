import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../controller/auth_controller.dart';
import '../controller/config/image_path_setter.dart';
import 'dashoboard/friends/friends.dart';
import 'dashoboard/home_feed.dart';
import 'dashoboard/Competition/pooling.dart';
import 'dashoboard/profile/profile.dart';
import 'dashoboard/profile/user_menu.dart';
import 'dashoboard/video/video_feed.dart';

class MainScreen extends StatefulWidget {
  final int screenIndex;
  const MainScreen({super.key,this.screenIndex = 0});

  @override
  _MainScreenState createState() => _MainScreenState();
}


class _MainScreenState extends State<MainScreen> with WidgetsBindingObserver {
  int _currentIndex = 0;
  String _profileImage = "";
  var _finalGetUserId = "";
  late List<Widget> _screens;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    mapToScreen();
    _screens = [
      HomeFeed(),
      Container(child:Text("No Vivid available right now")),
      // VideoFeed(),
      FriendsPage(),
      PollsScreen(),
      // ProfileScreen(userId: _finalGetUserId)
      // ProfileScreen(),
      UserMenu()
    ];
    profileData();
  }

  mapToScreen(){
    setState(() {
      _currentIndex = widget.screenIndex;
    });
  }

 @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // App is returning to the foreground, call initial APIs
      profileData();
    }
  }

  Future<void> profileData()async{
    var _userId = await getUserId();
    _finalGetUserId = _userId!;
    var _imageUrl = await getUserProfilePicture();

    setState(() {
      _finalGetUserId = _userId!;
      _screens = [
        HomeFeed(),
        Container(child:Center(child: Text("No Vivid available right now",style: TextStyle(color: Colors.black),))),
        // VideoFeed(),
        FriendsPage(),
        PollsScreen(),
        // ProfileScreen(userId: _finalGetUserId)
        // ProfileScreen(),
        UserMenu()
      ];

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
      canPop: _currentIndex == 0, // Allow pop only if on the first tab (Home)
      onPopInvoked: (bool didPop) {
        if (didPop) {
          return;
        }
        if (_currentIndex != 0) {
          setState(() {
            _currentIndex = 0; // Navigate to Home tab
          });
        } else {
          // If already on Home tab, show exit confirmation
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('Confirm Exit', style: TextStyle(color: Colors.black)),
              content: Text('Are you sure you want to exit the app?', style: TextStyle(color: Colors.black)),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text('Cancel', style: TextStyle(color: Colors.black)),
                ),
                TextButton(
                  onPressed: () => SystemNavigator.pop(), // Exit the app
                  child: Text('Yes', style: TextStyle(color: Colors.black)),
                ),
              ],
            ),
          );
        }
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
            BottomNavigationBarItem(icon: Icon(Icons.video_library,color: Theme.of(context).colorScheme.primary), label: 'Vivid'),
            BottomNavigationBarItem(icon: Icon(Icons.people,color: Theme.of(context).colorScheme.primary), label: 'Friends'),
            BottomNavigationBarItem(icon: Icon(Icons.poll,color: Theme.of(context).colorScheme.primary), label: 'Votes'),
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

