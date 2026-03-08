import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:medx/auth/data/auth_repository.dart';
import 'package:medx/auth/data/auth_service.dart';
import 'package:medx/auth/logic/auth_controller.dart';
import 'package:medx/auth/ui/login_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {

  final TextEditingController userController = TextEditingController();
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
    userController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  /// SIGNUP
  Future<void> signup() async {

    if (userController.text.isEmpty ||
        emailController.text.isEmpty ||
        passwordController.text.isEmpty) {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("All fields are required")),
      );

      return;
    }

    setState(() => isLoading = true);

    final error = await authController.signup(
      emailController.text.trim(),
      passwordController.text.trim(),
      userController.text.trim(),
    );

    if (!mounted) return;

    setState(() => isLoading = false);

    if (error != null) {

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error)));
    }
  }

  /// GOOGLE SIGNUP
  Future<void> googleSignup() async {

    setState(() => isLoading = true);

    final error = await authController.signInWithGoogle();

    if (!mounted) return;

    setState(() => isLoading = false);

    if (error != null) {

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error)));
    }
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
                "Create Account",
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                "Signup to get started",
                style: TextStyle(color: Colors.grey),
              ),

              const SizedBox(height: 40),

              /// USERNAME
              _textField(
                hintText: "Username",
                controller: userController,
                prefixIcon: const Icon(Icons.person_outline),
              ),

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

              const SizedBox(height: 15),

              /// SIGNUP BUTTON
              _button(
                name: "Signup",
                onPressed: isLoading ? null : signup,
              ),

              const SizedBox(height: 20),

              const Center(child: Text("OR")),

              const SizedBox(height: 20),

              /// GOOGLE SIGNUP
              _googleButton(),

              const SizedBox(height: 30),

              /// LOGIN LINK
              Center(
                child: RichText(
                  text: TextSpan(
                    text: "Already have an account? ",
                    style: const TextStyle(color: Colors.black87),

                    children: [

                      TextSpan(
                        text: "Login",
                        style: const TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),

                        recognizer: TapGestureRecognizer()
                          ..onTap = () {

                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const LoginScreen(),
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

        onPressed: isLoading ? null : googleSignup,

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