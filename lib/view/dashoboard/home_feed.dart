import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import '../../controller/api/api_controller.dart';
import '../../controller/auth_controller.dart';
import '../../controller/config/image_path_setter.dart';
import '../../model/logged_user_profile_model.dart';
import 'post/create_post_2.dart';
import 'post_card.dart';
import 'profile/profile.dart';
import 'profile/user_profile.dart';
import 'story.dart';

class HomeFeed extends StatefulWidget {
  @override
  _HomeFeedState createState() => _HomeFeedState();
}

class _HomeFeedState extends State<HomeFeed> {
  List<Map<String, dynamic>> _searchResults = [];
  bool _isLoading = false;
  String _searchQuery = '';
  List<dynamic> _allPostData = [];
  String _profileImage = "";

  @override
  void initState() {
    super.initState();
    _getAllPost();
    profileData();
  }

  Future<void> _search(String query) async {
    setState(() {
      _isLoading = true;
      _searchQuery = query;
      _searchResults = [];
    });

    try {
      final response = await API_V1_call(
        url: "/api/user/search?searchKeyword=$query",
        method: "GET",
      );

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

  Future<void> _getAllPost() async {
    var responseData = await API_V1_call(
      url: "/api/post/all?page=0&limit=30",
      method: "GET",
    );

    if (responseData.statusCode == 200) {
      final data = (jsonDecode(responseData.body)['data']['posts'] as List).reversed.toList();
      setState(() {
        _allPostData = data;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching posts')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          AppBar(
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Image.asset("assets/logo.png", height: 40),
            ),
            backgroundColor: Colors.white,
            actions: [
              IconButton(
                icon: Icon(Icons.notifications,
                    color: Theme.of(context).colorScheme.primary),
                onPressed: () {},
              ),
              IconButton(
                icon: Icon(Icons.search,
                    color: Theme.of(context).colorScheme.primary),
                onPressed: () async {
                  // Open search and reset after it's popped
                  await showSearch(
                    context: context,
                    delegate: DataSearch(search: _search),
                  );
                  setState(() {
                    _searchResults = [];
                    _searchQuery = '';
                  });
                },
              ),
            ],
          ),
          Divider(height: 1, color: Colors.black12),
          Container(
            height: 50,
            margin: EdgeInsets.symmetric(vertical: 10),
            color: Colors.white,
            child: Center(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundImage: (_profileImage.isNotEmpty && Uri.tryParse(_profileImage)?.hasAbsolutePath == true)
                      ? NetworkImage(_profileImage)
                      : AssetImage("assets/profile_images.png") as ImageProvider,
                ),
                trailing: IconButton(
                  icon: Icon(Icons.image,
                      color: Theme.of(context).colorScheme.primary),
                  onPressed: () async {
                    await showSearch(
                      context: context,
                      delegate: DataSearch(search: _search),
                    );
                    setState(() {
                      _searchResults = [];
                      _searchQuery = '';
                    });
                  },
                ),
                title: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CreatePostPage(),
                      ),
                    );
                  },
                  child: Text(
                    "What's on your mind?",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Divider(height: 3, color: Colors.black12),
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : CustomScrollView(
              slivers: [
                SliverToBoxAdapter(child: StoriesList()),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                        (context, index) =>
                        PostCard(_allPostData[index]),
                    childCount: _allPostData.length,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class DataSearch extends SearchDelegate<String> {
  final Function(String) search;
  Timer? _debounce;
  List<LoggedUserProfile?> _results = [];
  bool _isSearching = false;

  DataSearch({required this.search});

  void _performSearch(String query, BuildContext context) async {
    _results.clear();
    _isSearching = true;
    showSuggestions(context);

    try {
      final response = await API_V1_call(
        url: "/api/user/search?searchKeyword=$query",
        method: "GET",
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body)['data'] as List;
        _results = data.map((item) => LoggedUserProfile.fromJson(item)).toList();
      }
    } catch (e) {
      print("Search error: $e");
    }

    _isSearching = false;
    showResults(context);
  }

  @override
  List<Widget> buildActions(BuildContext context) => [
    IconButton(
      icon: Icon(Icons.clear),
      onPressed: () {
        query = '';
        _results.clear();
        showSuggestions(context);
      },
    ),
  ];

  @override
  Widget buildLeading(BuildContext context) => IconButton(
    icon: AnimatedIcon(
        icon: AnimatedIcons.menu_arrow, progress: transitionAnimation),
    onPressed: () {
      close(context, '');
    },
  );

  @override
  Widget buildResults(BuildContext context) {
    if (query.isEmpty) {
      return Center(child: Text("Type something to search..."));
    }

    if (_results.isEmpty && !_isSearching) {
      return Center(child: Text('No results found for "$query"'));
    }

    return ListView.builder(
      itemCount: _results.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: (){
            // Navigator.of(context).push(
            //   MaterialPageRoute(
            //     builder: (context) => ProfileScreen(
            //         userProfile: _results[index]
            //     ),
            //   ),
            // );
          },
          child: ListTile(
            leading: CircleAvatar(
              radius: 40,
              backgroundImage: (_results[index]?.profilePicture != null && _results[index]!.profilePicture!.isNotEmpty)
                  ? CachedNetworkImageProvider(
                      imagePathSetter(
                        imageName: _results[index]?.profilePicture,
                        imageSize: "THUMBNAIL",
                        requestingImageType: "PROFILE",
                        setUserId: _results[index]?.id.toString(),
                      ),
                    )
                  : AssetImage("assets/profile_images.png") as ImageProvider,
            ),
            title: Text(
              _results[index]?.displayName ?? 'No Name',
              style: TextStyle(color: Colors.black)
            ),
            subtitle: Text(_results[index]?.email ?? 'No Email',
                style: TextStyle(color: Colors.black)),
            trailing: IconButton.outlined(
                onPressed: (){
                  print("_results[index]: ${_results[index]}");
                  // Navigator.of(context).push(
                  //   MaterialPageRoute(
                  //     builder: (context) => ProfileScreen(
                  //       userProfile: _results[index]
                  //     ),
                  //   ),
                  // );
                },
                icon: Icon(Icons.menu, color: Colors.black,)
            ),
          ),
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();

    _debounce = Timer(Duration(milliseconds: 300), () {
      if (query.isNotEmpty) {
        _performSearch(query, context);
      } else {
        _results.clear();
        showSuggestions(context);
      }
    });

    return Center(
      child: _isSearching
          ? CircularProgressIndicator()
          : Text(query.isEmpty
          ? 'Search for something...'
          : 'Searching "$query"...'),
    );
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}
