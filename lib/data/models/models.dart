import 'package:flutter/foundation.dart';

enum MediaKind { track, video }

enum OwnershipKind { none, owned, rented, gifted }

enum PersonRole { artist, producer, director }

@immutable
class MediaItem {
  const MediaItem({
    required this.id,
    required this.title,
    required this.kind,
    this.genre,
    this.year,
    this.duration,
    this.seasons,
    this.director,
    this.actors = const [],
    this.imdb,
    this.likes = 0,
    this.dislikes = 0,
    this.ownership = OwnershipKind.none,
    this.views,
    this.publishedAgo,
    this.imageUrl,
    this.mediaUrl,
    this.progress = 0,
  });

  final String id;
  final String title;
  final MediaKind kind;
  final String? genre;
  final int? year;
  final Duration? duration;
  final int? seasons;
  final String? director;
  final List<String> actors;
  final double? imdb;
  final int likes;
  final int dislikes;
  final OwnershipKind ownership;
  final String? views;
  final String? publishedAgo;
  final String? imageUrl;
  final String? mediaUrl;

  /// How far through the title the viewer is, 0..1.
  final double progress;

  /// "2005 - Drama - 5 seasons"
  String get subtitle => [
    if (year != null) '$year',
    if (genre != null) genre,
    if (seasons != null) '$seasons seasons',
  ].join(' - ');

  MediaItem copyWith({OwnershipKind? ownership}) => MediaItem(
    id: id,
    title: title,
    kind: kind,
    genre: genre,
    year: year,
    duration: duration,
    seasons: seasons,
    director: director,
    actors: actors,
    imdb: imdb,
    likes: likes,
    dislikes: dislikes,
    ownership: ownership ?? this.ownership,
    views: views,
    publishedAgo: publishedAgo,
    imageUrl: imageUrl,
    mediaUrl: mediaUrl,
  );
}

@immutable
class UserProfile {
  const UserProfile({
    required this.name,
    required this.email,
    this.city,
    this.role,
    this.imageUrl,
    this.balance = 0,
  });

  final String name;
  final String email;
  final String? city;
  final String? role;
  final String? imageUrl;
  final double balance;

  String get firstName => name.split(' ').first;
}

@immutable
class Person {
  const Person({
    required this.id,
    required this.name,
    required this.role,
    this.following = false,
    this.imageUrl,
  });

  final String id;
  final String name;
  final PersonRole role;
  final bool following;
  final String? imageUrl;

  Person copyWith({bool? following}) => Person(
    id: id,
    name: name,
    role: role,
    following: following ?? this.following,
    imageUrl: imageUrl,
  );
}

@immutable
class Playlist {
  const Playlist({
    required this.id,
    required this.name,
    required this.owner,
    this.trackIds = const [],
    this.imageUrl,
  });

  final String id;
  final String name;
  final String owner;
  final List<String> trackIds;
  final String? imageUrl;
}

@immutable
class Season {
  const Season({
    required this.number,
    required this.title,
    required this.episodeRange,
    this.note,
  });

  final int number;
  final String title;
  final String episodeRange;
  final String? note;
}

@immutable
class GenreShare {
  const GenreShare(this.genre, this.percent);

  final String genre;
  final double percent;
}
