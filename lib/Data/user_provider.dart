import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'achievements_data.dart';
import 'database_helper.dart';
import 'movie_provider.dart';

class UserProvider extends ChangeNotifier {
  Map<String, dynamic>? _currentUser;
  List<Movie> _watchlist = [];
  List<Movie> _watchedMovies = [];
  List<Movie> _likedMovies = [];
  List<Movie> _dislikedMovies = [];
  bool _isLoading = false;

  Map<String, dynamic>? get currentUser => _currentUser;
  List<Movie> get watchlist => _watchlist;
  List<Movie> get watchedMovies => _watchedMovies;
  List<Movie> get likedMovies => _likedMovies;
  List<Movie> get dislikedMovies => _dislikedMovies;
  bool get isLoading => _isLoading;

  final DatabaseHelper _dbHelper = DatabaseHelper();

  // Auth Methods
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    var user = await _dbHelper.loginUser(email, password);
    if (user != null) {
      _currentUser = user;
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setInt('userId', user['id']);
      await _loadUserMovies();
      _isLoading = false;
      notifyListeners();
      return true;
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<bool> register(Map<String, dynamic> user) async {
    _isLoading = true;
    notifyListeners();

    int id = await _dbHelper.registerUser(user);
    if (id != -1) {
      // Auto login after register
      _currentUser = {...user, 'id': id};
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setInt('userId', id);
      await _loadUserMovies();
      _isLoading = false;
      notifyListeners();
      return true;
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<void> logout() async {
    _currentUser = null;
    _watchlist = [];
    _watchedMovies = [];
    _likedMovies = [];
    _dislikedMovies = [];
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('userId');
    notifyListeners();
  }

  Future<void> checkSession() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? userId = prefs.getInt('userId');
    if (userId != null) {
      _currentUser = await _dbHelper.getUser(userId);
      if (_currentUser != null) {
        await _loadUserMovies();
      }
    }
    notifyListeners();
  }

  // Movie Data Methods
  List<String> _unlockedAchievementCodes = [];
  List<String> get unlockedAchievementCodes => _unlockedAchievementCodes;

  // Stream for achievement notifications
  final _achievementStreamController =
      StreamController<Achievement>.broadcast();
  Stream<Achievement> get achievementStream =>
      _achievementStreamController.stream;

  Future<void> _loadUserMovies() async {
    if (_currentUser == null) {
      print("UserProvider: _loadUserMovies - Current user is null");
      return;
    }
    int userId = _currentUser!['id'];
    print("UserProvider: _loadUserMovies - Loading movies for user $userId");
    List<Map<String, dynamic>> moviesData =
        await _dbHelper.getUserMovies(userId);

    print("UserProvider: _loadUserMovies - Found ${moviesData.length} movies");

    _watchlist = [];
    _watchedMovies = [];
    _likedMovies = [];
    _dislikedMovies = [];

    for (var data in moviesData) {
      Movie movie = Movie(
        id: data['movie_id'],
        title: data['title'],
        overview: '', // Not stored locally, can be fetched if needed
        posterPath: data['poster_path'],
        voteAverage: data['vote_average'],
        releaseDate: data['release_date'],
        adult: false, // Default
        genreIds: data['genre_ids'] != null && data['genre_ids'].isNotEmpty
            ? (data['genre_ids'] as String)
                .split(',')
                .map((e) => int.tryParse(e) ?? 0)
                .toList()
            : [],
      );

      if (data['is_watchlist'] == 1) _watchlist.add(movie);
      if (data['is_watched'] == 1) _watchedMovies.add(movie);
      if (data['is_liked'] == 1) _likedMovies.add(movie);
      if (data['is_disliked'] == 1) _dislikedMovies.add(movie);
    }

    // Load unlocked achievements
    _unlockedAchievementCodes = await _dbHelper.getUnlockedAchievements(userId);

    print(
        "UserProvider: _loadUserMovies - Watchlist: ${_watchlist.length}, Watched: ${_watchedMovies.length}, Liked: ${_likedMovies.length}");
    notifyListeners();
  }

  Future<void> addToWatchlist(Movie movie) async {
    if (_currentUser == null) return;
    print("UserProvider: addToWatchlist - ${movie.title}");
    await _dbHelper.insertOrUpdateMovie(movie, _currentUser!['id'],
        isWatchlist: true);
    await _loadUserMovies();
  }

  Future<void> removeFromWatchlist(Movie movie) async {
    if (_currentUser == null) return;
    print("UserProvider: removeFromWatchlist - ${movie.title}");
    await _dbHelper.insertOrUpdateMovie(movie, _currentUser!['id'],
        isWatchlist: false);
    await _loadUserMovies();
  }

  Future<void> markAsWatched(Movie movie) async {
    if (_currentUser == null) return;
    print("UserProvider: markAsWatched - ${movie.title}");
    await _dbHelper.insertOrUpdateMovie(movie, _currentUser!['id'],
        isWatched: true);
    await _loadUserMovies();
    await _checkAchievements();
  }

  Future<void> unmarkAsWatched(Movie movie) async {
    if (_currentUser == null) return;
    print("UserProvider: unmarkAsWatched - ${movie.title}");
    await _dbHelper.insertOrUpdateMovie(movie, _currentUser!['id'],
        isWatched: false);
    await _loadUserMovies();
  }

  Future<void> toggleLike(Movie movie) async {
    if (_currentUser == null) return;
    bool isLiked = _likedMovies.any((m) => m.id == movie.id);
    print(
        "UserProvider: toggleLike - ${movie.title} (Currently Liked: $isLiked)");
    // If liking, ensure dislike is removed
    await _dbHelper.insertOrUpdateMovie(movie, _currentUser!['id'],
        isLiked: !isLiked,
        isDisliked: !isLiked ? false : null // If liking, set dislike to false
        );
    await _loadUserMovies();
  }

  Future<void> toggleDislike(Movie movie) async {
    if (_currentUser == null) return;
    bool isDisliked = _dislikedMovies.any((m) => m.id == movie.id);
    print(
        "UserProvider: toggleDislike - ${movie.title} (Currently Disliked: $isDisliked)");
    // If disliking, ensure like is removed
    await _dbHelper.insertOrUpdateMovie(movie, _currentUser!['id'],
        isDisliked: !isDisliked,
        isLiked: !isDisliked ? false : null // If disliking, set like to false
        );
    await _loadUserMovies();
  }

  bool isWatchlist(int movieId) {
    return _watchlist.any((m) => m.id == movieId);
  }

  bool isWatched(int movieId) {
    return _watchedMovies.any((m) => m.id == movieId);
  }

  bool isLiked(int movieId) {
    return _likedMovies.any((m) => m.id == movieId);
  }

  bool isDisliked(int movieId) {
    return _dislikedMovies.any((m) => m.id == movieId);
  }

  Future<void> clearData() async {
    await _dbHelper.clearDatabase();
    await logout();
  }

  Future<void> _checkAchievements() async {
    if (_currentUser == null) return;
    int userId = _currentUser!['id'];

    // Calculate stats
    int totalWatched = _watchedMovies.length;
    Map<int, int> genreCounts = {};
    for (var movie in _watchedMovies) {
      for (var genreId in movie.genreIds) {
        genreCounts[genreId] = (genreCounts[genreId] ?? 0) + 1;
      }
    }

    for (var achievement in allAchievements) {
      if (!_unlockedAchievementCodes.contains(achievement.code)) {
        if (achievement.condition(totalWatched, genreCounts)) {
          // Unlock!
          await _dbHelper.unlockAchievement(userId, achievement.code);
          _unlockedAchievementCodes.add(achievement.code);
          _achievementStreamController.add(achievement);
          notifyListeners();
        }
      }
    }
  }

  @override
  void dispose() {
    _achievementStreamController.close();
    super.dispose();
  }
}
