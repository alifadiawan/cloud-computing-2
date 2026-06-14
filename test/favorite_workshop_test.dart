import 'package:flutter_test/flutter_test.dart';

// ===================================================================
// 1. MOCK SERVICE & MODEL
// (Simulasi logic penyimpanan favorit untuk keperluan Integration Test)
// ===================================================================

class Workshop {
  final String id;
  final String name;
  Workshop({required this.id, required this.name});
}

class FavoriteService {
  final List _favorites = [];

  List get favorites => _favorites;

  // Fungsi untuk menambahkan bengkel ke favorit (dengan proteksi duplikasi)
  void addFavorite(Workshop workshop) {
    if (!_favorites.any((w) => w.id == workshop.id)) {
      _favorites.add(workshop);
    }
  }

  // Fungsi untuk menghapus bengkel dari favorit
  void removeFavorite(String id) {
    _favorites.removeWhere((w) => w.id == id);
  }

  // Fungsi untuk mengecek status favorit
  bool isFavorite(String id) {
    return _favorites.any((w) => w.id == id);
  }
}

// ===================================================================
// 2. SKENARIO INTEGRATION TEST (MENDETAIL)
// ===================================================================

void main() {
  group('Integration Test: Manajemen State Bengkel Favorit', () {
    late FavoriteService favoriteService;
    late Workshop dummyWorkshop1;
    late Workshop dummyWorkshop2;

    // setUp() akan dieksekusi sebelum SETIAP test() dijalankan.
    // Ini memastikan setiap test memiliki 'state' yang bersih dan tidak saling mengganggu.
    setUp(() {
      favoriteService = FavoriteService();
      dummyWorkshop1 = Workshop(id: 'B001', name: 'REJEKI MOTOR 1');
      dummyWorkshop2 = Workshop(id: 'B002', name: 'RIZKY MOTOR');
    });

    test('Skenario 1: Inisialisasi awal, daftar favorit harus kosong', () {
      expect(favoriteService.favorites.isEmpty, true);
    });

    test('Skenario 2: Berhasil menambahkan bengkel ke daftar favorit', () {
      favoriteService.addFavorite(dummyWorkshop1);

      expect(favoriteService.favorites.length, 1);
      expect(favoriteService.isFavorite('B001'), true);
      expect(favoriteService.favorites.first.name, 'REJEKI MOTOR 1');
    });

    test('Skenario 3: Berhasil menghapus bengkel dari daftar favorit', () {
      // Tambahkan dua bengkel sekaligus
      favoriteService.addFavorite(dummyWorkshop1);
      favoriteService.addFavorite(dummyWorkshop2);

      // Hapus bengkel pertama
      favoriteService.removeFavorite('B001');

      // Verifikasi bahwa sisa 1 bengkel, dan bengkel pertama benar-benar terhapus
      expect(favoriteService.favorites.length, 1);
      expect(favoriteService.isFavorite('B001'), false);
      expect(favoriteService.isFavorite('B002'), true);
    });

    test('Skenario 4: Edge Case - Mencegah duplikasi data favorit', () {
      // Coba tambahkan bengkel yang sama dua kali
      favoriteService.addFavorite(dummyWorkshop1);
      favoriteService.addFavorite(dummyWorkshop1);

      // Verifikasi bahwa list tidak bertambah secara duplikat
      expect(
        favoriteService.favorites.length, 
        1, 
        reason: 'Jumlah list favorit tidak boleh bertambah jika ID bengkel sudah ada di dalam state',
      );
    });
  });
}
