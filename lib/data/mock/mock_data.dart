import '../models/models.dart';

/// The stand-in "backend".
///
/// Everything the app renders comes from here, reached through
/// [MediaRepository] so a real API can replace it without touching the UI.
abstract final class MockData {
  /// Royalty-free demo stream (Blender Foundation, CC-BY).
  static const demoVideoUrl =
      'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4';

  static const user = UserProfile(
    name: 'Namal Rashmika',
    email: 'namal@gmail.com',
    city: 'Galle',
    role: 'Music Producer',
    imageUrl: 'assets/images/avatar_namal.png',
    balance: 12480.50,
  );

  static const interests = <String>[
    'Pop',
    'Entertainment',
    'Trending',
    'Melody',
    'Popular',
    'Rock',
    'Hip Hop',
    'Classical',
    'Other…',
  ];

  static const popularNow = <MediaItem>[
    MediaItem(
      id: 't1',
      imageUrl: 'assets/images/art_titanic.png',
      title: 'My Heart Will Go On',
      kind: MediaKind.track,
      genre: 'Celine Dion',
      year: 1997,
      duration: Duration(minutes: 4, seconds: 40),
    ),
    MediaItem(
      id: 't2',
      imageUrl: 'assets/images/art_badguy.png',
      title: 'Bad Guy',
      kind: MediaKind.track,
      genre: 'Billie Eilish',
      year: 2019,
      duration: Duration(minutes: 3, seconds: 14),
    ),
    MediaItem(
      id: 't3',
      imageUrl: 'assets/images/art_prionbreak.png',
      title: 'Blinding Lights',
      kind: MediaKind.track,
      genre: 'The Weeknd',
      year: 2019,
      duration: Duration(minutes: 3, seconds: 20),
    ),
  ];

  static const newest = <MediaItem>[
    MediaItem(
      id: 't4',
      imageUrl: 'assets/images/art_rings7.png',
      title: 'Seven Rings',
      kind: MediaKind.track,
      genre: 'Ariana Grande',
      year: 2019,
      duration: Duration(minutes: 3, seconds: 2),
    ),
    MediaItem(
      id: 't5',
      imageUrl: 'assets/images/art_enchanted.png',
      title: 'Enchanted',
      kind: MediaKind.track,
      genre: 'Taylor Swift',
      year: 2010,
      duration: Duration(minutes: 5, seconds: 52),
    ),
    MediaItem(
      id: 't6',
      imageUrl: 'assets/images/art_goku.png',
      title: 'See You Again',
      kind: MediaKind.track,
      genre: 'Wiz Khalifa',
      year: 2015,
      duration: Duration(minutes: 3, seconds: 49),
    ),
  ];

  static const videos = <MediaItem>[
    MediaItem(
      id: 'v1',
      imageUrl: 'assets/images/art_prionbreak.png',
      title: 'Prion Break',
      kind: MediaKind.video,
      year: 2005,
      genre: 'Action/Adventure',
      seasons: 5,
      director: 'Brett Ratner',
      actors: ['Michael Scofield'],
      imdb: 8.0,
      likes: 10000,
      dislikes: 780,
      ownership: OwnershipKind.rented,
    ),
    MediaItem(
      id: 'v2',
      imageUrl: 'assets/images/art_loki.png',
      title: 'Loki Season-1',
      kind: MediaKind.video,
      year: 2021,
      genre: 'Fantasy',
      seasons: 1,
      imdb: 8.2,
      ownership: OwnershipKind.owned,
    ),
    MediaItem(
      id: 'v3',
      imageUrl: 'assets/images/art_avengers.png',
      title: 'Avengers: Age of Ultron',
      kind: MediaKind.video,
      year: 2015,
      genre: 'Action',
      imdb: 7.3,
      ownership: OwnershipKind.owned,
    ),
    MediaItem(
      id: 'v4',
      imageUrl: 'assets/images/art_blackadam.png',
      title: 'Black Adam',
      kind: MediaKind.video,
      year: 2022,
      genre: 'Action',
      imdb: 6.3,
      ownership: OwnershipKind.owned,
    ),
    MediaItem(
      id: 'v5',
      imageUrl: 'assets/images/art_ringspower.png',
      title: 'The Rings of Power',
      kind: MediaKind.video,
      year: 2022,
      genre: 'Fantasy',
      seasons: 1,
      imdb: 6.9,
      ownership: OwnershipKind.gifted,
    ),
  ];

  /// Creator-side catalogue shown in My Videos and Analytics.
  static const published = <MediaItem>[
    MediaItem(
      id: 'p1',
      imageUrl: 'assets/images/art_quatal.png',
      title: 'Quatal',
      kind: MediaKind.video,
      views: '3.2M',
      publishedAgo: '1 year ago',
      genre: 'Action',
    ),
    MediaItem(
      id: 'p2',
      imageUrl: 'assets/images/art_breakingbad.png',
      title: 'Breaking Bad',
      kind: MediaKind.video,
      views: '10M',
      publishedAgo: '7 months ago',
      genre: 'Drama',
    ),
    MediaItem(
      id: 'p3',
      imageUrl: 'assets/images/art_loner.png',
      title: 'Loner',
      kind: MediaKind.video,
      views: '247k',
      publishedAgo: '3 weeks ago',
      genre: 'Thriller',
    ),
  ];

  static const seasons = <Season>[
    Season(
      number: 2,
      title: 'Season 2',
      episodeRange: 'Epi- 1-15',
      note: 'Escape',
    ),
    Season(
      number: 3,
      title: 'Season 3',
      episodeRange: 'Epi- 1-17',
      note: 'No more',
    ),
    Season(
      number: 4,
      title: 'Season 4',
      episodeRange: 'Epi- 1-22',
      note: 'The Final Break',
    ),
  ];

  static const people = <Person>[
    Person(
      id: 'a1',
      name: 'Max Martin',
      role: PersonRole.producer,
      following: true,
      imageUrl: 'assets/images/p_maxmartin.png',
    ),
    Person(
      id: 'a2',
      name: 'Charlie Puth',
      role: PersonRole.producer,
      following: true,
      imageUrl: 'assets/images/p_charlieputh.png',
    ),
    Person(
      id: 'a3',
      name: 'Leha Halton',
      role: PersonRole.producer,
      following: true,
      imageUrl: 'assets/images/p_lehahalton.png',
    ),
    Person(id: 'a4', name: 'Calvin Harris', role: PersonRole.producer),
    Person(
      id: 'd1',
      name: 'Cristoper Noland',
      role: PersonRole.director,
      following: true,
      imageUrl: 'assets/images/p_noland.png',
    ),
    Person(
      id: 'd2',
      name: 'Lady Gaga',
      role: PersonRole.director,
      following: true,
      imageUrl: 'assets/images/p_ladygaga.png',
    ),
    Person(
      id: 'd3',
      name: 'Louis Bell',
      role: PersonRole.director,
      following: true,
      imageUrl: 'assets/images/p_louisbell.png',
    ),
    Person(
      id: 'r1',
      name: 'Billie Eilish',
      role: PersonRole.artist,
      following: true,
      imageUrl: 'assets/images/art_badguy.png',
    ),
    Person(
      id: 'r2',
      name: 'Taylor Swift',
      role: PersonRole.artist,
      imageUrl: 'assets/images/art_enchanted.png',
    ),
    Person(
      id: 'r3',
      name: 'The Weeknd',
      role: PersonRole.artist,
      following: true,
    ),
  ];

  static const playlists = <Playlist>[
    Playlist(
      id: 'pl1',
      name: 'Liked Songs',
      owner: '33 Songs',
      trackIds: ['t1', 't2', 't3', 't4'],
    ),
    Playlist(
      id: 'pl2',
      name: 'Relaxing',
      owner: 'Namal Rashmika',
      trackIds: ['t5', 't6'],
      imageUrl: 'assets/images/pl_relaxing.png',
    ),
    Playlist(
      id: 'pl3',
      name: 'Workout',
      owner: 'Namal Rashmika',
      trackIds: ['t3', 't4'],
      imageUrl: 'assets/images/art_goku.png',
    ),
  ];

  /// Monitor tab — audience interest for the previous month.
  static const genreShares = <GenreShare>[
    GenreShare('Action', 30),
    GenreShare('Fantasy', 23),
    GenreShare('Adventure', 18),
    GenreShare('Romance', 15),
    GenreShare('Comedy', 9),
    GenreShare('Horror', 5),
  ];

  static const totalViews = '379,000';
  static const averageRating = 7.0;
}
