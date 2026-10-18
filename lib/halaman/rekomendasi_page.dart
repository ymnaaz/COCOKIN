import 'package:flutter/material.dart';
import '../main.dart';

const List<Map<String, dynamic>> kCatalogProducts = [
  {
    'id': 'prod-1',
    'name': 'Lip Cream',
    'brand': 'Make Over',
    'shade': 'Warm Teracotta',
    'shadeHex': 0xFFB6634B,
    'price': 45000,
    'priceLabel': 'Rp45.000',
    'category': 'Lip Product',
    'type': 'lip',
    'description':
        'Lip cream bertekstur velvet lembut dengan warna terracotta hangat yang menyatu alami di bibir tanpa membuat kering.',
    'whyMatch':
        'Shade Warm Teracotta selaras dengan undertone Warm dan menonjolkan rona kulit Medium.',
    'allShades': [
      {'name': 'Warm Teracotta', 'hex': 0xFFB6634B},
      {'name': 'Caramel Nude', 'hex': 0xFFC6846D},
      {'name': 'Dusty Rose', 'hex': 0xFFB86B79},
    ],
    'shopeeUrl': 'https://shopee.co.id/search?keyword=lip%20cream%20warm%20terracotta',
    'tokopediaUrl': 'https://www.tokopedia.com/search?st=product&q=lip%20cream%20terracotta',
  },
  {
    'id': 'prod-2',
    'name': 'Blush',
    'brand': 'Emina',
    'shade': 'Peach Sun',
    'shadeHex': 0xFFDE876B,
    'price': 55000,
    'priceLabel': 'Rp55.000',
    'category': 'Blush',
    'type': 'blush',
    'description':
        'Pressed powder blush dengan pigmen halus yang memberikan rona pipi hangat alami sepanjang hari.',
    'whyMatch':
        'Shade Peach Sun memberikan efek segar alami pada kulit Medium dengan undertone Warm.',
    'allShades': [
      {'name': 'Peach Sun', 'hex': 0xFFDE876B},
      {'name': 'Soft Mauve', 'hex': 0xFFCFA0A8},
    ],
    'shopeeUrl': 'https://shopee.co.id/search?keyword=blush%20peach%20sun',
    'tokopediaUrl': 'https://www.tokopedia.com/search?st=product&q=blush%20peach',
  },
  {
    'id': 'prod-3',
    'name': 'Eye Shadow',
    'brand': 'Luxcrime',
    'shade': 'Brown',
    'shadeHex': 0xFF8C624C,
    'price': 125000,
    'priceLabel': 'Rp125.000',
    'category': 'Eye Makeup',
    'type': 'eyeshadow',
    'description':
        'Palet eyeshadow 9 warna dengan kombinasi matte dan shimmer bernuansa cokelat hangat dan champagne.',
    'whyMatch':
        'Nuansa earthy brown mempertegas kelopak mata tanpa terlihat berlebihan untuk tampilan harian.',
    'allShades': [
      {'name': 'Brown Earth', 'hex': 0xFF8C624C},
      {'name': 'Cool Taupe', 'hex': 0xFF8E7B82},
    ],
    'shopeeUrl': 'https://shopee.co.id/search?keyword=eyeshadow%20palette%20brown',
    'tokopediaUrl': 'https://www.tokopedia.com/search?st=product&q=eyeshadow%20palette%20brown',
  },
  {
    'id': 'prod-4',
    'name': 'Mesh Cushion',
    'brand': 'Somethinc',
    'shade': 'W02 Warm Sand',
    'shadeHex': 0xFFD9AF8B,
    'price': 145000,
    'priceLabel': 'Rp145.000',
    'category': 'Complexion',
    'type': 'cushion',
    'description':
        'Cushion ringan dengan coverage medium-to-full yang meratakan warna kulit tanpa membuat wajah terlihat abu-abu.',
    'whyMatch':
        'Rona dasar kuning hangat pada shade W02 Warm Sand menyatu pas dengan kulit Medium Warm.',
    'allShades': [
      {'name': 'W02 Warm Sand', 'hex': 0xFFD9AF8B},
      {'name': 'C01 Cool Ivory', 'hex': 0xFFECD1C2},
    ],
    'shopeeUrl': 'https://shopee.co.id/search?keyword=cushion%20warm%20sand',
    'tokopediaUrl': 'https://www.tokopedia.com/search?st=product&q=cushion%20warm%20sand',
  },
];

class RekomendasiPage extends StatefulWidget {
  final ValueChanged<Map<String, dynamic>> onSelectProduct;

  const RekomendasiPage({super.key, required this.onSelectProduct});

  @override
  State<RekomendasiPage> createState() => _RekomendasiPageState();
}

class _RekomendasiPageState extends State<RekomendasiPage> {
  String _selectedCat = 'Semua';
  String _selectedPriceRange = 'all';

  final List<String> _categories = [
    'Semua',
    'Complexion',
    'Eye Makeup',
    'Blush',
    'Lip Product',
  ];

  final List<Map<String, dynamic>> _priceRanges = [
    {'id': 'all', 'label': 'Semua Harga', 'min': 0, 'max': 999999},
    {'id': 'under50', 'label': '< Rp50rb', 'min': 0, 'max': 50000},
    {'id': '50to100', 'label': 'Rp50rb - 100rb', 'min': 50000, 'max': 100000},
    {'id': 'above100', 'label': '> Rp100rb', 'min': 100001, 'max': 999999},
  ];

  @override
  Widget build(BuildContext context) {
    final activeRange = _priceRanges.firstWhere(
      (r) => r['id'] == _selectedPriceRange,
      orElse: () => _priceRanges.first,
    );

    final filtered = kCatalogProducts.where((p) {
      final matchCat =
          _selectedCat == 'Semua' || p['category'] == _selectedCat;
      final price = p['price'] as int;
      final matchPrice =
          price >= (activeRange['min'] as int) &&
          price <= (activeRange['max'] as int);
      return matchCat && matchPrice;
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Temukan makeup produk\nyang cocok untukmu!',
          style: TextStyle(
            fontSize: 21,
            height: 1.25,
            fontWeight: FontWeight.w700,
            color: CocokinColors.textDark,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Rekomendasi berdasarkan personal color dan budget kamu.',
          style: TextStyle(fontSize: 12.5, color: CocokinColors.textBody),
        ),
        const SizedBox(height: 14),

        // Pill Kategori sesuai Halaman 6 Figma
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _categories.map((cat) {
            final active = _selectedCat == cat;
            return GestureDetector(
              onTap: () => setState(() => _selectedCat = cat),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: active ? CocokinColors.primaryMauve : Colors.white,
                  borderRadius: BorderRadius.circular(99),
                  border: Border.all(
                    color: active
                        ? CocokinColors.primaryMauve
                        : CocokinColors.borderCard,
                  ),
                ),
                child: Text(
                  cat,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: active ? Colors.white : CocokinColors.textBody,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 14),

        // Filter Range Harga (Budget)
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: CocokinColors.borderLight),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Rentang Harga (Budget):',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: CocokinColors.textDark,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: _priceRanges.map((r) {
                  final active = _selectedPriceRange == r['id'];
                  return GestureDetector(
                    onTap: () =>
                        setState(() => _selectedPriceRange = r['id'] as String),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 11,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: active
                            ? CocokinColors.bgSoftPink
                            : CocokinColors.bgMain,
                        borderRadius: BorderRadius.circular(99),
                        border: Border.all(
                          color: active
                              ? CocokinColors.primaryMauve
                              : CocokinColors.borderCard,
                        ),
                      ),
                      child: Text(
                        r['label'] as String,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: active
                              ? FontWeight.w700
                              : FontWeight.w500,
                          color: CocokinColors.textDark,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),
        const Divider(color: CocokinColors.borderLight, height: 1),
        const SizedBox(height: 14),

        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Pilihan untukmu',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: CocokinColors.textDark,
              ),
            ),
            Text(
              'Ketuk produk untuk detail',
              style: TextStyle(
                fontSize: 11,
                color: CocokinColors.textMuted,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        if (filtered.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: CocokinColors.borderLight),
            ),
            child: Column(
              children: [
                const Text(
                  'Belum ada produk pada filter harga ini.',
                  style: TextStyle(fontSize: 12.5, color: CocokinColors.textBody),
                ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _selectedCat = 'Semua';
                      _selectedPriceRange = 'all';
                    });
                  },
                  child: const Text('Reset Filter'),
                ),
              ],
            ),
          )
        else
          for (final item in filtered) ...[
            _buildProductCard(item),
            const SizedBox(height: 14),
          ],
      ],
    );
  }

  Widget _buildProductCard(Map<String, dynamic> item) {
    return GestureDetector(
      onTap: () => widget.onSelectProduct(item),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: CocokinColors.borderLight),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              height: 165,
              decoration: BoxDecoration(
                color: const Color(0xFFFAF7F5),
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: buildProductIllustrationWidget(item['type'] as String),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  item['name'] as String,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1F1614),
                  ),
                ),
                Text(
                  item['brand'] as String,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: CocokinColors.textMuted,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              item['shade'] as String,
              style: const TextStyle(fontSize: 12, color: CocokinColors.textMuted),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  item['priceLabel'] as String,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: CocokinColors.primaryMauve,
                  ),
                ),
                const Text(
                  'Lihat Detail & Beli →',
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: CocokinColors.textBody,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

Widget buildProductIllustrationWidget(String type) {
  if (type == 'lip') {
    return SizedBox(
      width: 110,
      height: 120,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Transform.rotate(
            angle: -0.4,
            child: Container(
              width: 65,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFFBA6650),
                borderRadius: BorderRadius.circular(24),
              ),
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 16,
                    height: 26,
                    decoration: const BoxDecoration(
                      color: Color(0xFFB25944),
                      borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
                    ),
                  ),
                  Container(
                    width: 22,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF2DDD0),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 4),
              Container(
                width: 22,
                height: 38,
                decoration: BoxDecoration(
                  color: const Color(0xFFEBD2C3),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  if (type == 'blush') {
    return Container(
      width: 106,
      height: 106,
      decoration: const BoxDecoration(
        color: Color(0xFFD5B8A3),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Container(
        width: 78,
        height: 78,
        decoration: const BoxDecoration(
          color: Color(0xFFE08B70),
          shape: BoxShape.circle,
        ),
      ),
    );
  }

  if (type == 'cushion') {
    return Container(
      width: 108,
      height: 108,
      decoration: BoxDecoration(
        color: const Color(0xFFEBD6C8),
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFFCBB09E), width: 3),
      ),
      alignment: Alignment.center,
      child: Container(
        width: 76,
        height: 76,
        decoration: const BoxDecoration(
          color: Color(0xFFD9AF8B),
          shape: BoxShape.circle,
        ),
      ),
    );
  }

  final pans = [
    const Color(0xFFD9B89C),
    const Color(0xFFC49A7B),
    const Color(0xFFE5CBB5),
    const Color(0xFFCE9F7C),
    const Color(0xFFB88766),
    const Color(0xFF9B6B4F),
    const Color(0xFFB3856A),
    const Color(0xFF9A694F),
    const Color(0xFF7E523C),
  ];

  return Container(
    width: 112,
    height: 112,
    padding: const EdgeInsets.all(8),
    decoration: BoxDecoration(
      color: const Color(0xFF6F4937),
      borderRadius: BorderRadius.circular(8),
    ),
    child: GridView.count(
      crossAxisCount: 3,
      mainAxisSpacing: 5,
      crossAxisSpacing: 5,
      physics: const NeverScrollableScrollPhysics(),
      children: pans
          .map(
            (c) => Container(
              decoration: BoxDecoration(
                color: c,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          )
          .toList(),
    ),
  );
}
