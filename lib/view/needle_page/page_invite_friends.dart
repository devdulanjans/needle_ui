import 'package:flutter/material.dart';

class PageInviteFriends extends StatefulWidget {
  const PageInviteFriends({super.key});

  @override
  State<PageInviteFriends> createState() => _PageInviteFriendsState();
}

class _PageInviteFriendsState extends State<PageInviteFriends> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: Icon(Icons.arrow_back_ios, color: Colors.black),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Customise your page",
              style: TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              "Grow your presence by inviting friends to like your page.",
              style: TextStyle(color: Colors.black54, fontSize: 16),
            ),
            SizedBox(height: 20),
            SizedBox(
              height: 40,
              child: TextField(
                style: TextStyle(
                  color: Colors.black, // Set the text color to black

                ),
                onChanged: (value) {
                  // setState(() { _pageName = value; });
                },
                decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey), // Border color when enabled
                      borderRadius: BorderRadius.circular(20), // Curved corners
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.purple), // Border color when focused
                      borderRadius: BorderRadius.circular(10), // Curved corners
                    ),
                    hintText: 'Search Friend', // Optional hint text
                    hintStyle: TextStyle(color: Colors.purple,)
                ),
              ),
            ),

            Container(
              height: 250,
            ),

            Stack(
              children: [
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    height: 120,
                    width: MediaQuery.of(context).size.width - 30,
                    color: Colors.white,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 15, right: 15.0),
                          child: Text(
                            "By Creating a page, you agree to our Terms, Data Policy and Cookies Policy. You may receive SMS notifications from us and can opt out at any time.",
                            style: TextStyle(color: Colors.black54, fontSize: 12),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 20.0),
                          // Add some padding at the bottom
                          child: Center(
                            child: SizedBox(
                              width: MediaQuery.of(context).size.width, // Make the button full width
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.purple, // Button background color
                                ),
                                onPressed: _isLoading
                                    ? null // Disable button when loading
                                    : () async {
                                        setState(() {
                                          _isLoading = true;
                                        });
                                        // Simulate a network request or some async operation
                                        await Future.delayed(Duration(seconds: 2));
                                        setState(() {
                                          _isLoading = false;
                                        });
                                        // Navigator.of(context).push(
                                        //   MaterialPageRoute(
                                        //     builder: (context) => PageInviteFriends(),
                                        //   ),
                                        // );
                                      },
                                child: _isLoading
                                    ? SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                        ),
                                      )
                                    : Text(
                                  'Next',
                                  style: TextStyle(color: Colors.white, fontSize: 16),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
