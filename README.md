# Cocokin

Aplikasi mobile Personal Color Analysis & Rekomendasi Makeup untuk mata kuliah Implementasi dan Pengembangan Perangkat Lunak (IPPL).

## Navigasi Aplikasi (4 Tab Utama)
1. **Beranda** — Pengenalan aplikasi, ringkasan 3 langkah cara kerja, dan tombol cepat memulai analisis.
2. **Analisis** — Pengambilan foto wajah dari kamera HP, galeri HP, atau sampel uji untuk dianalisis menggunakan model AI.
3. **Produk** — Katalog rekomendasi produk makeup (Complexion, Lip Product, Blush, Eye Makeup) dengan filter kategori dan budget.
4. **Akun** — Informasi profil pengguna, aktivasi fitur **Akses Premium**, riwayat hasil analisis yang tersimpan, panduan cara kerja, dan informasi tentang aplikasi.

## Fitur Reguler vs Akses Premium
- **Akun Reguler (Gratis):**
  - Deteksi warna dasar kulit: **Skin Tone** (*Light, Medium, Deep*) dan **Undertone** (*Warm, Cool, Neutral*).
  - Menjelajahi katalog produk makeup umum.
- **Akses Premium:**
  - Membuka kunci hasil kategori **Personal Color** musiman (*Warm Autumn, Cool Summer, Warm Spring, Cool Winter*).
  - Membuka palet warna lengkap beserta deskripsi karakteristik kulit.
  - Dapat diaktifkan melalui kartu **Buka Kunci Personal Color** di halaman **Akun** atau langsung pada kartu yang terkunci di halaman **Hasil Analisis**.

## Struktur Kode (`lib/`)
### 1. Halaman Antarmuka (`lib/halaman/`)
- `lib/main.dart` — Navigasi utama aplikasi (4 tab bottom navigation bar)
- `lib/halaman/beranda_page.dart` — Halaman Beranda dan panduan Cara Kerja
- `lib/halaman/auth_page.dart` — Halaman Masuk & Daftar Akun
- `lib/halaman/kamera_page.dart` — Halaman Ambil Foto Wajah (mendukung Kamera HP & Galeri)
- `lib/halaman/loading_page.dart` — Halaman Proses Analisis Warna
- `lib/halaman/hasil_page.dart` — Halaman Hasil Analisis & Buka Kunci Premium
- `lib/halaman/riwayat_page.dart` — Halaman Riwayat Hasil Analisis
- `lib/halaman/rekomendasi_page.dart` — Halaman Rekomendasi Produk & Filter Budget
- `lib/halaman/detail_produk_page.dart` — Halaman Detail Produk, Shade, & Tautan E-Commerce
- `lib/halaman/profil_page.dart` — Halaman Akun, Status Premium, Riwayat, & Pengaturan

### 2. Backend & Service API (`lib/backend/`, `lib/services/`, `lib/models/`)
- `lib/backend/server.dart` — Server HTTP REST API utama & router
- `lib/backend/database_helper.dart` — Pengelola pembacaan & penyimpanan database JSON
- `lib/backend/auth_controller.dart` — Controller backend untuk login & registrasi
- `lib/backend/analysis_controller.dart` — Controller backend untuk analisis warna, riwayat, & fitur premium
- `lib/backend/product_controller.dart` — Controller backend untuk katalog produk, filter budget, & CRUD admin
- `lib/backend/db.json` — Database JSON lokal
- `lib/services/api_service.dart` — Penghubung HTTP client antara Flutter, Python AI Service, dan Supabase Cloud
- `lib/models/product_model.dart` — Model data produk & hasil analisis
