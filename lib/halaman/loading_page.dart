import 'dart:async';
import 'package:flutter/material.dart';
import '../main.dart';
import '../models/product_model.dart';
import '../services/api_service.dart';
import 'kamera_page.dart';

class LoadingPage extends StatefulWidget {
  final KameraCapturePayload? capturePayload;
  final String userEmail;
  final ValueChanged<AnalysisResultModel> onFinish;

  const LoadingPage({
    super.key,
    this.capturePayload,
    this.userEmail = 'yumna@gmail.com',
    required this.onFinish,
  });

  @override
  State<LoadingPage> createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage> {
  double _progress = 0.25;
  String _statusText = 'Mengekstrak ROI kulit wajah & ruang warna CIE-L*a*b*...';
  AnalysisResultModel? _result;
  bool _isAnalyzing = true;

  @override
  void initState() {
    super.initState();
    _runAiAnalysis();
  }

  Future<void> _runAiAnalysis() async {
    final payload = widget.capturePayload;
    setState(() {
      _progress = 0.45;
      _statusText = 'Menghitung Luminance (L*), ITA, dan rasio kromatik b*/a*...';
    });

    final res = await ApiService.analyzeFacePhoto(
      payload?.imagePath ?? 'kamera_wajah.png',
      imageBytes: payload?.imageBytes,
      sampleKey: payload?.sampleKey ?? 'sample_medium_warm',
      email: widget.userEmail,
    );

    if (!mounted) return;
    setState(() {
      _result = res;
      _progress = 1.0;
      _isAnalyzing = false;
      _statusText =
          'Analisis selesai! Terdeteksi Skin Tone ${res.skinTone} • ${res.undertone} Undertone (${res.confidence})';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 8),
        const Text(
          'COCOKIN AI COLOR ANALYSIS',
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
          child: Icon(
            _isAnalyzing
                ? Icons.tag_faces_outlined
                : Icons.check_circle_outline_rounded,
            size: 52,
            color: CocokinColors.primaryMauve,
          ),
        ),
        const SizedBox(height: 22),

        Text(
          _isAnalyzing
              ? 'Sedang mengenali warna\nterbaikmu'
              : 'Analisis AI Selesai!',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: CocokinColors.textDark,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _statusText,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 12.5, color: CocokinColors.textBody),
        ),
        const SizedBox(height: 24),

        const Text(
          'Analisis warna kulit (RGB, HSV, CIE-Lab & ITA)',
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
            onPressed: _isAnalyzing
                ? null
                : () {
                    if (_result != null) {
                      widget.onFinish(_result!);
                    }
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: CocokinColors.primaryMauve,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              _isAnalyzing
                  ? 'Memproses dengan AI...'
                  : 'Lihat hasil analisis →',
              style: const TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
              ),
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
