import 'package:flutter/material.dart';
import '../main.dart';
import '../services/api_service.dart';

class ProfilPage extends StatefulWidget {
  final String? userName;
  final String? userEmail;
  final bool isPremium;
  final VoidCallback onLogin;
  final VoidCallback onLogout;
  final VoidCallback onOpenRiwayat;
  final VoidCallback onOpenCaraKerja;
  final VoidCallback onUnlockPremium;

  const ProfilPage({
    super.key,
    required this.userName,
    required this.userEmail,
    required this.isPremium,
    required this.onLogin,
    required this.onLogout,
    required this.onOpenRiwayat,
    required this.onOpenCaraKerja,
    required this.onUnlockPremium,
  });

  @override
  State<ProfilPage> createState() => _ProfilPageState();
}

class _ProfilPageState extends State<ProfilPage> {
  int _historyCount = 0;
  bool _isLoadingHistory = false;

  @override
  void initState() {
    super.initState();
    _fetchHistoryStats();
  }

  @override
  void didUpdateWidget(covariant ProfilPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.userEmail != widget.userEmail) {
      _fetchHistoryStats();
    }
  }

  Future<void> _fetchHistoryStats() async {
    final email = widget.userEmail ?? '';
    if (email.isEmpty) return;

    setState(() => _isLoadingHistory = true);
    final list = await ApiService.fetchHistory(email: email);
    if (mounted) {
      setState(() {
        _historyCount = list.length;
        _isLoadingHistory = false;
      });
    }
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: CocokinColors.bgMain,
        title: const Text(
          'Tentang Cocokin',
          style: TextStyle(
            fontFamily: 'Georgia',
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: CocokinColors.textDark,
          ),
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Versi 1.0.0',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 12.5,
                color: CocokinColors.primaryMauve,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Cocokin membantu kamu mengenali skin tone, undertone, dan kategori personal color untuk memilih shade makeup yang paling sesuai.',
              style: TextStyle(
                fontSize: 12.5,
                color: CocokinColors.textBody,
                height: 1.45,
              ),
            ),
            SizedBox(height: 12),
            Text(
              'Proyek Mata Kuliah IPPL\nInstitut Teknologi Kalimantan',
              style: TextStyle(fontSize: 11.5, color: CocokinColors.textMuted),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Tutup',
              style: TextStyle(
                color: CocokinColors.primaryMauve,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showPremiumSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: CocokinColors.bgMain,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(22, 20, 22, 26),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'AKSES PREMIUM',
                style: TextStyle(
                  fontSize: 10.5,
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.w700,
                  color: CocokinColors.primaryMauve,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Buka Hasil Personal Color Lengkap',
                style: TextStyle(
                  fontFamily: 'Georgia',
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: CocokinColors.textDark,
                ),
              ),
              const SizedBox(height: 12),
              _buildBenefitRow('Membuka kategori Personal Color musiman'),
              const SizedBox(height: 8),
              _buildBenefitRow('Akses palet warna lengkap hasil analisis'),
              const SizedBox(height: 8),
              _buildBenefitRow('Simpan riwayat hasil tes ke akun tanpa batas'),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    widget.onUnlockPremium();
                  },
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
                    'Aktifkan Premium Sekarang',
                    style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBenefitRow(String text) {
    return Row(
      children: [
        const Icon(
          Icons.check_circle_outline,
          size: 16,
          color: CocokinColors.primaryMauve,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 12.5,
              color: CocokinColors.textBody,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLoggedIn = widget.userName != null && widget.userName!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'AKUN SAYA',
          style: TextStyle(
            fontSize: 10.5,
            letterSpacing: 1.2,
            fontWeight: FontWeight.w700,
            color: CocokinColors.primaryMauve,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Profil & Pengaturan',
          style: TextStyle(
            fontFamily: 'Georgia',
            fontSize: 25,
            fontWeight: FontWeight.w700,
            color: CocokinColors.textDark,
          ),
        ),
        const SizedBox(height: 16),

        // Kartu Informasi Akun
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: CocokinColors.borderLight),
          ),
          child: isLoggedIn
              ? Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: const BoxDecoration(
                        color: CocokinColors.bgSoftPink,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        widget.userName![0].toUpperCase(),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: CocokinColors.primaryMauve,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  widget.userName!,
                                  style: const TextStyle(
                                    fontSize: 15.5,
                                    fontWeight: FontWeight.w700,
                                    color: CocokinColors.textDark,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: widget.isPremium
                                      ? const Color(0xFFF3E5D8)
                                      : CocokinColors.bgSoftPink,
                                  borderRadius: BorderRadius.circular(99),
                                ),
                                child: Text(
                                  widget.isPremium ? 'Premium' : 'Reguler',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: CocokinColors.primaryMauve,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text(
                            widget.userEmail ?? '',
                            style: const TextStyle(
                              fontSize: 12,
                              color: CocokinColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Belum masuk ke akun',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: CocokinColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Masuk terlebih dahulu untuk menyimpan hasil analisis warna kulit dan mengakses riwayat akunmu.',
                      style: TextStyle(
                        fontSize: 12,
                        color: CocokinColors.textBody,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: widget.onLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: CocokinColors.primaryMauve,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 11),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          'Masuk atau Daftar Akun',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
        ),

        const SizedBox(height: 12),

        // Kartu Status Premium (Sesuai Desain Aplikasi)
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: CocokinColors.bgSoftPink,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: CocokinColors.borderCard),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  widget.isPremium
                      ? Icons.verified_outlined
                      : Icons.lock_open_outlined,
                  color: CocokinColors.primaryMauve,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.isPremium
                          ? 'Akses Premium Aktif'
                          : 'Buka Kunci Personal Color',
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: CocokinColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.isPremium
                          ? 'Palet warna lengkap dan hasil personal color sudah terbuka.'
                          : 'Buka hasil kategori personal color dan palet lengkap.',
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: CocokinColors.textBody,
                      ),
                    ),
                  ],
                ),
              ),
              if (!widget.isPremium) ...[
                const SizedBox(width: 8),
                TextButton(
                  onPressed: isLoggedIn ? _showPremiumSheet : widget.onLogin,
                  style: TextButton.styleFrom(
                    backgroundColor: CocokinColors.primaryMauve,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Buka',
                    style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ],
          ),
        ),

        const SizedBox(height: 20),

        const Text(
          'Menu Akun',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: CocokinColors.textDark,
          ),
        ),
        const SizedBox(height: 8),

        _buildMenuTile(
          icon: Icons.history_rounded,
          title: 'Riwayat Analisis',
          subtitle: isLoggedIn
              ? (_isLoadingHistory
                  ? 'Memuat riwayat...'
                  : '$_historyCount hasil analisis tersimpan')
              : 'Lihat hasil analisis sebelumnya',
          onTap: isLoggedIn ? widget.onOpenRiwayat : widget.onLogin,
        ),
        const SizedBox(height: 8),
        _buildMenuTile(
          icon: Icons.menu_book_outlined,
          title: 'Panduan & Cara Kerja',
          subtitle: 'Tahapan pengambilan foto dan analisis warna',
          onTap: widget.onOpenCaraKerja,
        ),
        const SizedBox(height: 8),
        _buildMenuTile(
          icon: Icons.info_outline_rounded,
          title: 'Tentang Cocokin',
          subtitle: 'Informasi aplikasi versi 1.0.0',
          onTap: _showAboutDialog,
        ),

        if (isLoggedIn) ...[
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: widget.onLogout,
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF9E3A3A),
                side: const BorderSide(color: CocokinColors.borderCard),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Keluar Akun',
                style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildMenuTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: CocokinColors.borderLight),
        ),
        child: Row(
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
                    title,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: CocokinColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 11.5,
                      color: CocokinColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              size: 18,
              color: CocokinColors.textMuted,
            ),
          ],
        ),
      ),
    );
  }
}
