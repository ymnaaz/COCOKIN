-- ==========================================================
-- SKEMA DATABASE COCOKIN (SESUAI DOKUMEN SDD & ERD BAB III)
-- ==========================================================

CREATE DATABASE IF NOT EXISTS cocokin_db;
USE cocokin_db;

-- 1. TABEL PENGGUNA
CREATE TABLE IF NOT EXISTS pengguna (
    id_pengguna INT AUTO_INCREMENT PRIMARY KEY,
    nama VARCHAR(150) NOT NULL,
    email VARCHAR(150) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    role ENUM('user', 'admin') DEFAULT 'user',
    status_premium BOOLEAN DEFAULT FALSE,
    tanggal_daftar TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 2. TABEL ANALISIS WAJAH
CREATE TABLE IF NOT EXISTS analisis_wajah (
    id_analisis INT AUTO_INCREMENT PRIMARY KEY,
    id_pengguna INT NOT NULL,
    foto_wajah VARCHAR(255),
    skin_tone VARCHAR(50) NOT NULL,
    undertone VARCHAR(50) NOT NULL,
    personal_color VARCHAR(50) NOT NULL,
    karakteristik TEXT,
    tanggal_analisis TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_pengguna) REFERENCES pengguna(id_pengguna) ON DELETE CASCADE
);

-- 3. TABEL PRODUK
CREATE TABLE IF NOT EXISTS produk (
    id_produk INT AUTO_INCREMENT PRIMARY KEY,
    nama_produk VARCHAR(150) NOT NULL,
    brand VARCHAR(100) NOT NULL,
    kategori VARCHAR(50) NOT NULL,
    deskripsi TEXT,
    harga DECIMAL(12, 2) NOT NULL,
    purchase_url VARCHAR(255),
    gambar VARCHAR(255),
    stok INT DEFAULT 10
);

-- 4. TABEL SHADE
CREATE TABLE IF NOT EXISTS shade (
    id_shade INT AUTO_INCREMENT PRIMARY KEY,
    id_produk INT NOT NULL,
    nama_shade VARCHAR(100) NOT NULL,
    kode_warna VARCHAR(20),
    skin_tone VARCHAR(50),
    undertone VARCHAR(50),
    personal_color VARCHAR(50),
    FOREIGN KEY (id_produk) REFERENCES produk(id_produk) ON DELETE CASCADE
);

-- 5. TABEL REKOMENDASI & RIWAYAT
CREATE TABLE IF NOT EXISTS rekomendasi (
    id_rekomendasi INT AUTO_INCREMENT PRIMARY KEY,
    id_pengguna INT NOT NULL,
    id_analisis INT NOT NULL,
    budget DECIMAL(12, 2),
    tanggal_rekomendasi TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_pengguna) REFERENCES pengguna(id_pengguna) ON DELETE CASCADE,
    FOREIGN KEY (id_analisis) REFERENCES analisis_wajah(id_analisis) ON DELETE CASCADE
);

-- 6. TABEL LANGGANAN PREMIUM
CREATE TABLE IF NOT EXISTS langganan_premium (
    id_langganan INT AUTO_INCREMENT PRIMARY KEY,
    id_pengguna INT NOT NULL,
    paket VARCHAR(50) DEFAULT 'Cocokin Premium',
    tanggal_mulai DATE,
    tanggal_berakhir DATE,
    status ENUM('aktif', 'kadaluarsa', 'dibatalkan') DEFAULT 'aktif',
    FOREIGN KEY (id_pengguna) REFERENCES pengguna(id_pengguna) ON DELETE CASCADE
);

-- ==========================================================
-- DUMMY DATA SEEDER (PERSIS SESUAI PROTOTIPE COCOKIN)
-- ==========================================================

INSERT INTO pengguna (nama, email, password, role, status_premium) VALUES
('Yumna', 'yumna@gmail.com', 'password123', 'user', FALSE),
('Admin Cocokin', 'admin@cocokin.id', 'admin123', 'admin', TRUE)
ON DUPLICATE KEY UPDATE nama=VALUES(nama);

INSERT INTO produk (id_produk, nama_produk, brand, kategori, deskripsi, harga, purchase_url, gambar) VALUES
(1, 'Lip Cream', 'Make Over', 'Lip Product', 'Tekstur creamy tahan lama dengan formula transferproof matte finish.', 45000, 'https://shopee.co.id/search?keyword=makeover%20lip%20cream%20teracotta', 'lip_cream.png'),
(2, 'Blush On', 'Emina', 'Blush', 'Blush powder halus dengan pigmentasi natural dan buildable untuk rona pipi segar.', 55000, 'https://shopee.co.id/search?keyword=emina%20blush%20peach', 'blush.png'),
(3, 'Eyeshadow Palette', 'Wardah', 'Eye Makeup', '9 warna earthy hangat bernuansa cokelat dan emas dengan tekstur powdery halus.', 125000, 'https://shopee.co.id/search?keyword=wardah%20eyeshadow%20palette%20warm', 'eyeshadow.png'),
(4, 'Liquid Foundation', 'Maybelline', 'Complexion', 'Coverage medium hingga full dengan matte finish tahan 24 jam.', 135000, 'https://shopee.co.id/search?keyword=maybelline%20foundation%20warm%20medium', 'foundation.png')
ON DUPLICATE KEY UPDATE nama_produk=VALUES(nama_produk);

INSERT INTO shade (id_produk, nama_shade, kode_warna, skin_tone, undertone, personal_color) VALUES
(1, 'Warm Teracotta', '#B24B3B', 'Medium', 'Warm', 'Warm Autumn'),
(2, 'Peach Sun', '#E58A73', 'Medium', 'Warm', 'Warm Autumn'),
(3, 'Earthy Brown & Gold', '#8C5A40', 'Medium', 'Warm', 'Warm Autumn'),
(4, 'Warm Sun Beige', '#D49F7D', 'Medium', 'Warm', 'Warm Autumn');
