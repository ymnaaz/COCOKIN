import 'dart:convert';
import 'dart:io';
import 'database_helper.dart';
import 'auth_controller.dart';
import 'analysis_controller.dart';
import 'product_controller.dart';

/// Server Utama Backend Cocokin (100% Pure Dart REST API)
/// Menghubungkan HTTP Router dengan:
/// - DatabaseHelper     (lib/backend/database_helper.dart)
/// - AuthController     (lib/backend/auth_controller.dart)
/// - AnalysisController (lib/backend/analysis_controller.dart)
/// - ProductController  (lib/backend/product_controller.dart)
Future<void> main() async {
  final port = int.tryParse(Platform.environment['PORT'] ?? '5000') ?? 5000;
  final dbHelper = DatabaseHelper(dbPath: 'lib/backend/db.json');
  final authController = AuthController(dbHelper);
  final analysisController = AnalysisController(dbHelper);
  final productController = ProductController(dbHelper);

  final server = await HttpServer.bind(InternetAddress.anyIPv4, port);
  stdout.writeln('=================================================');
  stdout.writeln('Cocokin Dart Backend Server Aktif!');
  stdout.writeln('URL Base : http://localhost:$port/api');
  stdout.writeln('Database : lib/backend/db.json');
  stdout.writeln('=================================================');

  await for (final HttpRequest request in server) {
    _addCorsHeaders(request.response);

    if (request.method == 'OPTIONS') {
      request.response.statusCode = HttpStatus.noContent;
      await request.response.close();
      continue;
    }

    final path = request.uri.path;
    final method = request.method;

    // 1. Cek Kesehatan Server & Statistik Database
    if (path == '/api/health' && method == 'GET') {
      await _sendJson(request.response, HttpStatus.ok, {
        'status': 'ok',
        'service': 'Cocokin Dart Backend Server',
        'totalUsers': dbHelper.getUsers().length,
        'totalProducts': dbHelper.getProducts().length,
        'totalHistory': dbHelper.getHistory().length,
      });
      continue;
    }

    // 2. Endpoint Login Pengguna & Admin (FR-01, FR-02)
    if (path == '/api/login' && method == 'POST') {
      final body = await _readJsonBody(request);
      final res = authController.handleLogin(body);
      await _sendJson(
        request.response,
        res['statusCode'] as int,
        res['data'] as Map<String, dynamic>,
      );
      continue;
    }

    // 3. Endpoint Registrasi Akun Baru (FR-01)
    if (path == '/api/register' && method == 'POST') {
      final body = await _readJsonBody(request);
      final res = authController.handleRegister(body);
      await _sendJson(
        request.response,
        res['statusCode'] as int,
        res['data'] as Map<String, dynamic>,
      );
      continue;
    }

    // 4. Endpoint Proses Analisis Warna Kulit (FR-03, FR-04, FR-05)
    if (path == '/api/analyze' && method == 'POST') {
      final body = await _readJsonBody(request);
      final res = analysisController.handleAnalyzePhoto(body);
      await _sendJson(
        request.response,
        res['statusCode'] as int,
        res['data'] as Map<String, dynamic>,
      );
      continue;
    }

    // 5. Endpoint Simpan Hasil Analisis ke Riwayat (FR-10)
    if (path == '/api/history' && method == 'POST') {
      final body = await _readJsonBody(request);
      final res = analysisController.handleSaveHistory(body);
      await _sendJson(
        request.response,
        res['statusCode'] as int,
        res['data'] as Map<String, dynamic>,
      );
      continue;
    }

    // 6. Endpoint Ambil Daftar Riwayat Analisis (FR-11)
    if (path == '/api/history' && method == 'GET') {
      final emailParam = request.uri.queryParameters['email'];
      final res = analysisController.handleGetHistory(emailParam);
      await _sendJson(
        request.response,
        res['statusCode'] as int,
        res['data'] as Map<String, dynamic>,
      );
      continue;
    }

    // 7. Endpoint Hapus Riwayat Analisis (FR-11)
    if (path == '/api/history' && method == 'DELETE') {
      final idParam = request.uri.queryParameters['id'];
      final res = analysisController.handleDeleteHistory(idParam);
      await _sendJson(
        request.response,
        res['statusCode'] as int,
        res['data'] as Map<String, dynamic>,
      );
      continue;
    }

    // 8. Endpoint Buka Kunci Fitur Premium (FR-12)
    if (path == '/api/premium/unlock' && method == 'POST') {
      final body = await _readJsonBody(request);
      final res = analysisController.handleUnlockPremium(body);
      await _sendJson(
        request.response,
        res['statusCode'] as int,
        res['data'] as Map<String, dynamic>,
      );
      continue;
    }

    // 9. Endpoint Ambil Katalog Produk & Filter Budget / Kategori (FR-06, FR-07, FR-08)
    if (path == '/api/products' && method == 'GET') {
      final res = productController.handleGetProducts(
        request.uri.queryParameters,
      );
      await _sendJson(
        request.response,
        res['statusCode'] as int,
        res['data'] as Map<String, dynamic>,
      );
      continue;
    }

    // 10. Endpoint Admin Tambah Produk & Shade Baru (FR-13, FR-14)
    if (path == '/api/products' && method == 'POST') {
      final body = await _readJsonBody(request);
      final res = productController.handleCreateProduct(body);
      await _sendJson(
        request.response,
        res['statusCode'] as int,
        res['data'] as Map<String, dynamic>,
      );
      continue;
    }

    // 11. Endpoint Admin Hapus Produk (FR-13)
    if (path == '/api/products' && method == 'DELETE') {
      final idParam = request.uri.queryParameters['id'];
      final res = productController.handleDeleteProduct(idParam);
      await _sendJson(
        request.response,
        res['statusCode'] as int,
        res['data'] as Map<String, dynamic>,
      );
      continue;
    }

    await _sendJson(request.response, HttpStatus.notFound, {
      'success': false,
      'message': 'Endpoint tidak ditemukan',
    });
  }
}

void _addCorsHeaders(HttpResponse response) {
  response.headers.set('Access-Control-Allow-Origin', '*');
  response.headers.set(
    'Access-Control-Allow-Methods',
    'GET, POST, PUT, DELETE, OPTIONS',
  );
  response.headers.set('Access-Control-Allow-Headers', 'Content-Type');
}

Future<Map<String, dynamic>> _readJsonBody(HttpRequest request) async {
  try {
    final content = await utf8.decoder.bind(request).join();
    if (content.isEmpty) return {};
    return jsonDecode(content) as Map<String, dynamic>;
  } catch (_) {
    return {};
  }
}

Future<void> _sendJson(
  HttpResponse response,
  int statusCode,
  Map<String, dynamic> data,
) async {
  response.statusCode = statusCode;
  response.headers.contentType = ContentType.json;
  response.write(jsonEncode(data));
  await response.close();
}
