import 'dart:io';
import 'dart:typed_data';
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
    this.label = 'Sampel Wajah Medium Warm',
  });
}

class KameraPage extends StatefulWidget {
  final ValueChanged<KameraCapturePayload> onCapture;

  const KameraPage({super.key, required this.onCapture});

  @override
  State<KameraPage> createState() => _KameraPageState();
}

class _KameraPageState extends State<KameraPage> {
  bool _isPreviewStep = false;
  bool _isCameraActive = true;
  Uint8List? _selectedBytes;
  String _selectedPath = '';
  String _selectedSampleKey = 'sample_medium_warm';
  String _selectedLabel = 'Foto Wajah (Medium / Warm)';

  static const List<Map<String, dynamic>> _sampleFaces = [
    {
      'key': 'sample_light',
      'label': 'Wajah 1 (Terang)',
      'path':
          r'D:\Semester 5\IPPL\COCOKIN-AI\images\images\all_cropped_images_by_class\1',
      'previewColor': Color(0xFFE8C9B5),
    },
    {
      'key': 'sample_medium_warm',
      'label': 'Wajah 2 (Medium)',
      'path':
          r'D:\Semester 5\IPPL\COCOKIN-AI\images\images\all_cropped_images_by_class\4',
      'previewColor': Color(0xFFC69472),
    },
    {
      'key': 'sample_tan_warm',
      'label': 'Wajah 3 (Sawo Matang)',
      'path':
          r'D:\Semester 5\IPPL\COCOKIN-AI\images\images\all_cropped_images_by_class\6',
      'previewColor': Color(0xFF9C6B4E),
    },
    {
      'key': 'sample_deep',
      'label': 'Wajah 4 (Gelap/Deep)',
      'path':
          r'D:\Semester 5\IPPL\COCOKIN-AI\images\images\all_cropped_images_by_class\9',
      'previewColor': Color(0xFF4A3228),
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadSampleFromDataset(_sampleFaces[1]);
  }

  void _loadSampleFromDataset(Map<String, dynamic> sample) {
    final key = sample['key'] as String;
    final label = sample['label'] as String;
    final folderPath = sample['path'] as String;

    Uint8List? bytes;
    String filePath = '';

    if (!kIsWeb) {
      try {
        final dir = Directory(folderPath);
        if (dir.existsSync()) {
          final files = dir
              .listSync()
              .whereType<File>()
              .where((f) => f.path.toLowerCase().endsWith('.jpg'))
              .toList();
          if (files.isNotEmpty) {
            filePath = files.first.path;
            bytes = files.first.readAsBytesSync();
          }
        }
      } catch (_) {}
    }

    setState(() {
      _selectedSampleKey = key;
      _selectedLabel = label;
      _selectedPath = filePath;
      _selectedBytes = bytes;
    });
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: source,
        maxWidth: 1080,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (picked != null) {
        final bytes = await picked.readAsBytes();
        setState(() {
          _selectedPath = picked.path;
          _selectedBytes = bytes;
          _selectedLabel = source == ImageSource.camera
              ? 'Foto Kamera HP'
              : 'Foto dari Galeri HP';
          _isPreviewStep = true;
          _isCameraActive = true;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: CocokinColors.textDark,
            content: Text(
              'Gagal membuka kamera/galeri: $e',
              style: const TextStyle(fontSize: 12),
            ),
          ),
        );
      }
    }
  }
    final controller = TextEditingController(text: _selectedPath);
    final chosenPath = await showDialog<String>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: CocokinColors.bgMain,
          title: const Text(
            'Pilih File Foto Wajah (.jpg / .png)',
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
                'Masukkan path file foto dari perangkatmu untuk dianalisis langsung oleh model AI:',
                style: TextStyle(fontSize: 12, color: CocokinColors.textBody),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: controller,
                style: const TextStyle(fontSize: 12),
                decoration: InputDecoration(
                  hintText: r'C:\Users\...\foto_wajah.jpg',
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
              child: const Text('Muat Foto'),
            ),
          ],
        );
      },
    );

    if (chosenPath != null && chosenPath.isNotEmpty && !kIsWeb) {
      final f = File(chosenPath);
      if (f.existsSync()) {
        final bytes = await f.readAsBytes();
        setState(() {
          _selectedPath = chosenPath;
          _selectedBytes = bytes;
          _selectedLabel = chosenPath.split(Platform.pathSeparator).last;
          _isPreviewStep = true;
        });
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('File foto tidak ditemukan. Periksa kembali path file.'),
          ),
        );
      }
    }
  }

  Future<void> _showServerIpDialog() async {
    final controller = TextEditingController(text: ApiService.serverHost);
    final chosenHost = await showDialog<String>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: CocokinColors.bgMain,
          title: const Text(
            'Atur IP Server AI (Untuk HP Fisik)',
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
                '• Gunakan "localhost" jika menjalankan di PC atau HP via kabel USB (adb reverse).\n'
                '• Gunakan IP Wi-Fi Laptop (contoh: 192.168.1.10) jika HP terhubung via Wi-Fi yang sama.\n'
                '• Gunakan "10.0.2.2" jika memakai Emulator Android.',
                style: TextStyle(fontSize: 11.5, color: CocokinColors.textBody),
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
              child: const Text('Simpan IP'),
            ),
          ],
        );
      },
    );

    if (chosenHost != null && chosenHost.isNotEmpty) {
      setState(() {
        ApiService.setServerHost(chosenHost);
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Server AI diarahkan ke: ${ApiService.localAiUrl}'),
          ),
        );
      }
    }
  }

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

  Color get _activePreviewSkinColor {
    final found = _sampleFaces.firstWhere(
      (s) => s['key'] == _selectedSampleKey,
      orElse: () => _sampleFaces[1],
    );
    return found['previewColor'] as Color;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'COCOKIN COLOR ANALYSIS (AI CONNECTED)',
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
              ? 'Foto siap dikirim ke AI Engine untuk ekstraksi Skin Tone (CIE-Lab & ITA) serta Undertone.'
              : 'Posisikan wajahmu di dalam panduan atau pilih sampel foto wajah asli untuk dianalisis AI.',
          style: const TextStyle(fontSize: 12.5, color: CocokinColors.textBody),
        ),
        const SizedBox(height: 14),

        // Pilihan Sampel Foto Wajah Asli dari Dataset COCOKIN-AI
        const Text(
          'Pilih Foto Wajah untuk Dianalisis AI:',
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w700,
            color: CocokinColors.textDark,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            for (final sample in _sampleFaces)
              GestureDetector(
                onTap: () => _loadSampleFromDataset(sample),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _selectedSampleKey == sample['key']
                        ? CocokinColors.primaryMauve
                        : Colors.white,
                    borderRadius: BorderRadius.circular(99),
                    border: Border.all(
                      color: _selectedSampleKey == sample['key']
                          ? CocokinColors.primaryMauve
                          : CocokinColors.borderCard,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 11,
                        height: 11,
                        decoration: BoxDecoration(
                          color: sample['previewColor'] as Color,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 1),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        sample['label'] as String,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: _selectedSampleKey == sample['key']
                              ? Colors.white
                              : CocokinColors.textDark,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 14),

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
              // Tombol Ikon Kanan Atas (Atur IP Server HP, Galeri HP, & Reset Kamera)
              Positioned(
                top: 12,
                right: 12,
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: _showServerIpDialog,
                      child: _buildSmallCamAction(Icons.settings_ethernet_rounded),
                    ),
                    const SizedBox(width: 6),
                    GestureDetector(
                      onTap: () => _pickImage(ImageSource.gallery),
                      child: _buildSmallCamAction(Icons.photo_library_outlined),
                    ),
                    const SizedBox(width: 6),
                    GestureDetector(
                      onTap: () => _pickImage(ImageSource.camera),
                      child: _buildSmallCamAction(Icons.photo_camera_front_outlined),
                    ),
                    const SizedBox(width: 6),
                    GestureDetector(
                      onTap: _retakePhoto,
                      child: _buildSmallCamAction(Icons.refresh_rounded),
                    ),
                  ],
                ),
              ),

              // Area Feed Kamera / Pratinjau Foto Asli di Dalam Bingkai Oval
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
                    if (_selectedBytes != null)
                      Positioned.fill(
                        child: Image.memory(
                          _selectedBytes!,
                          fit: BoxFit.cover,
                        ),
                      )
                    else
                      // Ilustrasi Feed Wajah Dinamis mengikuti warna sampel yang dipilih
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
                                  color: _activePreviewSkinColor,
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
                        ? 'Siap dianalisis: $_selectedLabel'
                        : 'Aktif: $_selectedLabel',
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
              onPressed: () {
                widget.onCapture(
                  KameraCapturePayload(
                    imagePath: _selectedPath.isNotEmpty
                        ? _selectedPath
                        : 'kamera_wajah.png',
                    imageBytes: _selectedBytes,
                    sampleKey: _selectedSampleKey,
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
                'Gunakan Foto & Mulai Analisis AI →',
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
                'Ambil Ulang / Ganti Foto',
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

          // Tombol Bulat Ambil Foto + Opsi Galeri HP
          Center(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Tombol Galeri HP
                    GestureDetector(
                      onTap: () => _pickImage(ImageSource.gallery),
                      child: Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: CocokinColors.borderLight,
                            width: 2,
                          ),
                        ),
                        child: const Icon(
                          Icons.photo_library_outlined,
                          color: CocokinColors.primaryMauve,
                          size: 20,
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),

                    // Tombol Ambil Foto Kamera HP
                    GestureDetector(
                      onTap: () => _pickImage(ImageSource.camera),
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: CocokinColors.primaryMauve,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFFE6D2CE),
                            width: 4,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: CocokinColors.primaryMauve.withValues(alpha: 0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.camera_alt_rounded,
                          color: Colors.white,
                          size: 26,
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),

                    // Tombol Simulasi / Path Komputer
                    GestureDetector(
                      onTap: _captureFrame,
                      child: Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: CocokinColors.borderLight,
                            width: 2,
                          ),
                        ),
                        child: const Icon(
                          Icons.check_circle_outline_rounded,
                          color: CocokinColors.primaryMauve,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Ambil Foto Kamera atau Pilih Galeri HP',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: CocokinColors.textDark,
                  ),
                ),
                const Text(
                  'Kiri: Galeri  |  Tengah: Kamera HP  |  Kanan: Gunakan Sampel',
                  style: TextStyle(
                    fontSize: 10.5,
                    color: CocokinColors.textMuted,
                  ),
                ),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: _showCustomFilePathDialog,
                  child: const Text(
                    'Atau masukkan path file foto manual',
                    style: TextStyle(
                      fontSize: 11,
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
