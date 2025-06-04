import 'package:flutter/material.dart';

import '../../../model/listItem.dart';

class UserListPage extends StatelessWidget {
  final String userDisplayName;

  UserListPage({required this.userDisplayName});

  @override
  Widget build(BuildContext context) {

    final List<ListItem> items = [
      ListItem(icon: Icon(Icons.report, color: Colors.grey), text: "Report Profile"),
      ListItem(icon: Icon(Icons.heart_broken, color: Colors.grey), text: "Help To ${userDisplayName}"),
      ListItem(icon: Icon(Icons.block, color: Colors.grey), text: "Block"),
      ListItem(icon: Icon(Icons.search, color: Colors.grey), text: "Search"),
      ListItem(icon: Icon(Icons.help, color: Colors.grey), text: "${userDisplayName}'s Profile Link"),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(userDisplayName,style: TextStyle(color: Colors.black),),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back,color:Colors.black),
          onPressed: () {
            Navigator.pop(context); // Navigate back to the previous page
          },
        ),
      ),
      body: ListView.builder(
        itemCount: items.length, // 5 items in the list
        itemBuilder: (context, index) {
          final item = items[index];
          return ListTile(
            leading: item.icon,
            title: Text(item.text, style: TextStyle(color: Colors.black),),
          );
        },
      ),
    );
  }
}