import 'dart:ui';
import 'package:flutter/material.dart';
import '../main.dart';
import '../services/api_service.dart';

class HasilPage extends StatefulWidget {
  final VoidCallback onGoToRekomendasi;
  final VoidCallback? onGoToRiwayat;

  const HasilPage({
    super.key,
    required this.onGoToRekomendasi,
    this.onGoToRiwayat,
  });

  @override
  State<HasilPage> createState() => _HasilPageState();
}

class _HasilPageState extends State<HasilPage> {
  bool _isPremiumUnlocked = false;
  bool _isSaved = false;

  Future<void> _handleUnlockPremium() async {
    await ApiService.unlockPremium('yumna@gmail.com');
    if (mounted) {
      setState(() => _isPremiumUnlocked = true);
    }
  }

  Future<void> _handleSaveResult() async {
    await ApiService.saveHistory(
      email: 'yumna@gmail.com',
      skinTone: 'Medium',
      undertone: 'Warm',
      personalColor: 'Warm Autumn',
    );
    if (!mounted) return;
    setState(() => _isSaved = true);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: CocokinColors.textDark,
        content: Text(
          'Hasil analisis berhasil disimpan ke Riwayat Akun.',
          style: TextStyle(fontSize: 12),
        ),
        duration: Duration(seconds: 2),
      ),
    );
    if (widget.onGoToRiwayat != null) {
      widget.onGoToRiwayat!();
    }
  }

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

        // 2 Kartu Terbuka: Skin Tone (Medium) & Undertone (Warm)
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 20,
                  horizontal: 12,
                ),
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
                      style: TextStyle(
                        fontSize: 11.5,
                        color: CocokinColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 20,
                  horizontal: 12,
                ),
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
                      style: TextStyle(
                        fontSize: 11.5,
                        color: CocokinColors.textMuted,
                      ),
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
                style: TextStyle(
                  fontSize: 11.5,
                  color: CocokinColors.textMuted,
                ),
              ),
              const SizedBox(height: 4),
              Stack(
                alignment: Alignment.center,
                children: [
                  ImageFiltered(
                    imageFilter: _isPremiumUnlocked
                        ? ImageFilter.blur(sigmaX: 0, sigmaY: 0)
                        : ImageFilter.blur(sigmaX: 6, sigmaY: 6),
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
                          style: TextStyle(
                            fontSize: 12,
                            color: CocokinColors.textBody,
                          ),
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

                  if (!_isPremiumUnlocked)
                    GestureDetector(
                      onTap: _handleUnlockPremium,
                      child: Column(
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
                            'Terkunci (Ketuk untuk Buka Premium)',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: CocokinColors.textDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: widget.onGoToRekomendasi,
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
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: _handleSaveResult,
            style: OutlinedButton.styleFrom(
              foregroundColor: CocokinColors.textDark,
              side: const BorderSide(color: CocokinColors.borderCard),
              padding: const EdgeInsets.symmetric(vertical: 13),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              _isSaved
                  ? 'Lihat Riwayat Hasil Analisis'
                  : 'Simpan & Lihat Riwayat Analisis',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
