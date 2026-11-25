import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../main.dart';
import 'api_service.dart';

/// Modal Bottom Sheet Pembayaran Cocokin Premium (Midtrans Sandbox Gateway)
/// Mendukung:
/// 1. Pemilihan Paket: Bulanan (Rp19.000) atau Lifetime (Rp49.000)
/// 2. Pembuatan Transaksi via Edge Function (`buat-pembayaran`) -> Midtrans Snap Sandbox
/// 3. Pengecekan Status Transaksi Real-Time via Edge Function (`cek-pembayaran`) -> Midtrans Core API
/// 4. Fallback jujur ke Simulasi Sandbox Demo jika Edge Function belum selesai di-deploy oleh pemilik proyek
class PremiumPaymentSheet extends StatefulWidget {
  final String userEmail;
  final VoidCallback onPaymentSuccess;

  const PremiumPaymentSheet({
    super.key,
    required this.userEmail,
    required this.onPaymentSuccess,
  });

  static Future<void> show(
    BuildContext context, {
    required String userEmail,
    required VoidCallback onPaymentSuccess,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: CocokinColors.bgMain,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (_) => PremiumPaymentSheet(
        userEmail: userEmail,
        onPaymentSuccess: onPaymentSuccess,
      ),
    );
  }

  @override
  State<PremiumPaymentSheet> createState() => _PremiumPaymentSheetState();
}

class _PremiumPaymentSheetState extends State<PremiumPaymentSheet> {
  String _selectedPaket = 'bulanan'; // 'bulanan' | 'lifetime'
  bool _isCreatingOrder = false;
  bool _isCheckingStatus = false;

  String? _orderId;
  String? _redirectUrl;
  String? _snapToken;
  bool _isEdgeLive = false;
  String? _statusMessage;
  bool _isError = false;

  int get _nominal => _selectedPaket == 'bulanan' ? 19000 : 49000;
  String get _nominalFormatted =>
      _selectedPaket == 'bulanan' ? 'Rp19.000' : 'Rp49.000';

  Future<void> _handleCreateOrder() async {
    setState(() {
      _isCreatingOrder = true;
      _statusMessage = null;
      _isError = false;
    });

    final res = await ApiService.createSandboxPayment(
      email: widget.userEmail,
      paket: _selectedPaket,
    );

    if (!mounted) return;

    if (res['success'] == true) {
      setState(() {
        _isCreatingOrder = false;
        _isEdgeLive = true;
        _orderId = res['order_id']?.toString();
        _redirectUrl = res['redirect_url']?.toString();
        _snapToken = res['snap_token']?.toString();
        _statusMessage =
            'Tagihan Midtrans Sandbox berhasil dibuat. Buka URL Snap untuk simulasi bayar, lalu klik Cek Status.';
      });
    } else {
      // Jika Edge Function belum di-deploy / MIDTRANS_SERVER_KEY belum diisi di dashboard,
      // berikan Order ID Sandbox lokal yang jujur agar alur pengujian tetap dapat didemokan.
      final fallbackOrderId =
          'COCOKIN-SBX-${DateTime.now().millisecondsSinceEpoch}';
      setState(() {
        _isCreatingOrder = false;
        _isEdgeLive = false;
        _orderId = fallbackOrderId;
        _redirectUrl =
            'https://simulator.sandbox.midtrans.com/qris/index';
        _statusMessage =
            'Mode Sandbox Lokal (Edge Function belum aktif: ${res['message']}). Kamu tetap bisa menguji simulasi di bawah.';
      });
    }
  }

  Future<void> _handleCheckStatus() async {
    if (_orderId == null) return;

    setState(() {
      _isCheckingStatus = true;
      _statusMessage = null;
      _isError = false;
    });

    if (_isEdgeLive) {
      final res = await ApiService.checkSandboxPaymentStatus(
        orderId: _orderId!,
      );
      if (!mounted) return;
      setState(() => _isCheckingStatus = false);

      final status = res['status']?.toString() ?? 'pending';
      final isPremiumActive = res['premium_aktif'] == true;

      if (status == 'lunas' || isPremiumActive) {
        widget.onPaymentSuccess();
        if (mounted) Navigator.pop(context);
        return;
      }

      setState(() {
        _isError = status == 'gagal' || status == 'kedaluwarsa';
        _statusMessage = status == 'pending'
            ? 'Status Midtrans: PENDING (Menunggu pembayaran diselesaikan di halaman Snap Sandbox).'
            : 'Status Midtrans: ${status.toUpperCase()}. Silakan buat tagihan baru jika kadaluarsa.';
      });
    } else {
      // Fallback sandbox demo ketika Edge Function belum di-deploy
      await ApiService.unlockPremium(widget.userEmail);
      if (!mounted) return;
      setState(() => _isCheckingStatus = false);
      widget.onPaymentSuccess();
      Navigator.pop(context);
    }
  }

  Future<void> _copyToClipboard(String text, String label) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: CocokinColors.textDark,
        content: Text(
          '$label berhasil disalin ke clipboard.',
          style: const TextStyle(fontSize: 12),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        22,
        20,
        22,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'COCOKIN PREMIUM • PAYMENT GATEWAY',
                  style: TextStyle(
                    fontSize: 10.5,
                    letterSpacing: 1.1,
                    fontWeight: FontWeight.w700,
                    color: CocokinColors.primaryMauve,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF4E5),
                    borderRadius: BorderRadius.circular(99),
                    border: Border.all(color: const Color(0xFFF0D5B0)),
                  ),
                  child: const Text(
                    'MIDTRANS SANDBOX',
                    style: TextStyle(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF8C581A),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            const Text(
              'Upgrade ke Cocokin Premium',
              style: TextStyle(
                fontFamily: 'Georgia',
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: CocokinColors.textDark,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Buka hasil Personal Color musiman, 4 palet warna lengkap, serta seluruh katalog rekomendasi produk tanpa batas.',
              style: TextStyle(
                fontSize: 12.5,
                color: CocokinColors.textBody,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 14),

            if (_orderId == null) ...[
              // Langkah 1: Pilihan Paket
              Row(
                children: [
                  Expanded(
                    child: _buildPlanOption(
                      id: 'bulanan',
                      badge: 'PAKET BULANAN',
                      price: 'Rp19.000',
                      subtitle: 'Aktif 30 hari',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildPlanOption(
                      id: 'lifetime',
                      badge: 'HEMAT • LIFETIME',
                      price: 'Rp49.000',
                      subtitle: 'Sekali bayar selamanya',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isCreatingOrder ? null : _handleCreateOrder,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: CocokinColors.primaryMauve,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    _isCreatingOrder
                        ? 'Membuat Tagihan Sandbox...'
                        : 'Buat Tagihan Midtrans Sandbox ($_nominalFormatted) →',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ] else ...[
              // Langkah 2: Detail Order Sandbox & Verifikasi Status
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: CocokinColors.borderCard),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'ID Tagihan (Order ID):',
                          style: TextStyle(
                            fontSize: 11,
                            color: CocokinColors.textMuted,
                          ),
                        ),
                        GestureDetector(
                          onTap: () =>
                              _copyToClipboard(_orderId!, 'Order ID'),
                          child: const Text(
                            'Salin ID',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: CocokinColors.primaryMauve,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    SelectableText(
                      _orderId!,
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: CocokinColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Paket: ${_selectedPaket == 'bulanan' ? 'Bulanan (30 Hari)' : 'Lifetime'}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: CocokinColors.textBody,
                          ),
                        ),
                        Text(
                          _nominalFormatted,
                          style: const TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            color: CocokinColors.primaryMauve,
                          ),
                        ),
                      ],
                    ),
                    if (_snapToken != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        'Snap Token: $_snapToken',
                        style: const TextStyle(
                          fontSize: 11,
                          color: CocokinColors.textMuted,
                        ),
                      ),
                    ],
                    if (_redirectUrl != null) ...[
                      const Divider(height: 18),
                      const Text(
                        'Tautan Pembayaran Midtrans Snap Sandbox:',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: CocokinColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      SelectableText(
                        _redirectUrl!,
                        style: const TextStyle(
                          fontSize: 11.5,
                          color: CocokinColors.primaryMauve,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () => _copyToClipboard(
                            _redirectUrl!,
                            'URL Pembayaran Sandbox',
                          ),
                          icon: const Icon(Icons.copy_rounded, size: 15),
                          label: const Text(
                            'Salin URL Snap Sandbox (Buka di Browser)',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: CocokinColors.primaryMauve,
                            side: const BorderSide(
                              color: CocokinColors.borderCard,
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              if (_statusMessage != null) ...[
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: _isError
                        ? const Color(0xFFFBEAEA)
                        : const Color(0xFFFFF4E5),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: _isError
                          ? const Color(0xFFE5B8B8)
                          : const Color(0xFFF0D5B0),
                    ),
                  ),
                  child: Text(
                    _statusMessage!,
                    style: TextStyle(
                      fontSize: 11.5,
                      color: _isError
                          ? const Color(0xFF9E3A3A)
                          : const Color(0xFF6B4210),
                      height: 1.35,
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed:
                          _isCheckingStatus ? null : _handleCheckStatus,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: CocokinColors.primaryMauve,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        _isCheckingStatus
                            ? 'Mengecek ke Midtrans...'
                            : _isEdgeLive
                                ? '↻ Cek Status Pembayaran'
                                : '✓ Simulasikan Lunas (Sandbox Lokal)',
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton(
                    onPressed: () {
                      setState(() {
                        _orderId = null;
                        _redirectUrl = null;
                        _snapToken = null;
                        _statusMessage = null;
                      });
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: CocokinColors.textBody,
                      side: const BorderSide(color: CocokinColors.borderCard),
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Ganti Paket',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 8),
            const Center(
              child: Text(
                'Lingkungan Sandbox Uji Coba • Tidak menggunakan uang asli',
                style: TextStyle(
                  fontSize: 10.5,
                  color: CocokinColors.textMuted,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanOption({
    required String id,
    required String badge,
    required String price,
    required String subtitle,
  }) {
    final bool selected = _selectedPaket == id;
    return GestureDetector(
      onTap: () => setState(() => _selectedPaket = id),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected
                ? CocokinColors.primaryMauve
                : CocokinColors.borderCard,
            width: selected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              badge,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: selected
                    ? CocokinColors.primaryMauve
                    : CocokinColors.textMuted,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              price,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: CocokinColors.textDark,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 11,
                color: CocokinColors.textBody,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
