import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class PollsScreen extends StatefulWidget {
  @override
  _PollsScreenState createState() => _PollsScreenState();
}

class _PollsScreenState extends State<PollsScreen> {
  final List<VideoPoll> _polls = [
    VideoPoll(
      id: '1',
      title: 'ඔය ඇස් දෙක ',
      channel: 'Apparel FM',
      youtubeUrl: 'https://www.youtube.com/shorts/PKHSP2H17r8',
      votes: 1245,
      isLeading: true,
    ),
    VideoPoll(
      id: '2',
      title: 'නිල්වන් මුහුදු තිරේ ',
      channel: 'Tech Master',
      youtubeUrl: 'https://www.youtube.com/shorts/a9SrO1WKwdk',
      votes: 845,
      isLeading: false,
    ),
    VideoPoll(
      id: '3',
      title: 'Tamil Song',
      channel: 'Tech Master',
      youtubeUrl: 'https://www.youtube.com/shorts/276ljDcap-w',
      votes: 845,
      isLeading: false,
    ),
    // Add more sample polls
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('Video Polls'),
        backgroundColor: Colors.black,
        actions: [
          IconButton(icon: Icon(Icons.add), onPressed: _createNewPoll),
        ],
      ),
      body: PageView.builder(
        scrollDirection: Axis.vertical,
        itemCount: _polls.length,
        itemBuilder: (context, index) => _buildPollItem(_polls[index]),
      ),
    );
  }

  Widget _buildPollItem(VideoPoll poll) {
    final youtubeId = YoutubePlayer.convertUrlToId(poll.youtubeUrl);
    final controller = YoutubePlayerController(
      initialVideoId: youtubeId!,
      flags: YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
      ),
    );

    return Stack(
      children: [
        Container(
          width: double.infinity,
          height: double.infinity,
          child: YoutubePlayer(
            controller: controller,
            showVideoProgressIndicator: true,
            progressIndicatorColor: Colors.purpleAccent,
            progressColors: ProgressBarColors(
              playedColor: Colors.purpleAccent,
              handleColor: Colors.purpleAccent,
            ),
          ),
        ),
        Positioned(
          bottom: 50,
          left: 20,
          right: 20,
          child: Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  poll.title,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  poll.channel,
                  style: TextStyle(color: Colors.grey[300]),
                ),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${poll.votes} votes',
                      style: TextStyle(
                        color: Colors.purpleAccent,
                        fontSize: 18,
                      ),
                    ),
                    ElevatedButton.icon(
                      icon: Icon(Icons.how_to_vote, size: 18),
                      label: Text('Vote Now'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      onPressed: () => _handleVote(poll.id),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        if (poll.isLeading)
          Positioned(
            top: 40,
            left: 20,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.purple,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Icon(Icons.star, color: Colors.amber, size: 16),
                  SizedBox(width: 6),
                  Text('Leading', style: TextStyle(color: Colors.white)),
                ],
              ),
            ),
          ),
      ],
    );
  }

  void _handleVote(String pollId) {
    setState(() {
      final poll = _polls.firstWhere((p) => p.id == pollId);
      poll.votes++;

      // Update leading status
      final maxVotes = _polls.map((p) => p.votes).reduce((a, b) => a > b ? a : b);
      _polls.forEach((p) => p.isLeading = p.votes == maxVotes);
    });
  }

  void _createNewPoll() {
    // Implement poll creation logic
  }
}

class VideoPoll {
  final String id;
  final String title;
  final String channel;
  final String youtubeUrl;
  int votes;
  bool isLeading;

  VideoPoll({
    required this.id,
    required this.title,
    required this.channel,
    required this.youtubeUrl,
    required this.votes,
    required this.isLeading,
  });
}
