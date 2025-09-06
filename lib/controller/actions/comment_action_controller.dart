import 'package:flutter/material.dart';

import '../api/api_controller.dart';

class CommentActionController {
  static void showCommentOptions(
      BuildContext context,
      String commentContent,
      String creatorId,
      String commentId,
      VoidCallback commentCallback
      ) {
    // Implement the logic to show comment options here.
    // This could be a dialog, bottom sheet, or any other UI element.
    bool _isLoading = false; // Moved _isLoading inside the method to manage state per dialog
    // This could be a dialog, bottom sheet, or any other UI element.
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) { // Changed context to dialogContext to avoid conflict
        return StatefulBuilder( // Added StatefulBuilder to manage loading state
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              backgroundColor: Colors.transparent,
              title: Text(
                'Comment Options',
                style: TextStyle(color: Colors.white),
                textAlign: TextAlign.center,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
              ),
              content: _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          ListTile(
                            leading: Icon(Icons.edit, color: Colors.black),
                            title: Text('Edit', style: TextStyle(color: Colors.black)),
                            onTap: () {
                              setState(() {
                                _isLoading = true;
                              });
                              // Handle edit action
                              // Simulate a network request or long-running task
                              Future.delayed(Duration(seconds: 2), () {
                                setState(() {
                                  _isLoading = false;
                                });

                                // Navigator.of(dialogContext).pop(); // Use dialogContext here
                                print(
                                    'Edit comment: $commentId by $creatorId with content: "$commentContent"');
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Comment editing simulated!'),
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                                // You would typically navigate to an edit screen or show an edit dialog
                              });
                            },
                          ),
                          ListTile(
                            leading: Icon(Icons.delete, color: Colors.black),
                            title: Text('Delete', style: TextStyle(color: Colors.black)),
                            onTap: () async { // Made onTap async
                              setState(() {
                                _isLoading = true;
                              });

                              final response = await API_V1_call(
                                url: "/api/post/comment/${commentId}",
                                method: "DELETE",
                              );
                              Navigator.of(dialogContext).pop(); // Use dialogContext to pop the dialog
                              setState(() {
                                  _isLoading = false;
                              });
                              commentCallback();
                              ScaffoldMessenger.of(dialogContext).showSnackBar(
                                SnackBar(
                                  content: Text('Comment Deleted simulated!'),
                                  duration: Duration(seconds: 2),
                                ),
                              );

                              print("COMMENT DELETE RESPONSE: ${response.body}");
                            },
                          ),
                          ListTile(
                            leading: Icon(Icons.report, color: Colors.black),
                            title: Text('Report', style: TextStyle(color: Colors.black)),
                            onTap: () {
                              // Handle report action
                              Navigator.of(dialogContext).pop(); // Use dialogContext here
                              print('Report comment: $commentId');
                            },
                          ),
                        ],
                      ),
                    ),
            );
          },
        );
      },
    ).then((_) => _isLoading = false); // Reset loading state when dialog is dismissed
  }
}