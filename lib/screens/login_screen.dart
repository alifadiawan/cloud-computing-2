import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: const Color(0xFFF5F5F7), // canvas-parchment
      child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 48),

                // Apple logo placeholder
                const Icon(
                  CupertinoIcons.device_phone_portrait,
                  size: 56,
                  color: Color(0xFF1D1D1F), // ink
                ),

                const SizedBox(height: 32),

                // Hero headline
                const Text(
                  'Sign in to your\naccount',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: '.SF Pro Display',
                    fontSize: 40,
                    fontWeight: FontWeight.w600,
                    height: 1.1,
                    letterSpacing: 0,
                    color: Color(0xFF1D1D1F), // ink
                    decoration: TextDecoration.none,
                  ),
                ),

                const SizedBox(height: 12),

                // Tagline
                const Text(
                  'Use your Apple ID to get started.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: '.SF Pro Text',
                    fontSize: 17,
                    fontWeight: FontWeight.w400,
                    height: 1.47,
                    letterSpacing: -0.374,
                    color: Color(0xFF333333), // ink-muted-80
                    decoration: TextDecoration.none,
                  ),
                ),

                const SizedBox(height: 48),

                // Email field
                _buildTextField(
                  controller: _emailController,
                  placeholder: 'Email or Phone Number',
                  keyboardType: TextInputType.emailAddress,
                  prefix: const Padding(
                    padding: EdgeInsets.only(left: 16),
                    child: Icon(
                      CupertinoIcons.mail,
                      size: 18,
                      color: Color(0xFF7A7A7A),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Password field
                _buildTextField(
                  controller: _passwordController,
                  placeholder: 'Password',
                  obscureText: _obscurePassword,
                  prefix: const Padding(
                    padding: EdgeInsets.only(left: 16),
                    child: Icon(
                      CupertinoIcons.lock,
                      size: 18,
                      color: Color(0xFF7A7A7A),
                    ),
                  ),
                  suffix: GestureDetector(
                    onTap: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: Icon(
                        _obscurePassword
                            ? CupertinoIcons.eye
                            : CupertinoIcons.eye_slash,
                        size: 18,
                        color: const Color(0xFF7A7A7A),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Forgot password link
                Align(
                  alignment: Alignment.centerRight,
                  child: CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () {},
                    child: const Text(
                      'Forgot password?',
                      style: TextStyle(
                        fontFamily: '.SF Pro Text',
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        letterSpacing: -0.224,
                        color: Color(0xFF0066CC), // primary
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // Sign In button (primary pill)
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: CupertinoButton(
                    color: const Color(0xFF0066CC), // primary
                    borderRadius: BorderRadius.circular(9999), // pill
                    padding: const EdgeInsets.symmetric(
                      vertical: 11,
                      horizontal: 22,
                    ),
                    onPressed: () {},
                    child: const Text(
                      'Sign In',
                      style: TextStyle(
                        fontFamily: '.SF Pro Text',
                        fontSize: 17,
                        fontWeight: FontWeight.w400,
                        letterSpacing: -0.374,
                        color: Color(0xFFFFFFFF), // on-primary
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Continue with Apple button (secondary pill)
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: CupertinoButton(
                    color: const Color(0xFF1D1D1F), // ink
                    borderRadius: BorderRadius.circular(9999), // pill
                    padding: const EdgeInsets.symmetric(
                      vertical: 11,
                      horizontal: 22,
                    ),
                    onPressed: () {},
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          CupertinoIcons.person_fill,
                          size: 18,
                          color: Color(0xFFFFFFFF),
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Continue with Apple',
                          style: TextStyle(
                            fontFamily: '.SF Pro Text',
                            fontSize: 17,
                            fontWeight: FontWeight.w400,
                            letterSpacing: -0.374,
                            color: Color(0xFFFFFFFF), // on-dark
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 48),

                // Divider with "or"
                const Row(
                  children: [
                    Expanded(
                      child: Divider(
                        color: Color(0xFFE0E0E0), // hairline
                        thickness: 0.5,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'or',
                        style: TextStyle(
                          fontFamily: '.SF Pro Text',
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          letterSpacing: -0.224,
                          color: Color(0xFF7A7A7A), // ink-muted-48
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Divider(
                        color: Color(0xFFE0E0E0), // hairline
                        thickness: 0.5,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // Create account link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Don't have an account? ",
                      style: TextStyle(
                        fontFamily: '.SF Pro Text',
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        letterSpacing: -0.224,
                        color: Color(0xFF333333), // ink-muted-80
                        decoration: TextDecoration.none,
                      ),
                    ),
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: () {},
                      child: const Text(
                        'Create one',
                        style: TextStyle(
                          fontFamily: '.SF Pro Text',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.224,
                          color: Color(0xFF0066CC), // primary
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 48),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String placeholder,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    Widget? prefix,
    Widget? suffix,
  }) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF), // canvas
        borderRadius: BorderRadius.circular(9999), // pill
        border: Border.all(
          color: const Color(0xFFE0E0E0), // hairline
          width: 1,
        ),
      ),
      child: Row(
        children: [
          ?prefix,
          Expanded(
            child: CupertinoTextField(
              controller: controller,
              placeholder: placeholder,
              keyboardType: keyboardType,
              obscureText: obscureText,
              padding: EdgeInsets.only(
                left: prefix != null ? 12 : 20,
                right: suffix != null ? 0 : 20,
                top: 14,
                bottom: 14,
              ),
              decoration: const BoxDecoration(
                color: Colors.transparent,
              ),
              placeholderStyle: const TextStyle(
                fontFamily: '.SF Pro Text',
                fontSize: 17,
                fontWeight: FontWeight.w400,
                letterSpacing: -0.374,
                color: Color(0xFF7A7A7A), // ink-muted-48
              ),
              style: const TextStyle(
                fontFamily: '.SF Pro Text',
                fontSize: 17,
                fontWeight: FontWeight.w400,
                letterSpacing: -0.374,
                color: Color(0xFF1D1D1F), // ink
              ),
            ),
          ),
          ?suffix,
        ],
      ),
    );
  }
}
