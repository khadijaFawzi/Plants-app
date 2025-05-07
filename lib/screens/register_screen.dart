// lib/screens/register_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_application_1/widgets/custom_text_field.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../models/user.dart';


class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameC = TextEditingController();
  final _emailC = TextEditingController();
  final _passC = TextEditingController();
  bool _loading = false, _obscure = true;
Future<void> _register() async {
  if (!_formKey.currentState!.validate()) return;
  setState(() => _loading = true);

  final auth = context.read<AuthProvider>();

  // عرّف المتغيّر محلياً قبل تمريره
  final newUser = User(
    name: _nameC.text.trim(),
    email: _emailC.text.trim(),
    password: _passC.text.trim(),
  );

  final success = await auth.register(newUser);

  setState(() => _loading = false);
  debugPrint('🔄 register returned success=$success');

  if (success) {
    debugPrint('✅ Registration succeeded, navigating to /main');
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed('/main');
    debugPrint('➡️ Navigation call done');
  } else {
    final error = auth.lastError ?? 'Registration failed';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(error), backgroundColor: Colors.red),
    );
  }
}


  @override
  Widget build(BuildContext context) {
    if (context.watch<AuthProvider>().isAuth) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, '/main');
      });
      return const SizedBox.shrink();
    }

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),
                Center(
                  child: Icon(Icons.eco,
                      size: 80, color: Theme.of(context).colorScheme.primary),
                ),
                const SizedBox(height: 24),
                Text('Create Account',
                    style: Theme.of(context).textTheme.headlineMedium,
                    textAlign: TextAlign.center),
                const SizedBox(height: 48),
                CustomTextField(
                  controller: _nameC,
                  hintText: 'Name',
                  prefixIcon: Icons.person_outline,
                  validator: (v) => v == null || v.isEmpty
                      ? 'Enter your name'
                      : null,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _emailC,
                  hintText: 'Email',
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) => v == null || v.isEmpty
                      ? 'Enter your email'
                      : null,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _passC,
                  hintText: 'Password',
                  prefixIcon: Icons.lock_outline,
                  obscureText: _obscure,
                  suffixIcon: IconButton(
                    icon: Icon(
                        _obscure ? Icons.visibility : Icons.visibility_off,
                        color: Colors.grey),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                  validator: (v) => v == null || v.isEmpty
                      ? 'Enter password'
                      : null,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _loading ? null : _register,
                  child: _loading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Register'),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Already have an account? ',
                        style: Theme.of(context).textTheme.bodyMedium),
                    GestureDetector(
                      onTap: () =>
                          Navigator.pushReplacementNamed(context, '/login'),
                      child: Text('Login',
                          style: TextStyle(
                              color:
                                  Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
