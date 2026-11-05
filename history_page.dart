import 'package:flutter/material.dart';
import 'music_state.dart';
import 'widgets.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final s = MusicState.instance;

    return ListenableBuilder(
      listenable: s,
      builder: (context, child) {
        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1100),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Text('History',
                          style: TextStyle(fontSize: 24,
                              fontWeight: FontWeight.bold)),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.delete_sweep),
                        tooltip: 'Hapus history',
                        onPressed: s.hapusHistory,
                      ),
                    ],
                  ),

                  // Riwayat disusun dari lagu terbaru ke lagu sebelumnya.
                  Expanded(
                    child: s.history.isEmpty
                        ? const Center(child: Text(
                        'Belum ada lagu yang diputar',
                        style: TextStyle(color: Colors.grey)))
                        : ListView.builder(
                      itemCount: s.history.length,
                      itemBuilder: (context, index) =>
                          itemList(context, s.history[index], s.history),
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
