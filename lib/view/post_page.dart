import 'package:flutter/material.dart';

class PostPage extends StatelessWidget {
  // List of sample posts (using images)
  final List<Post> posts = [
    Post(media: 'assets/image1.jpg', caption: 'Post 1: Beautiful Sunset'),
    Post(media: 'assets/image2.jpg', caption: 'Post 2: Flutter is awesome!'),
    Post(media: 'assets/image3.jpg', caption: 'Post 3: Nature at its best'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView.builder(
        scrollDirection: Axis.vertical,
        itemCount: posts.length,
        itemBuilder: (context, index) {
          return PostItem(post: posts[index]);
        },
      ),
    );
  }
}

class PostItem extends StatelessWidget {
  final Post post;

  const PostItem({required this.post});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Full-screen image
        Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(post.media), // Image URL from assets
              fit: BoxFit.cover, // Ensure the image fills the screen
            ),
          ),
        ),
        // Post Caption at the bottom
        Positioned(
          bottom: 100,
          left: 20,
          right: 20,
          child: Text(
            post.caption,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: [
                Shadow(
                  blurRadius: 10.0,
                  color: Colors.black,
                  offset: Offset(0.0, 0.0),
                ),
              ],
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
        ),
        // Interaction buttons (Like, Comment, Share)
        Positioned(
          bottom: 20,
          left: 20,
          child: Row(
            children: [
              IconButton(
                icon: Icon(Icons.favorite, color: Colors.white),
                onPressed: () {},
              ),
              IconButton(
                icon: Icon(Icons.comment, color: Colors.white),
                onPressed: () {},
              ),
              IconButton(
                icon: Icon(Icons.share, color: Colors.white),
                onPressed: () {},
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class Post {
  final String media;  // Image URL
  final String caption;

  Post({required this.media, required this.caption});
}