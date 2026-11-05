import 'dart:async';
import 'package:flutter/material.dart';
import 'music_state.dart';
import 'widgets.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final s = MusicState.instance;
  final namaController = TextEditingController();

  bool editNama = false;
  bool fotoDipilih = false;
  int likes = 10;
  bool showPlusOne = false;
  Timer? likeTimer;

  @override
  void initState() {
    super.initState();
    // Mengisi nama awal dari data yang tersimpan.
    namaController.text = s.profileName;
  }

  @override
  void dispose() {
    namaController.dispose();
    likeTimer?.cancel();
    super.dispose();
  }

  // Double tap foto profil menambah jumlah like dan menampilkan animasi +1.
  void handleDoubleTapLike() {
    setState(() {
      likes++;
      showPlusOne = true;
    });
    likeTimer?.cancel();
    likeTimer = Timer(const Duration(seconds: 1), () {
      if (mounted) setState(() => showPlusOne = false);
    });
  }

  // Menyimpan nama baru melalui MusicState dan SharedPreferences.
  void simpanNama() {
    s.simpanNama(namaController.text);
    setState(() => editNama = false);
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final aksen = Theme.of(context).colorScheme.primary;
    final kartu = Theme.of(context).cardColor;

    return ListenableBuilder(
      listenable: s,
      builder: (context, child) {
        if (!editNama && namaController.text != s.profileName) {
          namaController.text = s.profileName;
        }

        return SafeArea(
          child: SingleChildScrollView(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1000),
                child: Container(
                  width: double.infinity,
                  margin: const EdgeInsets.all(20),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: kartu,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: LayoutBuilder(
                    builder: (context, ukuran) {
                      final isSmallWidth = ukuran.maxWidth < 600;

                      // Foto profil memakai CircleAvatar dan GestureDetector
                      // seperti contoh profile pada PDF.
                      final avatar = GestureDetector(
                        onTap: () => setState(
                                () => fotoDipilih = !fotoDipilih),
                        onDoubleTap: handleDoubleTapLike,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: fotoDipilih ? aksen : Colors.transparent,
                                  width: 5,
                                ),
                              ),
                              child: const CircleAvatar(
                                radius: 65,
                                backgroundImage: AssetImage('swag.jpeg'),
                              ),
                            ),
                            if (showPlusOne)
                              const Text('+1',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 36,
                                    fontWeight: FontWeight.bold,
                                    shadows: [Shadow(
                                        color: Colors.black54, blurRadius: 8)],
                                  )),
                          ],
                        ),
                      );

                      // Nama dapat diedit dan disimpan dengan ikon centang.
                      final detailNama = Column(
                        crossAxisAlignment: isSmallWidth
                            ? CrossAxisAlignment.center
                            : CrossAxisAlignment.start,
                        children: [
                          if (editNama)
                            SizedBox(
                              width: 260,
                              child: TextField(
                                controller: namaController,
                                autofocus: true,
                                textAlign: isSmallWidth
                                    ? TextAlign.center : TextAlign.start,
                                decoration: InputDecoration(
                                  hintText: 'Masukkan nama',
                                  isDense: true,
                                  suffixIcon: IconButton(
                                    icon: const Icon(Icons.check),
                                    onPressed: simpanNama,
                                  ),
                                ),
                                onSubmitted: (_) => simpanNama(),
                              ),
                            )
                          else
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Flexible(
                                  child: Text(s.profileName,
                                      style: const TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold)),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.edit, size: 18),
                                  onPressed: () => setState(
                                          () => editNama = true),
                                ),
                              ],
                            ),
                          const Text('Music enthusiast',
                              style: TextStyle(color: Colors.grey)),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: isSmallWidth
                                ? MainAxisAlignment.center
                                : MainAxisAlignment.start,
                            children: [
                              Icon(Icons.headphones, size: 16, color: aksen),
                              const SizedBox(width: 5),
                              const Text('Hear Me Out member',
                                  style: TextStyle(color: Colors.grey)),
                            ],
                          ),
                        ],
                      );

                      // Tiga statistik utama berada dalam satu baris.
                      final statistik = Row(
                        children: [
                          Expanded(child: kotakStatistik(
                              context, s.totalPlayed, 'Lagu Didengar',
                              Icons.headphones)),
                          const SizedBox(width: 8),
                          Expanded(child: kotakStatistik(
                              context, s.playlists.length, 'Playlist',
                              Icons.library_music)),
                          const SizedBox(width: 8),
                          Expanded(child: kotakStatistik(
                              context, s.favorite.length, 'Favorite',
                              Icons.favorite)),
                        ],
                      );

                      // Layout berubah dari vertikal ke horizontal sesuai lebar.
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('My Profile',
                              style: TextStyle(fontSize: 22,
                                  fontWeight: FontWeight.bold)),
                          const SizedBox(height: 22),
                          if (isSmallWidth) ...[
                            Center(child: avatar),
                            const SizedBox(height: 14),
                            Center(child: detailNama),
                          ] else
                            Row(
                              children: [
                                avatar,
                                const SizedBox(width: 22),
                                Expanded(child: detailNama),
                              ],
                            ),
                          const SizedBox(height: 10),
                          Center(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.favorite, color: aksen, size: 18),
                                const SizedBox(width: 6),
                                Text('$likes likes',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ),
                          const SizedBox(height: 22),
                          statistik,
                          const SizedBox(height: 24),
                          const Text('Your Music Activity',
                              style: TextStyle(fontSize: 18,
                                  fontWeight: FontWeight.bold)),
                          const SizedBox(height: 10),

                          // Informasi tambahan terkait aktivitas musik.
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: Icon(Icons.history, color: aksen),
                            title: const Text('Total lagu unik di history'),
                            trailing: Text('${s.history.length}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                          ),
                          const Divider(height: 1),
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: Icon(Icons.music_note, color: aksen),
                            title: const Text('Genre yang tersedia'),
                            trailing: Text(
                                '${s.songs.map((e) => e.genre).toSet().length}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                          ),
                          const Divider(height: 1),
                          SwitchListTile(
                            contentPadding: EdgeInsets.zero,
                            secondary: Icon(
                                s.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                                color: aksen),
                            title: const Text('Dark Mode'),
                            subtitle: const Text('Ubah tampilan aplikasi',
                                style: TextStyle(color: Colors.grey)),
                            value: s.isDarkMode,
                            activeColor: aksen,
                            onChanged: s.ubahTema,
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // Widget statistik agar ketiga kotak memiliki tampilan seragam.
  Widget kotakStatistik(
      BuildContext context, int jumlah, String label, IconData ikon) {
    final aksen = Theme.of(context).colorScheme.primary;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 5),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(ikon, color: aksen, size: 23),
          const SizedBox(height: 8),
          Text('$jumlah', style: const TextStyle(
              fontSize: 21, fontWeight: FontWeight.bold)),
          const SizedBox(height: 3),
          Text(label, textAlign: TextAlign.center, maxLines: 2,
              style: const TextStyle(color: Colors.grey, fontSize: 11)),
        ],
      ),
    );
  }
}

// Menampilkan ikon pengganti jika foto assets belum tersedia.
Widget gambarGagal(BuildContext context, Object error, StackTrace? stack) {
  return const SizedBox(
    width: 125,
    height: 125,
    child: Icon(Icons.person, size: 65, color: Colors.white),
  );
}
