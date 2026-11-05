import 'package:flutter/material.dart';
import 'music_state.dart';
import 'widgets.dart';
import 'home_page.dart';
import 'library_page.dart';
import 'history_page.dart';
import 'profile_page.dart';

void main() {
  runApp(const HearMeOutApp());
}

class HearMeOutApp extends StatelessWidget {
  const HearMeOutApp({super.key});

  @override
  Widget build(BuildContext context) {
    final s = MusicState.instance;

    // Tema aplikasi diperbarui ketika pengguna mengganti mode.
    return ListenableBuilder(
      listenable: s,
      builder: (context, child) {
        return MaterialApp(
          title: 'Hear Me Out',
          debugShowCheckedModeBanner: false,
          themeMode: s.isDarkMode ? ThemeMode.dark : ThemeMode.light,

          // Mode gelap: hitam dengan aksen pink pastel.
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            scaffoldBackgroundColor: const Color(0xFF080808),
            cardColor: const Color(0xFF181818),
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFFF8BBD0),
              secondary: Color(0xFFF8BBD0),
              surface: Color(0xFF181818),
            ),
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF080808),
              foregroundColor: Colors.white,
              elevation: 0,
            ),
          ),

          // Mode terang: krem pastel, bukan putih polos.
          theme: ThemeData(
            brightness: Brightness.light,
            scaffoldBackgroundColor: const Color(0xFFFFFBF8),
            cardColor: const Color(0xFFFFFFFF),
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFE879A3),
              secondary: Color(0xFFE879A3),
              surface: Color(0xFFFFF9F0),
            ),
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFFFFFBF8),
              foregroundColor: Color(0xFF302722),
              elevation: 0,
            ),
          ),
          home: const MyApp(),
        );
      },
    );
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final s = MusicState.instance;
  int halaman = 0;

  // Empat halaman utama aplikasi.
  final List<Widget> daftarHalaman = const [
    HomePage(), LibraryPage(), HistoryPage(), ProfilePage(),
  ];

  // Kembali ke Home dan memuat kembali Top 50.
  void keHome() {
    setState(() => halaman = 0);
    s.searchController.clear();
    s.muatTrending();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 16,
        title: InkWell(
          onTap: keHome,
          child: Text(
            'Hear Me Out',
            style: TextStyle(
              fontFamily: 'Georgia',
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
              fontSize: 35,
            ),
          ),
        ),
      ),

      // IndexedStack menjaga halaman tetap tersimpan saat berpindah tab.
      body: IndexedStack(index: halaman, children: daftarHalaman),

      // Mini player ditampilkan di atas navigasi bawah.
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const NowPlayingBar(),
          BottomNavigationBar(
            currentIndex: halaman,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            type: BottomNavigationBarType.fixed,
            selectedItemColor: Theme.of(context).colorScheme.primary,
            unselectedItemColor: Colors.grey,
            onTap: (index) => setState(() => halaman = index),
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.library_music), label: 'Library'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.history), label: 'History'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.person_outline), label: 'Profile'),
            ],
          ),
        ],
      ),
    );
  }
}
