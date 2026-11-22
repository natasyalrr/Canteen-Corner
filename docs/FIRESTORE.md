# Skema Firestore dan kontrak service

## Koleksi

| Koleksi | Field | Catatan |
|---|---|---|
| `users/{uid}` | uid, nama, email, role (`mahasiswa`/`penjual`), nim, createdAt | role tidak bisa diubah setelah dibuat |
| `kantins/{id}` | nama, lokasi, jamBuka, ownerUid | ownerUid = uid penjual pemilik |
| `menus/{id}` | kantinId, nama, harga, kategori, stok, fotoUrl, tersedia, deskripsi | kategori: Makanan, Minuman, Snack |
| `orders/{id}` | userId, kantinId, kantinNama, items[], total, metodeBayar, statusBayar, statusOrder, kodePesanan, tipePesanan, jamAmbil, expiresAt, createdAt | lihat `lib/models/order_model.dart` |

## Siapa boleh apa (ringkasan `firestore.rules`)

| Koleksi | Mahasiswa | Penjual |
|---|---|---|
| users | baca dan ubah dokumen sendiri | sama |
| kantins | baca | baca; ubah dan hapus hanya kantin miliknya |
| menus | baca | tambah, ubah, hapus hanya di kantin miliknya |
| orders | buat atas nama sendiri; baca pesanan sendiri; batal (sebelum diproses) atau tandai kedaluwarsa | baca pesanan kantin miliknya; ubah **hanya** `statusOrder` dan `statusBayar` |

Kalau butuh field baru di pesanan yang diubah penjual (mis. `diprosesAt`),
tambahkan namanya di `hasOnly([...])` pada fungsi `penjualMengubah` di `firestore.rules`.

## MenuService (`lib/services/menu_service.dart`)

| Method | Fungsi |
|---|---|
| `streamKantins()` / `streamMenus()` | Mahasiswa: baca katalog (data contoh jika kosong) |
| `streamKantinMilik(ownerUid)` | Penjual: kantin miliknya |
| `streamMenuKantin(kantinId)` | Penjual: menu satu kantin, tanpa data contoh |
| `tambahMenu(MenuModel)` | Tambah menu, mengembalikan id; `ArgumentError` jika tidak valid |
| `ubahMenu(MenuModel)` | Ubah semua field menu |
| `hapusMenu(id)` | Hapus menu |
| `setTersedia(id, bool)` | Tombol tersedia/tidak |
| `ubahStok(id, int)` | Ubah stok; stok 0 otomatis tidak tersedia |
| `kantinMilik(uid)` | Kantin pertama milik penjual (dipakai KelolaMenuScreen) |
| `streamMenusKantin(kantinId)` | Nama lain `streamMenuKantin` (dipakai KelolaMenuScreen) |
| `ubahTersedia(id, bool)` | Nama lain `setTersedia` (dipakai KelolaMenuScreen) |
| `MenuService.pesanKesalahan(MenuModel)` | Validasi untuk `validator` di form (null = valid) |
| `MenuService.kategoriMenu` | Daftar kategori untuk dropdown |

## Untuk sisi pesanan penjual

Kueri pesanan penjual harus memakai `where('kantinId', isEqualTo: kantinId)`
(jangan mengambil semua pesanan lalu menyaring di aplikasi), karena aturan
membaca pesanan dicek per kantin.
