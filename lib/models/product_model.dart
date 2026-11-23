class ProductModel {
  final String id;
  final String name;
  final String brand;
  final String shade;
  final int shadeHex;
  final int price;
  final String priceLabel;
  final String category;
  final String type;
  final String description;
  final String whyMatch;
  final List<Map<String, dynamic>> allShades;
  final String shopeeUrl;
  final String tokopediaUrl;

  const ProductModel({
    required this.id,
    required this.name,
    required this.brand,
    required this.shade,
    required this.shadeHex,
    required this.price,
    required this.priceLabel,
    required this.category,
    required this.type,
    required this.description,
    required this.whyMatch,
    required this.allShades,
    required this.shopeeUrl,
    required this.tokopediaUrl,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] as String,
      name: json['name'] as String,
      brand: json['brand'] as String,
      shade: json['shade'] as String,
      shadeHex: json['shadeHex'] as int,
      price: json['price'] as int,
      priceLabel: json['priceLabel'] as String,
      category: json['category'] as String,
      type: json['type'] as String,
      description: json['description'] as String,
      whyMatch: json['whyMatch'] as String,
      allShades: (json['allShades'] as List).cast<Map<String, dynamic>>(),
      shopeeUrl: json['shopeeUrl'] as String,
      tokopediaUrl: json['tokopediaUrl'] as String,
    );
  }
}

class AnalysisResultModel {
  final String skinTone;
  final int skinToneHex;
  final String undertone;
  final int undertoneHex;
  final String personalColor;
  final String summary;
  final String confidence;
  final List<Map<String, dynamic>> palette;
  final Map<String, dynamic>? metrics;
  final bool isPremiumLocked;

  const AnalysisResultModel({
    required this.skinTone,
    required this.skinToneHex,
    required this.undertone,
    required this.undertoneHex,
    required this.personalColor,
    this.summary =
        'Palet warna hangat dengan nuansa earthy yang bisa kamu jadikan referensi.',
    this.confidence = '85.0%',
    this.palette = const [
      {'name': 'Deep Espresso', 'hex': 0xFF6B381B},
      {'name': 'Warm Caramel', 'hex': 0xFFC6946E},
      {'name': 'Soft Sand Peach', 'hex': 0xFFE1BBA0},
      {'name': 'Muted Sage Olive', 'hex': 0xFF8EAE86},
    ],
    this.metrics,
    this.isPremiumLocked = true,
  });

  factory AnalysisResultModel.fromJson(Map<String, dynamic> json) {
    final rawPalette = json['palette'] as List?;
    final parsedPalette = rawPalette != null
        ? rawPalette
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList()
        : const [
            {'name': 'Deep Espresso', 'hex': 0xFF6B381B},
            {'name': 'Warm Caramel', 'hex': 0xFFC6946E},
            {'name': 'Soft Sand Peach', 'hex': 0xFFE1BBA0},
            {'name': 'Muted Sage Olive', 'hex': 0xFF8EAE86},
          ];

    return AnalysisResultModel(
      skinTone: json['skinTone'] as String? ?? 'Medium',
      skinToneHex: (json['skinToneHex'] as num?)?.toInt() ?? 0xFF8C6258,
      undertone: json['undertone'] as String? ?? 'Warm',
      undertoneHex: (json['undertoneHex'] as num?)?.toInt() ?? 0xFFDEC4A1,
      personalColor: json['personalColor'] as String? ?? 'Warm Autumn',
      summary: json['summary'] as String? ??
          'Palet warna referensi yang selaras dengan karakteristik rona kulitmu.',
      confidence: json['confidence'] as String? ?? '85.0%',
      palette: parsedPalette,
      metrics: json['metrics'] != null
          ? Map<String, dynamic>.from(json['metrics'] as Map)
          : null,
      isPremiumLocked: json['isPremiumLocked'] as bool? ?? true,
    );
  }
}
