import 'dart:async';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart'
    show AuthException, AuthRetryableFetchException;

import '../auth/auth_controller.dart';
import '../l10n/formatters.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({
    super.key,
    required this.auth,
    required this.onLanguageChanged,
    required this.locale,
  });
  final AuthController auth;
  final ValueChanged<Locale?> onLanguageChanged;
  final Locale? locale;
  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final form = GlobalKey<FormState>();
  final email = TextEditingController();
  final password = TextEditingController();
  bool registering = false, busy = false, obscure = true;
  String? message;
  bool confirmation = false;
  bool browserOpened = false;
  late Locale? selectedLocale = widget.locale;

  String failureMessage(Object error, String fallback) {
    if (error is TimeoutException || error is AuthRetryableFetchException) {
      return 'network';
    }
    if (error is AuthException) {
      if (error.code == 'invalid_api_key' ||
          error.message.toLowerCase().contains('invalid api key')) {
        return 'configuration';
      }
      if ((int.tryParse(error.statusCode ?? '') ?? 0) >= 500) {
        return 'network';
      }
      return switch (error.code) {
        'invalid_credentials' => 'credentials',
        'email_not_confirmed' => 'unconfirmed',
        'over_request_rate_limit' ||
        'over_email_send_rate_limit' ||
        'over_sms_send_rate_limit' => 'rateLimit',
        _ => fallback,
      };
    }
    return fallback;
  }

  Future<void> signInWithProvider(SocialAuthProvider provider) async {
    if (busy || !widget.auth.socialProviders.contains(provider)) return;
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() {
      busy = true;
      message = null;
      confirmation = false;
      browserOpened = false;
    });
    try {
      await widget.auth.signInWithProvider(provider);
      if (mounted) setState(() => browserOpened = true);
    } catch (error) {
      if (mounted) {
        setState(() => message = failureMessage(error, 'social'));
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  void initState() {
    super.initState();
    widget.auth.addListener(authChanged);
  }

  bool returning = false;
  void authChanged() {
    if (!mounted || returning) return;
    if (widget.auth.userId != null) {
      returning = true;
      Navigator.of(context).pop();
    } else {
      setState(() {});
    }
  }

  @override
  void dispose() {
    widget.auth.removeListener(authChanged);
    email.dispose();
    password.dispose();
    super.dispose();
  }

  Future<void> submit() async {
    if (busy || !widget.auth.configured || !form.currentState!.validate()) {
      return;
    }
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() {
      busy = true;
      message = null;
      confirmation = false;
      browserOpened = false;
    });
    try {
      if (registering) {
        final needsConfirmation = await widget.auth.signUp(
          email.text.trim(),
          password.text,
        );
        if (mounted && needsConfirmation) {
          setState(() {
            confirmation = true;
            registering = false;
            password.clear();
          });
        }
      } else {
        await widget.auth.signIn(email.text.trim(), password.text);
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          message = failureMessage(error, registering ? 'signup' : 'signin');
        });
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final enabled = widget.auth.configured && !busy;
    final errorText = switch (message) {
      'signup' => l.authSignupError,
      'social' => l.authSocialError,
      'credentials' => l.authCredentialsError,
      'unconfirmed' => l.authConfirmEmail,
      'rateLimit' => l.authRateLimitError,
      'network' => l.authNetworkError,
      'configuration' => l.authInvalidConfiguration,
      _ => l.authError,
    };
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          key: const ValueKey('auth-cancel'),
          tooltip: l.cancel,
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.close),
        ),
        title: Text(l.signIn),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: ListView(
              shrinkWrap: true,
              padding: const EdgeInsets.all(24),
              children: [
                Text(
                  'Steady',
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                const SizedBox(height: 12),
                Text(l.authIntro),
                const SizedBox(height: 24),
                DropdownButtonFormField<String>(
                  key: ValueKey(
                    'auth-language-${selectedLocale?.languageCode ?? 'system'}',
                  ),
                  initialValue: selectedLocale?.languageCode ?? 'system',
                  isExpanded: true,
                  decoration: InputDecoration(labelText: l.language),
                  items: [
                    DropdownMenuItem(
                      value: 'system',
                      child: Text(l.systemLanguage),
                    ),
                    const DropdownMenuItem(
                      value: 'vi',
                      child: Text('Tiếng Việt'),
                    ),
                    const DropdownMenuItem(value: 'en', child: Text('English')),
                  ],
                  onChanged: (v) {
                    if (v != null) {
                      final value = v == 'system' ? null : Locale(v);
                      setState(() => selectedLocale = value);
                      widget.onLanguageChanged(value);
                    }
                  },
                ),
                const SizedBox(height: 24),
                if (!widget.auth.configured) ...[
                  const Icon(Icons.settings_outlined, size: 44),
                  const SizedBox(height: 16),
                  Text(
                    widget.auth.initializationFailed
                        ? l.authInitializationError
                        : l.authConfiguration,
                    key: const ValueKey('auth-unconfigured'),
                  ),
                  const SizedBox(height: 24),
                ],
                OutlinedButton.icon(
                  key: const ValueKey('auth-google'),
                  onPressed:
                      enabled &&
                          widget.auth.socialProviders.contains(
                            SocialAuthProvider.google,
                          )
                      ? () => signInWithProvider(SocialAuthProvider.google)
                      : null,
                  icon: const Icon(Icons.account_circle_outlined),
                  label: Text(l.continueWithGoogle),
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  key: const ValueKey('auth-facebook'),
                  onPressed:
                      enabled &&
                          widget.auth.socialProviders.contains(
                            SocialAuthProvider.facebook,
                          )
                      ? () => signInWithProvider(SocialAuthProvider.facebook)
                      : null,
                  icon: const Icon(Icons.facebook),
                  label: Text(l.continueWithFacebook),
                ),
                if (widget.auth.configured &&
                    widget.auth.socialProviders.length < 2) ...[
                  const SizedBox(height: 8),
                  Text(l.authProvidersUnavailable),
                ],
                if (browserOpened) ...[
                  const SizedBox(height: 12),
                  Text(
                    l.authBrowserOpened,
                    key: const ValueKey('auth-browser'),
                  ),
                ],
                if (widget.auth.connectionError) ...[
                  const SizedBox(height: 12),
                  Text(l.authNetworkError),
                ],
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Expanded(child: Divider()),
                    Flexible(
                      flex: 3,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(l.authOrEmail, textAlign: TextAlign.center),
                      ),
                    ),
                    const Expanded(child: Divider()),
                  ],
                ),
                const SizedBox(height: 16),
                Form(
                  key: form,
                  child: AutofillGroup(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          registering ? l.signUp : l.signIn,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          key: const ValueKey('auth-email'),
                          controller: email,
                          enabled: enabled,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          autofillHints: const [AutofillHints.email],
                          decoration: InputDecoration(
                            labelText: l.email,
                            errorMaxLines: 3,
                          ),
                          validator: (v) =>
                              RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$')
                                  .hasMatch((v ?? '').trim())
                              ? null
                              : l.emailError,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          key: const ValueKey('auth-password'),
                          controller: password,
                          enabled: enabled,
                          obscureText: obscure,
                          autofillHints: [
                            registering
                                ? AutofillHints.newPassword
                                : AutofillHints.password,
                          ],
                          onFieldSubmitted: (_) => submit(),
                          decoration: InputDecoration(
                            labelText: l.password,
                            errorMaxLines: 3,
                            suffixIcon: IconButton(
                              tooltip: l.password,
                              onPressed: enabled
                                  ? () => setState(() => obscure = !obscure)
                                  : null,
                              icon: Icon(
                                obscure
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                              ),
                            ),
                          ),
                          validator: (v) =>
                              (v ?? '').isEmpty ||
                                  (registering && v!.length < 8)
                              ? l.passwordError
                              : null,
                        ),
                        const SizedBox(height: 16),
                        if (confirmation)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Text(l.authConfirmEmail),
                          ),
                        if (message != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Text(
                              errorText,
                              key: const ValueKey('auth-error'),
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.error,
                              ),
                            ),
                          ),
                        FilledButton(
                          key: const ValueKey('auth-submit'),
                          onPressed: enabled ? submit : null,
                          child: busy
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(registering ? l.signUp : l.signIn),
                        ),
                        TextButton(
                          onPressed: !enabled
                              ? null
                              : () {
                                  setState(() {
                                    registering = !registering;
                                    message = null;
                                    confirmation = false;
                                    browserOpened = false;
                                  });
                                },
                          child: Text(
                            registering ? l.alreadyHaveAccount : l.needAccount,
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
    );
  }
}
