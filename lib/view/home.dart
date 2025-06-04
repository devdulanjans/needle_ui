// import 'package:flutter/material.dart';
//
// class HomePage extends StatelessWidget {
//   // List of sample posts (using images)
//   final List<Post> posts = [
//     Post(media: 'assets/image1.jpg', caption: 'Post 1: Beautiful Sunset'),
//     Post(media: 'assets/image2.jpg', caption: 'Post 2: Flutter is awesome!'),
//     Post(media: 'assets/image3.jpg', caption: 'Post 3: Nature at its best'),
//   ];
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: PageView.builder(
//         scrollDirection: Axis.vertical,
//         itemCount: posts.length,
//         itemBuilder: (context, index) {
//           return PostItem(post: posts[index]);
//         },
//       ),
//     );
//   }
// }
//
// class PostItem extends StatelessWidget {
//   final Post post;
//
//   const PostItem({required this.post});
//
//   @override
//   Widget build(BuildContext context) {
//     return Stack(
//       children: [
//         // Full-screen image
//         Container(
//           decoration: BoxDecoration(
//             image: DecorationImage(
//               image: AssetImage(post.media), // Image URL from assets
//               fit: BoxFit.cover, // Ensure the image fills the screen
//             ),
//           ),
//         ),
//         // Post Caption at the bottom
//         Positioned(
//           bottom: 100,
//           left: 20,
//           right: 20,
//           child: Text(
//             post.caption,
//             style: TextStyle(
//               fontSize: 24,
//               fontWeight: FontWeight.bold,
//               color: Colors.white,
//               shadows: [
//                 Shadow(
//                   blurRadius: 10.0,
//                   color: Colors.black,
//                   offset: Offset(0.0, 0.0),
//                 ),
//               ],
//             ),
//             overflow: TextOverflow.ellipsis,
//             maxLines: 2,
//           ),
//         ),
//         // Interaction buttons (Like, Comment, Share)
//         Positioned(
//           bottom: 20,
//           left: 20,
//           child: Row(
//             children: [
//               IconButton(
//                 icon: Icon(Icons.favorite, color: Colors.white),
//                 onPressed: () {},
//               ),
//               IconButton(
//                 icon: Icon(Icons.comment, color: Colors.white),
//                 onPressed: () {},
//               ),
//               IconButton(
//                 icon: Icon(Icons.share, color: Colors.white),
//                 onPressed: () {},
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
// }
//
// class Post {
//   final String media;  // Image URL
//   final String caption;
//
//   Post({required this.media, required this.caption});
// }

import 'package:flutter/material.dart';
import 'post_page.dart'; // Importing PostPage (Home feed)
// import 'profile_page.dart'; // Importing ProfilePage
// import 'notifications_page.dart'; // Importing NotificationsPage

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    PostPage(),
    // ProfilePage(),
    // NotificationsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent, // Transparent AppBar
        elevation: 0, // No shadow
        title: Text('Social Media App', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: Icon(Icons.menu, color: Colors.white), // Left icon (Menu icon)
          onPressed: () {
            // Add your menu functionality here
            print('Menu icon pressed');
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications, color: Colors.white), // Right icon (Notification icon)
            onPressed: () {
              // Add your notification functionality here
              print('Notification icon pressed');
            },
          ),
          IconButton(
            icon: Icon(Icons.chat, color: Colors.white), // Right icon (Chat icon)
            onPressed: () {
              // Add your chat functionality here
              print('Chat icon pressed');
            },
          ),
        ],
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Color(0xFFF7F7F7), // Off-white background
        selectedItemColor: Colors.purple[800], // Dark Purple for active icon
        unselectedItemColor: Colors.purple[200], // Light Purple for inactive icon
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.fixed, // Fixed to avoid animations
        iconSize: 30, // Reduced icon size
        elevation: 10, // Shadow effect for the bottom navigation
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home, size: 30), // Home icon
            label: '', // Empty label
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search, size: 30), // Search icon
            label: '', // Empty label
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_box_outlined, size: 30), // Add icon
            label: '', // Empty label
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_border, size: 30), // Notifications icon
            label: '', // Empty label
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle, size: 30), // Profile icon
            label: '', // Empty label
          ),
        ],
      ),
    );
  }
}
