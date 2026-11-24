import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../main.dart';
import '../services/api_service.dart';

class KameraCapturePayload {
  final String imagePath;
  final Uint8List? imageBytes;
  final String sampleKey;
  final String label;

  const KameraCapturePayload({
    required this.imagePath,
    this.imageBytes,
    this.sampleKey = 'sample_medium_warm',
    this.label = 'Foto Wajah',
  });
}

class KameraPage extends StatefulWidget {
  final ValueChanged<KameraCapturePayload> onCapture;

  const KameraPage({super.key, required this.onCapture});

  @override
  State<KameraPage> createState() => _KameraPageState();
}

class _KameraPageState extends State<KameraPage> {
  CameraController? _cameraController;
  List<CameraDescription> _cameras = [];
  int _selectedCameraIdx = 0;
  bool _isCameraInitialized = false;
  bool _isInitializingCamera = true;
  bool _isTakingPicture = false;

  bool _isPreviewStep = false;
  Uint8List? _selectedBytes;
  String _selectedPath = '';
  String _selectedLabel = 'Foto Wajah';

  final TransformationController _transformController =
      TransformationController();

  @override
  void initState() {
    super.initState();
    _initLiveCamera();
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _transformController.dispose();
    super.dispose();
  }

  Future<void> _initLiveCamera({int? cameraIndex}) async {
    if (kIsWeb) {
      setState(() => _isInitializingCamera = false);
      return;
    }

    setState(() {
      _isInitializingCamera = true;
    });

    try {
      if (_cameras.isEmpty) {
        _cameras = await availableCameras();
      }
      if (_cameras.isEmpty) {
        if (mounted) {
          setState(() {
            _isCameraInitialized = false;
            _isInitializingCamera = false;
          });
        }
        return;
      }

      if (cameraIndex != null) {
        _selectedCameraIdx = cameraIndex % _cameras.length;
      } else {
        // Prioritaskan kamera depan (selfie) secara default
        final frontIdx = _cameras.indexWhere(
          (c) => c.lensDirection == CameraLensDirection.front,
        );
        _selectedCameraIdx = frontIdx != -1 ? frontIdx : 0;
      }

      await _cameraController?.dispose();

      final controller = CameraController(
        _cameras[_selectedCameraIdx],
        ResolutionPreset.high,
        enableAudio: false,
      );

      _cameraController = controller;
      await controller.initialize();

      if (mounted) {
        setState(() {
          _isCameraInitialized = true;
          _isInitializingCamera = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isCameraInitialized = false;
          _isInitializingCamera = false;
        });
      }
    }
  }

  Future<void> _switchCamera() async {
    if (_cameras.length < 2 || _isInitializingCamera) return;
    await _initLiveCamera(cameraIndex: _selectedCameraIdx + 1);
  }

  Future<void> _captureFromLiveCamera() async {
    if (_isTakingPicture) return;

    // Jika live camera aktif di HP, langsung ambil gambar dari preview oval
    if (_isCameraInitialized &&
        _cameraController != null &&
        _cameraController!.value.isInitialized) {
      try {
        setState(() => _isTakingPicture = true);
        final XFile file = await _cameraController!.takePicture();
        final bytes = await file.readAsBytes();
        _transformController.value = Matrix4.identity();
        if (mounted) {
          setState(() {
            _selectedPath = file.path;
            _selectedBytes = bytes;
            _selectedLabel = 'Foto Kamera';
            _isPreviewStep = true;
            _isTakingPicture = false;
          });
        }
        return;
      } catch (_) {
        if (mounted) {
          setState(() => _isTakingPicture = false);
        }
      }
    }

    // Fallback jika live camera tidak tersedia di perangkat
    await _pickFromGallery();
  }

  Future<void> _pickFromGallery() async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1080,
        maxHeight: 1080,
        imageQuality: 88,
      );

      if (picked != null) {
        final bytes = await picked.readAsBytes();
        _transformController.value = Matrix4.identity();
        if (mounted) {
          setState(() {
            _selectedPath = picked.path;
            _selectedBytes = bytes;
            _selectedLabel = 'Foto Galeri';
            _isPreviewStep = true;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: CocokinColors.textDark,
            content: Text(
              'Tidak dapat membuka galeri: $e',
              style: const TextStyle(fontSize: 12),
            ),
          ),
        );
      }
    }
  }

  void _retakePhoto() {
    _transformController.value = Matrix4.identity();
    setState(() {
      _isPreviewStep = false;
      _selectedBytes = null;
      _selectedPath = '';
    });
  }

  Future<void> _showServerIpDialog() async {
    final controller = TextEditingController(text: ApiService.serverHost);
    final chosenHost = await showDialog<String>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: CocokinColors.bgMain,
          title: const Text(
            'Koneksi Server Analisis',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: CocokinColors.textDark,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Masukkan alamat IP laptop jika server analisis dijalankan melalui jaringan Wi-Fi yang sama:',
                style: TextStyle(fontSize: 12, color: CocokinColors.textBody),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: controller,
                style: const TextStyle(fontSize: 12.5),
                decoration: InputDecoration(
                  hintText: 'localhost atau 192.168.1.x',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, controller.text.trim()),
              style: ElevatedButton.styleFrom(
                backgroundColor: CocokinColors.primaryMauve,
                foregroundColor: Colors.white,
              ),
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );

    if (chosenHost != null && chosenHost.isNotEmpty) {
      setState(() {
        ApiService.setServerHost(chosenHost);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onLongPress: _showServerIpDialog,
          child: const Text(
            'COCOKIN COLOR ANALYSIS',
            style: TextStyle(
              fontSize: 10.5,
              letterSpacing: 1.2,
              fontWeight: FontWeight.w700,
              color: CocokinColors.primaryMauve,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          _isPreviewStep ? 'Sesuaikan posisi fotomu' : 'Ambil foto wajahmu',
          style: const TextStyle(
            fontFamily: 'Georgia',
            fontSize: 25,
            fontWeight: FontWeight.w700,
            color: CocokinColors.textDark,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          _isPreviewStep
              ? 'Geser atau cubit foto dengan dua jari agar wajah pas di dalam bingkai oval sebelum memulai analisis.'
              : 'Posisikan wajah di tengah bingkai oval dengan pencahayaan yang merata.',
          style: const TextStyle(
            fontSize: 12.5,
            height: 1.45,
            color: CocokinColors.textBody,
          ),
        ),
        const SizedBox(height: 16),

        // Area Bingkai Kamera dengan Panduan Kepala Oval
        Container(
          width: double.infinity,
          height: 360,
          decoration: BoxDecoration(
            color: const Color(0xFFDFD3C8),
            borderRadius: BorderRadius.circular(24),
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // 1. Tampilan Live Kamera atau Foto yang Bisa Digeser (InteractiveViewer)
              if (_isPreviewStep && _selectedBytes != null)
                Positioned.fill(
                  child: InteractiveViewer(
                    transformationController: _transformController,
                    panEnabled: true,
                    scaleEnabled: true,
                    minScale: 0.8,
                    maxScale: 4.0,
                    boundaryMargin: const EdgeInsets.all(120),
                    child: Image.memory(
                      _selectedBytes!,
                      fit: BoxFit.cover,
                    ),
                  ),
                )
              else if (_isCameraInitialized &&
                  _cameraController != null &&
                  _cameraController!.value.isInitialized)
                Positioned.fill(
                  child: FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      width: _cameraController!.value.previewSize?.height ?? 720,
                      height: _cameraController!.value.previewSize?.width ?? 1280,
                      child: CameraPreview(_cameraController!),
                    ),
                  ),
                )
              else if (_isInitializingCamera)
                const Center(
                  child: CircularProgressIndicator(
                    color: CocokinColors.primaryMauve,
                    strokeWidth: 2.5,
                  ),
                )
              else
                const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      'Kamera belum aktif.\nKetuk tombol Galeri di bawah untuk memilih foto wajah.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12.5,
                        color: CocokinColors.textBody,
                      ),
                    ),
                  ),
                ),

              // 2. Overlay Gelap Tipis di Luar Oval + Garis Panduan Kepala Oval
              IgnorePointer(
                child: CustomPaint(
                  size: const Size(double.infinity, 360),
                  painter: _OvalGuidePainter(isPreview: _isPreviewStep),
                ),
              ),

              // 3. Tombol Kecil di Kanan Atas (Ganti Kamera Depan/Belakang atau Reset Posisi Foto)
              Positioned(
                top: 12,
                right: 12,
                child: Row(
                  children: [
                    if (!_isPreviewStep && _cameras.length > 1)
                      GestureDetector(
                        onTap: _switchCamera,
                        child: _buildSmallCamAction(
                          Icons.cameraswitch_outlined,
                        ),
                      ),
                    if (_isPreviewStep) ...[
                      GestureDetector(
                        onTap: () {
                          _transformController.value = Matrix4.identity();
                        },
                        child: _buildSmallCamAction(
                          Icons.center_focus_strong_outlined,
                        ),
                      ),
                      const SizedBox(width: 6),
                      GestureDetector(
                        onTap: _retakePhoto,
                        child: _buildSmallCamAction(Icons.refresh_rounded),
                      ),
                    ],
                  ],
                ),
              ),

              // 4. Keterangan Panduan di Bawah Oval
              Positioned(
                bottom: 14,
                child: IgnorePointer(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4A332D).withValues(alpha: 0.75),
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: Text(
                      _isPreviewStep
                          ? 'Geser atau cubit foto untuk menyesuaikan posisi'
                          : 'Arahkan wajah ke dalam garis oval',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),

        // Jika sudah ambil foto -> Tombol Lanjut Analisis atau Ambil Ulang
        if (_isPreviewStep) ...[
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                widget.onCapture(
                  KameraCapturePayload(
                    imagePath: _selectedPath.isNotEmpty
                        ? _selectedPath
                        : 'kamera_wajah.png',
                    imageBytes: _selectedBytes,
                    label: _selectedLabel,
                  ),
                );
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
              child: const Text(
                'Gunakan Foto & Analisis →',
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
                  'Hadap kamera',
                  'Pastikan wajah terlihat jelas',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildGuideTip(
                  Icons.flash_off_outlined,
                  'Tanpa filter',
                  'Gunakan warna kulit asli',
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),

          // Tombol Shutter Kamera & Pilih Galeri yang Bersih
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Tombol Pilih dari Galeri
              GestureDetector(
                onTap: _pickFromGallery,
                child: Column(
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: CocokinColors.borderLight,
                          width: 1.5,
                        ),
                      ),
                      child: const Icon(
                        Icons.photo_library_outlined,
                        color: CocokinColors.primaryMauve,
                        size: 20,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Galeri',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: CocokinColors.textBody,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 28),

              // Tombol Jepret Kamera Utama
              GestureDetector(
                onTap: _captureFromLiveCamera,
                child: Column(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: CocokinColors.primaryMauve,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFFE6D2CE),
                          width: 4,
                        ),
                      ),
                      child: _isTakingPicture
                          ? const Padding(
                              padding: EdgeInsets.all(18),
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(
                              Icons.camera_alt_rounded,
                              color: Colors.white,
                              size: 26,
                            ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Ambil Foto',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: CocokinColors.textDark,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 28),

              // Tombol Putar Kamera (Depan/Belakang)
              GestureDetector(
                onTap: _switchCamera,
                child: Column(
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: CocokinColors.borderLight,
                          width: 1.5,
                        ),
                      ),
                      child: const Icon(
                        Icons.flip_camera_android_outlined,
                        color: CocokinColors.primaryMauve,
                        size: 20,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Putar',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: CocokinColors.textBody,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildSmallCamAction(IconData icon) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: const Color(0xFF4A332D).withValues(alpha: 0.65),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: 16, color: Colors.white),
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

/// Painter untuk menggambar bingkai panduan kepala oval di tengah kamera
class _OvalGuidePainter extends CustomPainter {
  final bool isPreview;

  const _OvalGuidePainter({required this.isPreview});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2 - 8);
    final ovalRect = Rect.fromCenter(
      center: center,
      width: 195,
      height: 250,
    );

    // Area luar oval agak digelapkan sedikit agar fokus pada wajah di tengah
    final bgPath = Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    final ovalPath = Path()..addOval(ovalRect);
    final maskPath = Path.combine(PathOperation.difference, bgPath, ovalPath);

    final maskPaint = Paint()
      ..color = const Color(0xFF2B211E).withValues(alpha: 0.32)
      ..style = PaintingStyle.fill;
    canvas.drawPath(maskPath, maskPaint);

    // Garis tepi oval panduan kepala
    final borderPaint = Paint()
      ..color = isPreview
          ? const Color(0xFF5FA869)
          : Colors.white.withValues(alpha: 0.9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2;
    canvas.drawOval(ovalRect, borderPaint);

    // Garis bantu tengah tipis saat membidik wajah
    if (!isPreview) {
      final guidePaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.25)
        ..strokeWidth = 1.0;

      canvas.drawLine(
        Offset(center.dx, ovalRect.top + 12),
        Offset(center.dx, ovalRect.bottom - 12),
        guidePaint,
      );
      canvas.drawLine(
        Offset(ovalRect.left + 12, center.dy),
        Offset(ovalRect.right - 12, center.dy),
        guidePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _OvalGuidePainter oldDelegate) {
    return oldDelegate.isPreview != isPreview;
  }
}
