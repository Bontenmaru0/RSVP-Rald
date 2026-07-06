import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/errors/app_exceptions.dart';
import '../data/rsvp_supabase_bootstrap.dart';

enum _AdminAuthMode { login, register }

Future<void> showAdminAccessModal(BuildContext context) {
  return showGeneralDialog(
    context: context,
    barrierDismissible: false,
    barrierLabel: 'Admin Access',
    barrierColor: Colors.black.withValues(alpha: 0.34),
    transitionDuration: const Duration(milliseconds: 320),
    pageBuilder: (dialogContext, animation, secondaryAnimation) {
      return AdminAccessModal(hostContext: context);
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
      );
      return FadeTransition(
        opacity: curved,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.985, end: 1.0).animate(curved),
          child: child,
        ),
      );
    },
  );
}

class AdminAccessModal extends StatefulWidget {
  const AdminAccessModal({super.key, required this.hostContext});

  final BuildContext hostContext;

  @override
  State<AdminAccessModal> createState() => _AdminAccessModalState();
}

class _AdminAccessModalState extends State<AdminAccessModal> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  _AdminAuthMode _mode = _AdminAuthMode.login;
  bool _isSubmitting = false;
  bool _isSuccess = false;
  String? _errorMessage;
  String _successMessage = '';

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String? _validateEmail(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return 'Please enter the admin email.';
    }
    final emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailPattern.hasMatch(trimmed)) {
      return 'Please enter a valid email address.';
    }
    return null;
  }

  String? _validatePassword(String value) {
    if (value.isEmpty) {
      return 'Please enter the password.';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters.';
    }
    return null;
  }

  String? _validateConfirmPassword(String value) {
    if (_mode != _AdminAuthMode.register) {
      return null;
    }
    if (value.isEmpty) {
      return 'Please confirm the password.';
    }
    if (value != _passwordController.text) {
      return 'Passwords do not match.';
    }
    return null;
  }

  String _mapAuthError(AuthException error) {
    final message = error.message.toLowerCase();

    if (message.contains('rate limit') ||
        message.contains('too many requests') ||
        message.contains('429')) {
      return 'Too many attempts. Please wait a moment and try again.';
    }

    if (message.contains('email not confirmed') ||
        message.contains('not confirmed')) {
      return 'Please confirm your email before signing in.';
    }

    if (message.contains('invalid login credentials') ||
        message.contains('invalid credentials')) {
      return 'The email or password is incorrect.';
    }

    if (message.contains('user not found')) {
      return 'No account was found for that email address.';
    }

    if (message.contains('already registered') ||
        message.contains('already exists')) {
      return 'That email is already registered. Please sign in instead.';
    }

    if (message.contains('password should be at least') ||
        message.contains('weak password')) {
      return 'Password must be at least 6 characters.';
    }

    return error.message;
  }

  Future<void> _submit() async {
    final emailError = _validateEmail(_emailController.text);
    final passwordError = _validatePassword(_passwordController.text);
    final confirmError = _validateConfirmPassword(_confirmPasswordController.text);

    if (emailError != null || passwordError != null || confirmError != null) {
      setState(() {
        _errorMessage = emailError ?? passwordError ?? confirmError;
      });
      return;
    }

    setState(() {
      _errorMessage = null;
      _isSubmitting = true;
    });

    try {
      await RsvpSupabaseBootstrap.ensureInitialized();
      final auth = Supabase.instance.client.auth;

      if (_mode == _AdminAuthMode.login) {
        await auth.signInWithPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
        if (!mounted) {
          return;
        }
        setState(() {
          _isSuccess = true;
          _successMessage = 'Admin access granted. Welcome back.';
        });
      } else {
        final response = await auth.signUp(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
        if (!mounted) {
          return;
        }

        final needsEmailConfirmation = response.session == null;
        setState(() {
          _isSuccess = true;
          _successMessage = needsEmailConfirmation
              ? 'Your admin account has been created. Please check your email to confirm it, then log in.'
              : 'Your admin account has been created and you are now signed in.';
        });
      }
    } on AuthException catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _errorMessage = _mapAuthError(error);
      });
    } on AppException catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _errorMessage = error.message;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _errorMessage = 'We could not complete the admin sign-in right now.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  InputDecoration _fieldDecoration(String hintText) {
    final colorScheme = Theme.of(context).colorScheme;
    return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(
        color: colorScheme.onSurface.withValues(alpha: 0.46),
      ),
      filled: true,
      fillColor: colorScheme.surface.withValues(alpha: 0.30),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 16,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(
          color: colorScheme.primary.withValues(alpha: 0.14),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(
          color: colorScheme.primary,
          width: 1.4,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(
          color: colorScheme.error,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(
          color: colorScheme.error,
          width: 1.4,
        ),
      ),
    );
  }

  Widget _buildModeToggle() {
    final colorScheme = Theme.of(context).colorScheme;
    final isLogin = _mode == _AdminAuthMode.login;
    return Row(
      children: [
        Expanded(
          child: FilledButton.tonal(
            onPressed: isLogin
                ? null
                : () {
                    setState(() {
                      _mode = _AdminAuthMode.login;
                      _errorMessage = null;
                    });
                  },
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              foregroundColor: colorScheme.onSurface,
            ),
            child: const Text('Sign in'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: FilledButton.tonal(
            onPressed: isLogin
                ? () {
                    setState(() {
                      _mode = _AdminAuthMode.register;
                      _errorMessage = null;
                    });
                  }
                : null,
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              foregroundColor: colorScheme.onSurface,
            ),
            child: const Text('Sign up'),
          ),
        ),
      ],
    );
  }

  Widget _buildSuccessView() {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface.withValues(alpha: 0.28),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colorScheme.primary.withValues(alpha: 0.16),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.verified_rounded,
                color: colorScheme.primary,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Access Granted',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _successMessage,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.82),
                ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isRegister = _mode == _AdminAuthMode.register;

    return Material(
      color: Colors.transparent,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                child: Container(
                  decoration: BoxDecoration(
                    color: colorScheme.surface.withValues(alpha: 0.96),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(
                      color: colorScheme.primary.withValues(alpha: 0.18),
                      width: 1.1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.24),
                        blurRadius: 24,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Admin Access',
                                    style: theme.textTheme.headlineSmall?.copyWith(
                                      color: colorScheme.onSurface,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Use your admin email and password to continue.',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: colorScheme.onSurface.withValues(alpha: 0.78),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Tooltip(
                              message: 'Close',
                              child: Material(
                                color: colorScheme.surface.withValues(alpha: 0.48),
                                shape: const CircleBorder(),
                                child: InkWell(
                                  customBorder: const CircleBorder(),
                                  onTap: () => Navigator.of(context).pop(),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8),
                                    child: Icon(
                                      Icons.close_rounded,
                                      color: colorScheme.onSurface,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        _buildModeToggle(),
                        const SizedBox(height: 16),
                        if (_isSuccess) ...[
                          _buildSuccessView(),
                          const SizedBox(height: 16),
                          FilledButton(
                            onPressed: () => Navigator.of(context).pop(),
                            style: FilledButton.styleFrom(
                              backgroundColor: colorScheme.primary,
                              foregroundColor: colorScheme.onPrimary,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 16,
                              ),
                              textStyle: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            child: const Text('OK'),
                          ),
                        ] else ...[
                          TextField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            style: TextStyle(color: colorScheme.onSurface),
                            decoration: _fieldDecoration('Admin email'),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _passwordController,
                            obscureText: true,
                            obscuringCharacter: '\u2022',
                            textInputAction: isRegister
                                ? TextInputAction.next
                                : TextInputAction.done,
                            style: TextStyle(color: colorScheme.onSurface),
                            decoration: _fieldDecoration('Password'),
                          ),
                          if (isRegister) ...[
                            const SizedBox(height: 12),
                            TextField(
                              controller: _confirmPasswordController,
                              obscureText: true,
                              obscuringCharacter: '\u2022',
                              textInputAction: TextInputAction.done,
                              style: TextStyle(color: colorScheme.onSurface),
                              decoration: _fieldDecoration('Confirm password'),
                            ),
                          ],
                          if (_errorMessage != null) ...[
                            const SizedBox(height: 8),
                            Text(
                              _errorMessage!,
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: colorScheme.error,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                          const SizedBox(height: 14),
                          FilledButton(
                            onPressed: _isSubmitting ? null : _submit,
                            style: FilledButton.styleFrom(
                              backgroundColor: colorScheme.primary,
                              foregroundColor: colorScheme.onPrimary,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 16,
                              ),
                              textStyle: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            child: Text(
                              _isSubmitting
                                  ? 'Please wait...'
                                  : (isRegister ? 'Create Admin' : 'Log In'),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
