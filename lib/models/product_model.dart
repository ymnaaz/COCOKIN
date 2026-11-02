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
  final bool isPremiumLocked;

  const AnalysisResultModel({
    required this.skinTone,
    required this.skinToneHex,
    required this.undertone,
    required this.undertoneHex,
    required this.personalColor,
    this.isPremiumLocked = true,
  });

  factory AnalysisResultModel.fromJson(Map<String, dynamic> json) {
    return AnalysisResultModel(
      skinTone: json['skinTone'] as String? ?? 'Medium',
      skinToneHex: json['skinToneHex'] as int? ?? 0xFF8C6258,
      undertone: json['undertone'] as String? ?? 'Warm',
      undertoneHex: json['undertoneHex'] as int? ?? 0xFFDEC4A1,
      personalColor: json['personalColor'] as String? ?? 'Warm Autumn',
      isPremiumLocked: json['isPremiumLocked'] as bool? ?? true,
    );
  }
}
