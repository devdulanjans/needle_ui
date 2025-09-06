import 'dart:async';
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../controller/api/api_controller.dart';
import '../controller/config/image_path_setter.dart';
import '../model/logged_user_profile_model.dart';
import 'dashoboard/profile/profile.dart';

class DataSearch extends SearchDelegate<String> {
  final Function(String) search;
  Timer? _debounce;
  List<LoggedUserProfile?> _results = [];
  List<dynamic> tem_data = [];
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
        for(var dataS in data){
          tem_data.add(dataS);
        }
        _results = data.map((item) => LoggedUserProfile.fromJson(item)).toList();
      }
    } catch (e) {
      print("Search error: $e");
    }

    _isSearching = false;
    showResults(context);
  }

  // ========== 🔹 STYLING OVERRIDES 🔹 ==========
  @override
  ThemeData appBarTheme(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return theme.copyWith(
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        iconTheme: IconThemeData(color: Colors.black),
        toolbarTextStyle: TextStyle(color: Colors.black),
      ),
      inputDecorationTheme: InputDecorationTheme(
        hintStyle: TextStyle(color: Colors.grey.shade600),
        border: InputBorder.none,
      ),
      textTheme: TextTheme(
        titleLarge: TextStyle(color: Colors.black, fontSize: 18),
      ),
    );
  }

  @override
  TextStyle get searchFieldStyle => TextStyle(
    color: Colors.black,
    fontSize: 16,
  );

  @override
  String? get searchFieldLabel => "Search users...";

  // ========== 🔹 ACTION BUTTONS 🔹 ==========
  @override
  List<Widget> buildActions(BuildContext context) => [
    IconButton(
      icon: Icon(Icons.clear, color: Colors.black),
      onPressed: () {
        query = '';
        _results.clear();
        showSuggestions(context);
      },
    ),
  ];

  // ========== 🔹 LEADING ICON 🔹 ==========
  @override
  Widget buildLeading(BuildContext context) => IconButton(
    icon: AnimatedIcon(
        icon: AnimatedIcons.menu_arrow, progress: transitionAnimation),
    color: Colors.black,
    onPressed: () {
      close(context, '');
    },
  );

  // ========== 🔹 RESULTS LIST 🔹 ==========
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
          onTap: () {
            print("Tapped on user: ${_results[index]}");
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => ProfileScreen(
                  userId: _results[index]?.id.toString(),
                  profileType: _results[index]?.type,
                ),
              ),
            );
            // Handle profile tap
          },
          child: ListTile(
            leading: CircleAvatar(
              radius: 20,
              backgroundImage: (_results[index]?.profilePicture != null &&
                  _results[index]!.profilePicture!.isNotEmpty)
                  ? CachedNetworkImageProvider(
                imagePathSetter(
                  imageName: _results[index]?.profilePicture,
                  imageSize: "THUMBNAIL",
                  requestingImageType: "PROFILE",
                  setUserId: _results[index]?.id.toString(),
                ),
              )
                  : AssetImage("assets/profile_images.png")
              as ImageProvider,
            ),
            title: Text(
              _results[index]?.displayName ?? 'No Name',
              style: TextStyle(
                  fontWeight: FontWeight.w600, color: Colors.black),
            ),
            subtitle: Text(
              // I want place this in middle
              _results[index]?.email ?? 'No Email',
              style: TextStyle(color: Colors.grey[700]),
            ),
            trailing: IconButton(
              onPressed: () {
                print("_results[index]: ${_results[index]}");
                // Handle action
              },
              icon: Icon(Icons.menu, color: Colors.black),
            ),
          ),
        );
      },
    );
  }

  // ========== 🔹 SUGGESTIONS AREA 🔹 ==========
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
          : Text(
        query.isEmpty
            ? 'Search for something...'
            : 'Searching "$query"...',
        style: TextStyle(fontSize: 16, color: Colors.grey[700]),
      ),
    );
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}
