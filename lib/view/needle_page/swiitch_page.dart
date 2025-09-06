import 'package:flutter/material.dart';

class SwitchPage extends StatefulWidget {
  final String pageName;
  final String profileImage;

  const SwitchPage({
    super.key,
    required this.pageName,
    required this.profileImage,
  });

  @override
  State<SwitchPage> createState() => _SwitchPageState();
}

class _SwitchPageState extends State<SwitchPage> {
  bool isLoading = false;

  initState() {
    super.initState();
    switchPage();
  }

  Future<void> switchPage() async {
    setState(() {
      isLoading = true;
    });

    // Simulate a network call or some processing
    await Future.delayed(Duration(seconds: 5 ));

    // After processing, you can navigate to the next page or perform any action
    setState(() {
      isLoading = false;
    });

    // Example: Navigate to the next page (replace with your actual navigation logic)
    // Navigator.pushReplacementNamed(context, '/nextPage');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading == true ? Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    height: 100,
                    width: 100,
                    child: CircularProgressIndicator(
                      strokeWidth: 10.0
                    ),
                  ),
                  CircleAvatar(
                    backgroundImage: AssetImage("assets/profile_images.png"),
                    radius: 50, // Adjust the radius as needed
                  ),
                ],
              ),
              SizedBox(height: 20),
              Text(
                "Switching to ${widget.pageName}",
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.purple.shade800,
                ),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ):SizedBox(),
    );
  }
}
