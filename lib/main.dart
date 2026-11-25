import 'package:flutter/material.dart';
import 'halaman/beranda_page.dart';
import 'halaman/auth_page.dart';
import 'halaman/kamera_page.dart';
import 'halaman/loading_page.dart';
import 'halaman/hasil_page.dart';
import 'halaman/rekomendasi_page.dart';
import 'halaman/detail_produk_page.dart';
import 'halaman/riwayat_page.dart';
import 'halaman/profil_page.dart';
import 'models/product_model.dart';
import 'services/api_service.dart';

void main() {
  runApp(const CocokinApp());
}

class CocokinColors {
  static const Color bgMain = Color(0xFFF7F3EE);
  static const Color bgSoftPink = Color(0xFFF2E5E2);
  static const Color bgCard = Color(0xFFFFFFFF);
  static const Color primaryMauve = Color(0xFF8D5B5B);
  static const Color textDark = Color(0xFF4A332D);
  static const Color textBody = Color(0xFF6E564F);
  static const Color textMuted = Color(0xFF9A847D);
  static const Color borderLight = Color(0xFFE4D7D0);
  static const Color borderCard = Color(0xFFD9C7BF);
}

class CocokinApp extends StatelessWidget {
  const CocokinApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cocokin',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: CocokinColors.bgMain,
        colorScheme: ColorScheme.fromSeed(
          seedColor: CocokinColors.primaryMauve,
          surface: CocokinColors.bgMain,
        ),
        useMaterial3: true,
      ),
      home: const MainMobileShell(),
    );
  }
}

class MainMobileShell extends StatefulWidget {
  const MainMobileShell({super.key});

  @override
  State<MainMobileShell> createState() => _MainMobileShellState();
}

class _MainMobileShellState extends State<MainMobileShell> {
  String currentPage = 'beranda';
  String _redirectAfterLogin = 'beranda';
  int bottomNavIndex = 0;
  String? loggedInUser;
  bool isPremiumUser = false;
  Map<String, dynamic> selectedProduct = kCatalogProducts.first;
  KameraCapturePayload? _capturedPayload;
  AnalysisResultModel _latestAnalysisResult = const AnalysisResultModel(
    skinTone: 'Medium',
    skinToneHex: 0xFF8C6258,
    undertone: 'Warm',
    undertoneHex: 0xFFDEC4A1,
    personalColor: 'Warm Autumn',
  );

  String get _currentUserEmail => loggedInUser != null
      ? '${loggedInUser!.toLowerCase().replaceAll(' ', '')}@gmail.com'
      : 'yumna@gmail.com';

  void navigateTo(String page) {
    setState(() {
      if ((page == 'kamera' || page == 'rekomendasi') && loggedInUser == null) {
        _redirectAfterLogin = page;
        currentPage = 'login';
      } else {
        currentPage = page;
      }
    });
  }

  void handleBack() {
    setState(() {
      if (currentPage == 'login' || currentPage == 'daftar') {
        currentPage = 'beranda';
        bottomNavIndex = 0;
      } else if (currentPage == 'kamera') {
        currentPage = 'beranda';
        bottomNavIndex = 0;
      } else if (currentPage == 'loading') {
        currentPage = 'kamera';
      } else if (currentPage == 'hasil') {
        currentPage = 'kamera';
      } else if (currentPage == 'riwayat') {
        currentPage = 'profil';
      } else if (currentPage == 'carakerja') {
        currentPage = 'profil';
      } else if (currentPage == 'rekomendasi') {
        currentPage = 'beranda';
        bottomNavIndex = 0;
      } else if (currentPage == 'detail_produk') {
        currentPage = 'rekomendasi';
      } else if (currentPage == 'profil') {
        currentPage = 'beranda';
        bottomNavIndex = 0;
      } else {
        currentPage = 'beranda';
        bottomNavIndex = 0;
      }
    });
  }

  String get _activeLandingTab {
    if (currentPage == 'carakerja') return 'carakerja';
    return 'beranda';
  }

  // AppBar Bersih Selayaknya Aplikasi HP (Dilengkapi Akses Riwayat & Tombol Keluar/Logout)
  Widget buildMobileAppBar() {
    final bool isLanding = currentPage == 'beranda';

    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: const BoxDecoration(
        color: CocokinColors.bgMain,
        border: Border(
          bottom: BorderSide(color: CocokinColors.borderLight, width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              if (!isLanding) ...[
                GestureDetector(
                  onTap: handleBack,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: CocokinColors.bgSoftPink,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 15,
                      color: CocokinColors.textDark,
                    ),
                  ),
                ),
              ],
              GestureDetector(
                onTap: () {
                  setState(() {
                    currentPage = 'beranda';
                    bottomNavIndex = 0;
                  });
                },
                child: const Text(
                  'cocokin.',
                  style: TextStyle(
                    fontFamily: 'Georgia',
                    fontSize: 23,
                    fontWeight: FontWeight.w700,
                    color: CocokinColors.primaryMauve,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
            ],
          ),
          if (isLanding)
            loggedInUser != null
                ? Row(
                    children: [
                      GestureDetector(
                        onTap: () => navigateTo('profil'),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 11,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: CocokinColors.bgSoftPink,
                            borderRadius: BorderRadius.circular(99),
                          ),
                          child: Text(
                            'Halo, $loggedInUser',
                            style: const TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                              color: CocokinColors.textBody,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            loggedInUser = null;
                            currentPage = 'beranda';
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFBEAEA),
                            borderRadius: BorderRadius.circular(99),
                          ),
                          child: const Text(
                            'Keluar',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF9E3A3A),
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                : ElevatedButton(
                    onPressed: () {
                      _redirectAfterLogin = 'beranda';
                      navigateTo('login');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: CocokinColors.primaryMauve,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      minimumSize: Size.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(99),
                      ),
                    ),
                    child: const Text(
                      'Masuk',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )
          else
            Text(
              _getPageTitle(),
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: CocokinColors.textMuted,
              ),
            ),
        ],
      ),
    );
  }

  String _getPageTitle() {
    switch (currentPage) {
      case 'login':
        return 'Masuk Akun';
      case 'daftar':
        return 'Daftar Akun';
      case 'kamera':
        return 'Ambil Foto';
      case 'loading':
        return 'Proses Analisis';
      case 'hasil':
        return 'Hasil Analisis';
      case 'riwayat':
        return 'Riwayat Analisis';
      case 'rekomendasi':
        return 'Rekomendasi';
      case 'detail_produk':
        return 'Detail Produk';
      case 'profil':
        return 'Akun Saya';
      case 'carakerja':
        return 'Cara Kerja';
      default:
        return '';
    }
  }

  Widget buildPageBody() {
    switch (currentPage) {
      case 'beranda':
      case 'carakerja':
        return BerandaPage(
          activeTab: _activeLandingTab,
          isLoggedIn: loggedInUser != null,
          onStartAnalysis: () {
            if (loggedInUser != null) {
              navigateTo('kamera');
            } else {
              _redirectAfterLogin = 'kamera';
              navigateTo('login');
            }
          },
        );
      case 'login':
        return AuthPage(
          isRegister: false,
          onSwitchMode: (toRegister) =>
              navigateTo(toRegister ? 'daftar' : 'login'),
          onAuthSuccess: (name) {
            setState(() {
              loggedInUser = name;
              currentPage = _redirectAfterLogin;
            });
          },
        );
      case 'daftar':
        return AuthPage(
          isRegister: true,
          onSwitchMode: (toRegister) =>
              navigateTo(toRegister ? 'daftar' : 'login'),
          onAuthSuccess: (name) {
            setState(() {
              loggedInUser = name;
              currentPage = _redirectAfterLogin;
            });
          },
        );
      case 'kamera':
        return KameraPage(
          onCapture: (payload) {
            setState(() {
              _capturedPayload = payload;
            });
            navigateTo('loading');
          },
        );
      case 'loading':
        return LoadingPage(
          capturePayload: _capturedPayload,
          userEmail: _currentUserEmail,
          onFinish: (result) {
            setState(() {
              _latestAnalysisResult = result;
            });
            navigateTo('hasil');
          },
        );
      case 'hasil':
        return HasilPage(
          analysisResult: _latestAnalysisResult,
          userEmail: _currentUserEmail,
          isPremiumUser: isPremiumUser,
          onPremiumActivated: () {
            setState(() {
              isPremiumUser = true;
            });
          },
          onGoToRekomendasi: () => navigateTo('rekomendasi'),
          onGoToRiwayat: () => navigateTo('riwayat'),
        );
      case 'riwayat':
        return RiwayatPage(
          userEmail: _currentUserEmail,
          onGoToRekomendasi: () => navigateTo('rekomendasi'),
          onNewAnalysis: () => navigateTo('kamera'),
        );
      case 'rekomendasi':
        return RekomendasiPage(
          analysisResult: _latestAnalysisResult,
          onSelectProduct: (prod) {
            setState(() {
              selectedProduct = prod;
              currentPage = 'detail_produk';
            });
          },
        );
      case 'detail_produk':
        return DetailProdukPage(
          product: selectedProduct,
        );
      case 'profil':
        return ProfilPage(
          userName: loggedInUser,
          userEmail: loggedInUser != null ? _currentUserEmail : null,
          isPremium: isPremiumUser,
          onLogin: () {
            _redirectAfterLogin = 'profil';
            navigateTo('login');
          },
          onLogout: () {
            setState(() {
              loggedInUser = null;
              isPremiumUser = false;
              currentPage = 'beranda';
            });
          },
          onOpenRiwayat: () => navigateTo('riwayat'),
          onOpenCaraKerja: () => navigateTo('carakerja'),
          onUnlockPremium: () {
            if (mounted) {
              setState(() => isPremiumUser = true);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  backgroundColor: CocokinColors.textDark,
                  content: Text(
                    'Pembayaran Sandbox terverifikasi! Cocokin Premium telah aktif.',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              );
            }
          },
        );
      default:
        return BerandaPage(
          activeTab: _activeLandingTab,
          isLoggedIn: loggedInUser != null,
          onStartAnalysis: () => navigateTo('login'),
        );
    }
  }

  // Bottom Navigation Bar 4 Tab Standar Aplikasi Mobile
  Widget buildBottomNavBar() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: CocokinColors.borderLight, width: 1),
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(
            icon: Icons.home_outlined,
            activeIcon: Icons.home_rounded,
            label: 'Beranda',
            active: currentPage == 'beranda',
            onTap: () {
              setState(() {
                currentPage = 'beranda';
                bottomNavIndex = 0;
              });
            },
          ),
          _buildNavItem(
            icon: Icons.camera_enhance_outlined,
            activeIcon: Icons.camera_enhance_rounded,
            label: 'Analisis',
            active: currentPage == 'kamera' ||
                currentPage == 'loading' ||
                currentPage == 'hasil',
            onTap: () => navigateTo('kamera'),
          ),
          _buildNavItem(
            icon: Icons.shopping_bag_outlined,
            activeIcon: Icons.shopping_bag_rounded,
            label: 'Produk',
            active:
                currentPage == 'rekomendasi' || currentPage == 'detail_produk',
            onTap: () => navigateTo('rekomendasi'),
          ),
          _buildNavItem(
            icon: Icons.person_outline_rounded,
            activeIcon: Icons.person_rounded,
            label: 'Akun',
            active: currentPage == 'profil' ||
                currentPage == 'riwayat' ||
                currentPage == 'carakerja' ||
                currentPage == 'login' ||
                currentPage == 'daftar',
            onTap: () {
              setState(() {
                currentPage = 'profil';
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required bool active,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                active ? activeIcon : icon,
                size: 21,
                color: active
                    ? CocokinColors.primaryMauve
                    : CocokinColors.textMuted,
              ),
              const SizedBox(height: 3),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  label,
                  maxLines: 1,
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                    color: active
                        ? CocokinColors.primaryMauve
                        : CocokinColors.textMuted,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CocokinColors.bgMain,
      body: SafeArea(
        child: Column(
          children: [
            buildMobileAppBar(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
                child: buildPageBody(),
              ),
            ),
            buildBottomNavBar(),
          ],
        ),
      ),
    );
  }
}
