import 'package:flutter/material.dart';
import 'package:waste_management_app/screens/home/models/carousel_blog_model.dart'; // Import CarouselBlogModel
import 'package:flutter_svg/flutter_svg.dart';

class ViewMoreScreen extends StatelessWidget {
  final CarouselBlogModel blog;

  const ViewMoreScreen({Key? key, required this.blog}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(blog.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                blog.title,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              blog.imagePath.endsWith('.svg')
                  ? SvgPicture.asset(
                      blog.imagePath,
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    )
                  : Image.asset(
                      blog.imagePath,
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
              const SizedBox(height: 20),

              const Text(
                'Detailed Description:',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                blog.description,
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
