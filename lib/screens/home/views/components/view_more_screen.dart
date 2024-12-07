import 'package:flutter/material.dart';

class ViewMoreScreen extends StatelessWidget {
  final String description;

  ViewMoreScreen({required this.description});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('View More'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Detailed Description:',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(description, style: TextStyle(fontSize: 16)),
            ],
          ),
        ),
      ),
    );
  }
}
