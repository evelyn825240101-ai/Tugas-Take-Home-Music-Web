import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'song_model.dart';

// Daftar lagu yang menjadi sumber data Top 50 Global.
final List<List<String>> top50 = [
  ['Housewife', 'Tate McRae'], ['BbY WOW', 'KAROL G'],
  ['Nicole Kidman', 'ADÉLA'], ['Stop The Wedding!', 'Ashe'],
  ["Ain't In LA", 'ADÉLA'], ['the cure', 'Olivia Rodrigo'],
  ['Thriller', 'Michael Jackson'], ['back to friends', 'sombr'],
  ['Beauty And A Beat', 'Justin Bieber'], ['Pós - Ao Vivo', 'Felipe e Rodrigo'],
  ['Die With A Smile', 'Lady Gaga'], ['The One That Got Away', 'Katy Perry'],
  ['Earrings', 'Malcolm Todd'], ['Iris', 'Goo Goo Dolls'],
  ['Just Give Me a Reason', 'P!nk'], ['Billie Jean', 'Michael Jackson'],
  ['Sweater Weather', 'The Neighbourhood'], ['Ghostbusters', 'Ray Parker Jr.'],
  ['End of Beginning', 'Djo'], ['Love Me Not', 'Ravyn Lenae'],
  ['stupid song', 'Olivia Rodrigo'], ['Babydoll', 'Jamie Miller'],
  ['Self Aware', 'Temper City'], ['Great Expectation', 'SIENNA SPIRO'],
  ['Suzuki', 'Fuerza Regida'], ['Alfaaz', 'Hamza Malik'],
  ['Loser', 'Tame Impala'], ['Babydoll', 'Dominic Fike'],
  ['Postinho de Gasolina', 'João Gustavo e Murilo'], ['Man I Need', 'Olivia Dean'],
  ['SWIM', 'BTS'], ['All I Want for Christmas Is You', 'Mariah Carey'],
  ["Choosin' Texas", 'Ella Langley'], ['Treat You Better', 'Shawn Mendes'],
  ['Creep', 'Radiohead'], ['Mr. Brightside', 'The Killers'],
  ['BIRDS OF A FEATHER', 'Billie Eilish'], ['One Of The Girls', 'The Weeknd'],
  ['Beat It', 'Michael Jackson'], ['Last Christmas', 'Wham!'],
  ['This Is Halloween', 'The Citizens of Halloween'], ['Sailor Song', 'Gigi Perez'],
  ['Sign of the Times', 'Harry Styles'], ['Every Breath You Take', 'The Police'],
  ['Ordinary', 'Alex Warren'], ['I Wanna Be Yours', 'Arctic Monkeys'],
  ['hate that i made you love me', 'Ariana Grande'], ['Animal', 'KATSEYE'],
  ['Cinderella', 'Mac Miller'], ['Dai Dai', 'Shakira'],
];

class MusicState extends ChangeNotifier {
  // Singleton agar semua halaman memakai satu sumber data.
  static final MusicState instance = MusicState._();

  MusicState._() {
    muatData();
    muatTrending();

    // Mendengarkan perubahan status audio dari AudioPlayer.
    player.onPlayerStateChanged.listen((state) {
      isPlaying = state == PlayerState.playing;
      notifyListeners();
    });
    player.onPositionChanged.listen((value) {
      posisi = value;
      notifyListeners();
    });
    player.onDurationChanged.listen((value) {
      durasi = value;
      notifyListeners();
    });
    player.onPlayerComplete.listen((_) {
      posisi = Duration.zero;
      notifyListeners();
      if (autoPlay) lanjut(1);
    });
  }

  final searchController = TextEditingController();
  final player = AudioPlayer();

  List<Song> songs = [];
  List<Song> favorite = [];
  List<Playlist> playlists = [];
  List<Song> history = [];
  List<Song> antrian = [];
  Song? lagu;

  bool isLoading = false;
  bool isPlaying = false;
  bool autoPlay = true;
  bool isDarkMode = true;

  String judulDaftar = 'Top 50 Global';
  String selectedGenre = 'Semua';
  String profileName = 'Music Lover';

  int totalPlayed = 0;
  Duration posisi = Duration.zero;
  Duration durasi = Duration.zero;

  // Memuat data pengguna yang sebelumnya disimpan di perangkat.
  Future<void> muatData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final fav = prefs.getString('favorite');
      final play = prefs.getString('playlists');
      final hist = prefs.getString('history');

      if (fav != null) {
        favorite = (jsonDecode(fav) as List).map((e) =>
            Song.fromJson(Map<String, dynamic>.from(e))).toList();
      }
      if (play != null) {
        playlists = (jsonDecode(play) as List).map((e) =>
            Playlist.fromJson(Map<String, dynamic>.from(e))).toList();
      }
      if (hist != null) {
        history = (jsonDecode(hist) as List).map((e) =>
            Song.fromJson(Map<String, dynamic>.from(e))).toList();
      }

      profileName = prefs.getString('profileName') ?? 'Music Lover';
      totalPlayed = prefs.getInt('totalPlayed') ?? 0;
      isDarkMode = prefs.getBool('isDarkMode') ?? true;
      notifyListeners();
    } catch (e) {
      debugPrint('Gagal memuat data: $e');
    }
  }

  // Menyimpan daftar lagu ke SharedPreferences dalam format JSON.
  Future<void> simpanLagu(String key, List<Song> data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(key,
          jsonEncode(data.map((e) => e.toJson()).toList()));
    } catch (e) {
      debugPrint('Gagal menyimpan $key: $e');
    }
  }

  // Menyimpan playlist dan data pengaturan pengguna.
  Future<void> simpanPlaylist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('playlists',
          jsonEncode(playlists.map((e) => e.toJson()).toList()));
    } catch (e) {
      debugPrint('Gagal menyimpan playlist: $e');
    }
  }

  Future<void> simpanPengaturan() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('profileName', profileName);
      await prefs.setInt('totalPlayed', totalPlayed);
      await prefs.setBool('isDarkMode', isDarkMode);
    } catch (e) {
      debugPrint('Gagal menyimpan pengaturan: $e');
    }
  }

  // Mengambil satu lagu dari API dan memeriksa status HTTP serta error.
  Future<Song?> ambilSatuLagu(String judul, String artis) async {
    try {
      final url = Uri.https('itunes.apple.com', '/search', {
        'term': '$judul $artis', 'limit': '1', 'entity': 'song',
      });
      final response = await http.get(url).timeout(
          const Duration(seconds: 15));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final hasil = data['results'] as List? ?? [];
        if (hasil.isNotEmpty) {
          return Song.fromJson(Map<String, dynamic>.from(hasil.first));
        }
      } else {
        debugPrint('HTTP ${response.statusCode}: $judul');
      }
    } catch (e) {
      debugPrint('Error mengambil lagu $judul: $e');
    }
    return null;
  }

  // Mengambil Top 50 dengan cache dan kelompok request kecil.
  Future<void> muatTrending() async {
    isLoading = true;
    judulDaftar = 'Top 50 Global';
    selectedGenre = 'Semua';
    songs = [];
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final cache = prefs.getString('top50_v2');
      if (cache != null) {
        songs = (jsonDecode(cache) as List).map((e) =>
            Song.fromJson(Map<String, dynamic>.from(e))).toList();
      } else {
        for (int awal = 0; awal < top50.length; awal += 5) {
          final akhir = awal + 5 < top50.length ? awal + 5 : top50.length;
          final kelompok = top50.sublist(awal, akhir);
          final hasil = await Future.wait(kelompok.map(
                  (e) => ambilSatuLagu(e[0], e[1])));
          songs.addAll(hasil.whereType<Song>());
          notifyListeners();
        }
        if (songs.isNotEmpty) {
          await prefs.setString('top50_v2',
              jsonEncode(songs.map((e) => e.toJson()).toList()));
        }
      }
    } catch (e) {
      debugPrint('Gagal memuat Top 50: $e');
    }
    isLoading = false;
    notifyListeners();
  }

  // Mencari lagu berdasarkan judul atau nama artis.
  Future<void> cariLagu() async {
    final kata = searchController.text.trim();
    if (kata.isEmpty) return;

    isLoading = true;
    judulDaftar = 'Hasil Pencarian';
    selectedGenre = 'Semua';
    notifyListeners();

    try {
      final url = Uri.https('itunes.apple.com', '/search', {
        'term': kata, 'limit': '20', 'entity': 'song',
      });
      final response = await http.get(url).timeout(
          const Duration(seconds: 15));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final hasil = data['results'] as List? ?? [];
        songs = hasil.map((e) =>
            Song.fromJson(Map<String, dynamic>.from(e))).toList();
      } else {
        debugPrint('HTTP pencarian: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Pencarian gagal: $e');
    }
    isLoading = false;
    notifyListeners();
  }

  // Mengatur genre yang sedang dipilih pada Home.
  void pilihGenre(String genre) {
    selectedGenre = genre;
    notifyListeners();
  }

  // Mengubah tema aplikasi dan menyimpan pilihan tersebut.
  void ubahTema(bool value) {
    isDarkMode = value;
    simpanPengaturan();
    notifyListeners();
  }

  // Menyimpan nama yang diedit pada halaman Profile.
  void simpanNama(String nama) {
    if (nama.trim().isEmpty) return;
    profileName = nama.trim();
    simpanPengaturan();
    notifyListeners();
  }

  // Memutar lagu baru atau mengubah play/pause jika lagu sama dipilih.
  Future<void> putarLagu(Song song, List<Song> daftar) async {
    if (song.previewUrl.isEmpty) return;
    if (lagu != null && lagu!.trackId == song.trackId) {
      await togglePlay();
      return;
    }
    antrian = List.from(daftar);
    await mulaiLagu(song);
  }

  // Memulai lagu, menambah total pemutaran, dan memperbarui history.
  Future<void> mulaiLagu(Song song) async {
    if (song.previewUrl.isEmpty) return;
    lagu = song;
    posisi = Duration.zero;
    totalPlayed++;

    history.removeWhere((e) => e.trackId == song.trackId);
    history.insert(0, song);
    if (history.length > 50) history = history.sublist(0, 50);

    simpanLagu('history', history);
    simpanPengaturan();
    notifyListeners();

    try {
      await player.play(UrlSource(song.previewUrl));
    } catch (e) {
      debugPrint('Gagal memutar lagu: $e');
    }
  }

  // Memutar lagu sebelum atau sesudah lagu yang sedang berjalan.
  Future<void> lanjut(int arah) async {
    if (antrian.isEmpty || lagu == null) return;
    final index = antrian.indexWhere((e) => e.trackId == lagu!.trackId);
    if (index == -1) return;

    for (int i = 1; i <= antrian.length; i++) {
      final nomor = (index + arah * i) % antrian.length;
      final aman = nomor < 0 ? nomor + antrian.length : nomor;
      if (antrian[aman].previewUrl.isNotEmpty) {
        await mulaiLagu(antrian[aman]);
        return;
      }
    }
  }

  // Mengontrol play, pause, dan resume audio.
  Future<void> togglePlay() async {
    if (lagu == null) return;
    try {
      if (isPlaying) {
        await player.pause();
      } else if (player.state == PlayerState.completed) {
        await player.play(UrlSource(lagu!.previewUrl));
      } else {
        await player.resume();
      }
    } catch (e) {
      debugPrint('Kontrol audio gagal: $e');
    }
  }

  // Mengecek apakah lagu sudah menjadi favorite.
  bool isFavorite(Song song) =>
      favorite.any((e) => e.trackId == song.trackId);

  // Menambah atau menghapus lagu dari favorite.
  void toggleFavorite(Song song) {
    if (isFavorite(song)) {
      favorite.removeWhere((e) => e.trackId == song.trackId);
    } else {
      favorite.add(song);
    }
    simpanLagu('favorite', favorite);
    notifyListeners();
  }

  // Membuat playlist baru.
  void buatPlaylist(String nama) {
    playlists.add(Playlist(nama: nama));
    simpanPlaylist();
    notifyListeners();
  }

  // Menghapus playlist berdasarkan index.
  void hapusPlaylist(int index) {
    if (index < 0 || index >= playlists.length) return;
    playlists.removeAt(index);
    simpanPlaylist();
    notifyListeners();
  }

  // Memeriksa keberadaan lagu di playlist.
  bool adaDiPlaylist(int index, Song song) {
    if (index < 0 || index >= playlists.length) return false;
    return playlists[index].lagu.any((e) => e.trackId == song.trackId);
  }

  // Menambah atau menghapus lagu dari playlist.
  void togglePlaylist(int index, Song song) {
    if (index < 0 || index >= playlists.length) return;
    final daftar = playlists[index].lagu;
    if (adaDiPlaylist(index, song)) {
      daftar.removeWhere((e) => e.trackId == song.trackId);
    } else {
      daftar.add(song);
    }
    simpanPlaylist();
    notifyListeners();
  }

  // Menghapus seluruh daftar history.
  void hapusHistory() {
    history = [];
    simpanLagu('history', history);
    notifyListeners();
  }
}
