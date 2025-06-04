import 'package:flutter/material.dart';

class EmptyStoryWidget extends StatelessWidget {
  const EmptyStoryWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(0.0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black12),
            // Add border color as needed
            borderRadius: BorderRadius.circular(
              12,
            ), // Adjust the radius as needed
          ),
          child: Stack(
            children: [
              Column(
                children: [
                  Container(
                    width: 100,
                    // Square shape
                    height: 200,
                    // Square shape
                    margin: EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      image: DecorationImage(
                        image: AssetImage("assets/logo.png"),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          bottom: 10,
                          left: 10,
                          child: Text(
                            'text',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              backgroundColor: Colors.black54,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Username',
                    style: TextStyle(color: Colors.red),
                  ),
                ],
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                height: 90,
                // Adjust the height as needed
                child: Container(
                  color: Colors.white, // Adjust the opacity as needed
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }
}