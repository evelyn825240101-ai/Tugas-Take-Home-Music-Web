import 'package:flutter/material.dart';
import 'music_state.dart';
import 'song_model.dart';
import 'widgets.dart';

class LibraryPage extends StatelessWidget {
  const LibraryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final s = MusicState.instance;

    return ListenableBuilder(
      listenable: s,
      builder: (context, child) {
        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Text('Library',
                          style: TextStyle(fontSize: 24,
                              fontWeight: FontWeight.bold)),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () => dialogBuatPlaylist(context),
                      ),
                    ],
                  ),

                  // Daftar Lagu Favorite dan playlist milik pengguna.
                  Expanded(
                    child: ListView(
                      children: [
                        ListTile(
                          leading: coverHati(56,
                              Theme.of(context).colorScheme.primary),
                          title: const Text('Lagu Favorite',
                              style: TextStyle(fontWeight: FontWeight.w600)),
                          subtitle: Text('Playlist • ${s.favorite.length} lagu',
                              style: const TextStyle(color: Colors.grey)),
                          onTap: () => Navigator.push(context,
                              MaterialPageRoute(builder: (context) =>
                              const DetailPlaylistPage(index: -1))),
                        ),
                        for (int i = 0; i < s.playlists.length; i++)
                          ListTile(
                            leading: coverHati(56, Colors.grey),
                            title: Text(s.playlists[i].nama,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600)),
                            subtitle: Text(
                                'Playlist • ${s.playlists[i].lagu.length} lagu',
                                style: const TextStyle(color: Colors.grey)),
                            onTap: () => Navigator.push(context,
                                MaterialPageRoute(builder: (context) =>
                                    DetailPlaylistPage(index: i))),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// Halaman isi playlist. Index -1 berarti halaman Lagu Favorite.
class DetailPlaylistPage extends StatelessWidget {
  final int index;
  const DetailPlaylistPage({super.key, required this.index});

  @override
  Widget build(BuildContext context) {
    final s = MusicState.instance;

    return ListenableBuilder(
      listenable: s,
      builder: (context, child) {
        // Memeriksa index agar tidak mengakses playlist yang sudah dihapus.
        if (index != -1 && index >= s.playlists.length) {
          return const Scaffold();
        }

        final nama = index == -1 ? 'Lagu Favorite' : s.playlists[index].nama;
        final daftar = index == -1 ? s.favorite : s.playlists[index].lagu;

        return Scaffold(
          appBar: AppBar(
            actions: [
              if (index != -1)
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () {
                    Navigator.pop(context);
                    s.hapusPlaylist(index);
                  },
                ),
            ],
          ),
          body: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1100),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    coverHati(140, index == -1
                        ? Theme.of(context).colorScheme.primary : Colors.grey),
                    const SizedBox(height: 12),
                    Text(nama, style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.bold)),
                    Text('${daftar.length} lagu',
                        style: const TextStyle(color: Colors.grey)),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: daftar.isEmpty ? null
                          : () => s.putarLagu(daftar.first, daftar),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor:
                        Theme.of(context).brightness == Brightness.dark
                            ? Colors.black : Colors.white,
                      ),
                      child: const Text('Putar Semua',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    Expanded(
                      child: daftar.isEmpty
                          ? const Center(child: Text('Belum ada lagu',
                          style: TextStyle(color: Colors.grey)))
                          : ListView.builder(
                        itemCount: daftar.length,
                        itemBuilder: (context, i) =>
                            itemList(context, daftar[i], daftar),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          bottomNavigationBar: const NowPlayingBar(),
        );
      },
    );
  }
}
