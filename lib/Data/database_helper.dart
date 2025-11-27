import 'dart:async';
import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'movie_provider.dart'; // Import for Movie model

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'cinephile.db');
    return await openDatabase(
      path,
      version: 3,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        email TEXT UNIQUE,
        password TEXT,
        name TEXT,
        phone TEXT,
        dob TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE movies(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER,
        movie_id INTEGER,
        title TEXT,
        poster_path TEXT,
        vote_average REAL,
        release_date TEXT,
        is_watchlist INTEGER DEFAULT 0,
        is_watched INTEGER DEFAULT 0,
        is_liked INTEGER DEFAULT 0,
        is_disliked INTEGER DEFAULT 0,
        genre_ids TEXT,
        FOREIGN KEY(user_id) REFERENCES users(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE achievements(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER,
        code TEXT,
        unlocked_at TEXT,
        FOREIGN KEY(user_id) REFERENCES users(id)
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS movies(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          user_id INTEGER,
          movie_id INTEGER,
          title TEXT,
          poster_path TEXT,
          vote_average REAL,
          release_date TEXT,
          is_watchlist INTEGER DEFAULT 0,
          is_watched INTEGER DEFAULT 0,
          is_liked INTEGER DEFAULT 0,
          is_disliked INTEGER DEFAULT 0,
          FOREIGN KEY(user_id) REFERENCES users(id)
        )
      ''');
    }
    if (oldVersion < 3) {
      // Add genre_ids column to movies table
      try {
        await db.execute('ALTER TABLE movies ADD COLUMN genre_ids TEXT');
      } catch (e) {
        print("Error adding genre_ids column: $e");
      }

      // Create achievements table
      await db.execute('''
        CREATE TABLE IF NOT EXISTS achievements(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          user_id INTEGER,
          code TEXT,
          unlocked_at TEXT,
          FOREIGN KEY(user_id) REFERENCES users(id)
        )
      ''');
    }
  }

  // User Methods
  Future<int> registerUser(Map<String, dynamic> user) async {
    Database db = await database;
    try {
      return await db.insert('users', user);
    } catch (e) {
      print("Error registering user: $e");
      return -1; // Return -1 on failure (e.g., duplicate email)
    }
  }

  Future<Map<String, dynamic>?> loginUser(String email, String password) async {
    Database db = await database;
    List<Map<String, dynamic>> result = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );
    if (result.isNotEmpty) {
      return result.first;
    }
    return null;
  }

  Future<Map<String, dynamic>?> getUser(int id) async {
    Database db = await database;
    List<Map<String, dynamic>> result = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (result.isNotEmpty) {
      return result.first;
    }
    return null;
  }

  // Movie Methods
  Future<void> insertOrUpdateMovie(Movie movie, int userId,
      {bool? isWatchlist,
      bool? isWatched,
      bool? isLiked,
      bool? isDisliked}) async {
    Database db = await database;
    print(
        "DatabaseHelper: insertOrUpdateMovie - User: $userId, Movie: ${movie.id}");

    try {
      // Check if movie exists for this user
      List<Map<String, dynamic>> existing = await db.query(
        'movies',
        where: 'user_id = ? AND movie_id = ?',
        whereArgs: [userId, movie.id],
      );

      if (existing.isNotEmpty) {
        // Update existing record
        print("DatabaseHelper: Updating existing record");
        Map<String, dynamic> updateData = {};
        if (isWatchlist != null)
          updateData['is_watchlist'] = isWatchlist ? 1 : 0;
        if (isWatched != null) updateData['is_watched'] = isWatched ? 1 : 0;
        if (isLiked != null) updateData['is_liked'] = isLiked ? 1 : 0;
        if (isDisliked != null) updateData['is_disliked'] = isDisliked ? 1 : 0;
        // Always update genre_ids to ensure we have the latest data
        updateData['genre_ids'] = movie.genreIds.join(',');

        await db.update(
          'movies',
          updateData,
          where: 'user_id = ? AND movie_id = ?',
          whereArgs: [userId, movie.id],
        );
      } else {
        // Insert new record
        print("DatabaseHelper: Inserting new record");
        await db.insert('movies', {
          'user_id': userId,
          'movie_id': movie.id,
          'title': movie.title,
          'poster_path': movie.posterPath,
          'vote_average': movie.voteAverage,
          'release_date': movie.releaseDate,
          'is_watchlist': (isWatchlist ?? false) ? 1 : 0,
          'is_watched': (isWatched ?? false) ? 1 : 0,
          'is_liked': (isLiked ?? false) ? 1 : 0,
          'is_disliked': (isDisliked ?? false) ? 1 : 0,
          'genre_ids': movie.genreIds.join(','),
        });
      }
    } catch (e) {
      print("DatabaseHelper Error: $e");
    }
  }

  Future<List<Map<String, dynamic>>> getUserMovies(int userId) async {
    Database db = await database;
    return await db.query(
      'movies',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
  }

  Future<void> clearDatabase() async {
    Database db = await database;
    await db.delete('movies');
    await db.delete('users');
    await db.delete('achievements');
  }

  // Achievement Methods
  Future<List<String>> getUnlockedAchievements(int userId) async {
    Database db = await database;
    List<Map<String, dynamic>> result = await db.query(
      'achievements',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
    return result.map((e) => e['code'] as String).toList();
  }

  Future<void> unlockAchievement(int userId, String code) async {
    Database db = await database;
    await db.insert('achievements', {
      'user_id': userId,
      'code': code,
      'unlocked_at': DateTime.now().toIso8601String(),
    });
  }
}
