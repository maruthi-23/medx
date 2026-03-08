import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:medx/auth/data/auth_repository.dart';
import 'package:medx/auth/data/auth_service.dart';
import 'package:medx/auth/logic/auth_controller.dart';
import 'package:medx/auth/ui/signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  late AuthController authController;

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    authController = AuthController(AuthRepository(AuthService()));
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  /// LOGIN
  Future<void> login() async {

    if (emailController.text.isEmpty || passwordController.text.isEmpty) {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Enter email and password")),
      );

      return;
    }

    setState(() => isLoading = true);

    final error = await authController.login(
      emailController.text.trim(),
      passwordController.text.trim(),
    );

    if (!mounted) return;

    setState(() => isLoading = false);

    if (error != null) {

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error)));
    }
  }

  /// GOOGLE LOGIN
  Future<void> googleLogin() async {

    setState(() => isLoading = true);

    final error = await authController.signInWithGoogle();

    if (!mounted) return;

    setState(() => isLoading = false);

    if (error != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error)));
    }
  }

  /// RESET PASSWORD
  Future<void> forgotPassword() async {

    if (emailController.text.isEmpty) {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Enter your email first")),
      );

      return;
    }

    final error =
        await authController.sendPasswordReset(emailController.text.trim());

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(error ?? "Password reset email sent"),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(
        child: SingleChildScrollView(

          padding: const EdgeInsets.symmetric(horizontal: 25),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [

              const SizedBox(height: 40),

              const Text(
                "Welcome Back",
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                "Login to continue",
                style: TextStyle(color: Colors.grey),
              ),

              const SizedBox(height: 40),

              /// EMAIL
              _textField(
                hintText: "Email",
                controller: emailController,
                prefixIcon: const Icon(Icons.email_outlined),
                keyboardType: TextInputType.emailAddress,
              ),

              /// PASSWORD
              _textField(
                hintText: "Password",
                controller: passwordController,
                prefixIcon: const Icon(Icons.lock_outline),
                obscureText: true,
              ),

              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: forgotPassword,
                  child: const Text("Forgot Password?"),
                ),
              ),

              const SizedBox(height: 10),

              /// LOGIN BUTTON
              _button(
                name: "Login",
                onPressed: isLoading ? null : login,
              ),

              const SizedBox(height: 20),

              const Center(child: Text("OR")),

              const SizedBox(height: 20),

              /// GOOGLE BUTTON
              _googleButton(),

              const SizedBox(height: 30),

              /// SIGNUP LINK
              Center(
                child: RichText(
                  text: TextSpan(
                    text: "Don't have an account? ",
                    style: const TextStyle(color: Colors.black87),

                    children: [

                      TextSpan(
                        text: "Signup",
                        style: const TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),

                        recognizer: TapGestureRecognizer()
                          ..onTap = () {

                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const SignupScreen(),
                              ),
                            );
                          },
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  /// GOOGLE BUTTON
  Widget _googleButton() {

    return SizedBox(
      width: double.infinity,
      height: 55,

      child: OutlinedButton.icon(

        onPressed: isLoading ? null : googleLogin,

        icon: Image.network(
          "https://cdn-icons-png.flaticon.com/512/2991/2991148.png",
          height: 22,
        ),

        label: const Text(
          "Continue with Google",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),

        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  /// TEXT FIELD
  Widget _textField({

    String? hintText,
    TextEditingController? controller,
    Icon? prefixIcon,
    bool obscureText = false,
    TextInputType? keyboardType,
  }) {

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),

      child: TextFormField(

        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,

        decoration: InputDecoration(

          hintText: hintText,

          prefixIcon: prefixIcon,

          filled: true,
          fillColor: Colors.grey.shade100,

          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  /// BUTTON
  Widget _button({
    String? name,
    required VoidCallback? onPressed,
  }) {

    return SizedBox(
      width: double.infinity,
      height: 55,

      child: ElevatedButton(

        onPressed: onPressed,

        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),

        child: isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : Text(
                name ?? "",
                style: const TextStyle(fontSize: 16),
              ),
      ),
    );
  }
}