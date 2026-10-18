import 'package:flutter/material.dart';
import '../main.dart';

class BerandaPage extends StatelessWidget {
  final String activeTab;
  final bool isLoggedIn;
  final VoidCallback onStartAnalysis;

  const BerandaPage({
    super.key,
    required this.activeTab,
    required this.isLoggedIn,
    required this.onStartAnalysis,
  });

  @override
  Widget build(BuildContext context) {
    if (activeTab == 'carakerja') {
      return _buildCaraKerja();
    }
    if (activeTab == 'tentang') {
      return _buildTentang();
    }
    return _buildBerandaUtama();
  }

  Widget _buildBerandaUtama() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Kenali warna\nyang paling\ncocok untukmu.',
          style: TextStyle(
            fontFamily: 'Georgia',
            fontSize: 30,
            height: 1.18,
            fontWeight: FontWeight.w700,
            color: CocokinColors.textDark,
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Temukan skin tone, undertone, dan personal color melalui analisis AI, lalu dapatkan rekomendasi makeup yang sesuai dengan kebutuhan kamu.',
          style: TextStyle(
            fontSize: 13.5,
            height: 1.5,
            color: CocokinColors.textBody,
          ),
        ),
        const SizedBox(height: 18),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: onStartAnalysis,
            style: ElevatedButton.styleFrom(
              backgroundColor: CocokinColors.primaryMauve,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(99),
              ),
            ),
            child: const Text(
              'Mulai Analisis →',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            const Icon(Icons.lock_outline, size: 14, color: CocokinColors.textMuted),
            const SizedBox(width: 6),
            Text(
              isLoggedIn
                  ? 'Akun sudah aktif, siap memulai analisis.'
                  : 'Login diperlukan untuk memulai analisis.',
              style: const TextStyle(fontSize: 11.5, color: CocokinColors.textMuted),
            ),
          ],
        ),
        const SizedBox(height: 22),

        // Kartu Visual Kolase sesuai Figma Mobile
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: CocokinColors.borderLight),
          ),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  height: 130,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFE3DC),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          for (final c in [
                            const Color(0xFF8C6258),
                            const Color(0xFFC6946E),
                            const Color(0xFFDEC4A1),
                            const Color(0xFF8EAE86),
                          ])
                            Container(
                              width: 12,
                              height: 12,
                              margin: const EdgeInsets.only(right: 4),
                              decoration: BoxDecoration(
                                color: c,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hasil Analisis',
                            style: TextStyle(fontSize: 10, color: CocokinColors.textMuted),
                          ),
                          Text(
                            'Warm Autumn',
                            style: TextStyle(
                              fontFamily: 'Georgia',
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: CocokinColors.textDark,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  height: 130,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: CocokinColors.bgSoftPink,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Palet Warna',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: CocokinColors.primaryMauve,
                        ),
                      ),
                      Row(
                        children: [
                          for (final c in [
                            const Color(0xFF6B381B),
                            const Color(0xFFC6946E),
                            const Color(0xFFE1BBA0),
                            const Color(0xFF8EAE86),
                          ])
                            Expanded(
                              child: Container(
                                height: 32,
                                margin: const EdgeInsets.only(right: 4),
                                decoration: BoxDecoration(
                                  color: c,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 26),

        // Tiga Langkah Sederhana sesuai Figma
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: CocokinColors.bgSoftPink,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: [
              const Text(
                'CARA KERJA COCOKIN',
                style: TextStyle(
                  fontSize: 10.5,
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.w700,
                  color: CocokinColors.primaryMauve,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Tiga langkah sederhana',
                style: TextStyle(
                  fontFamily: 'Georgia',
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: CocokinColors.textDark,
                ),
              ),
              const SizedBox(height: 16),
              _buildStepItem(
                icon: Icons.camera_alt_outlined,
                num: '01',
                title: 'Unggah Foto',
                desc: 'Pilih foto wajah dengan pencahayaan yang jelas.',
              ),
              const SizedBox(height: 12),
              _buildStepItem(
                icon: Icons.auto_awesome_outlined,
                num: '02',
                title: 'Analisis AI',
                desc: 'Sistem akan mengenali skintone, undertone, dan personal color kamu.',
              ),
              const SizedBox(height: 12),
              _buildStepItem(
                icon: Icons.shopping_bag_outlined,
                num: '03',
                title: 'Dapatkan Rekomendasi',
                desc: 'Lihat palet warna dan produk makeup yang sesuai denganmu.',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStepItem({
    required IconData icon,
    required String num,
    required String title,
    required String desc,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: CocokinColors.borderLight),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: CocokinColors.bgSoftPink,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: CocokinColors.primaryMauve),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  num,
                  style: const TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    color: CocokinColors.textMuted,
                  ),
                ),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: CocokinColors.textDark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  desc,
                  style: const TextStyle(
                    fontSize: 12,
                    color: CocokinColors.textBody,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCaraKerja() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'PANDUAN PENGGUNA',
          style: TextStyle(
            fontSize: 10.5,
            letterSpacing: 1.2,
            fontWeight: FontWeight.w700,
            color: CocokinColors.primaryMauve,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Dari foto wajah hingga pilihan makeup yang lebih terarah.',
          style: TextStyle(
            fontFamily: 'Georgia',
            fontSize: 24,
            height: 1.2,
            fontWeight: FontWeight.w700,
            color: CocokinColors.textDark,
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'Kenali setiap tahapan Cocokin, mulai dari persiapan foto hingga memahami hasil analisis dan memilih produk yang sesuai.',
          style: TextStyle(fontSize: 13, color: CocokinColors.textBody),
        ),
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: CocokinColors.bgSoftPink,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'SEBELUM MEMULAI',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: CocokinColors.primaryMauve,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Siapkan foto wajah yang jelas',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: CocokinColors.textDark,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Gunakan pencahayaan yang merata, hindari filter yang mengubah warna kulit, dan pastikan wajah terlihat jelas.',
                style: TextStyle(fontSize: 12.5, color: CocokinColors.textBody),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'Pahami setiap tahapnya',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: CocokinColors.textDark,
          ),
        ),
        const SizedBox(height: 12),
        _buildStageCard(
          stage: 'TAHAP 01',
          title: 'Masuk ke Cocokin',
          desc: 'Buat akun atau masuk melalui halaman login sebelum memulai pengambilan foto.',
        ),
        const SizedBox(height: 10),
        _buildStageCard(
          stage: 'TAHAP 02',
          title: 'Unggah foto wajah',
          desc: 'Posisikan wajah pada panduan kamera dengan pencahayaan yang baik.',
        ),
        const SizedBox(height: 10),
        _buildStageCard(
          stage: 'TAHAP 03',
          title: 'Pahami hasil analisis',
          desc: 'Hasil menampilkan skin tone, undertone, dan kategori personal color.',
        ),
        const SizedBox(height: 10),
        _buildStageCard(
          stage: 'TAHAP 04',
          title: 'Jelajahi rekomendasi produk',
          desc: 'Pilih kategori complexion, lip product, blush, atau eye makeup yang sesuai.',
        ),
      ],
    );
  }

  Widget _buildStageCard({
    required String stage,
    required String title,
    required String desc,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: CocokinColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            stage,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: CocokinColors.primaryMauve,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: CocokinColors.textDark,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            desc,
            style: const TextStyle(fontSize: 12.5, color: CocokinColors.textBody),
          ),
        ],
      ),
    );
  }

  Widget _buildTentang() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'TENTANG COCOKIN',
          style: TextStyle(
            fontSize: 10.5,
            letterSpacing: 1.2,
            fontWeight: FontWeight.w700,
            color: CocokinColors.primaryMauve,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Setiap warna punya ceritanya sendiri.',
          style: TextStyle(
            fontFamily: 'Georgia',
            fontSize: 25,
            height: 1.2,
            fontWeight: FontWeight.w700,
            color: CocokinColors.textDark,
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'Cocokin hadir untuk membantu kamu mengenali karakteristik warna kulit dan memahami referensi makeup yang sesuai agar setiap pilihan terasa lebih terarah dan personal.',
          style: TextStyle(fontSize: 13, color: CocokinColors.textBody),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: onStartAnalysis,
          style: ElevatedButton.styleFrom(
            backgroundColor: CocokinColors.primaryMauve,
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(99),
            ),
          ),
          child: const Text(
            'Kenali Personal Colormu →',
            style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
          ),
        ),
        const SizedBox(height: 20),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: CocokinColors.borderLight),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Apa itu Cocokin?',
                style: TextStyle(
                  fontFamily: 'Georgia',
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: CocokinColors.textDark,
                ),
              ),
              SizedBox(height: 6),
              Text(
                'Cocokin merupakan rancangan aplikasi personal color analysis yang membantu pengguna memahami skin tone, undertone, dan personal color, serta menemukan referensi makeup berdasarkan hasil analisis.',
                style: TextStyle(fontSize: 12.5, color: CocokinColors.textBody),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
