import 'dart:io';
import 'database_helper.dart';

/// Controller Backend untuk Fitur Autentikasi Pengguna & Admin (FR-01 & FR-02)
class AuthController {
  final DatabaseHelper dbHelper;

  AuthController(this.dbHelper);

  /// POST /api/login — Validasi kredensial login pengguna & admin
  Map<String, dynamic> handleLogin(Map<String, dynamic> body) {
    final email = (body['email'] as String? ?? '').trim().toLowerCase();
    final password = (body['password'] as String? ?? '').trim();

    if (email.isEmpty || password.isEmpty) {
      return {
        'statusCode': HttpStatus.badRequest,
        'data': {
          'success': false,
          'message': 'Email dan password wajib diisi.',
        },
      };
    }

    if (!email.contains('@')) {
      return {
        'statusCode': HttpStatus.badRequest,
        'data': {
          'success': false,
          'message': 'Format email tidak valid.',
        },
      };
    }

    final users = dbHelper.getUsers();
    final match = users.where((u) {
      return (u['email'] as String? ?? '').toLowerCase() == email;
    }).toList();

    if (match.isNotEmpty) {
      final user = match.first;
      if (user['password'] != password) {
        return {
          'statusCode': HttpStatus.unauthorized,
          'data': {
            'success': false,
            'message': 'Password yang dimasukkan salah.',
          },
        };
      }

      return {
        'statusCode': HttpStatus.ok,
        'data': {
          'success': true,
          'message': 'Berhasil masuk.',
          'user': {
            'id': user['id'],
            'name': user['name'],
            'email': user['email'],
            'role': user['role'] ?? 'user',
            'isPremium': user['isPremium'] ?? false,
          },
        },
      };
    }

    // Jika akun belum ada di db.json pada mode prototipe, buat sesi otomatis
    final isAdmin = email.contains('admin');
    final newUser = {
      'id': 'usr-${DateTime.now().millisecondsSinceEpoch}',
      'name': isAdmin ? 'Admin Cocokin' : email.split('@').first,
      'email': email,
      'password': password,
      'role': isAdmin ? 'admin' : 'user',
      'isPremium': isAdmin,
    };

    users.add(newUser);
    dbHelper.updateTable('users', users);

    return {
      'statusCode': HttpStatus.ok,
      'data': {
        'success': true,
        'message': 'Berhasil masuk.',
        'user': {
          'id': newUser['id'],
          'name': newUser['name'],
          'email': newUser['email'],
          'role': newUser['role'],
          'isPremium': newUser['isPremium'],
        },
      },
    };
  }

  /// POST /api/register — Pendaftaran pengguna baru ke database
  Map<String, dynamic> handleRegister(Map<String, dynamic> body) {
    final name = (body['name'] as String? ?? '').trim();
    final email = (body['email'] as String? ?? '').trim().toLowerCase();
    final password = (body['password'] as String? ?? '').trim();

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      return {
        'statusCode': HttpStatus.badRequest,
        'data': {
          'success': false,
          'message': 'Nama lengkap, email, dan password wajib diisi.',
        },
      };
    }

    if (password.length < 8) {
      return {
        'statusCode': HttpStatus.badRequest,
        'data': {
          'success': false,
          'message': 'Password minimal harus terdiri dari 8 karakter.',
        },
      };
    }

    final users = dbHelper.getUsers();
    final alreadyExists = users.any(
      (u) => (u['email'] as String? ?? '').toLowerCase() == email,
    );

    if (alreadyExists) {
      return {
        'statusCode': HttpStatus.conflict,
        'data': {
          'success': false,
          'message': 'Email sudah terdaftar. Silakan masuk.',
        },
      };
    }

    final newUser = {
      'id': 'usr-${DateTime.now().millisecondsSinceEpoch}',
      'name': name,
      'email': email,
      'password': password,
      'role': email.contains('admin') ? 'admin' : 'user',
      'isPremium': false,
    };

    users.add(newUser);
    dbHelper.updateTable('users', users);

    return {
      'statusCode': HttpStatus.created,
      'data': {
        'success': true,
        'message': 'Akun berhasil dibuat.',
        'user': {
          'id': newUser['id'],
          'name': newUser['name'],
          'email': newUser['email'],
          'role': newUser['role'],
          'isPremium': newUser['isPremium'],
        },
      },
    };
  }
}
