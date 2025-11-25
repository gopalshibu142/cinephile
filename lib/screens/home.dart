import 'dart:ui';
import 'package:cinephile/Data/movie_provider.dart';
import 'package:cinephile/screens/movie_screen.dart';
import 'package:cinephile/screens/watchlist_screen.dart';
import 'package:cinephile/screens/watched_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cinephile/screens/movie_search_delegate.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late PageController _trendingController;
  final ScrollController _scrollController = ScrollController();
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _trendingController = PageController(viewportFraction: 0.7, initialPage: 0);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<MovieProvider>(context, listen: false);
      provider.getTrendingMovies();
      provider.getAllMovies();
    });
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _trendingController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      Provider.of<MovieProvider>(context, listen: false).getNextPage();
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> _pages = [
      homePage(),
      const WatchlistScreen(),
      const WatchedScreen(),
      profile(),
    ];

    return Scaffold(
      extendBody: true,
      body: _pages[_selectedIndex],
      bottomNavigationBar: Container(
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: BottomNavigationBar(
              currentIndex: _selectedIndex,
              onTap: _onItemTapped,
              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.black.withOpacity(0.6),
              selectedItemColor: Colors.redAccent,
              unselectedItemColor: Colors.white.withOpacity(0.5),
              showSelectedLabels: false,
              showUnselectedLabels: false,
              elevation: 0,
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
                BottomNavigationBarItem(
                    icon: Icon(Icons.bookmark), label: 'Watchlist'),
                BottomNavigationBarItem(
                    icon: Icon(Icons.check_circle), label: 'Watched'),
                BottomNavigationBarItem(
                    icon: Icon(Icons.person), label: 'Profile'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget homePage() {
    return Consumer<MovieProvider>(builder: (context, movieProvider, child) {
      if (movieProvider.trendingMovies.isEmpty &&
          movieProvider.allMovies.isEmpty) {
        return const Center(
            child: CircularProgressIndicator(color: Colors.redAccent));
      }
      return CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverAppBar(
            pinned: true,
            floating: false,
            backgroundColor: const Color(0xFF121212),
            elevation: 0,
            toolbarHeight: 80,
            automaticallyImplyLeading: false,
            title: const Text(
              "Movie Library",
              style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
            centerTitle: false,
            actions: [
              IconButton(
                onPressed: () {
                  showSearch(
                    context: context,
                    delegate: MovieSearchDelegate(movieProvider),
                  );
                },
                icon: const Icon(Icons.search, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 10),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: const Text(
                "Trending",
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 350, // Increased height for the carousel
              child: PageView.builder(
                controller: _trendingController,
                itemCount: movieProvider.trendingMovies.length,
                itemBuilder: (context, index) {
                  final movie = movieProvider.trendingMovies[index];
                  return AnimatedBuilder(
                    animation: _trendingController,
                    builder: (context, child) {
                      double value = 1.0;
                      if (_trendingController.position.haveDimensions) {
                        value = _trendingController.page! - index;
                        value = (1 - (value.abs() * 0.3)).clamp(0.0, 1.0);
                      } else {
                        // Initial state: center item (index 0) is 1.0, others smaller
                        value = index == 0 ? 1.0 : 0.7;
                      }
                      final curve = Curves.easeOut.transform(value);
                      return Center(
                        child: SizedBox(
                          height: curve * 350,
                          width: curve * 250,
                          child: child,
                        ),
                      );
                    },
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MovieScreen(movie: movie),
                          ),
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.5),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              Image.network(
                                'https://image.tmdb.org/t/p/w500${movie.posterPath}',
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Container(
                                        color: Colors.grey[800],
                                        child: const Icon(Icons.movie)),
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.transparent,
                                      Colors.black.withOpacity(0.8),
                                    ],
                                    stops: const [0.6, 1.0],
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 20,
                                left: 20,
                                right: 20,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      movie.title,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    Row(
                                      children: [
                                        const Icon(Icons.star,
                                            color: Colors.amber, size: 16),
                                        const SizedBox(width: 5),
                                        Text(
                                          movie.voteAverage.toStringAsFixed(1),
                                          style: const TextStyle(
                                              color: Colors.white),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "All Movies",
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () =>
                            _showSortBottomSheet(context, movieProvider),
                        child: _buildChip("Sort", Icons.keyboard_arrow_down),
                      ),
                      const SizedBox(width: 10),
                      GestureDetector(
                        onTap: () =>
                            _showFilterBottomSheet(context, movieProvider),
                        child: _buildChip("Filter", Icons.tune),
                      ),
                      if (movieProvider.isModified) ...[
                        const SizedBox(width: 10),
                        GestureDetector(
                          onTap: () => movieProvider.resetAll(),
                          child: _buildChip("Clear", Icons.close),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
                childAspectRatio: 0.65,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final movie = movieProvider.allMovies[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MovieScreen(movie: movie),
                        ),
                      );
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: Image.network(
                              'https://image.tmdb.org/t/p/w500${movie.posterPath}',
                              fit: BoxFit.cover,
                              width: double.infinity,
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(
                                      color: Colors.grey[800],
                                      child: const Icon(Icons.movie)),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          movie.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          "${movie.releaseDate.split('-').first} • ${movie.voteAverage.toStringAsFixed(1)}",
                          style:
                              TextStyle(color: Colors.grey[400], fontSize: 12),
                        ),
                      ],
                    ),
                  );
                },
                childCount: movieProvider.allMovies.length,
              ),
            ),
          ),
        ],
      );
    });
  }

  void _showSortBottomSheet(BuildContext context, MovieProvider provider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E1E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Sort By",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              _buildSortOption(
                  context, provider, "Rating (High to Low)", "rating_desc"),
              _buildSortOption(
                  context, provider, "Rating (Low to High)", "rating_asc"),
              _buildSortOption(
                  context, provider, "Release Date (Newest)", "date_newest"),
              _buildSortOption(
                  context, provider, "Release Date (Oldest)", "date_oldest"),
              _buildSortOption(context, provider, "Title (A-Z)", "title_asc"),
              _buildSortOption(context, provider, "Title (Z-A)", "title_desc"),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSortOption(BuildContext context, MovieProvider provider,
      String label, String value) {
    return ListTile(
      title: Text(label, style: const TextStyle(color: Colors.white)),
      onTap: () {
        provider.sortMovies(value);
        Navigator.pop(context);
      },
    );
  }

  void _showFilterBottomSheet(BuildContext context, MovieProvider provider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E1E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Filter By",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              _buildFilterOption(context, provider, "Show All", "all"),
              _buildFilterOption(
                  context, provider, "Rating > 8.0", "rating_gt_8"),
              _buildFilterOption(
                  context, provider, "Released after 2020", "year_gt_2020"),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterOption(BuildContext context, MovieProvider provider,
      String label, String value) {
    return ListTile(
      title: Text(label, style: const TextStyle(color: Colors.white)),
      onTap: () {
        provider.filterMovies(value);
        Navigator.pop(context);
      },
    );
  }

  Widget _buildChip(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2C),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Text(label,
              style: const TextStyle(color: Colors.white, fontSize: 12)),
          const SizedBox(width: 4),
          Icon(icon, color: Colors.white, size: 14),
        ],
      ),
    );
  }

  Widget profile() {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: const Center(child: Text('Profile')),
    );
  }
}
