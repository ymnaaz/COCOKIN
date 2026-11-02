import 'dart:io';
import 'database_helper.dart';

/// Controller Backend untuk Fitur Analisis Warna, Riwayat Analisis, & Fitur Premium
/// Mencakup FR-03, FR-04, FR-05, FR-10, FR-11, dan FR-12
class AnalysisController {
  final DatabaseHelper dbHelper;

  AnalysisController(this.dbHelper);

  static const Map<String, Map<String, dynamic>> _colorProfiles = {
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

  /// POST /api/analyze — Validasi input foto & proses analisis warna kulit (FR-03, FR-04, FR-05)
  Map<String, dynamic> handleAnalyzePhoto(Map<String, dynamic> body) {
    final imageName = (body['image'] as String? ?? 'kamera_wajah.png').trim();
    final userEmail = (body['email'] as String? ?? 'yumna@gmail.com').trim();
    final preset = (body['preset'] as String? ?? 'Warm Autumn').trim();

    // Validasi ekstensi file foto (FR-04 / BB-06)
    final lowerImg = imageName.toLowerCase();
    final validExt = lowerImg.endsWith('.png') ||
        lowerImg.endsWith('.jpg') ||
        lowerImg.endsWith('.jpeg') ||
        lowerImg.endsWith('.webp');

    if (!validExt) {
      return {
        'statusCode': HttpStatus.badRequest,
        'data': {
          'success': false,
          'message':
              'Format file foto tidak didukung. Gunakan JPG, JPEG, atau PNG.',
        },
      };
    }

    final chosen = _colorProfiles[preset] ?? _colorProfiles['Warm Autumn']!;
    final formattedDate = _formatCurrentDate();

    final record = {
      'id': 'hist-${DateTime.now().millisecondsSinceEpoch}',
      'userEmail': userEmail,
      'date': formattedDate,
      ...chosen,
    };

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
      'skinToneHex': chosen['skinToneHex'],
      'undertone': undertone,
      'undertoneHex': chosen['undertoneHex'],
      'personalColor': personalColor,
      'palette': chosen['palette'],
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
