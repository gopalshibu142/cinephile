//movie_search_delegate.dart
import 'package:cinephile/screens/movie_screen.dart';
import 'package:flutter/material.dart';
import 'package:cinephile/Data/movie_provider.dart';

class MovieSearchDelegate extends SearchDelegate {
  final MovieProvider movieProvider;

  MovieSearchDelegate(this.movieProvider);

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return FutureBuilder<List<Movie>>(
      future: movieProvider.searchMovies(query),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          print(snapshot.error);
          print(snapshot.data);
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No results found.'));
        } else {
          final results = snapshot.data!;
          return GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, // Number of columns
              crossAxisSpacing: 8.0, // Spacing between columns
              mainAxisSpacing: 8.0, // Spacing between rows
              childAspectRatio: 0.7, // Aspect ratio of each grid item
            ),
            itemCount: results.length,
            itemBuilder: (context, index) {
              final movie = results[index];
              return GestureDetector(
                onTap: () {
                  // Navigate to movie details page
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MovieScreen(movie: movie),
                    ),
                  );
                },
                child: Card(
                  elevation: 4.0,
                  child: Column(
                    children: [
                      Expanded(
                        child: Image.network(
                          movie.posterPath.isNotEmpty
                              ? 'https://image.tmdb.org/t/p/w500${movie.posterPath}'
                              : 'https://n-lightenment.com/love-movies/wp-content/uploads/2022/02/poster-placeholder.png',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Center(child: Icon(Icons.movie));
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          movie.title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(movie.voteAverage == 0.0
                          ? 'Rating: N/A'
                          : 'Rating: ${movie.voteAverage.toStringAsFixed(1)}'),
                    ],
                  ),
                ),
              );
            },
          );
        }
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.0),
      child: Text('Type to search for movies...'),
    );
  }
}
