import 'package:flutter/material.dart';
import 'dart:convert';

class DetailsScreen extends StatelessWidget {
  final Map<String, dynamic> item;

  const DetailsScreen({Key? key, required this.item}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final title = item['title'] ?? 'No Titles';
    final price = item['price'] ?? 'No Price';
    final images = item['images'] as List<dynamic>;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Item Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Title: $title',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Price: ₹$price',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 16),
            const Text(
              'Images:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: images.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Image.memory(
                      base64Decode(images[index]),
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
