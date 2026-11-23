# Data awal Firestore (kantins dan menus)

Mengisi koleksi `kantins` dan `menus` dengan data yang sama seperti
`lib/data/dummy_data.dart`, tetapi sungguhan di Firestore.

## Langkah

1. **Daftarkan akun penjual** lewat aplikasi (pilih peran *Pemilik Stan*); idealnya 3 akun, satu per kantin.
2. Buka Firebase Console > Authentication, salin **UID** akun tersebut.
3. Unduh kunci akses: Firebase Console > Project settings > Service accounts >
   *Generate new private key*. Simpan sebagai `tool/serviceAccountKey.json`.
   Berkas ini rahasia dan sudah diabaikan oleh `tool/.gitignore`. **Jangan di-commit.**
4. Jalankan (butuh Node.js 18+):

   ```
   cd tool
   npm install
   node seed_firestore.js --dry-run --owner=<UID>    # cek rencana dulu
   node seed_firestore.js --owner=<UID>               # tulis ke Firestore
   ```

   **Disarankan: satu akun penjual per kantin** (daftarkan 3 akun penjual), karena layar
   Kelola Menu saat ini mengelola satu kantin per akun:
   `--owner:kantin-pusat=<UID1> --owner:kantin-fakultas-a=<UID2> --owner:kantin-fakultas-b=<UID3>`.
   `--owner=<UID>` (satu akun untuk semua kantin) tetap bisa, tetapi skrip akan memberi peringatan.

5. Skrip melewati dokumen yang sudah ada. Tambahkan `--force` hanya jika ingin
   menimpa (stok yang sudah diubah penjual akan kembali ke nilai awal).
6. Setelah data muncul di Firestore Console, ubah
   `MenuService.pakaiDataContoh` di `lib/services/menu_service.dart` menjadi `false`.

Skrip memakai Firebase Admin SDK, sehingga **tidak terkena Security Rules**.
Itu sebabnya skrip hanya boleh dijalankan oleh anggota tim, bukan dimasukkan ke aplikasi.
