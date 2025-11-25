import 'dart:convert';
import 'package:flutter/material.dart';
import '../api.dart';
import 'package:http/http.dart' as http;

class MovieProvider extends ChangeNotifier {
  List<Movie> _trendingMovies = [];
  List<Movie> _allMovies = [];
  List<Movie> _masterAllMovies = []; // To store original list for filtering
  int _currentPage = 1;
  bool _isLoading = false;
  String _currentSortBy = 'vote_average.desc';
  String _currentFilterQuery = ''; // e.g., &vote_average.gte=8

  List<Movie> get trendingMovies => _trendingMovies;
  List<Movie> get allMovies => _allMovies;
  // Fallback for older code if any
  List<Movie> get getmovies =>
      _allMovies.isNotEmpty ? _allMovies : _trendingMovies;

  Future<void> getAllMovies({bool reset = false}) async {
    if (_isLoading) return;
    _isLoading = true;

    if (reset) {
      _currentPage = 1;
      _allMovies = [];
      notifyListeners();
    }

    String url =
        "https://api.themoviedb.org/3/discover/movie?sort_by=$_currentSortBy$_currentFilterQuery&page=$_currentPage&vote_count.gte=10";

    var headers = {
      "accept": "application/json",
      "content-type": "application/json",
      "Authorization": "Bearer $apiToken"
    };

    try {
      var res = await http.get(Uri.parse(url), headers: headers);
      if (res.statusCode == 200) {
        var jsonResponse = res.body;
        List<Movie> movies = parseMovies(jsonResponse);
        if (reset) {
          _allMovies = movies;
        } else {
          _allMovies.addAll(movies);
        }
        _currentPage++;
        notifyListeners();
      } else {
        print(res.body);
        throw Exception("Failed to load all movies");
      }
    } catch (e) {
      print("Error fetching movies: $e");
    } finally {
      _isLoading = false;
    }
  }

  void getTrendingMovies() async {
    String moviesUrl = "https://api.themoviedb.org/3/trending/movie/day";

    var headers = {
      "accept": "application/json",
      "content-type": "application/json",
      "Authorization": "Bearer $apiToken"
    };
    var res = await http.get(Uri.parse(moviesUrl), headers: headers);
    if (res.statusCode == 200) {
      var jsonResponse = res.body;
      List<Movie> movies = parseMovies(jsonResponse);
      _trendingMovies = movies;
      notifyListeners();
    } else {
      print(res.body);
      throw Exception("Failed to load trending movies");
    }
  }

  Future<List<Movie>> searchMovies(String query) async {
    String searchUrl = "https://api.themoviedb.org/3/search/movie?query=$query";

    var headers = {
      "accept": "application/json",
      "content-type": "application/json",
      "Authorization": "Bearer $apiToken"
    };
    var res = await http.get(Uri.parse(searchUrl), headers: headers);
    if (res.statusCode == 200) {
      var jsonResponse = res.body;
      List<Movie> movies = parseMovies(jsonResponse);
      notifyListeners();
      return movies;
    } else {
      print("ERROR: ${res.body}");
      throw Exception("Failed to search movies");
    }
  }

  void getNextPage() {
    getAllMovies(reset: false);
  }

  void sortMovies(String criterion) {
    if (criterion == 'rating_desc') {
      _currentSortBy = 'vote_average.desc';
    } else if (criterion == 'rating_asc') {
      _currentSortBy = 'vote_average.asc';
    } else if (criterion == 'date_newest') {
      _currentSortBy = 'primary_release_date.desc';
    } else if (criterion == 'date_oldest') {
      _currentSortBy = 'primary_release_date.asc';
    } else if (criterion == 'title_asc') {
      _currentSortBy = 'original_title.asc';
    } else if (criterion == 'title_desc') {
      _currentSortBy = 'original_title.desc';
    }
    getAllMovies(reset: true);
  }

  void filterMovies(String criterion) {
    if (criterion == 'all') {
      _currentFilterQuery = '';
    } else if (criterion == 'rating_gt_8') {
      _currentFilterQuery = '&vote_average.gte=8';
    } else if (criterion == 'year_gt_2020') {
      _currentFilterQuery = '&primary_release_date.gte=2020-01-01';
    }
    getAllMovies(reset: true);
  }

  void resetAll() {
    _currentSortBy = 'vote_average.desc';
    _currentFilterQuery = '';
    getAllMovies(reset: true);
  }

  bool get isModified {
    return _currentSortBy != 'vote_average.desc' || _currentFilterQuery != '';
  }

  Future<String?> getMovieTrailer(int movieId) async {
    String url = "https://api.themoviedb.org/3/movie/$movieId/videos";
    var headers = {
      "accept": "application/json",
      "content-type": "application/json",
      "Authorization": "Bearer $apiToken"
    };

    try {
      var res = await http.get(Uri.parse(url), headers: headers);
      if (res.statusCode == 200) {
        var jsonResponse = jsonDecode(res.body);
        List videos = jsonResponse['results'];
        var trailer = videos.firstWhere(
          (video) => video['site'] == 'YouTube' && video['type'] == 'Trailer',
          orElse: () => null,
        );
        return trailer != null ? trailer['key'] : null;
      }
    } catch (e) {
      print("Error fetching trailer: $e");
    }
    return null;
  }

  Movie getMovieDetails(int movieId) {
    try {
      return _allMovies.firstWhere((movie) => movie.id == movieId);
    } catch (e) {
      return _trendingMovies.firstWhere((movie) => movie.id == movieId);
    }
  }

  List<Movie> parseMovies(String responseBody) {
    final parsed =
        jsonDecode(responseBody)['results'].cast<Map<String, dynamic>>();
    return parsed.map<Movie>((json) => Movie.fromJson(json)).toList();
  }
}

class Movie {
  final int id;
  final String title;
  final String overview;
  final String posterPath;
  final double voteAverage;
  final bool adult;
  final String releaseDate;

  Movie({
    required this.id,
    required this.title,
    required this.overview,
    required this.posterPath,
    required this.voteAverage,
    required this.releaseDate,
    required this.adult,
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      id: json['id'],
      title: json['title'],
      overview: json['overview'],
      posterPath: json['poster_path'] ?? '',
      voteAverage: (json['vote_average'] ?? 0.0).toDouble(),
      releaseDate: json['release_date'] ?? '',
      adult: json['adult'] ?? false,
    );
  }
}
