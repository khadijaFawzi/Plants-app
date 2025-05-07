// // lib/screens/login_screen.dart
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import '../utils/database_helper.dart';
// import '../widgets/custom_text_field.dart'; // ← المسار الصحيح للـ widget

// class LoginScreen extends StatefulWidget {
//   const LoginScreen({Key? key}) : super(key: key);

//   @override
//   State<LoginScreen> createState() => _LoginScreenState();
// }

// class _LoginScreenState extends State<LoginScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final _emailController = TextEditingController();
//   final _passwordController = TextEditingController();
//   bool _isLoading = false;            // ← هنا عُرّف الـ loading
//   bool _obscurePassword = true;

//   @override
//   void dispose() {
//     _emailController.dispose();
//     _passwordController.dispose();
//     super.dispose();
//   }

//   Future<void> _login() async {
//     if (!_formKey.currentState!.validate()) return;
//     if (!mounted) return;

//     setState(() => _isLoading = true);

//     try {
//       final dbHelper = DatabaseHelper();
//       final user = await dbHelper.getUser(
//         _emailController.text.trim(),
//         _passwordController.text.trim(),
//       );

//       if (user != null) {
//         // حفظ حالة الدخول
//         final prefs = await SharedPreferences.getInstance();
//         await prefs.setBool('isLoggedIn', true);
//         await prefs.setInt('userId', user.id!);
//         await prefs.setString('userName', user.name);

//         if (!mounted) return;
//         setState(() => _isLoading = false);

//         // الانتقال للشاشة الرئيسية والانتهاء هنا لمنع finally من استدعاء setState بعد dispose
//         Navigator.pushReplacementNamed(context, '/main');
//         return;
//       } else {
//         if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(
//               content: Text('Invalid email or password'),
//               backgroundColor: Colors.red,
//             ),
//           );
//         }
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Error: ${e.toString()}'),
//             backgroundColor: Colors.red,
//           ),
//         );
//       }
//     } finally {
//       if (!mounted) return;
//       setState(() => _isLoading = false);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SafeArea(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.all(24.0),
//           child: Form(
//             key: _formKey,
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.stretch,
//               children: [
//                 const SizedBox(height: 40),
//                 Center(
//                   child: Icon(
//                     Icons.eco,
//                     size: 80,
//                     color: Theme.of(context).colorScheme.primary,
//                   ),
//                 ),
//                 const SizedBox(height: 24),
//                 Text(
//                   'Welcome Back',
//                   style: Theme.of(context).textTheme.headlineMedium,
//                   textAlign: TextAlign.center,
//                 ),
//                 const SizedBox(height: 8),
//                 Text(
//                   'Login to your account',
//                   style: Theme.of(context).textTheme.bodyLarge?.copyWith(
//                         color: Theme.of(context).colorScheme.secondary,
//                       ),
//                   textAlign: TextAlign.center,
//                 ),
//                 const SizedBox(height: 48),

//                 // بريد المستخدم
//                 CustomTextField(
//                   controller: _emailController,
//                   hintText: 'Email',
//                   prefixIcon: Icons.email_outlined,
//                   keyboardType: TextInputType.emailAddress,
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return 'Please enter your email';
//                     }
//                     if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
//                         .hasMatch(value.trim())) {
//                       return 'Enter a valid email';
//                     }
//                     return null;
//                   },
//                 ),
//                 const SizedBox(height: 16),

//                 // كلمة المرور
//                 CustomTextField(
//                   controller: _passwordController,
//                   hintText: 'Password',
//                   prefixIcon: Icons.lock_outline,
//                   obscureText: _obscurePassword,
//                   suffixIcon: IconButton(
//                     icon: Icon(_obscurePassword
//                         ? Icons.visibility_off
//                         : Icons.visibility),
//                     onPressed: () {
//                       if (!mounted) return;
//                       setState(() => _obscurePassword = !_obscurePassword);
//                     },
//                   ),
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return 'Please enter your password';
//                     }
//                     return null;
//                   },
//                 ),
//                 const SizedBox(height: 32),

//                 // زر الدخول أو مؤشر التحميل
//                 _isLoading
//                     ? const Center(child: CircularProgressIndicator())
//                     : ElevatedButton(
//                         onPressed: _login,
//                         child: const Text('Login'),
//                       ),

//                 const SizedBox(height: 16),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     const Text('Don\'t have an account?'),
//                     TextButton(
//                       onPressed: () =>
//                           Navigator.pushReplacementNamed(context, '/register'),
//                       child: const Text('Register'),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
// lib/screens/login_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final auth = context.read<AuthProvider>();
    final success = await auth.login(
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );
    setState(() => _isLoading = false);

    if (success) {
      Navigator.pushReplacementNamed(context, '/main');
    } else {
      final error = auth.lastError ?? 'Login failed';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),
                Center(
                  child: Icon(
                    Icons.eco,
                    size: 80,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Welcome Back',
                  style: Theme.of(context).textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Login to your account',
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge
                      ?.copyWith(color: Theme.of(context).colorScheme.secondary),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),
                // Email field
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    hintText: 'Email',
                    prefixIcon: Icon(Icons.email_outlined),
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                        .hasMatch(value.trim())) {
                      return 'Enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                // Password field
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    hintText: 'Password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                          _obscurePassword ? Icons.visibility_off : Icons.visibility),
                      onPressed: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                    ),
                    border: const OutlineInputBorder(),
                  ),
                  obscureText: _obscurePassword,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),
                // Login button or loading
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        onPressed: _login,
                        child: const Text('Login'),
                      ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Don't have an account?"),
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, '/register');
                      },
                      child: const Text('Register'),
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
