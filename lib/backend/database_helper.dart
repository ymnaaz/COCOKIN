import 'dart:convert';
import 'dart:io';

/// Lapisan Akses Database JSON (Database Helper) untuk Backend Cocokin
/// Menangani pembacaan, penyimpanan, pencarian, dan pembaruan data pada db.json
class DatabaseHelper {
  final File _dbFile;

  DatabaseHelper({String dbPath = 'lib/backend/db.json'})
      : _dbFile = File(dbPath);

  /// Membaca seluruh isi database dari file db.json
  Map<String, dynamic> readDatabase() {
    if (_dbFile.existsSync()) {
      try {
        final raw = _dbFile.readAsStringSync();
        if (raw.trim().isNotEmpty) {
          return jsonDecode(raw) as Map<String, dynamic>;
        }
      } catch (_) {}
    }
    return {
      'users': <Map<String, dynamic>>[],
      'analysis_history': <Map<String, dynamic>>[],
      'products': <Map<String, dynamic>>[],
    };
  }

  /// Menyimpan perubahan data kembali ke file db.json secara permanen
  void writeDatabase(Map<String, dynamic> data) {
    try {
      final formatted = const JsonEncoder.withIndent('  ').convert(data);
      _dbFile.writeAsStringSync(formatted);
    } catch (_) {}
  }

  /// Mengambil tabel users
  List<Map<String, dynamic>> getUsers() {
    final db = readDatabase();
    return (db['users'] as List? ?? []).cast<Map<String, dynamic>>();
  }

  /// Mengambil tabel analysis_history
  List<Map<String, dynamic>> getHistory() {
    final db = readDatabase();
    return (db['analysis_history'] as List? ?? []).cast<Map<String, dynamic>>();
  }

  /// Mengambil tabel products
  List<Map<String, dynamic>> getProducts() {
    final db = readDatabase();
    return (db['products'] as List? ?? []).cast<Map<String, dynamic>>();
  }

  /// Menyimpan pembaruan pada salah satu tabel
  void updateTable(String tableName, List<Map<String, dynamic>> rows) {
    final db = readDatabase();
    db[tableName] = rows;
    writeDatabase(db);
  }
}
