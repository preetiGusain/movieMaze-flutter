import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:moviemaze_flutter/movie_search_delegate.dart';
import 'package:html/parser.dart' as html_parser;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<dynamic> movies = [];
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchMovies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MovieMaze'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () async {
              final query = await showSearch<String>(
                context: context,
                delegate: MovieSearchDelegate(),
              );
              if (query != null && query.isNotEmpty) {
                //Navigate to searchScreen
                Navigator.pushNamed(context, '/search', arguments: query);
              }
            },
          ),
        ],
      ),
      body: movies.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: movies.length,
              itemBuilder: (context, index) {
                final movie = movies[index]['show'];
                final name = movie != null && movie['name'] != null
                    ? movie['name']
                    : 'No Title';
                final imageUrl = movie != null && movie['image'] != null
                    ? movie['image']['medium']
                    : 'No Image';
                final summaryHtml = movie != null && movie['summary'] != null
                    ? movie['summary']
                    : 'No summary available';
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
                      // Passing the entire movie object to DetailsScreen
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
                              Text(
                                name,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
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

  void fetchMovies() async {
    const url = 'https://api.tvmaze.com/search/shows?q=all';
    final uri = Uri.parse(url);
    final response = await http.get(uri);
    final body = response.body;
    final json = jsonDecode(body);

    setState(() {
      movies = json;
    });
  }

   String stripHtmlTags(String htmlString) {
    final document = html_parser.parse(htmlString);
    return document.body?.text ?? '';
  }
}
