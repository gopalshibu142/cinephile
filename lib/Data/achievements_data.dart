import 'package:flutter/material.dart';

class Achievement {
  final String code;
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final bool Function(int totalWatched, Map<int, int> genreCounts) condition;

  Achievement({
    required this.code,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.condition,
  });
}

// TMDB Genre IDs
const int action = 28;
const int adventure = 12;
const int animation = 16;
const int comedy = 35;
const int crime = 80;
const int documentary = 99;
const int drama = 18;
const int family = 10751;
const int fantasy = 14;
const int history = 36;
const int horror = 27;
const int music = 10402;
const int mystery = 9648;
const int romance = 10749;
const int scienceFiction = 878;
const int tvMovie = 10770;
const int thriller = 53;
const int war = 10752;
const int western = 37;

final List<Achievement> allAchievements = [
  // --- Count Based ---
  Achievement(
    code: 'count_1',
    title: 'First Step',
    description: 'Watch your first movie',
    icon: Icons.looks_one,
    color: Colors.blue,
    condition: (total, genres) => total >= 1,
  ),
  Achievement(
    code: 'count_5',
    title: 'Couch Potato',
    description: 'Watch 5 movies',
    icon: Icons.weekend,
    color: Colors.green,
    condition: (total, genres) => total >= 5,
  ),
  Achievement(
    code: 'count_10',
    title: 'Popcorn Addict',
    description: 'Watch 10 movies',
    icon: Icons.local_movies,
    color: Colors.orange,
    condition: (total, genres) => total >= 10,
  ),
  Achievement(
    code: 'count_25',
    title: 'Cinephile',
    description: 'Watch 25 movies',
    icon: Icons.movie_filter,
    color: Colors.red,
    condition: (total, genres) => total >= 25,
  ),
  Achievement(
    code: 'count_50',
    title: 'Cinema Legend',
    description: 'Watch 50 movies',
    icon: Icons.star,
    color: Colors.purple,
    condition: (total, genres) => total >= 50,
  ),
  Achievement(
    code: 'count_100',
    title: 'Movie Marathoner',
    description: 'Watch 100 movies',
    icon: Icons.directions_run,
    color: Colors.amber,
    condition: (total, genres) => total >= 100,
  ),

  // --- Genre Based: Action ---
  Achievement(
    code: 'action_5',
    title: 'Action Hero',
    description: 'Watch 5 Action movies',
    icon: Icons.flash_on,
    color: Colors.redAccent,
    condition: (total, genres) => (genres[action] ?? 0) >= 5,
  ),
  Achievement(
    code: 'action_10',
    title: 'Explosion Lover',
    description: 'Watch 10 Action movies',
    icon: Icons.local_fire_department,
    color: Colors.redAccent,
    condition: (total, genres) => (genres[action] ?? 0) >= 10,
  ),
  Achievement(
    code: 'action_20',
    title: 'Adrenaline Junkie',
    description: 'Watch 20 Action movies',
    icon: Icons.speed,
    color: Colors.redAccent,
    condition: (total, genres) => (genres[action] ?? 0) >= 20,
  ),

  // --- Genre Based: Comedy ---
  Achievement(
    code: 'comedy_5',
    title: 'Giggle Monster',
    description: 'Watch 5 Comedy movies',
    icon: Icons.sentiment_very_satisfied,
    color: Colors.yellow,
    condition: (total, genres) => (genres[comedy] ?? 0) >= 5,
  ),
  Achievement(
    code: 'comedy_10',
    title: 'Laugh Track',
    description: 'Watch 10 Comedy movies',
    icon: Icons.theater_comedy,
    color: Colors.yellow,
    condition: (total, genres) => (genres[comedy] ?? 0) >= 10,
  ),
  Achievement(
    code: 'comedy_20',
    title: 'Stand-up Star',
    description: 'Watch 20 Comedy movies',
    icon: Icons.mic,
    color: Colors.yellow,
    condition: (total, genres) => (genres[comedy] ?? 0) >= 20,
  ),

  // --- Genre Based: Horror ---
  Achievement(
    code: 'horror_5',
    title: 'Scream Queen/King',
    description: 'Watch 5 Horror movies',
    icon: Icons.bug_report,
    color: Colors.deepPurple,
    condition: (total, genres) => (genres[horror] ?? 0) >= 5,
  ),
  Achievement(
    code: 'horror_10',
    title: 'Ghost Hunter',
    description: 'Watch 10 Horror movies',
    icon: Icons.visibility_off,
    color: Colors.deepPurple,
    condition: (total, genres) => (genres[horror] ?? 0) >= 10,
  ),
  Achievement(
    code: 'horror_20',
    title: 'Fearless',
    description: 'Watch 20 Horror movies',
    icon: Icons.nightlight_round,
    color: Colors.deepPurple,
    condition: (total, genres) => (genres[horror] ?? 0) >= 20,
  ),

  // --- Genre Based: Romance ---
  Achievement(
    code: 'romance_5',
    title: 'Hopeless Romantic',
    description: 'Watch 5 Romance movies',
    icon: Icons.favorite,
    color: Colors.pink,
    condition: (total, genres) => (genres[romance] ?? 0) >= 5,
  ),
  Achievement(
    code: 'romance_10',
    title: 'Lovebird',
    description: 'Watch 10 Romance movies',
    icon: Icons.favorite_border,
    color: Colors.pink,
    condition: (total, genres) => (genres[romance] ?? 0) >= 10,
  ),

  // --- Genre Based: Sci-Fi ---
  Achievement(
    code: 'scifi_5',
    title: 'Space Cadet',
    description: 'Watch 5 Sci-Fi movies',
    icon: Icons.rocket_launch,
    color: Colors.cyan,
    condition: (total, genres) => (genres[scienceFiction] ?? 0) >= 5,
  ),
  Achievement(
    code: 'scifi_10',
    title: 'Time Traveler',
    description: 'Watch 10 Sci-Fi movies',
    icon: Icons.access_time,
    color: Colors.cyan,
    condition: (total, genres) => (genres[scienceFiction] ?? 0) >= 10,
  ),

  // --- Genre Based: Drama ---
  Achievement(
    code: 'drama_5',
    title: 'Drama Queen/King',
    description: 'Watch 5 Drama movies',
    icon: Icons.masks,
    color: Colors.teal,
    condition: (total, genres) => (genres[drama] ?? 0) >= 5,
  ),
  Achievement(
    code: 'drama_10',
    title: 'Serious Business',
    description: 'Watch 10 Drama movies',
    icon: Icons.business_center,
    color: Colors.teal,
    condition: (total, genres) => (genres[drama] ?? 0) >= 10,
  ),

  // --- Genre Based: Animation ---
  Achievement(
    code: 'animation_5',
    title: 'Cartoon Lover',
    description: 'Watch 5 Animated movies',
    icon: Icons.animation,
    color: Colors.orangeAccent,
    condition: (total, genres) => (genres[animation] ?? 0) >= 5,
  ),
  Achievement(
    code: 'animation_10',
    title: 'Kid at Heart',
    description: 'Watch 10 Animated movies',
    icon: Icons.child_care,
    color: Colors.orangeAccent,
    condition: (total, genres) => (genres[animation] ?? 0) >= 10,
  ),

  // --- Genre Based: Thriller ---
  Achievement(
    code: 'thriller_5',
    title: 'Edge of Seat',
    description: 'Watch 5 Thriller movies',
    icon: Icons.psychology,
    color: Colors.blueGrey,
    condition: (total, genres) => (genres[thriller] ?? 0) >= 5,
  ),
  Achievement(
    code: 'thriller_10',
    title: 'Suspense Master',
    description: 'Watch 10 Thriller movies',
    icon: Icons.search,
    color: Colors.blueGrey,
    condition: (total, genres) => (genres[thriller] ?? 0) >= 10,
  ),

  // --- Genre Based: Adventure ---
  Achievement(
    code: 'adventure_5',
    title: 'Explorer',
    description: 'Watch 5 Adventure movies',
    icon: Icons.map,
    color: Colors.greenAccent,
    condition: (total, genres) => (genres[adventure] ?? 0) >= 5,
  ),
  Achievement(
    code: 'adventure_10',
    title: 'Adventurer',
    description: 'Watch 10 Adventure movies',
    icon: Icons.explore,
    color: Colors.greenAccent,
    condition: (total, genres) => (genres[adventure] ?? 0) >= 10,
  ),

  // --- Genre Based: Fantasy ---
  Achievement(
    code: 'fantasy_5',
    title: 'Dreamer',
    description: 'Watch 5 Fantasy movies',
    icon: Icons.auto_awesome,
    color: Colors.purpleAccent,
    condition: (total, genres) => (genres[fantasy] ?? 0) >= 5,
  ),
  Achievement(
    code: 'fantasy_10',
    title: 'Wizard',
    description: 'Watch 10 Fantasy movies',
    icon: Icons.auto_fix_high,
    color: Colors.purpleAccent,
    condition: (total, genres) => (genres[fantasy] ?? 0) >= 10,
  ),

  // --- Genre Based: Crime ---
  Achievement(
    code: 'crime_5',
    title: 'Detective',
    description: 'Watch 5 Crime movies',
    icon: Icons.fingerprint,
    color: Colors.grey,
    condition: (total, genres) => (genres[crime] ?? 0) >= 5,
  ),

  // --- Genre Based: Documentary ---
  Achievement(
    code: 'doc_5',
    title: 'Fact Finder',
    description: 'Watch 5 Documentaries',
    icon: Icons.menu_book,
    color: Colors.brown,
    condition: (total, genres) => (genres[documentary] ?? 0) >= 5,
  ),

  // --- Genre Based: Family ---
  Achievement(
    code: 'family_5',
    title: 'Family Time',
    description: 'Watch 5 Family movies',
    icon: Icons.family_restroom,
    color: Colors.lightGreen,
    condition: (total, genres) => (genres[family] ?? 0) >= 5,
  ),

  // --- Genre Based: History ---
  Achievement(
    code: 'history_5',
    title: 'Historian',
    description: 'Watch 5 History movies',
    icon: Icons.history_edu,
    color: Colors.brown,
    condition: (total, genres) => (genres[history] ?? 0) >= 5,
  ),

  // --- Genre Based: Music ---
  Achievement(
    code: 'music_5',
    title: 'Music Lover',
    description: 'Watch 5 Music movies',
    icon: Icons.music_note,
    color: Colors.pinkAccent,
    condition: (total, genres) => (genres[music] ?? 0) >= 5,
  ),

  // --- Genre Based: Mystery ---
  Achievement(
    code: 'mystery_5',
    title: 'Puzzle Solver',
    description: 'Watch 5 Mystery movies',
    icon: Icons.question_mark,
    color: Colors.indigo,
    condition: (total, genres) => (genres[mystery] ?? 0) >= 5,
  ),

  // --- Genre Based: TV Movie ---
  Achievement(
    code: 'tvmovie_5',
    title: 'TV Binger',
    description: 'Watch 5 TV Movies',
    icon: Icons.tv,
    color: Colors.blue,
    condition: (total, genres) => (genres[tvMovie] ?? 0) >= 5,
  ),

  // --- Genre Based: War ---
  Achievement(
    code: 'war_5',
    title: 'Veteran',
    description: 'Watch 5 War movies',
    icon: Icons.military_tech,
    color: Colors.green,
    condition: (total, genres) => (genres[war] ?? 0) >= 5,
  ),

  // --- Genre Based: Western ---
  Achievement(
    code: 'western_5',
    title: 'Cowboy',
    description: 'Watch 5 Western movies',
    icon: Icons.star_border,
    color: Colors.brown,
    condition: (total, genres) => (genres[western] ?? 0) >= 5,
  ),

  // --- Mixed ---
  Achievement(
    code: 'mixed_10',
    title: 'Jack of All Trades',
    description:
        'Watch 10 movies of different genres', // Simplified logic for now
    icon: Icons.category,
    color: Colors.tealAccent,
    condition: (total, genres) => genres.keys.length >= 5,
  ),
  // --- Genre Combinations ---
  Achievement(
    code: 'combo_action_comedy',
    title: 'Action Comedy Fan',
    description: 'Watch 5 Action and 5 Comedy movies',
    icon: Icons.emoji_emotions,
    color: Colors.orange,
    condition: (total, genres) =>
        (genres[action] ?? 0) >= 5 && (genres[comedy] ?? 0) >= 5,
  ),
  Achievement(
    code: 'combo_rom_com',
    title: 'RomCom Lover',
    description: 'Watch 5 Romance and 5 Comedy movies',
    icon: Icons.favorite_border,
    color: Colors.pinkAccent,
    condition: (total, genres) =>
        (genres[romance] ?? 0) >= 5 && (genres[comedy] ?? 0) >= 5,
  ),
  Achievement(
    code: 'combo_scifi_horror',
    title: 'Sci-Fi Horror Buff',
    description: 'Watch 5 Sci-Fi and 5 Horror movies',
    icon: Icons.science,
    color: Colors.deepPurpleAccent,
    condition: (total, genres) =>
        (genres[scienceFiction] ?? 0) >= 5 && (genres[horror] ?? 0) >= 5,
  ),
  Achievement(
    code: 'combo_family_adventure',
    title: 'Family Adventure',
    description: 'Watch 5 Family and 5 Adventure movies',
    icon: Icons.backpack,
    color: Colors.lightGreen,
    condition: (total, genres) =>
        (genres[family] ?? 0) >= 5 && (genres[adventure] ?? 0) >= 5,
  ),

  // --- Higher Genre Tiers ---
  Achievement(
    code: 'action_50',
    title: 'Action Star',
    description: 'Watch 50 Action movies',
    icon: Icons.local_activity,
    color: Colors.red,
    condition: (total, genres) => (genres[action] ?? 0) >= 50,
  ),
  Achievement(
    code: 'comedy_50',
    title: 'Comedy Legend',
    description: 'Watch 50 Comedy movies',
    icon: Icons.theater_comedy,
    color: Colors.yellowAccent,
    condition: (total, genres) => (genres[comedy] ?? 0) >= 50,
  ),
  Achievement(
    code: 'drama_50',
    title: 'Drama Icon',
    description: 'Watch 50 Drama movies',
    icon: Icons.star_rate,
    color: Colors.tealAccent,
    condition: (total, genres) => (genres[drama] ?? 0) >= 50,
  ),

  // --- Variety & Fun ---
  Achievement(
    code: 'variety_5',
    title: 'Taste Tester',
    description: 'Watch movies from 5 different genres',
    icon: Icons.palette,
    color: Colors.indigoAccent,
    condition: (total, genres) => genres.keys.length >= 5,
  ),
  Achievement(
    code: 'variety_10',
    title: 'Genre Explorer',
    description: 'Watch movies from 10 different genres',
    icon: Icons.explore_off,
    color: Colors.indigo,
    condition: (total, genres) => genres.keys.length >= 10,
  ),
  Achievement(
    code: 'count_42',
    title: 'The Answer',
    description: 'Watch 42 movies',
    icon: Icons.question_answer,
    color: Colors.blueGrey,
    condition: (total, genres) => total >= 42,
  ),
  Achievement(
    code: 'lucky_7',
    title: 'Lucky 7',
    description: 'Watch 7 movies',
    icon: Icons.casino,
    color: Colors.green,
    condition: (total, genres) => total >= 7,
  ),
];
