import 'package:flutter/material.dart';

import '../../../controller/auth_controller.dart';
import '../../../controller/friend_api.dart';
import '../../../model/listItem.dart';

class UserListPage extends StatelessWidget {
  final String userDisplayName;
  final String userId;

  UserListPage({required this.userDisplayName, required this.userId});

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
            onTap: () async{
              var _userId = await getUserId();
              if(item.text == "Block"){
                bool result = await blockUser(userId ?? "",_userId.toString());
                if(result){
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('User blocked successfully.',style: TextStyle(color: Colors.black),),backgroundColor: Colors.purple.shade100,),);
                }else{
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('User blocked failed.',style: TextStyle(color: Colors.black),),backgroundColor: Colors.red.shade100,),);
                }
              }
            },
            leading: item.icon,
            title: Text(item.text, style: TextStyle(color: Colors.black),),
          );
        },
      ),
    );
  }
}