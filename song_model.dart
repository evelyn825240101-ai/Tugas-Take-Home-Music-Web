// Model data lagu dari API iTunes.
class Song {
  final int? trackId;
  final String trackName, artistName, artworkUrl100, previewUrl, genre;
  final int trackTimeMillis;

  const Song({
    this.trackId,
    required this.trackName,
    required this.artistName,
    required this.artworkUrl100,
    required this.previewUrl,
    required this.genre,
    required this.trackTimeMillis,
  });

  // Parsing JSON dilakukan terpisah agar mudah digunakan di seluruh aplikasi.
  factory Song.fromJson(Map<String, dynamic> json) {
    return Song(
      trackId: json['trackId'] is int ? json['trackId'] : null,
      trackName: json['trackName']?.toString() ?? '-',
      artistName: json['artistName']?.toString() ?? '-',
      artworkUrl100: json['artworkUrl100']?.toString() ?? '',
      previewUrl: json['previewUrl']?.toString() ?? '',
      genre: json['primaryGenreName']?.toString() ?? 'Other',
      trackTimeMillis: json['trackTimeMillis'] is int
          ? json['trackTimeMillis'] : 0,
    );
  }

  // Mengubah model menjadi JSON untuk penyimpanan lokal.
  Map<String, dynamic> toJson() => {
    'trackId': trackId,
    'trackName': trackName,
    'artistName': artistName,
    'artworkUrl100': artworkUrl100,
    'previewUrl': previewUrl,
    'primaryGenreName': genre,
    'trackTimeMillis': trackTimeMillis,
  };
}

// Model playlist berisi nama playlist dan daftar lagu.
class Playlist {
  String nama;
  List<Song> lagu;

  Playlist({required this.nama, List<Song>? lagu}) : lagu = lagu ?? [];

  factory Playlist.fromJson(Map<String, dynamic> json) {
    final data = json['lagu'] as List? ?? [];
    return Playlist(
      nama: json['nama']?.toString() ?? 'Playlist Baru',
      lagu: data.map((e) =>
          Song.fromJson(Map<String, dynamic>.from(e))).toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'nama': nama,
    'lagu': lagu.map((e) => e.toJson()).toList(),
  };
}
