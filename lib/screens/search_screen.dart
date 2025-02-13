import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html_parser;

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  List<dynamic> searchResults = [];

  @override
  Widget build(BuildContext context) {
    //Get the search query passed from the HomeScreen
    final searchTerm = ModalRoute.of(context)?.settings.arguments as String;
    fetchSearchResults(searchTerm);

    return Scaffold(
      appBar: AppBar(
        title: Text('Search Results for "$searchTerm"'),
      ),
      body: searchResults.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: searchResults.length,
              itemBuilder: (context, index) {
                final movie = searchResults[index]['show'];
                final name = movie['name'] ?? 'No Title';
                final imageUrl = movie['image']?['medium'] ?? 'No Image';
                final summaryHtml = movie['summary'] ?? 'No summary available';
                final summary = stripHtmlTags(summaryHtml);

                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                      vertical: 8.0, horizontal: 16.0),
                  leading: Container(
                    width: 60.0,
                    height: 90.0,
                    decoration: BoxDecoration(
                      image: imageUrl != null
                          ? DecorationImage(
                              image: NetworkImage(imageUrl),
                              fit: BoxFit.cover,
                            )
                          : null,
                      color: Colors.grey[300],
                    ),
                    child: imageUrl == null
                        ? const Icon(Icons.movie, color: Colors.white)
                        : null,
                  ),
                  title: GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, '/details',
                          arguments: movie);
                    },
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(name,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4.0),
                              Text(
                                summary,
                                style: TextStyle(
                                    color: Colors.grey[600], fontSize: 12.0),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  void fetchSearchResults(String searchTerm) async {
    final url =
        'https://api.tvmaze.com/search/shows?q=${Uri.encodeComponent(searchTerm)}';
    final uri = Uri.parse(url);
    final response = await http.get(uri);
    final body = response.body;
    final json = jsonDecode(body);

    setState(() {
      searchResults = json;
    });
  }
}

String stripHtmlTags(String htmlString) {
  final document = html_parser.parse(htmlString);
  return document.body?.text ?? '';
}
