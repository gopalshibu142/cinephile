import 'dart:ui';
import 'package:cinephile/Data/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class WatchedScreen extends StatelessWidget {
  const WatchedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: const Color(0xFF121212),
      body: Consumer<UserProvider>(
        builder: (context, userProvider, child) {
          final movies = userProvider.watchedMovies;

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                pinned: true,
                floating: false,
                backgroundColor: Colors.transparent,
                elevation: 0,
                toolbarHeight: 80,
                automaticallyImplyLeading: false,
                flexibleSpace: ClipRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      color: const Color(0xFF121212).withOpacity(0.8),
                    ),
                  ),
                ),
                title: const Text(
                  "Watched",
                  style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                centerTitle: false,
                actions: [
                  IconButton(
                    icon: const Icon(Icons.sort, color: Colors.white),
                    onPressed: () {},
                  ),
                  const SizedBox(width: 10),
                ],
              ),
              if (movies.isEmpty)
                const SliverFillRemaining(
                  child: Center(
                    child: Text("No watched movies yet",
                        style: TextStyle(color: Colors.white)),
                  ),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final movie = movies[index];
                      return Container(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                        height: 120,
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E1E1E),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(20),
                                bottomLeft: Radius.circular(20),
                              ),
                              child: Image.network(
                                'https://image.tmdb.org/t/p/w200${movie.posterPath}',
                                width: 80,
                                height: 120,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Container(
                                        width: 80, color: Colors.grey[800]),
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      movie.title,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      "${movie.releaseDate.split('-').first} • Action", // Placeholder genre
                                      style: TextStyle(
                                          color: Colors.grey[400],
                                          fontSize: 12),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        const Icon(Icons.check_circle_rounded,
                                            color: Colors.greenAccent,
                                            size: 16),
                                        const SizedBox(width: 4),
                                        const Text(
                                          "Watched",
                                          style: TextStyle(
                                              color: Colors.greenAccent,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline_rounded,
                                  color: Colors.grey),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      backgroundColor: const Color(0xFF1E1E1E),
                                      title: const Text("Remove from Watched?",
                                          style:
                                              TextStyle(color: Colors.white)),
                                      content: const Text(
                                          "Are you sure you want to remove this movie from your watched list?",
                                          style:
                                              TextStyle(color: Colors.white70)),
                                      actions: [
                                        TextButton(
                                          child: const Text("Cancel",
                                              style: TextStyle(
                                                  color: Colors.white54)),
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                        TextButton(
                                          child: const Text("Remove",
                                              style: TextStyle(
                                                  color: Colors.redAccent)),
                                          onPressed: () {
                                            userProvider.unmarkAsWatched(movie);
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                            ),
                          ],
                        ),
                      );
                    },
                    childCount: movies.length,
                  ),
                ),
              const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
            ],
          );
        },
      ),
    );
  }
}
