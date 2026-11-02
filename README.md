# Cocokin

Aplikasi mobile Personal Color Analysis & Rekomendasi Makeup untuk mata kuliah Implementasi dan Pengembangan Perangkat Lunak (IPPL).

## Struktur Kode (`lib/`)
### 1. Halaman Antarmuka (`lib/halaman/`)
- `lib/main.dart` — Navigasi utama aplikasi
- `lib/halaman/beranda_page.dart` — Halaman Beranda, Cara Kerja, dan Tentang
- `lib/halaman/auth_page.dart` — Halaman Masuk & Daftar Akun
- `lib/halaman/kamera_page.dart` — Halaman Ambil Foto Wajah
- `lib/halaman/loading_page.dart` — Halaman Proses Analisis Warna
- `lib/halaman/hasil_page.dart` — Halaman Hasil Analisis & Fitur Premium
- `lib/halaman/riwayat_page.dart` — Halaman Riwayat Hasil Analisis
- `lib/halaman/rekomendasi_page.dart` — Halaman Rekomendasi Produk & Filter Budget
- `lib/halaman/detail_produk_page.dart` — Halaman Detail Produk, Shade, & Tautan E-Commerce

### 2. Backend & Service API (`lib/backend/`, `lib/services/`, `lib/models/`)
- `lib/backend/server.dart` — Server HTTP REST API utama & router
- `lib/backend/database_helper.dart` — Pengelola pembacaan & penyimpanan database JSON
- `lib/backend/auth_controller.dart` — Controller backend untuk login & registrasi
- `lib/backend/analysis_controller.dart` — Controller backend untuk analisis warna, riwayat, & fitur premium
- `lib/backend/product_controller.dart` — Controller backend untuk katalog produk, filter budget, & CRUD admin
- `lib/backend/db.json` — Database JSON (akun pengguna, riwayat analisis, dan katalog produk)
- `lib/services/api_service.dart` — Penghubung HTTP client antara UI Flutter dan backend server
- `lib/models/product_model.dart` — Model data produk & hasil analisis
