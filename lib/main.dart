import 'package:flutter/material.dart';
import 'halaman/beranda_page.dart';
import 'halaman/auth_page.dart';
import 'halaman/kamera_page.dart';
import 'halaman/loading_page.dart';
import 'halaman/hasil_page.dart';
import 'halaman/rekomendasi_page.dart';
import 'halaman/detail_produk_page.dart';

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
  int bottomNavIndex = 0; // 0: Beranda, 1: Cara Kerja, 2: Tentang
  String? loggedInUser;
  Map<String, dynamic> selectedProduct = kCatalogProducts.first;

  void navigateTo(String page) {
    setState(() {
      if (page == 'kamera' && loggedInUser == null) {
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
      } else if (currentPage == 'kamera') {
        currentPage = 'beranda';
      } else if (currentPage == 'loading') {
        currentPage = 'kamera';
      } else if (currentPage == 'hasil') {
        currentPage = 'kamera';
      } else if (currentPage == 'rekomendasi') {
        currentPage = 'hasil';
      } else if (currentPage == 'detail_produk') {
        currentPage = 'rekomendasi';
      } else {
        currentPage = 'beranda';
      }
    });
  }

  String get _activeLandingTab {
    if (bottomNavIndex == 1) return 'carakerja';
    if (bottomNavIndex == 2) return 'tentang';
    return 'beranda';
  }

  // AppBar Bersih Selayaknya Aplikasi HP (Tidak Menumpuk!)
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
                ? Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: CocokinColors.bgSoftPink,
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: Text(
                      'Halo, $loggedInUser',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: CocokinColors.textBody,
                      ),
                    ),
                  )
                : ElevatedButton(
                    onPressed: () => navigateTo('login'),
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
      case 'rekomendasi':
        return 'Rekomendasi';
      case 'detail_produk':
        return 'Detail Produk';
      default:
        return '';
    }
  }

  Widget buildPageBody() {
    switch (currentPage) {
      case 'beranda':
        return BerandaPage(
          activeTab: _activeLandingTab,
          isLoggedIn: loggedInUser != null,
          onStartAnalysis: () =>
              navigateTo(loggedInUser != null ? 'kamera' : 'login'),
        );
      case 'login':
        return AuthPage(
          isRegister: false,
          onSwitchMode: (toRegister) =>
              navigateTo(toRegister ? 'daftar' : 'login'),
          onAuthSuccess: (name) {
            setState(() {
              loggedInUser = name;
              currentPage = 'kamera';
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
              currentPage = 'kamera';
            });
          },
        );
      case 'kamera':
        return KameraPage(
          onCapture: () => navigateTo('loading'),
        );
      case 'loading':
        return LoadingPage(
          onFinish: () => navigateTo('hasil'),
        );
      case 'hasil':
        return HasilPage(
          onGoToRekomendasi: () => navigateTo('rekomendasi'),
        );
      case 'rekomendasi':
        return RekomendasiPage(
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
      default:
        return BerandaPage(
          activeTab: _activeLandingTab,
          isLoggedIn: loggedInUser != null,
          onStartAnalysis: () => navigateTo('login'),
        );
    }
  }

  // Bottom Navigation Bar Khas Aplikasi HP
  Widget buildBottomNavBar() {
    final bool isLanding = currentPage == 'beranda';

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
            active: isLanding && bottomNavIndex == 0,
            onTap: () {
              setState(() {
                currentPage = 'beranda';
                bottomNavIndex = 0;
              });
            },
          ),
          _buildNavItem(
            icon: Icons.menu_book_outlined,
            activeIcon: Icons.menu_book_rounded,
            label: 'Cara Kerja',
            active: isLanding && bottomNavIndex == 1,
            onTap: () {
              setState(() {
                currentPage = 'beranda';
                bottomNavIndex = 1;
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
            onTap: () => navigateTo(loggedInUser != null ? 'kamera' : 'login'),
          ),
          _buildNavItem(
            icon: Icons.shopping_bag_outlined,
            activeIcon: Icons.shopping_bag_rounded,
            label: 'Produk',
            active:
                currentPage == 'rekomendasi' || currentPage == 'detail_produk',
            onTap: () {
              if (loggedInUser != null) {
                navigateTo('rekomendasi');
              } else {
                navigateTo('login');
              }
            },
          ),
          _buildNavItem(
            icon: Icons.info_outline_rounded,
            activeIcon: Icons.info_rounded,
            label: 'Tentang',
            active: isLanding && bottomNavIndex == 2,
            onTap: () {
              setState(() {
                currentPage = 'beranda';
                bottomNavIndex = 2;
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
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
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
            Text(
              label,
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                color: active
                    ? CocokinColors.primaryMauve
                    : CocokinColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2C2523),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Container(
            height: double.infinity,
            decoration: BoxDecoration(
              color: CocokinColors.bgMain,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.35),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: SafeArea(
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
          ),
        ),
      ),
    );
  }
}
