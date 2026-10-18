import 'dart:ui';
import 'package:flutter/material.dart';
import '../main.dart';

class HasilPage extends StatelessWidget {
  final VoidCallback onGoToRekomendasi;

  const HasilPage({super.key, required this.onGoToRekomendasi});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          'HASIL COLOR ANALYSIS',
          style: TextStyle(
            fontSize: 10.5,
            letterSpacing: 1.2,
            fontWeight: FontWeight.w700,
            color: CocokinColors.primaryMauve,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Ini warna yang cocok\nuntukmu!',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 22,
            height: 1.2,
            fontWeight: FontWeight.w700,
            color: CocokinColors.textDark,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Berikut hasil analisis warna personalmu.',
          style: TextStyle(fontSize: 12.5, color: CocokinColors.textBody),
        ),
        const SizedBox(height: 18),

        // 2 Kartu Terbuka: Skin Tone (Medium) & Undertone (Warm) sesuai Halaman 5 Figma
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
                decoration: BoxDecoration(
                  color: CocokinColors.bgSoftPink,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: CocokinColors.borderCard),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: const BoxDecoration(
                        color: Color(0xFF8C6258),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Medium',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: CocokinColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Skin Tone',
                      style: TextStyle(fontSize: 11.5, color: CocokinColors.textMuted),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: CocokinColors.borderCard),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: const BoxDecoration(
                        color: Color(0xFFDEC4A1),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Warm',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: CocokinColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Undertone',
                      style: TextStyle(fontSize: 11.5, color: CocokinColors.textMuted),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // Kartu Personal Color: Di-blur & Diberi Gembok untuk Fitur Premium
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: CocokinColors.borderCard),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Personal Color',
                style: TextStyle(fontSize: 11.5, color: CocokinColors.textMuted),
              ),
              const SizedBox(height: 4),
              Stack(
                alignment: Alignment.center,
                children: [
                  ImageFiltered(
                    imageFilter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Warm Autumn',
                          style: TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.w700,
                            color: CocokinColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Palet warna hangat dengan nuansa earthy yang bisa kamu jadikan referensi.',
                          style: TextStyle(fontSize: 12, color: CocokinColors.textBody),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            for (final hex in [
                              const Color(0xFF6B381B),
                              const Color(0xFFC6946E),
                              const Color(0xFFE1BBA0),
                              const Color(0xFF8EAE86),
                            ])
                              Expanded(
                                child: Container(
                                  height: 42,
                                  margin: const EdgeInsets.only(right: 8),
                                  decoration: BoxDecoration(
                                    color: hex,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Gembok Fitur Premium di Tengah Area Blur
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: const BoxDecoration(
                          color: CocokinColors.primaryMauve,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.lock_outline,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Terkunci (Fitur Premium)',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: CocokinColors.textDark,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),

        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: onGoToRekomendasi,
            style: ElevatedButton.styleFrom(
              backgroundColor: CocokinColors.primaryMauve,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'Lihat Rekomendasi Produk →',
              style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }
}
