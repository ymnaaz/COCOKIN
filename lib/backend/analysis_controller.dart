import 'dart:convert';
import 'dart:io';
import 'database_helper.dart';

/// Controller Backend untuk Fitur Analisis Warna, Riwayat Analisis, & Fitur Premium
/// Mencakup FR-03, FR-04, FR-05, FR-10, FR-11, dan FR-12
/// Terhubung langsung dengan COCOKIN Python AI Service (http://localhost:8000/predict)
class AnalysisController {
  final DatabaseHelper dbHelper;
  final String aiServiceUrl;

  AnalysisController(
    this.dbHelper, {
    this.aiServiceUrl = 'http://localhost:8000/predict',
  });

  static const Map<String, Map<String, dynamic>> _colorProfiles = {
    'Warm Autumn': {
      'skinTone': 'Medium',
      'skinToneHex': 0xFF8C6258,
      'undertone': 'Warm',
      'undertoneHex': 0xFFDEC4A1,
      'personalColor': 'Warm Autumn',
      'summary':
          'Palet warna hangat dengan nuansa earthy terracotta, caramel, dan bronze yang menyatu alami di kulitmu.',
      'palette': [
        {'name': 'Deep Espresso', 'hex': 0xFF6B381B},
        {'name': 'Warm Caramel', 'hex': 0xFFC6946E},
        {'name': 'Soft Sand Peach', 'hex': 0xFFE1BBA0},
        {'name': 'Muted Sage Olive', 'hex': 0xFF8EAE86},
      ],
    },
    'Warm Spring': {
      'skinTone': 'Light',
      'skinToneHex': 0xFFD9AE94,
      'undertone': 'Warm',
      'undertoneHex': 0xFFDEC4A1,
      'personalColor': 'Warm Spring',
      'summary':
          'Palet warna hangat dan cerah bernuansa peach, coral, serta golden nude yang membuat wajah tampak segar bercahaya.',
      'palette': [
        {'name': 'Peach Coral', 'hex': 0xFFE88D72},
        {'name': 'Warm Apricot', 'hex': 0xFFF2B895},
        {'name': 'Golden Honey', 'hex': 0xFFD99B52},
        {'name': 'Soft Warm Nude', 'hex': 0xFFD8A48F},
      ],
    },
    'Cool Summer': {
      'skinTone': 'Light',
      'skinToneHex': 0xFFC59B91,
      'undertone': 'Cool',
      'undertoneHex': 0xFFE8C7C8,
      'personalColor': 'Cool Summer',
      'summary':
          'Palet warna sejuk dengan nuansa dusty rose, berry lembut, dan mauve yang serasi untuk kulitmu.',
      'palette': [
        {'name': 'Rosewood Berry', 'hex': 0xFF7D3C52},
        {'name': 'Dusty Mauve', 'hex': 0xFFB6768A},
        {'name': 'Soft Petal Pink', 'hex': 0xFFE4B5C1},
        {'name': 'Cool Lavender', 'hex': 0xFF9EA3B8},
      ],
    },
    'Cool Winter': {
      'skinTone': 'Deep',
      'skinToneHex': 0xFF5E3F38,
      'undertone': 'Cool',
      'undertoneHex': 0xFFE8C7C8,
      'personalColor': 'Cool Winter',
      'summary':
          'Palet warna sejuk berkontras tegas seperti plum, berry wine, dan deep rose yang menonjolkan dimensi wajahmu.',
      'palette': [
        {'name': 'Deep Berry Wine', 'hex': 0xFF6E2239},
        {'name': 'Cool Ruby Plum', 'hex': 0xFF8F3553},
        {'name': 'Icy Mauve Pink', 'hex': 0xFFD69EB1},
        {'name': 'Royal Slate', 'hex': 0xFF56637A},
      ],
    },
  };

  /// POST /api/analyze — Validasi input foto & proses analisis warna kulit via Python AI Service (FR-03, FR-04, FR-05)
  Future<Map<String, dynamic>> handleAnalyzePhoto(
    Map<String, dynamic> body,
  ) async {
    final imageName = (body['image'] as String? ?? 'kamera_wajah.png').trim();
    final userEmail = (body['email'] as String? ?? 'yumna@gmail.com').trim();
    final preset = (body['preset'] as String? ?? 'Warm Autumn').trim();
    final imageBase64 = body['imageBase64'] as String?;
    final imagePath = body['imagePath'] as String?;
    final sampleKey = body['sampleKey'] as String?;

    // Validasi ekstensi file foto jika tidak mengirim base64 langsung (FR-04 / BB-06)
    final lowerImg = imageName.toLowerCase();
    final validExt = lowerImg.endsWith('.png') ||
        lowerImg.endsWith('.jpg') ||
        lowerImg.endsWith('.jpeg') ||
        lowerImg.endsWith('.webp');

    if ((imageBase64 == null || imageBase64.isEmpty) && !validExt) {
      return {
        'statusCode': HttpStatus.badRequest,
        'data': {
          'success': false,
          'message':
              'Format file foto tidak didukung. Gunakan JPG, JPEG, atau PNG.',
        },
      };
    }

    // 1. Panggil Python AI Service (http://localhost:8000/predict)
    Map<String, dynamic>? aiResult;
    try {
      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 5);
      final req = await client.postUrl(Uri.parse(aiServiceUrl));
      req.headers.set(HttpHeaders.contentTypeHeader, 'application/json');
      req.add(
        utf8.encode(
          jsonEncode({
            'imageBase64': imageBase64,
            'imagePath': imagePath,
            'sampleKey': sampleKey,
            'preset': preset,
          }),
        ),
      );
      final res = await req.close();
      final resBody = await res.transform(utf8.decoder).join();
      if (res.statusCode == 200) {
        final decoded = jsonDecode(resBody) as Map<String, dynamic>;
        if (decoded['success'] == true || decoded['status'] == 'success') {
          aiResult = decoded;
        }
      }
    } catch (_) {
      // Fallback ke profil lokal jika AI Server belum dijalankan
    }

    final formattedDate = _formatCurrentDate();
    late final Map<String, dynamic> record;

    if (aiResult != null) {
      final pc = aiResult['personalColor'] as String? ?? 'Warm Autumn';
      final fallbackProfile =
          _colorProfiles[pc] ?? _colorProfiles['Warm Autumn']!;
      record = {
        'id': 'hist-${DateTime.now().millisecondsSinceEpoch}',
        'userEmail': userEmail,
        'date': formattedDate,
        'skinTone': aiResult['skinTone'] ?? fallbackProfile['skinTone'],
        'skinToneHex':
            aiResult['skinToneHex'] ?? fallbackProfile['skinToneHex'],
        'undertone': aiResult['undertone'] ?? fallbackProfile['undertone'],
        'undertoneHex':
            aiResult['undertoneHex'] ?? fallbackProfile['undertoneHex'],
        'personalColor': pc,
        'summary': aiResult['summary'] ?? fallbackProfile['summary'],
        'confidence': aiResult['confidence'] ?? '85.0%',
        'palette': aiResult['palette'] ?? fallbackProfile['palette'],
        'metrics': aiResult['metrics'],
        'source': 'ai_model',
      };
    } else {
      final chosen = _colorProfiles[preset] ?? _colorProfiles['Warm Autumn']!;
      record = {
        'id': 'hist-${DateTime.now().millisecondsSinceEpoch}',
        'userEmail': userEmail,
        'date': formattedDate,
        ...chosen,
        'confidence': '80.0%',
        'source': 'fallback_profile',
      };
    }

    // Simpan otomatis ke riwayat analisis di db.json (FR-10)
    final history = dbHelper.getHistory();
    history.insert(0, record);
    dbHelper.updateTable('analysis_history', history);

    return {
      'statusCode': HttpStatus.ok,
      'data': {
        'success': true,
        'message': 'Analisis warna kulit berhasil diproses.',
        'result': record,
      },
    };
  }

  /// POST /api/history — Menyimpan hasil analisis secara eksplisit ke database (FR-10)
  Map<String, dynamic> handleSaveHistory(Map<String, dynamic> body) {
    final userEmail = (body['email'] as String? ?? 'yumna@gmail.com').trim();
    final skinTone = (body['skinTone'] as String? ?? 'Medium').trim();
    final undertone = (body['undertone'] as String? ?? 'Warm').trim();
    final personalColor =
        (body['personalColor'] as String? ?? 'Warm Autumn').trim();

    final chosen =
        _colorProfiles[personalColor] ?? _colorProfiles['Warm Autumn']!;
    final newRecord = {
      'id': 'hist-${DateTime.now().millisecondsSinceEpoch}',
      'userEmail': userEmail,
      'date': _formatCurrentDate(),
      'skinTone': skinTone,
      'skinToneHex': body['skinToneHex'] ?? chosen['skinToneHex'],
      'undertone': undertone,
      'undertoneHex': body['undertoneHex'] ?? chosen['undertoneHex'],
      'personalColor': personalColor,
      'summary': body['summary'] ?? chosen['summary'],
      'palette': body['palette'] ?? chosen['palette'],
    };

    final history = dbHelper.getHistory();
    history.insert(0, newRecord);
    dbHelper.updateTable('analysis_history', history);

    return {
      'statusCode': HttpStatus.created,
      'data': {
        'success': true,
        'message': 'Hasil analisis berhasil disimpan ke riwayat.',
        'record': newRecord,
      },
    };
  }

  /// GET /api/history — Mengambil daftar riwayat analisis pengguna (FR-11)
  Map<String, dynamic> handleGetHistory(String? emailFilter) {
    final history = dbHelper.getHistory();
    final cleanEmail = emailFilter?.trim().toLowerCase();

    final filtered = (cleanEmail == null || cleanEmail.isEmpty)
        ? history
        : history.where((h) {
            return (h['userEmail'] as String? ?? '').toLowerCase() ==
                cleanEmail;
          }).toList();

    return {
      'statusCode': HttpStatus.ok,
      'data': {
        'success': true,
        'total': filtered.length,
        'history': filtered.isNotEmpty ? filtered : history,
      },
    };
  }

  /// DELETE /api/history?id=... — Menghapus satu item riwayat analisis (FR-11)
  Map<String, dynamic> handleDeleteHistory(String? id) {
    if (id == null || id.isEmpty) {
      return {
        'statusCode': HttpStatus.badRequest,
        'data': {
          'success': false,
          'message': 'ID riwayat wajib disertakan.',
        },
      };
    }

    final history = dbHelper.getHistory();
    history.removeWhere((h) => h['id'] == id);
    dbHelper.updateTable('analysis_history', history);

    return {
      'statusCode': HttpStatus.ok,
      'data': {
        'success': true,
        'message': 'Riwayat analisis berhasil dihapus.',
      },
    };
  }

  /// POST /api/premium/unlock — Membuka kunci fitur Personal Color Premium (FR-12)
  Map<String, dynamic> handleUnlockPremium(Map<String, dynamic> body) {
    final email = (body['email'] as String? ?? '').trim().toLowerCase();
    final users = dbHelper.getUsers();

    for (final u in users) {
      if ((u['email'] as String? ?? '').toLowerCase() == email) {
        u['isPremium'] = true;
      }
    }
    dbHelper.updateTable('users', users);

    return {
      'statusCode': HttpStatus.ok,
      'data': {
        'success': true,
        'isPremium': true,
        'message': 'Fitur Cocokin Premium berhasil diaktifkan.',
      },
    };
  }

  String _formatCurrentDate() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')} '
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
  }
}
