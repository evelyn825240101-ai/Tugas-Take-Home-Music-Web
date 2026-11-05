
import 'package:flutter/material.dart';
import 'music_state.dart';
import 'song_model.dart';

// Mengubah durasi menjadi format menit:detik.
String formatDurasi(Duration d) {
  final menit = d.inMinutes.toString();
  final detik = (d.inSeconds % 60).toString().padLeft(2, '0');
  return '$menit:$detik';
}

// Menampilkan cover lagu dari URL artwork API.
Widget gambarLagu(Song song, double ukuran) {
  return Image.network(
    song.artworkUrl100,
    width: ukuran,
    height: ukuran,
    fit: BoxFit.cover,
    errorBuilder: (context, error, stack) => Container(
      width: ukuran,
      height: ukuran,
      color: Theme.of(context).cardColor,
      child: const Icon(Icons.music_note),
    ),
  );
}

// Cover playlist sederhana menggunakan ikon hati.
Widget coverHati(double ukuran, Color warna) {
  return Container(
    width: ukuran,
    height: ukuran,
    decoration: BoxDecoration(
      color: const Color(0xFFE8DCD0),
      borderRadius: BorderRadius.circular(6),
    ),
    child: Icon(Icons.favorite, color: warna, size: ukuran * 0.5),
  );
}

// Menampilkan satu lagu dalam format list.
Widget itemList(BuildContext context, Song song, List<Song> daftar) {
  final s = MusicState.instance;
  final aktif = s.lagu?.trackId == song.trackId;
  final aksen = Theme.of(context).colorScheme.primary;

  return ListTile(
    onTap: () => s.putarLagu(song, daftar),
    leading: ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: gambarLagu(song, 50),
    ),
    title: Text(
      song.trackName,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        color: aktif ? aksen : null,
        fontWeight: FontWeight.w600,
      ),
    ),
    subtitle: Text(
      song.artistName,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(color: Colors.grey),
    ),
    trailing: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.playlist_add, color: Colors.grey),
          onPressed: () => pilihPlaylist(context, song),
        ),
        IconButton(
          icon: Icon(
            s.isFavorite(song) ? Icons.favorite : Icons.favorite_border,
            color: s.isFavorite(song) ? aksen : Colors.grey,
          ),
          onPressed: () => s.toggleFavorite(song),
        ),
      ],
    ),
  );
}

// Menampilkan satu lagu dalam kartu grid untuk layar lebar.
Widget itemGrid(BuildContext context, Song song, List<Song> daftar) {
  final s = MusicState.instance;
  final aktif = s.lagu?.trackId == song.trackId;
  final aksen = Theme.of(context).colorScheme.primary;
  final cover = song.artworkUrl100.replaceAll('100x100', '300x300');

  return InkWell(
    onTap: () => s.putarLagu(song, daftar),
    borderRadius: BorderRadius.circular(8),
    child: Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Image.network(
                    cover,
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stack) => Container(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      child: const Center(
                        child: Icon(Icons.music_note),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.playlist_add,
                          color: Colors.white,
                        ),
                        onPressed: () => pilihPlaylist(context, song),
                      ),
                      IconButton(
                        icon: Icon(
                          s.isFavorite(song)
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: s.isFavorite(song)
                              ? aksen
                              : Colors.white,
                        ),
                        onPressed: () => s.toggleFavorite(song),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            song.trackName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: aktif ? aksen : null,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            song.artistName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 12,
            ),
          ),
        ],
      ),
    ),
  );
}

// Dialog untuk membuat playlist baru.
void dialogBuatPlaylist(BuildContext context) {
  final s = MusicState.instance;
  final controller = TextEditingController();

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Playlist Baru'),
      content: TextField(
        controller: controller,
        autofocus: true,
        decoration: const InputDecoration(
          hintText: 'Nama playlist',
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        TextButton(
          onPressed: () {
            final nama = controller.text.trim();

            if (nama.isEmpty) return;

            s.buatPlaylist(nama);
            Navigator.pop(context);
          },
          child: Text(
            'Buat',
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
      ],
    ),
  );
}

// Bottom sheet untuk memilih playlist tempat lagu akan disimpan.
void pilihPlaylist(BuildContext context, Song song) {
  final s = MusicState.instance;

  showModalBottomSheet(
    context: context,
    builder: (context) => ListenableBuilder(
      listenable: s,
      builder: (context, child) => ListView(
        shrinkWrap: true,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Tambah ke playlist',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ListTile(
            leading: Icon(
              Icons.add,
              color: Theme.of(context).colorScheme.primary,
            ),
            title: const Text('Playlist baru'),
            onTap: () => dialogBuatPlaylist(context),
          ),

          // Menampilkan seluruh playlist yang sudah dibuat.
          for (int i = 0; i < s.playlists.length; i++)
            ListTile(
              leading: coverHati(40, Colors.grey),
              title: Text(s.playlists[i].nama),
              trailing: s.adaDiPlaylist(i, song)
                  ? Icon(
                Icons.check_circle,
                color: Theme.of(context).colorScheme.primary,
              )
                  : const Icon(
                Icons.add_circle_outline,
                color: Colors.grey,
              ),
              onTap: () {
                // Mengecek apakah lagu sudah ada di playlist.
                final sudahAda = s.adaDiPlaylist(i, song);
                final namaPlaylist = s.playlists[i].nama;

                // Menambahkan atau menghapus lagu dari playlist.
                s.togglePlaylist(i, song);
                Navigator.pop(context);

                // Menampilkan notifikasi setelah playlist diperbarui.
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      sudahAda
                          ? 'Lagu dihapus dari $namaPlaylist'
                          : 'Lagu ditambahkan ke $namaPlaylist',
                    ),
                    duration: const Duration(seconds: 2),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            ),
        ],
      ),
    ),
  );
}

// Mini player untuk lagu yang sedang diputar.
class NowPlayingBar extends StatelessWidget {
  const NowPlayingBar({super.key});

  @override
  Widget build(BuildContext context) {
    final s = MusicState.instance;
    final aksen = Theme.of(context).colorScheme.primary;

    return ListenableBuilder(
      listenable: s,
      builder: (context, child) {
        if (s.lagu == null) return const SizedBox.shrink();

        final song = s.lagu!;
        final maxDurasi = s.durasi.inSeconds > 0
            ? s.durasi.inSeconds.toDouble()
            : 1.0;

        return InkWell(
          // Menekan mini player membuka halaman detail lagu.
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const NowPlayingPage(),
            ),
          ),
          child: Container(
            color: Theme.of(context).cardColor,
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: gambarLagu(song, 48),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            song.trackName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            song.artistName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      iconSize: 32,
                      icon: const Icon(Icons.skip_previous),
                      onPressed: () => s.lanjut(-1),
                    ),
                    IconButton(
                      iconSize: 44,
                      color: aksen,
                      icon: Icon(
                        s.isPlaying
                            ? Icons.pause_circle_filled
                            : Icons.play_circle_filled,
                      ),
                      onPressed: s.togglePlay,
                    ),
                    IconButton(
                      iconSize: 32,
                      icon: const Icon(Icons.skip_next),
                      onPressed: () => s.lanjut(1),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Text(
                      formatDurasi(s.posisi),
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                    Expanded(
                      child: Slider(
                        activeColor: aksen,
                        inactiveColor: Colors.grey,
                        max: maxDurasi,
                        value: s.posisi.inSeconds
                            .toDouble()
                            .clamp(0.0, maxDurasi)
                            .toDouble(),
                        onChanged: (value) => s.player.seek(
                          Duration(seconds: value.toInt()),
                        ),
                      ),
                    ),
                    Text(
                      formatDurasi(s.durasi),
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// Halaman pemutar layar penuh seperti tampilan Now Playing Spotify.
class NowPlayingPage extends StatelessWidget {
  const NowPlayingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final s = MusicState.instance;
    final aksen = Theme.of(context).colorScheme.primary;

    return ListenableBuilder(
      listenable: s,
      builder: (context, child) {
        final song = s.lagu;

        if (song == null) {
          return const Scaffold(
            body: Center(
              child: Text('Belum ada lagu yang diputar'),
            ),
          );
        }

        final maxDurasi = s.durasi.inSeconds > 0
            ? s.durasi.inSeconds.toDouble()
            : 1.0;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Now Playing'),
            centerTitle: true,
          ),

          // SingleChildScrollView membuat halaman bisa di-scroll.
          body: SafeArea(
            child: SingleChildScrollView(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 650),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    child: Column(
                      children: [
                        // Cover album dibatasi maksimal 300 px.
                        ConstrainedBox(
                          constraints: const BoxConstraints(
                            maxWidth: 300,
                          ),
                          child: AspectRatio(
                            aspectRatio: 1,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(18),
                              child: Image.network(
                                song.artworkUrl100.replaceAll(
                                  '100x100',
                                  '600x600',
                                ),
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stack) =>
                                    Container(
                                      color: Theme.of(context).cardColor,
                                      child: const Icon(
                                        Icons.music_note,
                                        size: 80,
                                      ),
                                    ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 28),

                        // Menampilkan judul, penyanyi, favorite, dan playlist.
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    song.trackName,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 23,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    song.artistName,
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              iconSize: 30,
                              icon: Icon(
                                s.isFavorite(song)
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: s.isFavorite(song)
                                    ? aksen
                                    : Colors.grey,
                              ),
                              onPressed: () => s.toggleFavorite(song),
                            ),
                            IconButton(
                              iconSize: 30,
                              icon: const Icon(Icons.playlist_add),
                              onPressed: () => pilihPlaylist(
                                context,
                                song,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 18),

                        // Progress bar untuk mengatur posisi lagu.
                        Slider(
                          activeColor: aksen,
                          inactiveColor: Colors.grey,
                          max: maxDurasi,
                          value: s.posisi.inSeconds
                              .toDouble()
                              .clamp(0.0, maxDurasi)
                              .toDouble(),
                          onChanged: (value) => s.player.seek(
                            Duration(seconds: value.toInt()),
                          ),
                        ),

                        Row(
                          mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              formatDurasi(s.posisi),
                              style: const TextStyle(
                                color: Colors.grey,
                              ),
                            ),
                            Text(
                              formatDurasi(s.durasi),
                              style: const TextStyle(
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 18),

                        // Tombol kontrol pemutar lagu.
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              iconSize: 38,
                              icon: const Icon(Icons.skip_previous),
                              onPressed: () => s.lanjut(-1),
                            ),
                            const SizedBox(width: 24),
                            IconButton(
                              iconSize: 68,
                              color: aksen,
                              icon: Icon(
                                s.isPlaying
                                    ? Icons.pause_circle_filled
                                    : Icons.play_circle_filled,
                              ),
                              onPressed: s.togglePlay,
                            ),
                            const SizedBox(width: 24),
                            IconButton(
                              iconSize: 38,
                              icon: const Icon(Icons.skip_next),
                              onPressed: () => s.lanjut(1),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        // Menampilkan genre lagu.
                        Text(
                          song.genre,
                          style: const TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
