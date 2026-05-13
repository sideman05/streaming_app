import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/widgets/app_background.dart';
import '../../../core/widgets/app_states.dart';
import '../data/auth_repository.dart';
import 'auth_controller.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authControllerProvider);
    ref.listen(authControllerProvider, (_, next) {
      if (next.hasError) {
        final error = next.error;
        final message = error is AuthException
            ? error.message
            : 'Registration failed. Please try again.';
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: AppBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  TextFormField(
                    controller: _name,
                    decoration: const InputDecoration(labelText: 'Name'),
                    validator: (v) =>
                        (v ?? '').trim().isNotEmpty ? null : 'Name required',
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _email,
                    decoration: const InputDecoration(labelText: 'Email'),
                    validator: (v) => v != null && v.contains('@')
                        ? null
                        : 'Valid email required',
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _password,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: 'Password'),
                    validator: (v) =>
                        (v ?? '').length >= 6 ? null : 'Min 6 characters',
                  ),
                  const SizedBox(height: 20),
                  if (auth.isLoading)
                    const LoadingView()
                  else
                    ElevatedButton(
                      onPressed: () async {
                        if (!_formKey.currentState!.validate()) return;
                        await ref
                            .read(authControllerProvider.notifier)
                            .register(
                              _name.text.trim(),
                              _email.text.trim(),
                              _password.text,
                            );
                        final current = ref.read(authControllerProvider);
                        if (context.mounted &&
                            !current.hasError &&
                            current.valueOrNull != null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Account created successfully'),
                            ),
                          );
                          context.go('/home');
                        }
                      },
                      child: const Text('Register'),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
