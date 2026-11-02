import 'dart:io';
import 'database_helper.dart';

/// Controller Backend untuk Katalog Produk, Pencocokan Shade, Filter Budget, & Admin CRUD
/// Mencakup FR-06, FR-07, FR-08, FR-09, FR-13, dan FR-14
class ProductController {
  final DatabaseHelper dbHelper;

  ProductController(this.dbHelper);

  /// GET /api/products — Mengambil produk dengan filter kategori, undertone, & rentang budget (FR-06, FR-07, FR-08)
  Map<String, dynamic> handleGetProducts(Map<String, String> queryParams) {
    final products = dbHelper.getProducts();
    final category = queryParams['category'];
    final undertone = queryParams['undertone'];
    final minPrice = int.tryParse(queryParams['minPrice'] ?? '');
    final maxPrice = int.tryParse(queryParams['maxPrice'] ?? '');

    final filtered = products.where((p) {
      final matchCat = category == null ||
          category.isEmpty ||
          category == 'Semua' ||
          p['category'] == category;

      final matchUndertone = undertone == null ||
          undertone.isEmpty ||
          p['undertone'] == null ||
          (p['undertone'] as String).toLowerCase() == undertone.toLowerCase();

      final price = p['price'] as int? ?? 0;
      final matchMin = minPrice == null || price >= minPrice;
      final matchMax = maxPrice == null || price <= maxPrice;

      return matchCat && matchUndertone && matchMin && matchMax;
    }).toList();

    return {
      'statusCode': HttpStatus.ok,
      'data': {
        'success': true,
        'total': filtered.length,
        'products': filtered,
      },
    };
  }

  /// POST /api/products — Admin menambah produk & shade baru ke katalog (FR-13 & FR-14)
  Map<String, dynamic> handleCreateProduct(Map<String, dynamic> body) {
    final name = (body['name'] as String? ?? '').trim();
    final brand = (body['brand'] as String? ?? '').trim();
    final shade = (body['shade'] as String? ?? '01 Natural').trim();
    final price = int.tryParse(body['price']?.toString() ?? '') ?? 50000;
    final category = (body['category'] as String? ?? 'Lip Product').trim();

    if (name.isEmpty || brand.isEmpty) {
      return {
        'statusCode': HttpStatus.badRequest,
        'data': {
          'success': false,
          'message': 'Nama produk dan brand wajib diisi.',
        },
      };
    }

    final products = dbHelper.getProducts();
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
      'description': body['description'] ??
          'Produk rekomendasi makeup yang sesuai dengan karakteristik warna kulitmu.',
      'whyMatch': body['whyMatch'] ??
          'Shade $shade direkomendasikan untuk menonjolkan rona alami wajahmu.',
      'allShades': [
        {'name': shade, 'hex': body['shadeHex'] ?? 0xFFB6634B},
      ],
      'shopeeUrl': body['shopeeUrl'] ??
          'https://shopee.co.id/search?keyword=${Uri.encodeComponent('$brand $name')}',
      'tokopediaUrl': body['tokopediaUrl'] ??
          'https://www.tokopedia.com/search?st=product&q=${Uri.encodeComponent('$brand $name')}',
    };

    products.insert(0, newProd);
    dbHelper.updateTable('products', products);

    return {
      'statusCode': HttpStatus.created,
      'data': {
        'success': true,
        'message': 'Produk baru berhasil ditambahkan.',
        'product': newProd,
      },
    };
  }

  /// DELETE /api/products?id=... — Admin menghapus produk dari katalog (FR-13)
  Map<String, dynamic> handleDeleteProduct(String? id) {
    if (id == null || id.isEmpty) {
      return {
        'statusCode': HttpStatus.badRequest,
        'data': {
          'success': false,
          'message': 'ID produk wajib disertakan.',
        },
      };
    }

    final products = dbHelper.getProducts();
    products.removeWhere((p) => p['id'] == id);
    dbHelper.updateTable('products', products);

    return {
      'statusCode': HttpStatus.ok,
      'data': {
        'success': true,
        'message': 'Produk berhasil dihapus dari database.',
      },
    };
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
}
