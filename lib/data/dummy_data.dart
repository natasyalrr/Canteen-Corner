import '../models/kantin_model.dart';
import '../models/menu_model.dart';

/// Data contoh, dipakai hanya selama koleksi `kantins` / `menus` di Firestore
/// masih kosong (lihat MenuService.pakaiDataContoh).
class DummyData {
  static const kantins = <KantinModel>[
    KantinModel(
      id: 'kantin-pusat',
      nama: 'Kantin Pusat',
      lokasi: 'Gedung Pusat',
      jamBuka: '07.00 - 16.00',
    ),
    KantinModel(
      id: 'kantin-fakultas-a',
      nama: 'Kantin Fakultas A',
      lokasi: 'Fakultas A',
      jamBuka: '08.00 - 15.00',
    ),
    KantinModel(
      id: 'kantin-fakultas-b',
      nama: 'Kantin Fakultas B',
      lokasi: 'Fakultas B',
      jamBuka: '08.00 - 14.00',
    ),
  ];

  static const menus = <MenuModel>[
    MenuModel(
      id: 'dummy-1',
      kantinId: 'kantin-pusat',
      nama: 'Nasi Goreng',
      harga: 15000,
      kategori: 'Makanan',
      stok: 20,
      deskripsi: 'Nasi goreng spesial dengan telur dan sayuran.',
    ),
    MenuModel(
      id: 'dummy-2',
      kantinId: 'kantin-pusat',
      nama: 'Mie Ayam',
      harga: 12000,
      kategori: 'Makanan',
      stok: 20,
      deskripsi: 'Mie ayam dengan topping ayam dan sayuran.',
    ),
    MenuModel(
      id: 'dummy-3',
      kantinId: 'kantin-fakultas-a',
      nama: 'Es Teh',
      harga: 5000,
      kategori: 'Minuman',
      stok: 50,
      deskripsi: 'Minuman teh segar.',
    ),
    MenuModel(
      id: 'dummy-4',
      kantinId: 'kantin-fakultas-b',
      nama: 'Kentang Goreng',
      harga: 10000,
      kategori: 'Snack',
      stok: 15,
      deskripsi: 'Kentang goreng renyah.',
    ),
    MenuModel(
      id: 'dummy-5',
      kantinId: 'kantin-fakultas-a',
      nama: 'Ayam Geprek',
      harga: 18000,
      kategori: 'Makanan',
      stok: 12,
      deskripsi: 'Ayam crispy dengan sambal pedas.',
    ),
    MenuModel(
      id: 'dummy-6',
      kantinId: 'kantin-fakultas-b',
      nama: 'Jus Alpukat',
      harga: 12000,
      kategori: 'Minuman',
      stok: 10,
      deskripsi: 'Jus alpukat segar.',
    ),
    MenuModel(
      id: 'dummy-7',
      kantinId: 'kantin-pusat',
      nama: 'Nasi Ayam',
      harga: 17000,
      kategori: 'Makanan',
      stok: 18,
      deskripsi: 'Nasi dengan ayam goreng dan sambal.',
    ),
    MenuModel(
      id: 'dummy-8',
      kantinId: 'kantin-fakultas-a',
      nama: 'Roti Bakar',
      harga: 10000,
      kategori: 'Snack',
      stok: 0,
      tersedia: false,
      deskripsi: 'Roti bakar dengan berbagai topping.',
    ),
    MenuModel(
      id: 'dummy-9',
      kantinId: 'kantin-fakultas-b',
      nama: 'Es Jeruk',
      harga: 6000,
      kategori: 'Minuman',
      stok: 30,
      deskripsi: 'Minuman jeruk segar.',
    ),
    MenuModel(
      id: 'dummy-10',
      kantinId: 'kantin-pusat',
      nama: 'Bakso',
      harga: 14000,
      kategori: 'Makanan',
      stok: 25,
      deskripsi: 'Bakso dengan kuah hangat.',
    ),
  ];
}
