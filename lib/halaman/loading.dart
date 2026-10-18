import 'dart:async';
import 'package:flutter/material.dart';
import '../main.dart';

class LoadingPage extends StatefulWidget {
  final VoidCallback onFinish;

  const LoadingPage({super.key, required this.onFinish});

  @override
  State<LoadingPage> createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage> {
  double _progress = 0.35;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(milliseconds: 900), () {
      if (mounted) {
        setState(() => _progress = 0.85);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 8),
        const Text(
          'COCOKIN COLOR ANALYSIS',
          style: TextStyle(
            fontSize: 10.5,
            letterSpacing: 1.2,
            fontWeight: FontWeight.w700,
            color: CocokinColors.primaryMauve,
          ),
        ),
        const SizedBox(height: 16),

        // Kotak Pink Ikon Pemindaian Wajah sesuai Halaman 4 Figma
        Container(
          width: double.infinity,
          height: 125,
          decoration: BoxDecoration(
            color: CocokinColors.bgSoftPink,
            borderRadius: BorderRadius.circular(18),
          ),
          alignment: Alignment.center,
          child: const Icon(
            Icons.tag_faces_outlined,
            size: 52,
            color: CocokinColors.primaryMauve,
          ),
        ),
        const SizedBox(height: 22),

        const Text(
          'Sedang mengenali warna\nterbaikmu',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: CocokinColors.textDark,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Tunggu sebentar, kami sedang menganalisis karakteristik warna kulitmu.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 12.5, color: CocokinColors.textBody),
        ),
        const SizedBox(height: 24),

        const Text(
          'Analisis warna kulit',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: CocokinColors.textBody,
          ),
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(99),
          child: LinearProgressIndicator(
            value: _progress,
            minHeight: 6,
            backgroundColor: CocokinColors.borderLight,
            valueColor: const AlwaysStoppedAnimation<Color>(
              CocokinColors.primaryMauve,
            ),
          ),
        ),
        const SizedBox(height: 26),

        const Text(
          'Yang akan kamu dapatkan',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: CocokinColors.textDark,
          ),
        ),
        const SizedBox(height: 12),

        Row(
          children: [
            _buildInfoChip('Skin Tone'),
            const SizedBox(width: 8),
            _buildInfoChip('Under Tone'),
            const SizedBox(width: 8),
            _buildInfoChip('Personal Color'),
          ],
        ),
        const SizedBox(height: 24),

        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: widget.onFinish,
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
              'Lihat hasil analisis →',
              style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoChip(String text) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: CocokinColors.borderCard),
        ),
        child: Text(
          text,
          style: const TextStyle(fontSize: 11.5, color: CocokinColors.textBody),
        ),
      ),
    );
  }
}
