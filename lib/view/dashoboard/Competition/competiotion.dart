import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../../../controller/api/api_controller.dart';

class CompetitionOption extends StatefulWidget {
  final Map<String, dynamic> data;

  const CompetitionOption({super.key, required this.data});

  @override
  State<CompetitionOption> createState() => _CompetitionOptionState();
}

class _CompetitionOptionState extends State<CompetitionOption> {
  late YoutubePlayerController _controller;
  bool _isLoading = false;
  String _searchQuery = '';
  List<Map<String, dynamic>> _searchResults = [];

  Future<void> _callOption() async {
    print("CALL DATA ${ widget.data['id']}");
    setState(() {
      _isLoading = true;
      _searchResults = [];
    });

    try {
      final response = await API_V1_call(
          // url: "/api/competition/${widget.data['id']}",
          url: "/api/competition/option/${widget.data['id']}",
          method: "GET",
      );

      print("OPTIONS RESPONSE: ${jsonDecode(response.body)['data']}");

      if (response.statusCode == 200) {
        final data = (jsonDecode(response.body)['data'] as List<dynamic>)
            .cast<Map<String, dynamic>>();
        setState(() {
          _searchResults = data;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching search results')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Network error')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();

    _callOption();

    // // Default YouTube video ID
    // const defaultVideoId = 'dQw4w9WgXcQ';
    //
    // _controller = YoutubePlayerController(
    //   initialVideoId: defaultVideoId,
    //   flags: const YoutubePlayerFlags(
    //     autoPlay: false,
    //     mute: false,
    //   ),
    // );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildPollItem(dataSet) {

    print("dataSet: $dataSet");

    final controller = YoutubePlayerController(
      initialVideoId: dataSet['youTubeLink'],
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
              color: Colors.white.withAlpha(50),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dataSet['title'],
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                // SizedBox(height: 8),
                // Text(
                //   widget.data['name'],
                //   style: TextStyle(color: Colors.grey[300]),
                // ),
                // SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Text(
                    //   '${widget.data['name']} votes',
                    //   style: TextStyle(
                    //     color: Colors.purpleAccent,
                    //     fontSize: 18,
                    //   ),
                    // ),
                    ElevatedButton.icon(
                      icon: Icon(Icons.how_to_vote, size: 18),
                      label: Text('Vote Now'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      onPressed: (){},
                      // onPressed: () => _handleVote(poll.id),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        // if (poll.isLeading)
        //   Positioned(
        //     top: 40,
        //     left: 20,
        //     child: Container(
        //       padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        //       decoration: BoxDecoration(
        //         color: Colors.purple,
        //         borderRadius: BorderRadius.circular(20),
        //       ),
        //       child: Row(
        //         children: [
        //           Icon(Icons.star, color: Colors.amber, size: 16),
        //           SizedBox(width: 6),
        //           Text('Leading', style: TextStyle(color: Colors.white)),
        //         ],
        //       ),
        //     ),
        //   ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.data;

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Expanded(child:
              PageView.builder(
                  scrollDirection: Axis.vertical,
                  itemCount: _searchResults.length,
                  itemBuilder: (context, index) => _buildPollItem(_searchResults[index]),
                ),
            )
          ],
        ),
      ),
    );
  }
}