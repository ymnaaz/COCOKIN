import 'dart:ui';
import 'package:flutter/material.dart';
import '../main.dart';
import '../models/product_model.dart';
import '../services/api_service.dart';
import '../services/premium_payment_sheet.dart';

class HasilPage extends StatefulWidget {
  final AnalysisResultModel analysisResult;
  final String userEmail;
  final bool isPremiumUser;
  final VoidCallback? onPremiumActivated;
  final VoidCallback onGoToRekomendasi;
  final VoidCallback? onGoToRiwayat;

  const HasilPage({
    super.key,
    required this.analysisResult,
    this.userEmail = 'yumna@gmail.com',
    this.isPremiumUser = false,
    this.onPremiumActivated,
    required this.onGoToRekomendasi,
    this.onGoToRiwayat,
  });

  @override
  State<HasilPage> createState() => _HasilPageState();
}

class _HasilPageState extends State<HasilPage> {
  bool _isPremiumUnlocked = false;
  bool _isSaved = false;

  @override
  void initState() {
    super.initState();
    _isPremiumUnlocked = widget.isPremiumUser;
  }

  @override
  void didUpdateWidget(covariant HasilPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPremiumUser != oldWidget.isPremiumUser) {
      _isPremiumUnlocked = widget.isPremiumUser;
    }
  }

  Future<void> _handleUnlockPremium() async {
    await PremiumPaymentSheet.show(
      context,
      userEmail: widget.userEmail,
      onPaymentSuccess: () {
        if (mounted) {
          setState(() => _isPremiumUnlocked = true);
        }
        widget.onPremiumActivated?.call();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: CocokinColors.textDark,
            content: Text(
              'Pembayaran Sandbox terverifikasi! Cocokin Premium telah aktif.',
              style: TextStyle(fontSize: 12),
            ),
          ),
        );
      },
    );
  }

  Future<void> _handleSaveResult() async {
    final res = widget.analysisResult;
    await ApiService.saveHistory(
      email: widget.userEmail,
      skinTone: res.skinTone,
      skinToneHex: res.skinToneHex,
      undertone: res.undertone,
      undertoneHex: res.undertoneHex,
      personalColor: res.personalColor,
      palette: res.palette,
      karakteristik: res.summary,
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
    final res = widget.analysisResult;
    final hexCodeStr =
        '#${(res.skinToneHex & 0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase()}';

    return Column(
      children: [
        const Text(
          'HASIL AI COLOR ANALYSIS',
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
        Text(
          'Tingkat keyakinan model AI: ${res.confidence} • Warna Kulit: $hexCodeStr',
          style: const TextStyle(fontSize: 12, color: CocokinColors.textBody),
        ),
        const SizedBox(height: 18),

        // 2 Kartu Terbuka Dinamis dari Hasil AI: Skin Tone & Undertone
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
                      decoration: BoxDecoration(
                        color: Color(res.skinToneHex),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      res.skinTone,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: CocokinColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Skin Tone ($hexCodeStr)',
                      style: const TextStyle(
                        fontSize: 11,
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
                      decoration: BoxDecoration(
                        color: Color(res.undertoneHex),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: CocokinColors.borderLight,
                          width: 1.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      res.undertone,
                      style: const TextStyle(
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
        const SizedBox(height: 12),

        // Metrik Ilmiah Pengolahan Citra Digital (CIE-L*a*b* & ITA) jika tersedia dari AI
        if (res.metrics != null)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: CocokinColors.borderLight),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildMetricItem(
                  'Luminance (L*)',
                  '${res.metrics!['Luminance_L'] ?? '-'}',
                ),
                _buildMetricItem(
                  'Sudut ITA',
                  '${res.metrics!['ITA'] ?? '-'}°',
                ),
                _buildMetricItem(
                  'Rasio b*/a*',
                  '${res.metrics!['ratio_b_a'] ?? '-'}',
                ),
              ],
            ),
          ),

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
                        Text(
                          res.personalColor,
                          style: const TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.w700,
                            color: CocokinColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          res.summary,
                          style: const TextStyle(
                            fontSize: 12,
                            color: CocokinColors.textBody,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            for (final item in res.palette)
                              Expanded(
                                child: Container(
                                  height: 42,
                                  margin: const EdgeInsets.only(right: 8),
                                  decoration: BoxDecoration(
                                    color: Color(
                                      (item['hex'] as num).toInt(),
                                    ),
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

  Widget _buildMetricItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: CocokinColors.primaryMauve,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: CocokinColors.textMuted),
        ),
      ],
    );
  }
}
