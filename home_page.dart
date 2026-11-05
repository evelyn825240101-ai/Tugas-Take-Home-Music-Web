import 'package:flutter/material.dart';
import 'music_state.dart';
import 'widgets.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final s = MusicState.instance;
    final aksen = Theme.of(context).colorScheme.primary;

    return ListenableBuilder(
      listenable: s,
      builder: (context, child) {
        final daftar = s.songs;

        // Mengambil genre unik dari data API untuk pilihan filter.
        // Filter sederhana agar pilihan genre tidak terlalu banyak.
        final tampil = s.selectedGenre == 'Semua'
            ? daftar
            : daftar.where((e) {
          final genre = e.genre.toLowerCase();
          if (s.selectedGenre == 'Pop') return genre.contains('pop');
          if (s.selectedGenre == 'Rock') return genre.contains('rock');
          if (s.selectedGenre == 'R&B') {
            return genre.contains('r&b') || genre.contains('soul');
          }
          return !genre.contains('pop') &&
              !genre.contains('rock') &&
              !genre.contains('r&b') &&
              !genre.contains('soul');
        }).toList();

        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1400),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Tombol panah berada di ujung kanan kotak pencarian.
                  TextField(
                    controller: s.searchController,
                    // Enter pada keyboard menjalankan pencarian.
                    textInputAction: TextInputAction.search,
                    onSubmitted: (_) => s.cariLagu(),
                    decoration: InputDecoration(
                      hintText: 'Search',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.arrow_forward),
                        onPressed: s.cariLagu,
                      ),
                      filled: true,
                      fillColor: Theme.of(context).cardColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Judul daftar dan pengaturan Auto Play.
                  Row(
                    children: [
                      Expanded(
                        child: Text(s.judulDaftar,
                            style: const TextStyle(
                                fontSize: 22, fontWeight: FontWeight.bold)),
                      ),
                      const Text('Auto Play',
                          style: TextStyle(color: Colors.grey, fontSize: 12)),
                      Switch(
                        value: s.autoPlay,
                        activeColor: aksen,
                        onChanged: (value) {
                          s.autoPlay = value;
                          s.notifyListeners();
                        },
                      ),
                    ],
                  ),

                  // Filter genre terletak tepat di bawah judul Top 50 Global.
                  SizedBox(
                    height: 42,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        filterGenre(context, s, 'Semua'),
                        filterGenre(context, s, 'Pop'),
                        filterGenre(context, s, 'Rock'),
                        filterGenre(context, s, 'R&B'),
                        filterGenre(context, s, 'Lainnya'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Daftar berubah menjadi grid saat layar cukup lebar.
                  Expanded(
                    child: s.isLoading && daftar.isEmpty
                        ? Center(child: CircularProgressIndicator(color: aksen))
                        : tampil.isEmpty
                        ? const Center(
                        child: Text('Tidak ada lagu untuk ditampilkan',
                            style: TextStyle(color: Colors.grey)))
                        : LayoutBuilder(
                      builder: (context, ukuran) {
                        if (ukuran.maxWidth >= 650) {
                          return GridView.builder(
                            itemCount: tampil.length,
                            gridDelegate:
                            const SliverGridDelegateWithMaxCrossAxisExtent(
                              maxCrossAxisExtent: 230,
                              childAspectRatio: 0.78,
                              crossAxisSpacing: 14,
                              mainAxisSpacing: 14,
                            ),
                            itemBuilder: (context, index) =>
                                itemGrid(context, tampil[index], tampil),
                          );
                        }
                        return ListView.builder(
                          itemCount: tampil.length,
                          itemBuilder: (context, index) =>
                              itemList(context, tampil[index], tampil),
                        );
                      },
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

  // Chip untuk memilih genre lagu.
  Widget filterGenre(BuildContext context, MusicState s, String genre) {
    final dipilih = s.selectedGenre == genre;
    final aksen = Theme.of(context).colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(genre),
        selected: dipilih,
        onSelected: (_) => s.pilihGenre(genre),
        selectedColor: aksen,
        backgroundColor: Theme.of(context).cardColor,
        labelStyle: TextStyle(
          color: dipilih
              ? (Theme.of(context).brightness == Brightness.dark
              ? Colors.black : Colors.white)
              : Theme.of(context).textTheme.bodyMedium?.color,
          fontWeight: dipilih ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }
}
