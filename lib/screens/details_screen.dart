import 'package:flutter/material.dart';
import 'package:html/parser.dart' as html_parser;

class DetailsScreen extends StatefulWidget {
  const DetailsScreen({super.key});

  @override
  State<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  @override
  Widget build(BuildContext context) {
    final movie =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;

    //Extracting details from movie object
    final name = movie?['name'] ?? 'No Title';
    final summaryHtml = movie?['summary'] ?? 'No summary available';
    final imageUrl =
        movie?['image']?['original'] ?? 'https://via.placeholder.com/150';
    final summary = stripHtmlTags(summaryHtml);

    return Scaffold(
      appBar: AppBar(
        title: Text(name),
      ),
      body: movie == null
          ? const Center(child: Text('Movie details not found'))
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Image.network(imageUrl),
                    const SizedBox(height: 16.0),
                    Text(
                      name,
                      style: const TextStyle(
                          fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8.0),
                    Text(
                      summary,
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

String stripHtmlTags(String htmlString) {
  final document = html_parser.parse(htmlString);
  return document.body?.text ?? '';
}
