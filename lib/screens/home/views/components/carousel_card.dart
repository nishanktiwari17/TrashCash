import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'view_more_screen.dart'; // Import the ViewMoreScreen

class CarouselCard extends StatelessWidget {
  final String title;
  final String description;
  final String imagePath;

  CarouselCard({required this.title, required this.description, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          Image.asset(imagePath), // For local images, or Image.network() for online images
          Text(title),
          Text(description),
          ElevatedButton(
            onPressed: () {
              // Navigate to ViewMoreScreen when clicked
              Get.to(ViewMoreScreen(description: description));
            },
            child: Text('View More'),
          ),
        ],
      ),
    );
  }
}
