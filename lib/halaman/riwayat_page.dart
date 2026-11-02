import 'package:flutter/material.dart';
import '../main.dart';
import '../services/api_service.dart';

class RiwayatPage extends StatefulWidget {
  final String userEmail;
  final VoidCallback onGoToRekomendasi;
  final VoidCallback onNewAnalysis;

  const RiwayatPage({
    super.key,
    required this.userEmail,
    required this.onGoToRekomendasi,
    required this.onNewAnalysis,
  });

  @override
  State<RiwayatPage> createState() => _RiwayatPageState();
}

class _RiwayatPageState extends State<RiwayatPage> {
  List<Map<String, dynamic>> _historyList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final data = await ApiService.fetchHistory(email: widget.userEmail);
    if (mounted) {
      setState(() {
        _historyList = data;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'RIWAYAT ANALISIS',
          style: TextStyle(
            fontSize: 10.5,
            letterSpacing: 1.2,
            fontWeight: FontWeight.w700,
            color: CocokinColors.primaryMauve,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Catatan Hasil Color\nAnalysis Kamu',
          style: TextStyle(
            fontSize: 21,
            height: 1.25,
            fontWeight: FontWeight.w700,
            color: CocokinColors.textDark,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Hasil analisis yang telah disimpan ke akunmu.',
          style: TextStyle(fontSize: 12.5, color: CocokinColors.textBody),
        ),
        const SizedBox(height: 16),

        if (_isLoading)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: CircularProgressIndicator(
                color: CocokinColors.primaryMauve,
              ),
            ),
          )
        else if (_historyList.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: CocokinColors.borderLight),
            ),
            child: const Text(
              'Belum ada riwayat analisis yang tersimpan.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12.5, color: CocokinColors.textBody),
            ),
          )
        else
          for (final item in _historyList) ...[
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: CocokinColors.bgSoftPink,
                          borderRadius: BorderRadius.circular(99),
                        ),
                        child: Text(
                          item['date'] as String? ?? 'Baru saja',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: CocokinColors.textDark,
                          ),
                        ),
                      ),
                      const Text(
                        'Tersimpan',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: CocokinColors.primaryMauve,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildMiniStat(
                          label: 'Skin Tone',
                          value: item['skinTone'] as String? ?? 'Medium',
                          dotColor: const Color(0xFF8C6258),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildMiniStat(
                          label: 'Undertone',
                          value: item['undertone'] as String? ?? 'Warm',
                          dotColor: const Color(0xFFDEC4A1),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: widget.onGoToRekomendasi,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: CocokinColors.primaryMauve,
                        side: const BorderSide(
                          color: CocokinColors.primaryMauve,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Lihat Rekomendasi yang Cocok →',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],

        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: widget.onNewAnalysis,
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
              'Mulai Analisis Baru',
              style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMiniStat({
    required String label,
    required String value,
    required Color dotColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: CocokinColors.bgMain,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: CocokinColors.borderLight),
      ),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: CocokinColors.textDark,
                ),
              ),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 10.5,
                  color: CocokinColors.textMuted,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
