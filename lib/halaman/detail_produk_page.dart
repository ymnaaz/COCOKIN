import 'package:flutter/material.dart';
import '../main.dart';
import 'rekomendasi_page.dart';

class DetailProdukPage extends StatefulWidget {
  final Map<String, dynamic> product;

  const DetailProdukPage({super.key, required this.product});

  @override
  State<DetailProdukPage> createState() => _DetailProdukPageState();
}

class _DetailProdukPageState extends State<DetailProdukPage> {
  late String _selectedShadeName;

  @override
  void initState() {
    super.initState();
    _selectedShadeName = widget.product['shade'] as String;
  }

  void _showEcommerceSheet(BuildContext context, String storeName, String url) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: CocokinColors.textDark,
        content: Text(
          'Membuka halaman $storeName: $url',
          style: const TextStyle(fontSize: 12),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.product;
    final shades = (p['allShades'] as List).cast<Map<String, dynamic>>();

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: CocokinColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            height: 190,
            decoration: BoxDecoration(
              color: const Color(0xFFFAF7F5),
              borderRadius: BorderRadius.circular(14),
            ),
            alignment: Alignment.center,
            child: buildProductIllustrationWidget(p['type'] as String),
          ),
          const SizedBox(height: 14),
          Text(
            '${p['brand']} • ${p['category']}'.toUpperCase(),
            style: const TextStyle(
              fontSize: 10.5,
              letterSpacing: 1.1,
              fontWeight: FontWeight.w700,
              color: CocokinColors.primaryMauve,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            p['name'] as String,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: CocokinColors.textDark,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            p['priceLabel'] as String,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: CocokinColors.primaryMauve,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            p['description'] as String,
            style: const TextStyle(fontSize: 12.5, color: CocokinColors.textBody),
          ),
          const SizedBox(height: 16),

          const Text(
            'Pilihan Shade:',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: CocokinColors.textDark,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: shades.map((sh) {
              final name = sh['name'] as String;
              final hex = sh['hex'] as int;
              final active = _selectedShadeName == name;
              return GestureDetector(
                onTap: () => setState(() => _selectedShadeName = name),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: active ? CocokinColors.bgSoftPink : Colors.white,
                    borderRadius: BorderRadius.circular(99),
                    border: Border.all(
                      color: active
                          ? CocokinColors.primaryMauve
                          : CocokinColors.borderCard,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 13,
                        height: 13,
                        decoration: BoxDecoration(
                          color: Color(hex),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        name,
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight:
                              active ? FontWeight.w700 : FontWeight.w500,
                          color: CocokinColors.textDark,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 14),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: CocokinColors.bgSoftPink,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              p['whyMatch'] as String,
              style: const TextStyle(fontSize: 12, color: CocokinColors.textDark),
            ),
          ),
          const SizedBox(height: 18),
          const Divider(color: CocokinColors.borderLight, height: 1),
          const SizedBox(height: 14),

          const Text(
            'Tautan Pembelian E-Commerce:',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: CocokinColors.textDark,
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _showEcommerceSheet(
                context,
                'Shopee',
                p['shopeeUrl'] as String,
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: CocokinColors.primaryMauve,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Beli di Shopee ↗',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => _showEcommerceSheet(
                context,
                'Tokopedia',
                p['tokopediaUrl'] as String,
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: CocokinColors.textDark,
                side: const BorderSide(color: CocokinColors.borderCard),
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Beli di Tokopedia ↗',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
