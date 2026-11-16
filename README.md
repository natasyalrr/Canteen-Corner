# 🍽️ CanteenCorner — Kantin Kampus Digital

**CanteenCorner** adalah aplikasi mobile berbasis Flutter dan Dart yang dirancang untuk memudahkan mahasiswa dalam melihat menu, mengetahui harga makanan dan minuman, melakukan pemesanan, serta memantau status pesanan di kantin kampus. Aplikasi ini juga membantu penjual kantin mengelola menu dan pesanan secara lebih terstruktur melalui sistem digital.

## 📌 Latar Belakang

Proses pemesanan makanan dan minuman di kantin kampus masih banyak dilakukan secara manual. Hal ini dapat menimbulkan beberapa permasalahan, seperti antrean panjang saat jam istirahat, informasi menu dan harga yang kurang transparan, kesalahan pencatatan pesanan, serta kesulitan penjual dalam mengelola pesanan yang masuk secara bersamaan.

CanteenCorner dikembangkan sebagai solusi digital agar mahasiswa dapat memesan makanan sebelum tiba di kantin, memilih metode pembayaran, dan memantau perkembangan pesanannya. Sementara itu, penjual dapat mengelola menu, menerima pesanan, serta memperbarui status pesanan melalui aplikasi.

## 🎯 Tujuan

1. Memudahkan mahasiswa melihat informasi menu, harga, dan ketersediaan makanan.
2. Mengurangi antrean dengan menyediakan pemesanan sebelum mahasiswa tiba di kantin.
3. Menyediakan pilihan metode pembayaran yang fleksibel.
4. Membantu penjual mengelola menu dan pesanan secara digital.
5. Menyediakan informasi status pesanan secara real-time.

## ✨ Fitur Utama

- **Autentikasi Pengguna:** Login dan registrasi menggunakan Firebase Authentication dengan peran mahasiswa dan penjual.
- **Katalog Menu:** Menampilkan daftar kantin dan menu makanan atau minuman beserta foto, harga, kategori, dan ketersediaan. Dilengkapi pencarian dan filter.
- **Keranjang dan Checkout:** Memungkinkan mahasiswa memilih beberapa menu, menambahkan catatan, menentukan tipe pesanan, dan memilih jam pengambilan.
- **Pembayaran Multi-Metode:** Menyediakan pilihan QRIS, e-wallet, transfer bank, dan tunai. Pembayaran pada tahap pengembangan dibuat dalam bentuk simulasi.
- **Status Pesanan Real-Time:** Mahasiswa dapat memantau status pembayaran dan perkembangan pesanan yang diperbarui melalui Firestore.
- **Dashboard Penjual:** Memungkinkan penjual mengelola menu, melihat pesanan masuk, mengonfirmasi pembayaran tunai, dan memperbarui status pesanan.
- **Riwayat Pesanan dan Ulasan:** Fitur tambahan yang direncanakan apabila waktu pengembangan memungkinkan.

## 🛠️ Teknologi yang Digunakan

| Teknologi | Kegunaan |
|---|---|
| Flutter | Framework pengembangan aplikasi mobile |
| Dart | Bahasa pemrograman |
| Firebase Authentication | Autentikasi pengguna |
| Cloud Firestore | Database penyimpanan dan pengelolaan data |

## 🗄️ Rancangan Database Firestore

Aplikasi menggunakan Firebase Cloud Firestore sebagai database utama dengan rancangan koleksi berikut:

| Koleksi | Field Utama |
|---|---|
| `users` | uid, nama, email, role, nim |
| `kantins` | nama, lokasi, jamBuka, ownerUid |
| `menus` | kantinId, nama, deskripsi, harga, kategori, stok, fotoUrl, tersedia |
| `orders` | userId, kantinId, items[], total, metodeBayar, statusBayar, statusOrder, kodePesanan, tipePesanan, jamAmbil, expiresAt, createdAt |

**Keterangan:**
- Data pesanan disimpan pada koleksi `orders`.
- Setiap pesanan dapat berisi beberapa item menu dalam satu transaksi.
- Informasi setiap item meliputi menuId, nama, harga, jumlah, dan catatan.
- Perubahan status pesanan menggunakan listener Firestore agar informasi dapat diperbarui secara real-time.
- Pembayaran tunai memiliki batas waktu 15 menit melalui field `expiresAt`.

## 👥 Pembagian Tugas Anggota

| Nama | Peran | Tanggung Jawab |
|---|---|---|
| Khoirul Lathifah Oktaviani | Frontend 1 | UI/UX, Login, Register, Home, Profile, dan navigasi |
| Zukhruf Na’ilah Rohmah | Frontend 2 | Katalog menu, detail menu, keranjang, checkout, dan riwayat pesanan |
| Natasya Luthfia Ramadhani | Backend 1 | Konfigurasi Firebase, Authentication, struktur Firestore, CRUD menu, dan data pengguna |
| Anisa Ramadhani | Backend 2 | CRUD pesanan, pengelolaan transaksi, update status pesanan, integrasi checkout, dan dashboard penjual |

## 📱 Alur Penggunaan Aplikasi

**Mahasiswa:**

Login → Beranda → Daftar Menu → Detail Menu → Keranjang → Checkout → Pembayaran → Status Pesanan → Selesai.

**Penjual:**

Login → Dashboard Penjual → Mengelola Menu → Melihat Pesanan Masuk → Konfirmasi Pembayaran → Memperbarui Status Pesanan.

## 🚧 Status Pengembangan

CanteenCorner dikembangkan secara bertahap selama empat minggu sebagai proyek mata kuliah Pemrograman Perangkat Bergerak.

Pengembangan meliputi tahap identifikasi masalah, perancangan antarmuka dan database, implementasi fitur, integrasi Firebase, pengujian, serta presentasi aplikasi.

Saat ini, pengembangan awal antarmuka dan persiapan model data sedang dilakukan. Fitur lainnya akan diimplementasikan dan diintegrasikan secara bertahap.

## ▶️ Menjalankan Proyek

Pastikan Flutter dan Dart sudah terpasang pada perangkat.

Clone repository:

```bash
git clone https://github.com/natasyalrr/Canteen-Corner.git
```

Masuk ke direktori proyek:

```bash
cd Canteen-Corner
```

Unduh dependensi:

```bash
flutter pub get
```

Jalankan aplikasi:

```bash
flutter run
```

Pastikan konfigurasi Firebase proyek sudah tersedia sebelum menjalankan fitur yang membutuhkan Firebase.

## 📚 Repository

Repository GitHub: [Canteen-Corner](https://github.com/natasyalrr/Canteen-Corner)

---

*Dikembangkan sebagai proyek kelompok mata kuliah Pemrograman Perangkat Bergerak.*
