import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLogin = true;
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// =========================================================
  /// PENGATURAN TEMA WARNA (Pilih salah satu & uncomment)
  /// =========================================================

  // ---> TEMA 1: Industrial & Energetic (Oranye Mekanik & Abu-abu) <---
  // final Color _primaryColor = const Color(0xFFE67E22); // Pumpkin Orange
  // final Color _secondaryColor = const Color(0xFFD35400); // Darker Orange
  // final Color _titleColor = const Color(0xFF2C3E50); // Charcoal
  // final Color _bgTop = const Color(0xFFFFF3E0); // Soft Orange Latar Atas
  // final Color _bgBottom = const Color(0xFFF4F7FB);

  
  // ---> TEMA 2: Trust & Professional (Navy & Steel) <---
  final Color _primaryColor = const Color(0xFF1A365D); // Navy Blue
  final Color _secondaryColor = const Color(0xFF2B6CB0); // Bright Blue
  final Color _titleColor = const Color(0xFF1A365D); // Navy Blue
  final Color _bgTop = const Color(0xFFEBF8FF); // Soft Blue Latar Atas
  final Color _bgBottom = const Color(0xFFF4F7FB);
  
  // // ---> TEMA 3: Sporty & Bold (Merah Racing & Hitam) <---
  // final Color _primaryColor = const Color(0xFFE53E3E); // Racing Red
  // final Color _secondaryColor = const Color(0xFFC53030); // Dark Red
  // final Color _titleColor = const Color(0xFF1A202C); // Midnight Black
  // final Color _bgTop = const Color(0xFFFEE2E2); // Soft Red Latar Atas
  // final Color _bgBottom = const Color(0xFFF4F7FB);
  

  /// =========================================================

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      if (_isLogin) {
        await _auth.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
        if (mounted) {
          _showSnackBar('Berhasil masuk!', Colors.green, Icons.check_circle_rounded);
        }
      } else {
        if (_passwordController.text != _confirmPasswordController.text) {
          throw FirebaseAuthException(
            code: 'passwords-dont-match',
            message: 'Konfirmasi password tidak cocok.',
          );
        }

        await _auth.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        if (mounted) {
          _showSnackBar('Pendaftaran berhasil! Akun telah masuk.', Colors.green, Icons.check_circle_rounded);
        }
      }
    } on FirebaseAuthException catch (e) {
      String message = 'Terjadi kesalahan.';
      if (e.code == 'user-not-found') {
        message = 'Email tidak terdaftar. Silakan daftar terlebih dahulu.';
      } else if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
        message = 'Email atau password salah. Silakan coba lagi.';
      } else if (e.code == 'email-already-in-use') {
        message = 'Email ini sudah terdaftar. Silakan gunakan email lain.';
      } else if (e.code == 'invalid-email') {
        message = 'Format email tidak valid.';
      } else if (e.code == 'weak-password') {
        message = 'Password terlalu lemah. Minimal 6 karakter.';
      } else if (e.code == 'passwords-dont-match') {
        message = e.message ?? 'Konfirmasi password tidak cocok.';
      } else {
        message = e.message ?? message;
      }

      if (mounted) {
        _showSnackBar(message, Colors.redAccent, Icons.error_outline_rounded);
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Kesalahan sistem: $e', Colors.redAccent, Icons.error_outline_rounded);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showSnackBar(String message, Color bgColor, IconData icon) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.inter(fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        backgroundColor: bgColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        margin: const EdgeInsets.all(16),
        elevation: 6,
      ),
    );
  }

  InputDecoration _buildInputDecoration({
    required String labelText,
    required String hintText,
    required IconData prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      hintStyle: GoogleFonts.inter(color: Colors.grey.shade400, fontSize: 14),
      labelStyle: GoogleFonts.inter(color: Colors.grey.shade600, fontSize: 14),
      // Mengganti withOpacity menjadi withValues sesuai standar Flutter terbaru
      prefixIcon: Icon(prefixIcon, color: _primaryColor.withValues(alpha: 0.7)),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.grey.shade200, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: _primaryColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgBottom,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [_bgTop, _bgBottom],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    /// APP LOGO & HEADER
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            // Mengganti withOpacity menjadi withValues
                            color: _primaryColor.withValues(alpha: 0.15),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.build_circle_rounded,
                        size: 64,
                        color: _primaryColor,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'BengkelFinder',
                      style: GoogleFonts.montserrat(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: _titleColor,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _isLogin
                          ? 'Selamat datang kembali!\nSilakan masuk untuk melanjutkan.'
                          : 'Mari bergabung dengan BengkelFinder!\nDaftar untuk mulai menjelajah.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        color: Colors.grey.shade600,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 36),

                    /// FORM CARD
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            // Mengganti withOpacity menjadi withValues
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 24,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: AnimatedSize(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              /// EMAIL FIELD
                              TextFormField(
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                textInputAction: TextInputAction.next,
                                enabled: !_isLoading,
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  color: Colors.black87,
                                  fontWeight: FontWeight.w500,
                                ),
                                decoration: _buildInputDecoration(
                                  labelText: 'Email',
                                  hintText: 'nama@email.com',
                                  prefixIcon: Icons.email_outlined,
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) return 'Email tidak boleh kosong';
                                  final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                                  if (!emailRegex.hasMatch(value.trim())) return 'Format email tidak valid';
                                  return null;
                                },
                              ),
                              const SizedBox(height: 20),

                              /// PASSWORD FIELD
                              TextFormField(
                                controller: _passwordController,
                                obscureText: _obscurePassword,
                                textInputAction: _isLogin ? TextInputAction.done : TextInputAction.next,
                                enabled: !_isLoading,
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  color: Colors.black87,
                                  fontWeight: FontWeight.w500,
                                ),
                                decoration: _buildInputDecoration(
                                  labelText: 'Password',
                                  hintText: 'Minimal 6 karakter',
                                  prefixIcon: Icons.lock_outline_rounded,
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                      color: Colors.grey.shade500,
                                    ),
                                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) return 'Password tidak boleh kosong';
                                  if (value.length < 6) return 'Password minimal 6 karakter';
                                  return null;
                                },
                                onFieldSubmitted: (_) {
                                  if (_isLogin) _submitForm();
                                },
                              ),

                              /// CONFIRM PASSWORD
                              if (!_isLogin) ...[
                                const SizedBox(height: 20),
                                TextFormField(
                                  controller: _confirmPasswordController,
                                  obscureText: _obscureConfirmPassword,
                                  textInputAction: TextInputAction.done,
                                  enabled: !_isLoading,
                                  style: GoogleFonts.inter(
                                    fontSize: 16,
                                    color: Colors.black87,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  decoration: _buildInputDecoration(
                                    labelText: 'Konfirmasi Password',
                                    hintText: 'Ulangi password Anda',
                                    prefixIcon: Icons.lock_reset_outlined,
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscureConfirmPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                        color: Colors.grey.shade500,
                                      ),
                                      onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                                    ),
                                  ),
                                  validator: (value) {
                                    if (!_isLogin) {
                                      if (value == null || value.isEmpty) return 'Konfirmasi password wajib diisi';
                                      if (value != _passwordController.text) return 'Password tidak cocok';
                                    }
                                    return null;
                                  },
                                  onFieldSubmitted: (_) => _submitForm(),
                                ),
                              ],
                              const SizedBox(height: 32),

                              /// SUBMIT BUTTON
                              Container(
                                height: 56,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  gradient: LinearGradient(
                                    colors: [_primaryColor, _secondaryColor],
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      // Mengganti withOpacity menjadi withValues
                                      color: _primaryColor.withValues(alpha: 0.3),
                                      blurRadius: 12,
                                      offset: const Offset(0, 6),
                                    ),
                                  ],
                                ),
                                child: ElevatedButton(
                                  onPressed: _isLoading ? null : _submitForm,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                  child: _isLoading
                                      ? const SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                                        )
                                      : Text(
                                          _isLogin ? 'Masuk' : 'Daftar',
                                          style: GoogleFonts.inter(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                            letterSpacing: 1,
                                          ),
                                        ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    /// TOGGLE SIGN IN / SIGN UP
                    TextButton(
                      onPressed: _isLoading
                          ? null
                          : () {
                              setState(() {
                                _isLogin = !_isLogin;
                                _formKey.currentState?.reset();
                              });
                            },
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text.rich(
                        TextSpan(
                          text: _isLogin ? 'Belum punya akun? ' : 'Sudah punya akun? ',
                          style: GoogleFonts.inter(
                            color: Colors.grey.shade600,
                            fontSize: 14,
                          ),
                          children: [
                            TextSpan(
                              text: _isLogin ? 'Daftar di sini' : 'Masuk di sini',
                              style: GoogleFonts.inter(
                                color: _primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}