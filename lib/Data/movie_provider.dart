import 'dart:convert';

import 'package:flutter/material.dart';
import '../api.dart';
import 'package:http/http.dart' as http;

class MovieProvider extends ChangeNotifier {
  List<Movie> _trendingMovies = [];
  List<Movie> _allMovies = [];

  List<Movie> get trendingMovies => _trendingMovies;
  List<Movie> get allMovies => _allMovies;
  // Fallback for older code if any
  List<Movie> get getmovies =>
      _allMovies.isNotEmpty ? _allMovies : _trendingMovies;

  Future<void> getAllMovies() async {
    String url =
        "https://api.themoviedb.org/3/discover/movie?sort_by=vote_average.desc&vote_count.gte=10";

    var headers = {
      "accept": "application/json",
      "content-type": "application/json",
      "Authorization": "Bearer $apiToken"
    };
    var res = await http.get(Uri.parse(url), headers: headers);
    if (res.statusCode == 200) {
      var jsonResponse = res.body;
      List<Movie> movies = parseMovies(jsonResponse);
      _allMovies = movies;
      notifyListeners();
    } else {
      print(res.body);
      throw Exception("Failed to load all movies");
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
      print(res.body);
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
      print(movies);
      return movies;
    } else {
      print("ERROR: ${res.body}");
      throw Exception("Failed to search movies");
    }
  }

  void getNextPage(page) async {
    String moviesUrl =
        "https://api.themoviedb.org/3/trending/movie/day?page=$page";

    var headers = {
      "accept": "application/json",
      "content-type": "application/json",
      "Authorization": "Bearer $apiToken"
    };
    var res = await http.get(Uri.parse(moviesUrl), headers: headers);
    if (res.statusCode == 200) {
      print(res.body);
      var jsonResponse = res.body;
      List<Movie> movies = parseMovies(jsonResponse);
      _allMovies += movies; // Append to all movies
      notifyListeners();
    } else {
      print(res.body);
      throw Exception("Failed to load movies");
    }
  }

  Movie getMovieDetails(int movieId) {
    try {
      return _allMovies.firstWhere((movie) => movie.id == movieId);
    } catch (e) {
      return _trendingMovies.firstWhere((movie) => movie.id == movieId);
    }
  }

  List<Movie> parseMovies(String responseBody) {
    // This is a placeholder. You'll need to implement actual JSON parsing here.
    // For example, using `dart:convert`
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
