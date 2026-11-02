import 'package:flutter/material.dart';
import '../main.dart';

class KameraPage extends StatefulWidget {
  final VoidCallback onCapture;

  const KameraPage({super.key, required this.onCapture});

  @override
  State<KameraPage> createState() => _KameraPageState();
}

class _KameraPageState extends State<KameraPage> {
  bool _isPreviewStep = false;
  bool _isCameraActive = true;

  void _captureFrame() {
    setState(() {
      _isPreviewStep = true;
    });
  }

  void _retakePhoto() {
    setState(() {
      _isPreviewStep = false;
      _isCameraActive = true;
    });
  }

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
        Text(
          _isPreviewStep ? 'Periksa hasil fotomu' : 'Ambil foto wajahmu',
          style: const TextStyle(
            fontFamily: 'Georgia',
            fontSize: 25,
            fontWeight: FontWeight.w700,
            color: CocokinColors.textDark,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          _isPreviewStep
              ? 'Pastikan wajahmu terlihat jelas dan pencahayaan sudah merata sebelum dianalisis.'
              : 'Posisikan wajahmu di dalam panduan agar hasil analisis lebih akurat.',
          style: const TextStyle(fontSize: 12.5, color: CocokinColors.textBody),
        ),
        const SizedBox(height: 18),

        // Bingkai Kamera Live dengan Panduan Oval Wajah (Face Guide Frame)
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
              // Tombol Ikon Kanan Atas (Galeri & Reset Kamera)
              Positioned(
                top: 12,
                right: 12,
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: _captureFrame,
                      child: _buildSmallCamAction(Icons.photo_library_outlined),
                    ),
                    const SizedBox(width: 6),
                    GestureDetector(
                      onTap: _retakePhoto,
                      child: _buildSmallCamAction(Icons.refresh_rounded),
                    ),
                  ],
                ),
              ),

              // Area Feed Kamera / Pratinjau Foto di Dalam Bingkai Oval
              Container(
                width: 176,
                height: 226,
                decoration: BoxDecoration(
                  color: _isCameraActive
                      ? const Color(0xFF2B211E)
                      : const Color(0xFFDFD3C8),
                  borderRadius: BorderRadius.circular(110),
                  border: Border.all(
                    color: _isPreviewStep
                        ? const Color(0xFF5FA869)
                        : Colors.white.withValues(alpha: 0.92),
                    width: 2.5,
                  ),
                ),
                clipBehavior: Clip.antiAlias,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Ilustrasi Feed Wajah pada Frame Kamera
                    Positioned(
                      bottom: 0,
                      child: Column(
                        children: [
                          Container(
                            width: 150,
                            height: 195,
                            decoration: const BoxDecoration(
                              color: Color(0xFF49332B),
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(80),
                              ),
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

                    // Garis Bantu Tengah Wajah (Crosshair Guide) saat Live Camera
                    if (!_isPreviewStep) ...[
                      Container(
                        width: 1,
                        height: 226,
                        color: Colors.white.withValues(alpha: 0.25),
                      ),
                      Container(
                        width: 176,
                        height: 1,
                        color: Colors.white.withValues(alpha: 0.25),
                      ),
                    ],
                  ],
                ),
              ),

              // Pill Status di Bawah Bingkai Oval
              Positioned(
                bottom: 14,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: _isPreviewStep
                        ? const Color(0xFF2E6B38).withValues(alpha: 0.9)
                        : const Color(0xFF5C443C).withValues(alpha: 0.82),
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: Text(
                    _isPreviewStep
                        ? 'Foto berhasil diambil! Pastikan pencahayaan cukup'
                        : 'Posisikan wajah di dalam oval',
                    style: const TextStyle(
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

        // Jika sudah ambil foto -> Tampilkan tombol Pratinjau Foto (Gunakan Foto vs Ambil Ulang)
        if (_isPreviewStep) ...[
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: widget.onCapture,
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
                'Gunakan Foto & Mulai Analisis →',
                style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: _retakePhoto,
              style: OutlinedButton.styleFrom(
                foregroundColor: CocokinColors.textDark,
                side: const BorderSide(color: CocokinColors.borderCard),
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Ambil Ulang Foto',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ] else ...[
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

          // Tombol Bulat Ambil Foto + Pilih dari Galeri
          Center(
            child: Column(
              children: [
                GestureDetector(
                  onTap: _captureFrame,
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: CocokinColors.primaryMauve,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFFE6D2CE),
                        width: 4,
                      ),
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
                  style: TextStyle(
                    fontSize: 11,
                    color: CocokinColors.textMuted,
                  ),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: _captureFrame,
                  child: const Text(
                    'Atau pilih foto dari galeri perangkat',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: CocokinColors.primaryMauve,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
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
