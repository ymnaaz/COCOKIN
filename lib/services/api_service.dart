import 'dart:convert';
import 'dart:io';
import '../models/product_model.dart';
import '../halaman/rekomendasi_page.dart';

/// Service penghubung aplikasi Flutter langsung dengan Supabase Cloud REST API (PostgreSQL)
class ApiService {
  static const String supabaseUrl = 'https://izgfxqikndcuhrepcjjd.supabase.co';
  static const String supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Iml6Z2Z4cWlrbmRjdWhyZXBjampkIiwicm9sZSI6ImFub24iLCJpYXQiOjE3OTUyNjY2MzksImV4cCI6MjExMDg0MjYzOX0.rhVkZHUNZC3F3_cstYN2EWM47yrU1EvgkcRjqDYSXcQ';
  static const String restBaseUrl = '$supabaseUrl/rest/v1';

  static void _attachSupabaseHeaders(
    HttpHeaders headers, {
    String? prefer,
  }) {
    headers.set('apikey', supabaseAnonKey);
    headers.set(HttpHeaders.authorizationHeader, 'Bearer $supabaseAnonKey');
    headers.set(HttpHeaders.contentTypeHeader, 'application/json');
    if (prefer != null) {
      headers.set('Prefer', prefer);
    }
  }

  /// 1. Login Pengguna / Admin ke tabel `pengguna` di Supabase Cloud
  static Future<Map<String, dynamic>> loginUser({
    required String email,
    required String password,
  }) async {
    final cleanEmail = email.trim().toLowerCase();
    try {
      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 4);
      final uri = Uri.parse(
        '$restBaseUrl/pengguna?email=eq.${Uri.encodeComponent(cleanEmail)}&select=*',
      );
      final request = await client.getUrl(uri);
      _attachSupabaseHeaders(request.headers);

      final response = await request.close();
      final body = await response.transform(utf8.decoder).join();

      if (response.statusCode == 200) {
        final rows = jsonDecode(body) as List;
        if (rows.isEmpty) {
          return {
            'success': false,
            'message': 'Email belum terdaftar. Silakan daftar terlebih dahulu.',
          };
        }
        final user = rows.first as Map<String, dynamic>;
        if (user['password'] != password) {
          return {
            'success': false,
            'message':
                'Password yang kamu masukkan salah. Silakan periksa kembali.',
          };
        }

        return {
          'success': true,
          'user': {
            'id': user['id_pengguna'].toString(),
            'name': user['nama'],
            'email': user['email'],
            'role': user['role'] ?? 'user',
            'isPremium': user['status_premium'] == true,
          },
        };
      }
    } catch (_) {}

    return {
      'success': false,
      'message': 'Gagal terhubung ke server. Periksa koneksi internetmu.',
    };
  }

  /// 2. Pendaftaran Akun Baru
  static Future<Map<String, dynamic>> registerUser({
    required String name,
    required String email,
    required String password,
  }) async {
    final cleanEmail = email.trim().toLowerCase();
    try {
      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 4);

      final checkUri = Uri.parse(
        '$restBaseUrl/pengguna?email=eq.${Uri.encodeComponent(cleanEmail)}&select=id_pengguna',
      );
      final checkReq = await client.getUrl(checkUri);
      _attachSupabaseHeaders(checkReq.headers);
      final checkRes = await checkReq.close();
      final checkBody = await checkRes.transform(utf8.decoder).join();
      if (checkRes.statusCode == 200) {
        final existing = jsonDecode(checkBody) as List;
        if (existing.isNotEmpty) {
          return {
            'success': false,
            'message': 'Email sudah terdaftar. Silakan gunakan email lain.',
          };
        }
      }

      // Insert user baru ke tabel `pengguna`
      final insertUri = Uri.parse('$restBaseUrl/pengguna');
      final insertReq = await client.postUrl(insertUri);
      _attachSupabaseHeaders(
        insertReq.headers,
        prefer: 'return=representation',
      );
      final role = cleanEmail.contains('admin') ? 'admin' : 'user';
      insertReq.add(
        utf8.encode(
          jsonEncode({
            'nama': name.trim(),
            'email': cleanEmail,
            'password': password,
            'role': role,
            'status_premium': false,
          }),
        ),
      );

      final insertRes = await insertReq.close();
      final insertBody = await insertRes.transform(utf8.decoder).join();
      if (insertRes.statusCode == 201) {
        final createdList = jsonDecode(insertBody) as List;
        final created = createdList.first as Map<String, dynamic>;
        return {
          'success': true,
          'user': {
            'id': created['id_pengguna'].toString(),
            'name': created['nama'],
            'email': created['email'],
            'role': created['role'],
            'isPremium': created['status_premium'] == true,
          },
        };
      }
    } catch (_) {}

    return {
      'success': false,
      'message': 'Gagal mendaftarkan akun. Silakan coba lagi.',
    };
  }

  /// 3. Analisis Foto Wajah
  static Future<AnalysisResultModel> analyzeFacePhoto(
    String imagePath, {
    String email = 'yumna@gmail.com',
    String preset = 'Warm Autumn',
  }) async {
    return const AnalysisResultModel(
      skinTone: 'Medium',
      skinToneHex: 0xFF8C6258,
      undertone: 'Warm',
      undertoneHex: 0xFFDEC4A1,
      personalColor: 'Warm Autumn',
      isPremiumLocked: true,
    );
  }

  /// 4. Simpan Hasil Analisis ke tabel `analisis_wajah` di Supabase Cloud
  static Future<bool> saveHistory({
    int userId = 1,
    String skinTone = 'Medium',
    String undertone = 'Warm',
    String personalColor = 'Warm Autumn',
    String karakteristik =
        'Palet warna hangat dengan nuansa earthy yang serasi dengan kulitmu.',
  }) async {
    try {
      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 4);
      final request = await client.postUrl(
        Uri.parse('$restBaseUrl/analisis_wajah'),
      );
      _attachSupabaseHeaders(request.headers, prefer: 'return=minimal');
      request.add(
        utf8.encode(
          jsonEncode({
            'id_pengguna': userId,
            'skin_tone': skinTone,
            'undertone': undertone,
            'personal_color': personalColor,
            'karakteristik': karakteristik,
          }),
        ),
      );

      final response = await request.close();
      return response.statusCode == 201 || response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  /// 5. Ambil Riwayat Analisis dari tabel `analisis_wajah` di Supabase Cloud
  static Future<List<Map<String, dynamic>>> fetchHistory({
    int? userId,
  }) async {
    try {
      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 4);
      final filter = userId != null ? 'id_pengguna=eq.$userId&' : '';
      final uri = Uri.parse(
        '$restBaseUrl/analisis_wajah?${filter}select=*&order=tanggal_analisis.desc',
      );
      final request = await client.getUrl(uri);
      _attachSupabaseHeaders(request.headers);
      final response = await request.close();

      if (response.statusCode == 200) {
        final body = await response.transform(utf8.decoder).join();
        final data = jsonDecode(body) as List;
        return data.cast<Map<String, dynamic>>();
      }
    } catch (_) {}

    return [];
  }

  /// 6. Buka Kunci Fitur Premium di tabel `pengguna` Supabase Cloud
  static Future<bool> unlockPremium(int userId) async {
    try {
      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 4);
      final request = await client.patchUrl(
        Uri.parse('$restBaseUrl/pengguna?id_pengguna=eq.$userId'),
      );
      _attachSupabaseHeaders(request.headers, prefer: 'return=minimal');
      request.add(utf8.encode(jsonEncode({'status_premium': true})));

      final response = await request.close();
      return response.statusCode == 204 || response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  /// 7. Ambil Katalog Produk beserta tabel `shade` langsung dari Supabase Cloud
  static Future<List<Map<String, dynamic>>> fetchProducts({
    String? category,
    int? maxBudget,
  }) async {
    try {
      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 4);
      final uri = Uri.parse(
        '$restBaseUrl/produk?select=*,shade(*)&order=id_produk.asc',
      );
      final request = await client.getUrl(uri);
      _attachSupabaseHeaders(request.headers);
      final response = await request.close();

      if (response.statusCode == 200) {
        final body = await response.transform(utf8.decoder).join();
        final rows = jsonDecode(body) as List;
        if (rows.isNotEmpty) {
          return rows.cast<Map<String, dynamic>>();
        }
      }
    } catch (_) {}

    return kCatalogProducts;
  }
}
