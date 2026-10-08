import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/auth_model.dart';
import '../theme/app_theme.dart';
import '../widgets/loading_indicator.dart';
import '../widgets/toast_stack.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthModel>();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Профиль', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 16),
          Expanded(
            child: auth.isLoggedIn
                ? _ProfileView(auth: auth)
                : const AuthForm(),
          ),
        ],
      ),
    );
  }
}

class _ProfileView extends StatelessWidget {
  final AuthModel auth;

  const _ProfileView({required this.auth});

  @override
  Widget build(BuildContext context) {
    final name = auth.name.isNotEmpty ? auth.name : 'Гость';

    return Column(
      children: [
        const SizedBox(height: 16),
        const CircleAvatar(
          radius: 40,
          backgroundColor: AppColors.surface,
          child: Icon(Icons.person, size: 40, color: AppColors.primary),
        ),
        const SizedBox(height: 16),
        Text(name, style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 4),
        Text(
          auth.email,
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        if (auth.phone.isNotEmpty) ...[
          const SizedBox(height: 2),
          Text(
            auth.phone,
            style: const TextStyle(color: AppColors.textSecondary),
          ),
        ],
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.primary),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              auth.logout();
              toastController.show('Вы вышли из аккаунта');
            },
            child: const Text('Выйти'),
          ),
        ),
      ],
    );
  }
}

class AuthForm extends StatefulWidget {
  /// Вызывается после успешного входа или регистрации.
  final VoidCallback? onSuccess;

  const AuthForm({super.key, this.onSuccess});

  @override
  State<AuthForm> createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> {
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();

  bool _registering = false;
  bool _loading = false;
  bool _hidePassword = true;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  InputDecoration _decoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: AppColors.textSecondary),
      prefixIcon: Icon(icon, color: AppColors.textSecondary),
      filled: true,
      fillColor: AppColors.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary),
      ),
    );
  }

  String? _validate() {
    final email = _email.text.trim();
    if (_registering && _name.text.trim().isEmpty) return 'Введите имя.';
    if (!email.contains('@') || !email.contains('.')) {
      return 'Введите корректный email.';
    }
    if (_password.text.length < 8) {
      return 'Пароль должен содержать не менее 8 символов.';
    }
    return null;
  }

  Future<void> _submit() async {
    final problem = _validate();
    if (problem != null) {
      setState(() => _error = problem);
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() {
      _loading = true;
      _error = null;
    });

    final auth = context.read<AuthModel>();
    try {
      if (_registering) {
        await auth.register(
          name: _name.text.trim(),
          email: _email.text.trim(),
          password: _password.text,
          phone: _phone.text.trim(),
        );
        toastController.show('Добро пожаловать в Gari Grill!');
      } else {
        await auth.login(_email.text.trim(), _password.text);
        toastController.show('Вы вошли в аккаунт');
      }
      widget.onSuccess?.call();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = authErrorMessage(e, registering: _registering);
        _loading = false;
      });
    }
    // При успехе экран сам заменится на профиль (AuthModel уведомит слушателей).
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            _registering ? 'Создайте аккаунт' : 'Войдите, чтобы делать заказы',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 20),
          if (_registering) ...[
            TextField(
              controller: _name,
              textCapitalization: TextCapitalization.words,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: _decoration('Имя', Icons.person_outline),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _phone,
              keyboardType: TextInputType.phone,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: _decoration('Телефон (необязательно)', Icons.phone),
            ),
            const SizedBox(height: 12),
          ],
          TextField(
            controller: _email,
            keyboardType: TextInputType.emailAddress,
            autocorrect: false,
            style: const TextStyle(color: AppColors.textPrimary),
            decoration: _decoration('Email', Icons.email_outlined),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _password,
            obscureText: _hidePassword,
            style: const TextStyle(color: AppColors.textPrimary),
            onSubmitted: (_) => _loading ? null : _submit(),
            decoration: _decoration('Пароль', Icons.lock_outline).copyWith(
              suffixIcon: IconButton(
                icon: Icon(
                  _hidePassword ? Icons.visibility_off : Icons.visibility,
                  color: AppColors.textSecondary,
                ),
                onPressed: () => setState(() => _hidePassword = !_hidePassword),
              ),
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(_error!, style: const TextStyle(color: Colors.redAccent)),
          ],
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _loading ? null : _submit,
            child: _loading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: LoadingIndicator(
                      size: 20,
                      strokeWidth: 2,
                      color: AppColors.background,
                    ),
                  )
                : Text(_registering ? 'Зарегистрироваться' : 'Войти'),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: _loading
                ? null
                : () => setState(() {
                    _registering = !_registering;
                    _error = null;
                  }),
            child: Text(
              _registering
                  ? 'Уже есть аккаунт? Войти'
                  : 'Нет аккаунта? Зарегистрироваться',
              style: const TextStyle(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }
}
