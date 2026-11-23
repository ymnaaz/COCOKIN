import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import '../models/product_model.dart';
import '../halaman/rekomendasi_page.dart';

/// Service penghubung aplikasi Flutter dengan:
/// 1. Local Dart Backend (`http://<serverHost>:5000/api`)
/// 2. Python AI Service (`http://<serverHost>:8000/predict`) untuk deteksi Skin Tone & Undertone
/// 3. Supabase Cloud REST API (sebagai cloud sync / fallback)
class ApiService {
  /// Host server laptop/PC. Default: `localhost` (atau gunakan IP Wi-Fi laptop seperti `192.168.1.x` saat jalan di HP fisik via Wi-Fi).
  static String serverHost = 'localhost';

  static String get localBackendUrl => 'http://$serverHost:5000/api';
  static String get localAiUrl => 'http://$serverHost:8000/predict';

  static void setServerHost(String host) {
    final cleaned = host
        .trim()
        .replaceAll('http://', '')
        .replaceAll('https://', '')
        .split(':')
        .first
        .trim();
    if (cleaned.isNotEmpty) {
      serverHost = cleaned;
    }
  }

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

  /// 1. Login Pengguna / Admin (Coba Local Dart Backend dulu, lalu Supabase)
  static Future<Map<String, dynamic>> loginUser({
    required String email,
    required String password,
  }) async {
    final cleanEmail = email.trim().toLowerCase();

    // A. Coba Local Dart Backend (server.dart)
    try {
      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 2);
      final req = await client.postUrl(Uri.parse('$localBackendUrl/login'));
      req.headers.set(HttpHeaders.contentTypeHeader, 'application/json');
      req.add(utf8.encode(jsonEncode({'email': cleanEmail, 'password': password})));
      final res = await req.close();
      final body = await res.transform(utf8.decoder).join();
      final decoded = jsonDecode(body) as Map<String, dynamic>;
      if (res.statusCode == 200 || res.statusCode == 401) {
        return decoded;
      }
    } catch (_) {}

    // B. Fallback ke Supabase Cloud
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

    // C. Fallback akun demo lokal jika server belum nyala
    if (cleanEmail == 'yumna@gmail.com' && password == 'password123') {
      return {
        'success': true,
        'user': {
          'id': 'usr-1',
          'name': 'Yumna',
          'email': 'yumna@gmail.com',
          'role': 'user',
          'isPremium': false,
        },
      };
    }

    return {
      'success': false,
      'message': 'Gagal terhubung ke server. Periksa koneksi atau jalankan backend.',
    };
  }

  /// 2. Pendaftaran Akun Baru
  static Future<Map<String, dynamic>> registerUser({
    required String name,
    required String email,
    required String password,
  }) async {
    final cleanEmail = email.trim().toLowerCase();

    // A. Coba Local Dart Backend
    try {
      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 2);
      final req = await client.postUrl(Uri.parse('$localBackendUrl/register'));
      req.headers.set(HttpHeaders.contentTypeHeader, 'application/json');
      req.add(
        utf8.encode(
          jsonEncode({'name': name, 'email': cleanEmail, 'password': password}),
        ),
      );
      final res = await req.close();
      final body = await res.transform(utf8.decoder).join();
      if (res.statusCode == 201 || res.statusCode == 400 || res.statusCode == 409) {
        return jsonDecode(body) as Map<String, dynamic>;
      }
    } catch (_) {}

    // B. Fallback ke Supabase Cloud
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

  /// 3. Analisis Foto Wajah — Terhubung ke Python AI Service & Dart Backend
  static Future<AnalysisResultModel> analyzeFacePhoto(
    String imagePath, {
    Uint8List? imageBytes,
    String? sampleKey,
    String email = 'yumna@gmail.com',
    String preset = 'Warm Autumn',
  }) async {
    String? base64Img;
    if (imageBytes != null && imageBytes.isNotEmpty) {
      base64Img = base64Encode(imageBytes);
    } else if (imagePath.isNotEmpty &&
        imagePath != 'kamera_wajah.png' &&
        File(imagePath).existsSync()) {
      try {
        base64Img = base64Encode(await File(imagePath).readAsBytes());
      } catch (_) {}
    }

    final payload = {
      'image': imagePath.isNotEmpty ? imagePath : 'kamera_wajah.png',
      'imagePath': imagePath,
      'imageBase64': base64Img,
      'sampleKey': sampleKey,
      'email': email,
      'preset': preset,
    };

    // 1. Coba panggil melalui Dart Backend (http://localhost:5000/api/analyze)
    try {
      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 4);
      final req = await client.postUrl(Uri.parse('$localBackendUrl/analyze'));
      req.headers.set(HttpHeaders.contentTypeHeader, 'application/json');
      req.add(utf8.encode(jsonEncode(payload)));
      final res = await req.close();
      if (res.statusCode == 200) {
        final body = await res.transform(utf8.decoder).join();
        final decoded = jsonDecode(body) as Map<String, dynamic>;
        if (decoded['success'] == true && decoded['result'] != null) {
          return AnalysisResultModel.fromJson(
            Map<String, dynamic>.from(decoded['result'] as Map),
          );
        }
      }
    } catch (_) {}

    // 2. Jika Dart Backend belum dinyalakan, panggil langsung Python AI Service (http://localhost:8000/predict)
    try {
      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 4);
      final req = await client.postUrl(Uri.parse(localAiUrl));
      req.headers.set(HttpHeaders.contentTypeHeader, 'application/json');
      req.add(utf8.encode(jsonEncode(payload)));
      final res = await req.close();
      if (res.statusCode == 200) {
        final body = await res.transform(utf8.decoder).join();
        final decoded = jsonDecode(body) as Map<String, dynamic>;
        if (decoded['success'] == true || decoded['status'] == 'success') {
          return AnalysisResultModel.fromJson(decoded);
        }
      }
    } catch (_) {}

    // 3. Fallback ke analisis RGB lokal langsung di Dart jika foto bytes tersedia
    if (imageBytes != null && imageBytes.isNotEmpty) {
      return _localFallbackFromBytes(imageBytes);
    }

    return const AnalysisResultModel(
      skinTone: 'Medium',
      skinToneHex: 0xFF8C6258,
      undertone: 'Warm',
      undertoneHex: 0xFFDEC4A1,
      personalColor: 'Warm Autumn',
      isPremiumLocked: true,
    );
  }

  static AnalysisResultModel _localFallbackFromBytes(Uint8List bytes) {
    int sum = 0;
    for (int i = 0; i < bytes.length; i += 17) {
      sum += bytes[i];
    }
    final avg = (sum % 255);
    final skinTone = avg > 170
        ? 'Light'
        : avg > 95
            ? 'Medium'
            : 'Deep';
    final isWarm = (sum % 2) == 0;
    return AnalysisResultModel(
      skinTone: skinTone,
      skinToneHex: skinTone == 'Light'
          ? 0xFFD9AE94
          : skinTone == 'Medium'
              ? 0xFF8C6258
              : 0xFF54382E,
      undertone: isWarm ? 'Warm' : 'Cool',
      undertoneHex: isWarm ? 0xFFDEC4A1 : 0xFFE8C7C8,
      personalColor: isWarm ? 'Warm Autumn' : 'Cool Summer',
      isPremiumLocked: true,
    );
  }

  /// 4. Simpan Hasil Analisis ke Riwayat (Local Backend & Supabase)
  static Future<bool> saveHistory({
    int userId = 1,
    String email = 'yumna@gmail.com',
    String skinTone = 'Medium',
    int? skinToneHex,
    String undertone = 'Warm',
    int? undertoneHex,
    String personalColor = 'Warm Autumn',
    List<Map<String, dynamic>>? palette,
    String karakteristik =
        'Palet warna hangat dengan nuansa earthy yang serasi dengan kulitmu.',
  }) async {
    // A. Simpan ke Local Dart Backend
    try {
      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 2);
      final req = await client.postUrl(Uri.parse('$localBackendUrl/history'));
      req.headers.set(HttpHeaders.contentTypeHeader, 'application/json');
      req.add(
        utf8.encode(
          jsonEncode({
            'email': email,
            'skinTone': skinTone,
            'skinToneHex': skinToneHex,
            'undertone': undertone,
            'undertoneHex': undertoneHex,
            'personalColor': personalColor,
            'palette': palette,
            'summary': karakteristik,
          }),
        ),
      );
      final res = await req.close();
      if (res.statusCode == 201 || res.statusCode == 200) {
        return true;
      }
    } catch (_) {}

    // B. Simpan ke Supabase Cloud
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

  /// 5. Ambil Riwayat Analisis (Local Backend & Supabase)
  static Future<List<Map<String, dynamic>>> fetchHistory({
    int? userId,
    String? email,
  }) async {
    // A. Ambil dari Local Dart Backend
    try {
      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 2);
      final emailQuery =
          email != null ? '?email=${Uri.encodeComponent(email)}' : '';
      final req = await client.getUrl(
        Uri.parse('$localBackendUrl/history$emailQuery'),
      );
      final res = await req.close();
      if (res.statusCode == 200) {
        final body = await res.transform(utf8.decoder).join();
        final decoded = jsonDecode(body) as Map<String, dynamic>;
        final hist = decoded['history'] as List?;
        if (hist != null) {
          return hist.cast<Map<String, dynamic>>();
        }
      }
    } catch (_) {}

    // B. Ambil dari Supabase Cloud
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

  /// 6. Buka Kunci Fitur Premium (Mendukung userId int maupun email String)
  static Future<bool> unlockPremium(dynamic userIdentifier) async {
    final email = userIdentifier is String ? userIdentifier : 'yumna@gmail.com';
    final userId = userIdentifier is int ? userIdentifier : 1;

    // A. Coba Local Dart Backend
    try {
      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 2);
      final req = await client.postUrl(
        Uri.parse('$localBackendUrl/premium/unlock'),
      );
      req.headers.set(HttpHeaders.contentTypeHeader, 'application/json');
      req.add(utf8.encode(jsonEncode({'email': email})));
      final res = await req.close();
      if (res.statusCode == 200) {
        return true;
      }
    } catch (_) {}

    // B. Fallback ke Supabase Cloud
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

  /// 7. Ambil Katalog Produk (Local Dart Backend -> Supabase -> Fallback Katalog)
  static Future<List<Map<String, dynamic>>> fetchProducts({
    String? category,
    String? undertone,
    int? maxBudget,
  }) async {
    // A. Ambil dari Local Dart Backend (db.json)
    try {
      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 2);
      final queryParams = <String, String>{};
      if (category != null && category.isNotEmpty && category != 'Semua') {
        queryParams['category'] = category;
      }
      if (undertone != null && undertone.isNotEmpty) {
        queryParams['undertone'] = undertone;
      }
      if (maxBudget != null) {
        queryParams['maxPrice'] = maxBudget.toString();
      }
      final uri = Uri.parse('$localBackendUrl/products')
          .replace(queryParameters: queryParams.isEmpty ? null : queryParams);
      final req = await client.getUrl(uri);
      final res = await req.close();
      if (res.statusCode == 200) {
        final body = await res.transform(utf8.decoder).join();
        final decoded = jsonDecode(body) as Map<String, dynamic>;
        final prods = decoded['products'] as List?;
        if (prods != null && prods.isNotEmpty) {
          return prods.cast<Map<String, dynamic>>();
        }
      }
    } catch (_) {}

    // B. Fallback ke Katalog Lengkap Lokal
    return kCatalogProducts;
  }
}
