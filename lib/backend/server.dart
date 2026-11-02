import 'dart:convert';
import 'dart:io';

/// Server Backend Cocokin (100% Pure Dart REST API + JSON Database Persistence)
/// Menangani seluruh kebutuhan fungsional backend:
/// 1. POST   /api/login           -> Autentikasi Pengguna & Admin (FR-01, FR-02)
/// 2. POST   /api/register        -> Pendaftaran Pengguna Baru (FR-01)
/// 3. POST   /api/analyze         -> Analisis Warna Kulit & Pencocokan (FR-04, FR-05)
/// 4. GET    /api/history         -> Mengambil Riwayat Analisis (FR-11)
/// 5. POST   /api/history         -> Menyimpan Hasil Analisis (FR-10)
/// 6. POST   /api/premium/unlock  -> Membuka Gembok Fitur Premium (FR-12)
/// 7. GET    /api/products        -> Katalog & Filter Budget/Kategori (FR-06, FR-07, FR-08)
/// 8. POST   /api/products        -> Admin Tambah Produk & Shade (FR-13, FR-14)
/// 9. DELETE /api/products        -> Admin Hapus Produk (FR-13)
Future<void> main() async {
  final port = int.tryParse(Platform.environment['PORT'] ?? '5000') ?? 5000;
  final dbFile = File('lib/backend/db.json');

  Map<String, dynamic> loadDb() {
    if (dbFile.existsSync()) {
      try {
        return jsonDecode(dbFile.readAsStringSync()) as Map<String, dynamic>;
      } catch (_) {}
    }
    return {'users': [], 'analysis_history': [], 'products': []};
  }

  void saveDb(Map<String, dynamic> data) {
    try {
      dbFile.writeAsStringSync(
        const JsonEncoder.withIndent('  ').convert(data),
      );
    } catch (_) {}
  }

  final server = await HttpServer.bind(InternetAddress.anyIPv4, port);
  stdout.writeln('=================================================');
  stdout.writeln('Cocokin Dart Backend Server Aktif!');
  stdout.writeln('URL Base : http://localhost:$port/api');
  stdout.writeln('Database : ${dbFile.path}');
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
    final db = loadDb();
    final users = (db['users'] as List).cast<Map<String, dynamic>>();
    final history = (db['analysis_history'] as List).cast<Map<String, dynamic>>();
    final products = (db['products'] as List).cast<Map<String, dynamic>>();

    // 1. Cek Status Server
    if (path == '/api/health' && method == 'GET') {
      await _sendJson(request.response, HttpStatus.ok, {
        'status': 'ok',
        'service': 'Cocokin Dart Backend Server',
        'totalUsers': users.length,
        'totalProducts': products.length,
        'totalHistory': history.length,
      });
      continue;
    }

    // 2. Login Pengguna / Admin (FR-01 & FR-02)
    if (path == '/api/login' && method == 'POST') {
      final body = await _readJsonBody(request);
      final email = (body['email'] as String? ?? '').trim().toLowerCase();
      final password = (body['password'] as String? ?? '').trim();

      if (email.isEmpty || password.isEmpty) {
        await _sendJson(request.response, HttpStatus.badRequest, {
          'success': false,
          'message': 'Email dan password wajib diisi.',
        });
        continue;
      }

      final match = users.where((u) {
        return (u['email'] as String).toLowerCase() == email;
      }).toList();

      if (match.isNotEmpty) {
        final user = match.first;
        if (user['password'] != password) {
          await _sendJson(request.response, HttpStatus.unauthorized, {
            'success': false,
            'message': 'Password yang dimasukkan salah.',
          });
          continue;
        }
        await _sendJson(request.response, HttpStatus.ok, {
          'success': true,
          'user': {
            'id': user['id'],
            'name': user['name'],
            'email': user['email'],
            'role': user['role'] ?? 'user',
            'isPremium': user['isPremium'] ?? false,
          },
        });
        continue;
      }

      // Jika email belum terdaftar di db.json, izinkan login prototipe & catat
      final isAdmin = email.contains('admin');
      final autoUser = {
        'id': 'usr-${DateTime.now().millisecondsSinceEpoch}',
        'name': isAdmin ? 'Admin Cocokin' : email.split('@').first,
        'email': email,
        'password': password,
        'role': isAdmin ? 'admin' : 'user',
        'isPremium': isAdmin,
      };
      users.add(autoUser);
      saveDb(db);

      await _sendJson(request.response, HttpStatus.ok, {
        'success': true,
        'user': {
          'id': autoUser['id'],
          'name': autoUser['name'],
          'email': autoUser['email'],
          'role': autoUser['role'],
          'isPremium': autoUser['isPremium'],
        },
      });
      continue;
    }

    // 3. Register Akun Baru (FR-01)
    if (path == '/api/register' && method == 'POST') {
      final body = await _readJsonBody(request);
      final name = (body['name'] as String? ?? '').trim();
      final email = (body['email'] as String? ?? '').trim().toLowerCase();
      final password = (body['password'] as String? ?? '').trim();

      if (name.isEmpty || email.isEmpty || password.isEmpty) {
        await _sendJson(request.response, HttpStatus.badRequest, {
          'success': false,
          'message': 'Nama lengkap, email, dan password wajib diisi.',
        });
        continue;
      }

      final exists = users.any(
        (u) => (u['email'] as String).toLowerCase() == email,
      );
      if (exists) {
        await _sendJson(request.response, HttpStatus.conflict, {
          'success': false,
          'message': 'Email sudah terdaftar. Silakan masuk.',
        });
        continue;
      }

      final newUser = {
        'id': 'usr-${DateTime.now().millisecondsSinceEpoch}',
        'name': name,
        'email': email,
        'password': password,
        'role': 'user',
        'isPremium': false,
      };
      users.add(newUser);
      saveDb(db);

      await _sendJson(request.response, HttpStatus.created, {
        'success': true,
        'user': {
          'id': newUser['id'],
          'name': newUser['name'],
          'email': newUser['email'],
          'role': newUser['role'],
          'isPremium': newUser['isPremium'],
        },
      });
      continue;
    }

    // 4. Analisis Foto Wajah & Simpan Riwayat Otomatis (FR-04, FR-05, FR-10)
    if (path == '/api/analyze' && method == 'POST') {
      final body = await _readJsonBody(request);
      final userEmail = (body['email'] as String? ?? 'guest@cocokin.id').trim();
      final preset = (body['preset'] as String? ?? 'Warm Autumn').trim();

      final Map<String, Map<String, dynamic>> profiles = {
        'Warm Autumn': {
          'skinTone': 'Medium',
          'skinToneHex': 0xFF8C6258,
          'undertone': 'Warm',
          'undertoneHex': 0xFFDEC4A1,
          'personalColor': 'Warm Autumn',
          'summary':
              'Palet warna hangat dengan nuansa earthy yang bisa kamu jadikan referensi.',
          'palette': [
            {'name': 'Deep Espresso', 'hex': 0xFF6B381B},
            {'name': 'Warm Caramel', 'hex': 0xFFC6946E},
            {'name': 'Soft Sand Peach', 'hex': 0xFFE1BBA0},
            {'name': 'Muted Sage Olive', 'hex': 0xFF8EAE86},
          ],
        },
        'Cool Summer': {
          'skinTone': 'Light',
          'skinToneHex': 0xFFC59B91,
          'undertone': 'Cool',
          'undertoneHex': 0xFFE8C7C8,
          'personalColor': 'Cool Summer',
          'summary':
              'Palet warna sejuk dengan nuansa dusty rose dan mauve lembut yang serasi untuk kulitmu.',
          'palette': [
            {'name': 'Rosewood Berry', 'hex': 0xFF7D3C52},
            {'name': 'Dusty Mauve', 'hex': 0xFFB6768A},
            {'name': 'Soft Petal Pink', 'hex': 0xFFE4B5C1},
            {'name': 'Cool Lavender', 'hex': 0xFF9EA3B8},
          ],
        },
      };

      final chosen = profiles[preset] ?? profiles['Warm Autumn']!;
      final now = DateTime.now();
      final formattedDate =
          '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')} '
          '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

      final record = {
        'id': 'hist-${now.millisecondsSinceEpoch}',
        'userEmail': userEmail,
        'date': formattedDate,
        ...chosen,
      };

      history.insert(0, record);
      saveDb(db);

      await _sendJson(request.response, HttpStatus.ok, {
        'success': true,
        'result': record,
      });
      continue;
    }

    // 5. Ambil Riwayat Hasil Analisis Pengguna (FR-11)
    if (path == '/api/history' && method == 'GET') {
      final emailParam = request.uri.queryParameters['email']?.toLowerCase();
      final filteredHistory = (emailParam == null || emailParam.isEmpty)
          ? history
          : history.where((h) {
              return (h['userEmail'] as String? ?? '').toLowerCase() ==
                  emailParam;
            }).toList();

      await _sendJson(request.response, HttpStatus.ok, {
        'success': true,
        'history': filteredHistory,
      });
      continue;
    }

    // 6. Buka Kunci Fitur Premium (FR-12)
    if (path == '/api/premium/unlock' && method == 'POST') {
      final body = await _readJsonBody(request);
      final email = (body['email'] as String? ?? '').trim().toLowerCase();

      for (final u in users) {
        if ((u['email'] as String).toLowerCase() == email) {
          u['isPremium'] = true;
        }
      }
      saveDb(db);

      await _sendJson(request.response, HttpStatus.ok, {
        'success': true,
        'isPremium': true,
        'message': 'Fitur Cocokin Premium berhasil diaktifkan.',
      });
      continue;
    }

    // 7. Ambil Daftar Produk & Filter Budget / Kategori (FR-06, FR-07, FR-08)
    if (path == '/api/products' && method == 'GET') {
      final category = request.uri.queryParameters['category'];
      final maxPriceStr = request.uri.queryParameters['maxPrice'];
      final maxPrice = maxPriceStr != null ? int.tryParse(maxPriceStr) : null;

      final filtered = products.where((p) {
        final matchCat =
            category == null ||
            category.isEmpty ||
            category == 'Semua' ||
            p['category'] == category;
        final price = p['price'] as int? ?? 0;
        final matchPrice = maxPrice == null || price <= maxPrice;
        return matchCat && matchPrice;
      }).toList();

      await _sendJson(request.response, HttpStatus.ok, {
        'success': true,
        'total': filtered.length,
        'products': filtered,
      });
      continue;
    }

    // 8. Admin Tambah Produk & Shade Baru (FR-13 & FR-14)
    if (path == '/api/products' && method == 'POST') {
      final body = await _readJsonBody(request);
      final name = (body['name'] as String? ?? '').trim();
      final brand = (body['brand'] as String? ?? '').trim();
      final shade = (body['shade'] as String? ?? '01 Natural').trim();
      final price = int.tryParse(body['price'].toString()) ?? 50000;
      final category = (body['category'] as String? ?? 'Lip Product').trim();

      if (name.isEmpty || brand.isEmpty) {
        await _sendJson(request.response, HttpStatus.badRequest, {
          'success': false,
          'message': 'Nama produk dan brand wajib diisi.',
        });
        continue;
      }

      final newProd = {
        'id': 'prod-${DateTime.now().millisecondsSinceEpoch}',
        'name': name,
        'brand': brand,
        'shade': shade,
        'shadeHex': body['shadeHex'] ?? 0xFFB6634B,
        'price': price,
        'priceLabel': 'Rp${_formatThousand(price)}',
        'category': category,
        'type': category == 'Blush'
            ? 'blush'
            : category == 'Eye Makeup'
                ? 'eyeshadow'
                : category == 'Complexion'
                    ? 'cushion'
                    : 'lip',
        'undertone': body['undertone'] ?? 'Warm',
        'personalColor': body['personalColor'] ?? 'Warm Autumn',
        'description':
            body['description'] ??
            'Produk rekomendasi makeup yang sesuai dengan karakteristik warna kulitmu.',
        'whyMatch':
            body['whyMatch'] ??
            'Shade $shade direkomendasikan untuk menonjolkan rona alami wajahmu.',
        'allShades': [
          {'name': shade, 'hex': body['shadeHex'] ?? 0xFFB6634B},
        ],
        'shopeeUrl':
            body['shopeeUrl'] ??
            'https://shopee.co.id/search?keyword=${Uri.encodeComponent('$brand $name')}',
        'tokopediaUrl':
            body['tokopediaUrl'] ??
            'https://www.tokopedia.com/search?st=product&q=${Uri.encodeComponent('$brand $name')}',
      };

      products.insert(0, newProd);
      saveDb(db);

      await _sendJson(request.response, HttpStatus.created, {
        'success': true,
        'product': newProd,
      });
      continue;
    }

    // 9. Admin Hapus Produk (FR-13)
    if (path == '/api/products' && method == 'DELETE') {
      final id = request.uri.queryParameters['id'];
      products.removeWhere((p) => p['id'] == id);
      saveDb(db);

      await _sendJson(request.response, HttpStatus.ok, {
        'success': true,
        'message': 'Produk berhasil dihapus.',
      });
      continue;
    }

    await _sendJson(request.response, HttpStatus.notFound, {
      'success': false,
      'message': 'Endpoint tidak ditemukan',
    });
  }
}

String _formatThousand(int number) {
  final str = number.toString();
  final buffer = StringBuffer();
  for (int i = 0; i < str.length; i++) {
    if (i > 0 && (str.length - i) % 3 == 0) {
      buffer.write('.');
    }
    buffer.write(str[i]);
  }
  return buffer.toString();
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
