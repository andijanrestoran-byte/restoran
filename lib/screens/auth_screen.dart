part of 'package:andijan_flutter/app.dart';

class _LoginScreen extends StatelessWidget {
  const _LoginScreen({
    required this.loginInput,
    required this.passwordInput,
    required this.errorText,
    required this.isLoading,
    required this.onLoginChanged,
    required this.onPasswordChanged,
    required this.onSubmit,
  });

  final String loginInput;
  final String passwordInput;
  final String errorText;
  final bool isLoading;
  final ValueChanged<String> onLoginChanged;
  final ValueChanged<String> onPasswordChanged;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Andijan Restoran',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Ofitsant va direktor paneliga kirish',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    key: const Key('login_username'),
                    controller: TextEditingController(text: loginInput)
                      ..selection = TextSelection.collapsed(
                        offset: loginInput.length,
                      ),
                    onChanged: onLoginChanged,
                    decoration: const InputDecoration(labelText: 'Login'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    key: const Key('login_password'),
                    controller: TextEditingController(text: passwordInput)
                      ..selection = TextSelection.collapsed(
                        offset: passwordInput.length,
                      ),
                    onChanged: onPasswordChanged,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: 'Parol'),
                  ),
                  if (errorText.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(
                      errorText,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      key: const Key('login_submit'),
                      onPressed: isLoading ? null : onSubmit,
                      child: Text(isLoading ? 'Tekshirilmoqda...' : 'Kirish'),
                    ),
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
