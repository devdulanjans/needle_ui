import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoItem extends StatefulWidget {
  @override
  _VideoItemState createState() => _VideoItemState();
}

class _VideoItemState extends State<VideoItem> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(
        'https://www.youtube.com/watch?v=e1buqfwcYos')
      ..initialize().then((_) => setState(() {}))
      ..play();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        _controller.value.isInitialized
            ? AspectRatio(
          aspectRatio: _controller.value.aspectRatio,
          child: VideoPlayer(_controller),
        )
            : Center(child: CircularProgressIndicator()),
        Positioned(
          bottom: 40,
          left: 16,
          right: 16,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('@username', style: TextStyle(color: Colors.white)),
              Text('Video description...', style: TextStyle(color: Colors.white)),
            ],
          ),
        ),
        Positioned(
          right: 16,
          bottom: 40,
          child: Column(
            children: [
              IconButton(icon: Icon(Icons.favorite, color: Colors.white), onPressed: () {}),
              Text('12.3K', style: TextStyle(color: Colors.white)),
              IconButton(icon: Icon(Icons.comment, color: Colors.white), onPressed: () {}),
              Text('1.2K', style: TextStyle(color: Colors.white)),
              IconButton(icon: Icon(Icons.share, color: Colors.white), onPressed: () {}),
            ],
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }
}