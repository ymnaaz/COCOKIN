import 'package:flutter/material.dart';
import '../main.dart';

class KameraPage extends StatelessWidget {
  final VoidCallback onCapture;

  const KameraPage({super.key, required this.onCapture});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'COCOKIN COLOR ANALYSIS',
          style: TextStyle(
            fontSize: 10.5,
            letterSpacing: 1.2,
            fontWeight: FontWeight.w700,
            color: CocokinColors.primaryMauve,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Ambil foto wajahmu',
          style: TextStyle(
            fontFamily: 'Georgia',
            fontSize: 25,
            fontWeight: FontWeight.w700,
            color: CocokinColors.textDark,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Posisikan wajahmu di dalam panduan agar hasil analisis lebih akurat.',
          style: TextStyle(fontSize: 12.5, color: CocokinColors.textBody),
        ),
        const SizedBox(height: 18),

        // Bingkai Kamera dengan Panduan Oval Wajah persis seperti Figma
        Container(
          width: double.infinity,
          height: 310,
          decoration: BoxDecoration(
            color: const Color(0xFFDFD3C8),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Tombol Ikon Kanan Atas
              Positioned(
                top: 12,
                right: 12,
                child: Row(
                  children: [
                    _buildSmallCamAction(Icons.auto_awesome_outlined),
                    const SizedBox(width: 6),
                    _buildSmallCamAction(Icons.cameraswitch_outlined),
                  ],
                ),
              ),

              // Siluet Wajah & Rambut
              Positioned(
                bottom: 0,
                child: Column(
                  children: [
                    Container(
                      width: 150,
                      height: 195,
                      decoration: const BoxDecoration(
                        color: Color(0xFF49332B),
                        borderRadius: BorderRadius.vertical(top: Radius.circular(80)),
                      ),
                      alignment: Alignment.center,
                      child: Container(
                        width: 112,
                        height: 145,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE5C8B3),
                          borderRadius: BorderRadius.circular(65),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Garis Panduan Oval
              Container(
                width: 156,
                height: 204,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.9),
                    width: 2,
                  ),
                ),
              ),

              // Pill Teks di Bawah Oval
              Positioned(
                bottom: 14,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFF5C443C).withValues(alpha: 0.82),
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: const Text(
                    'Posisikan wajah di dalam oval',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),

        // 3 Panduan Ikon di Bawah Kamera
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _buildGuideTip(
                Icons.wb_sunny_outlined,
                'Cahaya alami',
                'Cahaya yang cukup dan merata',
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildGuideTip(
                Icons.center_focus_strong_outlined,
                'Wajah menghadap kamera',
                'Pastikan wajah terlihat jelas',
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildGuideTip(
                Icons.flash_off_outlined,
                'Tanpa filter',
                'Gunakan wajah asli tanpa filter',
              ),
            ),
          ],
        ),
        const SizedBox(height: 22),

        // Tombol Bulat Ambil Foto
        Center(
          child: Column(
            children: [
              GestureDetector(
                onTap: onCapture,
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: CocokinColors.primaryMauve,
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFE6D2CE), width: 4),
                  ),
                  child: const Icon(
                    Icons.camera_alt_outlined,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Ambil Foto',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: CocokinColors.textDark,
                ),
              ),
              const Text(
                'Pastikan wajah terlihat jelas',
                style: TextStyle(fontSize: 11, color: CocokinColors.textMuted),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      color: Color(0xFF4E8C57),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 5),
                  const Text(
                    'Kamera aktif',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF4E8C57),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSmallCamAction(IconData icon) {
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        color: const Color(0xFF4A332D).withValues(alpha: 0.65),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: 15, color: Colors.white),
    );
  }

  Widget _buildGuideTip(IconData icon, String title, String subtitle) {
    return Column(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: const BoxDecoration(
            color: CocokinColors.bgSoftPink,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 16, color: CocokinColors.primaryMauve),
        ),
        const SizedBox(height: 6),
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: CocokinColors.textDark,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 10, color: CocokinColors.textMuted),
        ),
      ],
    );
  }
}
