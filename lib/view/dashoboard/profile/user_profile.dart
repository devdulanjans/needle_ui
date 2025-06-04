import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class UserProfile extends StatefulWidget {
  const UserProfile({super.key});

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          // backgroundColor: Colors.transparent, // Transparent AppBar
          // elevation: 0, // No shadow
          // title: Text('Social Media App', style: TextStyle(color: Colors.black)),
          // leading: IconButton(
          //   icon: Icon(Icons.arrow_back_ios, color: Colors.black), // Left icon (Menu icon)
          //   onPressed: () {
          //     // Add your menu functionality here
          //     print('Menu icon pressed');
          //   },
          // ),
          // actions: [
          //   IconButton(
          //     icon: Icon(Icons.notifications, color: Colors.black), // Right icon (Notification icon)
          //     onPressed: () {
          //       // Add your notification functionality here
          //       print('Notification icon pressed');
          //     },
          //   ),
          //   IconButton(
          //     icon: Icon(Icons.chat, color: Colors.black), // Right icon (Chat icon)
          //     onPressed: () {
          //       // Add your chat functionality here
          //       print('Chat icon pressed');
          //     },
          //   ),
          // ],
        ),
      body:  CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            flexibleSpace: FlexibleSpaceBar(
              background: CachedNetworkImage(
                imageUrl: 'https://picsum.photos/800/600',
                fit: BoxFit.cover,
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
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundImage: CachedNetworkImageProvider(
                              'https://randomuser.me/api/portraits/men/75.jpg'),
                        ),
                        Spacer(),
                        Column(
                          children: [
                            Text('1,234', style: TextStyle(fontWeight: FontWeight.bold)),
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
                            Text('456', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
                            Text('Following',style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
                          ],
                        ),
                        Spacer(),
                      ],
                    ),
                    SizedBox(height: 16),
                    Text('John Doe', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 25)),
                    Text('Bio description goes here...', style: TextStyle(color: Colors.black),),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {},
                            child: Text('Edit Profile'),
                          ),
                        ),
                        SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () {},
                          child: Icon(Icons.add),
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
      )
    );
  }
}
