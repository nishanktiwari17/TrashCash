import 'package:flutter/material.dart';
import 'package:waste_management_app/screens/home/data/carousel_blog_list.dart';  // Import the blogList
import 'package:waste_management_app/screens/home/models/carousel_blog_model.dart';  // Import CarouselBlogModel
import 'package:flutter_svg/flutter_svg.dart';

class ViewMoreScreen extends StatelessWidget {
  final List<CarouselBlogModel> blogs;

  // Ensure blogs are passed correctly and have a default value if null
  ViewMoreScreen({Key? key, required this.blogs}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Check if blogs is null and return an error message if true
    if (blogs == null) {
      return Scaffold(
        appBar: AppBar(title: Text('View More')),
        body: Center(child: Text('No blog data available.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('More Information'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: blogs.map((blog) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 10),
                  Text(
                    blog.title,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  SvgPicture.asset(blog.imagePath),  // Display the image
                  SizedBox(height: 10),
                  Text(
                    'Detailed Description:',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Text(blog.description, style: TextStyle(fontSize: 16)),  // Display the description
                  SizedBox(height: 20),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
