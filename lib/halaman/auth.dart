import 'package:flutter/material.dart';
import '../main.dart';

class AuthPage extends StatefulWidget {
  final bool isRegister;
  final ValueChanged<bool> onSwitchMode;
  final ValueChanged<String> onAuthSuccess;

  const AuthPage({
    super.key,
    required this.isRegister,
    required this.onSwitchMode,
    required this.onAuthSuccess,
  });

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _passCtrl = TextEditingController();
  final TextEditingController _confirmCtrl = TextEditingController();
  String? _errorMsg;

  void _handleSubmit() {
    setState(() => _errorMsg = null);

    final name = _nameCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    final pass = _passCtrl.text.trim();
    final confirm = _confirmCtrl.text.trim();

    if (widget.isRegister && name.isEmpty) {
      setState(() => _errorMsg = 'Nama lengkap wajib diisi.');
      return;
    }
    if (email.isEmpty || pass.isEmpty) {
      setState(() => _errorMsg = 'Email dan password wajib diisi.');
      return;
    }
    if (!email.contains('@')) {
      setState(() => _errorMsg = 'Format email tidak valid.');
      return;
    }
    if (widget.isRegister) {
      if (pass.length < 8) {
        setState(() => _errorMsg = 'Password minimal 8 karakter.');
        return;
      }
      if (pass != confirm) {
        setState(() => _errorMsg = 'Password dan konfirmasi kata sandi tidak cocok.');
        return;
      }
    }

    final displayName = widget.isRegister ? name : email.split('@').first;
    widget.onAuthSuccess(displayName);
  }

  @override
  Widget build(BuildContext context) {
    final isReg = widget.isRegister;

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: CocokinColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isReg ? 'Buatkan Akun' : 'Selamat datang!',
            style: const TextStyle(
              fontSize: 23,
              fontWeight: FontWeight.w700,
              color: CocokinColors.textDark,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            isReg
                ? 'Daftar untuk memulai analisis personal color.'
                : 'Masuk ke akun Cocokin untuk memulai analisis.',
            style: const TextStyle(fontSize: 13, color: CocokinColors.textBody),
          ),
          const SizedBox(height: 18),

          // Tab Toggle Masuk / Daftar sesuai Halaman 2 & 7 Figma
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => widget.onSwitchMode(false),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: !isReg ? CocokinColors.bgSoftPink : Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: !isReg
                            ? CocokinColors.primaryMauve
                            : CocokinColors.borderCard,
                      ),
                    ),
                    child: Text(
                      'Masuk',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: !isReg
                            ? CocokinColors.textDark
                            : CocokinColors.textBody,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: GestureDetector(
                  onTap: () => widget.onSwitchMode(true),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isReg ? CocokinColors.bgSoftPink : Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isReg
                            ? CocokinColors.primaryMauve
                            : CocokinColors.borderCard,
                      ),
                    ),
                    child: Text(
                      'Daftar',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isReg
                            ? CocokinColors.textDark
                            : CocokinColors.textBody,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          if (_errorMsg != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              margin: const EdgeInsets.only(bottom: 14),
              decoration: BoxDecoration(
                color: const Color(0xFFFBEAEA),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                _errorMsg!,
                style: const TextStyle(fontSize: 12, color: Color(0xFF9E3A3A)),
              ),
            ),

          if (isReg) ...[
            _buildInputLabel('Nama Lengkap'),
            _buildTextField(_nameCtrl, 'Masukkan nama lengkap', false),
            const SizedBox(height: 14),
          ],

          _buildInputLabel('Email'),
          _buildTextField(_emailCtrl, 'nama@gmail.com', false),
          const SizedBox(height: 14),

          _buildInputLabel('Password'),
          _buildTextField(
            _passCtrl,
            isReg ? 'Minimal 8 karakter' : 'Masukkan password',
            true,
          ),

          if (isReg) ...[
            const SizedBox(height: 14),
            _buildInputLabel('Konfirmasi kata sandi'),
            _buildTextField(_confirmCtrl, 'Ulangi kata sandi', true),
          ],

          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _handleSubmit,
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
                isReg ? 'Buat Akun' : 'Masuk',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ),
          ),

          const SizedBox(height: 16),
          Center(
            child: GestureDetector(
              onTap: () => widget.onSwitchMode(!isReg),
              child: RichText(
                text: TextSpan(
                  style: const TextStyle(fontSize: 12, color: CocokinColors.textMuted),
                  children: [
                    TextSpan(
                      text: isReg ? 'Sudah punya akun? ' : 'Belum punya akun? ',
                    ),
                    TextSpan(
                      text: isReg ? 'Masuk' : 'Daftar sekarang',
                      style: const TextStyle(
                        color: CocokinColors.primaryMauve,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12.5,
          fontWeight: FontWeight.w700,
          color: CocokinColors.textDark,
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController ctrl,
    String hint,
    bool obscure,
  ) {
    return TextField(
      controller: ctrl,
      obscureText: obscure,
      style: const TextStyle(fontSize: 13.5, color: CocokinColors.textDark),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(fontSize: 13, color: CocokinColors.textMuted),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFB8A69E)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: CocokinColors.primaryMauve, width: 1.5),
        ),
      ),
    );
  }
}
