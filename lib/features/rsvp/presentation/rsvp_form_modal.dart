import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/errors/app_exceptions.dart';
import '../data/rsvp_repository_factory.dart';
import '../domain/entities/rsvp_submission.dart';

Future<void> showRsvpFormModal(BuildContext context) {
  return showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'RSVP Response',
    barrierColor: Colors.black.withValues(alpha: 0.34),
    transitionDuration: const Duration(milliseconds: 320),
    pageBuilder: (dialogContext, animation, secondaryAnimation) {
      return const RsvpFormModal();
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
      );
      final slide = Tween<Offset>(
        begin: const Offset(0.18, 0),
        end: Offset.zero,
      ).animate(curved);
      return FadeTransition(
        opacity: curved,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.985, end: 1.0).animate(curved),
          child: SlideTransition(
            position: slide,
            child: child,
          ),
        ),
      );
    },
  );
}

class RsvpFormModal extends StatefulWidget {
  const RsvpFormModal({super.key});

  @override
  State<RsvpFormModal> createState() => _RsvpFormModalState();
}

class _RsvpFormModalState extends State<RsvpFormModal> {
  final _passcodeController = TextEditingController();
  final _confirmPasscodeController = TextEditingController();
  final _nameController = TextEditingController();

  String? _passcodeError;
  String? _confirmPasscodeError;
  String? _nameError;
  int _guestCount = 5;
  bool _showPasscode = false;
  bool _showConfirmPasscode = false;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _passcodeController.dispose();
    _confirmPasscodeController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  String? _validatePasscode(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return 'Please enter the passcode.';
    }
    if (trimmed.length > 6) {
      return 'Passcode must be 6 characters or fewer.';
    }
    return null;
  }

  String? _validateConfirmPasscode(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return 'Please confirm the passcode.';
    }
    if (trimmed.length > 6) {
      return 'Passcode must be 6 characters or fewer.';
    }
    if (trimmed != _passcodeController.text.trim()) {
      return 'Passcodes do not match.';
    }
    return null;
  }

  String? _validateName(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return 'Please enter your name.';
    }
    if (trimmed.length > 50) {
      return 'Name must be 50 characters or fewer.';
    }
    return null;
  }

  int _textLength(String value) => value.length;

  void _syncErrors() {
    setState(() {
      _passcodeError = _validatePasscode(_passcodeController.text);
      _confirmPasscodeError = _validateConfirmPasscode(
        _confirmPasscodeController.text,
      );
      _nameError = _validateName(_nameController.text);
    });
  }

  void _clearPasscodeErrorIfValid(String value) {
    if (_passcodeError != null && _validatePasscode(value) == null) {
      setState(() => _passcodeError = null);
    }
    if (_confirmPasscodeError != null &&
        _validateConfirmPasscode(_confirmPasscodeController.text) == null) {
      setState(() => _confirmPasscodeError = null);
    }
  }

  void _clearConfirmErrorIfValid(String value) {
    if (_confirmPasscodeError != null && _validateConfirmPasscode(value) == null) {
      setState(() => _confirmPasscodeError = null);
    }
  }

  void _clearNameErrorIfValid(String value) {
    if (_nameError != null && _validateName(value) == null) {
      setState(() => _nameError = null);
    }
  }

  Future<void> _submit() async {
    if (_isSubmitting) {
      return;
    }

    _syncErrors();
    if (_passcodeError != null ||
        _confirmPasscodeError != null ||
        _nameError != null) {
      return;
    }

    final value = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        final theme = Theme.of(dialogContext);
        final colorScheme = theme.colorScheme;
        return AlertDialog(
          backgroundColor: Colors.black.withValues(alpha: 0.96),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: BorderSide(
              color: colorScheme.primary.withValues(alpha: 0.28),
            ),
          ),
          title: Text(
            'Will you be attending our wedding?',
            style: theme.textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          content: Text(
            'Please choose Yes or No to confirm your attendance.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.82),
            ),
          ),
          actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          actions: [
            OutlinedButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: BorderSide(
                  color: Colors.white.withValues(alpha: 0.16),
                ),
              ),
              child: const Text('No'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );

    if (value == null || !mounted) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final repository = createRsvpRepository();
    final submission = RsvpSubmission(
      passcode: _passcodeController.text.trim(),
      fullName: _nameController.text.trim(),
      guestCount: _guestCount,
      isAttending: value,
    );

    try {
      await repository.submitResponse(submission);
    } on AppException catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.message),
        ),
      );
      return;
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'We could not save your RSVP right now. Please try again.',
          ),
        ),
      );
      return;
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          value
              ? 'Thanks! We marked you as attending.'
              : 'Thanks! We marked you as not attending.',
        ),
      ),
    );
  }

  InputDecoration _fieldDecoration(String hintText, {Widget? suffixIcon}) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(
        color: Colors.white.withValues(alpha: 0.46),
      ),
      filled: true,
      fillColor: Colors.black.withValues(alpha: 0.22),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 16,
      ),
      suffixIcon: suffixIcon,
      suffixIconColor: Colors.white70,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(
          color: Colors.white.withValues(alpha: 0.12),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(
          color: Theme.of(context).colorScheme.primary,
          width: 1.4,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(
          color: Theme.of(context).colorScheme.error,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(
          color: Theme.of(context).colorScheme.error,
          width: 1.4,
        ),
      ),
    );
  }

  Widget _buildFieldHeader({
    required String label,
    required String? errorText,
    required String counterText,
    bool isRequired = true,
  }) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isRequired ? '$label *' : label,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (errorText != null) ...[
                const SizedBox(height: 2),
                Text(
                  errorText,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          ),
        ),
        Text(
          counterText,
          style: theme.textTheme.labelMedium?.copyWith(
            color: Colors.white.withValues(alpha: 0.70),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildFieldCard({
    required String label,
    required String? errorText,
    required String counterText,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldHeader(
          label: label,
          errorText: errorText,
          counterText: counterText,
        ),
        const SizedBox(height: 10),
        child,
      ],
    );
  }

  Widget _buildGuestStepper(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    void changeGuests(int delta) {
      setState(() {
        _guestCount = (_guestCount + delta).clamp(1, 100);
      });
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.12),
        ),
      ),
      child: Row(
        children: [
          _GuestStepperButton(
            icon: Icons.remove_rounded,
            onPressed: _guestCount > 1 ? () => changeGuests(-1) : null,
            colorScheme: colorScheme,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$_guestCount guest${_guestCount == 1 ? '' : 's'}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Tap + to add more guests',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.72),
                      ),
                ),
              ],
            ),
          ),
          _GuestStepperButton(
            icon: Icons.add_rounded,
            onPressed: _guestCount < 100 ? () => changeGuests(1) : null,
            colorScheme: colorScheme,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final mediaSize = MediaQuery.sizeOf(context);
    final isCompact = mediaSize.height < 740 || mediaSize.width < 390;

    return Material(
      color: Colors.transparent,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'lib/assets/wedding-imgs/default-app-bg.png',
            fit: BoxFit.cover,
            filterQuality: FilterQuality.low,
          ),
          ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
            child: Image.asset(
              'lib/assets/wedding-imgs/default-app-bg.png',
              fit: BoxFit.cover,
              filterQuality: FilterQuality.low,
            ),
          ),
          Container(
            color: Colors.black.withValues(alpha: 0.54),
          ),
          SafeArea(
            child: Padding(
              padding: EdgeInsets.all(isCompact ? 16 : 20),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Invitation Response',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: textTheme.headlineSmall?.copyWith(
                                color: colorScheme.primary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Please complete the form below.',
                              style: textTheme.bodyMedium?.copyWith(
                                color: Colors.white.withValues(alpha: 0.82),
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close),
                        color: Colors.white,
                      ),
                    ],
                  ),
                  SizedBox(height: isCompact ? 12 : 16),
                  Expanded(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 860),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(28),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.18),
                              borderRadius: BorderRadius.circular(28),
                              border: Border.all(
                                color: colorScheme.primary.withValues(alpha: 0.36),
                                width: 1.2,
                              ),
                            ),
                            child: SingleChildScrollView(
                              padding: EdgeInsets.all(isCompact ? 16 : 20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  _buildFieldCard(
                                    label: 'Passcode',
                                    errorText: _passcodeError,
                                    counterText:
                                        '${_textLength(_passcodeController.text)}/6',
                                    child: TextField(
                                      controller: _passcodeController,
                                      obscureText: !_showPasscode,
                                      obscuringCharacter: '\u2022',
                                      maxLength: 6,
                                      maxLengthEnforcement:
                                          MaxLengthEnforcement.enforced,
                                      inputFormatters: [
                                        LengthLimitingTextInputFormatter(6),
                                      ],
                                      style: const TextStyle(color: Colors.white),
                                      decoration: _fieldDecoration(
                                        'Passcode',
                                        suffixIcon: IconButton(
                                          onPressed: () {
                                            setState(() {
                                              _showPasscode = !_showPasscode;
                                            });
                                          },
                                          icon: Icon(
                                            _showPasscode
                                                ? Icons.visibility_off_outlined
                                                : Icons.visibility_outlined,
                                          ),
                                        ),
                                      ).copyWith(counterText: ''),
                                      onChanged: (value) {
                                        setState(() {
                                          if (_passcodeError != null &&
                                              _validatePasscode(value) == null) {
                                            _passcodeError = null;
                                          }
                                          if (_confirmPasscodeError != null &&
                                              _validateConfirmPasscode(
                                                    _confirmPasscodeController.text,
                                                  ) ==
                                                  null) {
                                            _confirmPasscodeError = null;
                                          }
                                        });
                                      },
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  _buildFieldCard(
                                    label: 'Confirm Passcode',
                                    errorText: _confirmPasscodeError,
                                    counterText:
                                        '${_textLength(_confirmPasscodeController.text)}/6',
                                    child: TextField(
                                      controller: _confirmPasscodeController,
                                      obscureText: !_showConfirmPasscode,
                                      obscuringCharacter: '\u2022',
                                      maxLength: 6,
                                      maxLengthEnforcement:
                                          MaxLengthEnforcement.enforced,
                                      inputFormatters: [
                                        LengthLimitingTextInputFormatter(6),
                                      ],
                                      style: const TextStyle(color: Colors.white),
                                      decoration: _fieldDecoration(
                                        'Confirm passcode',
                                        suffixIcon: IconButton(
                                          onPressed: () {
                                            setState(() {
                                              _showConfirmPasscode =
                                                  !_showConfirmPasscode;
                                            });
                                          },
                                          icon: Icon(
                                            _showConfirmPasscode
                                                ? Icons.visibility_off_outlined
                                                : Icons.visibility_outlined,
                                          ),
                                        ),
                                      ).copyWith(counterText: ''),
                                      onChanged: (value) {
                                        setState(() {
                                          if (_confirmPasscodeError != null &&
                                              _validateConfirmPasscode(value) ==
                                                  null) {
                                            _confirmPasscodeError = null;
                                          }
                                        });
                                      },
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  _buildFieldCard(
                                    label: 'Name',
                                    errorText: _nameError,
                                    counterText:
                                        '${_textLength(_nameController.text)}/50',
                                    child: TextField(
                                      controller: _nameController,
                                      maxLength: 50,
                                      maxLengthEnforcement:
                                          MaxLengthEnforcement.enforced,
                                      style: const TextStyle(color: Colors.white),
                                      decoration: _fieldDecoration('Full name')
                                          .copyWith(counterText: ''),
                                      onChanged: (value) {
                                        setState(() {
                                          if (_nameError != null &&
                                              _validateName(value) == null) {
                                            _nameError = null;
                                          }
                                        });
                                      },
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  _buildFieldCard(
                                    label: 'Number of Guests',
                                    errorText: null,
                                    counterText: '$_guestCount / 100',
                                    child: _buildGuestStepper(context),
                                  ),
                                  const SizedBox(height: 18),
                                  FilledButton(
                                    onPressed: _isSubmitting ? null : () => _submit(),
                                    style: FilledButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 20,
                                        vertical: 16,
                                      ),
                                      textStyle: textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    child: Text(
                                      _isSubmitting
                                          ? 'Sending...'
                                          : 'Send Your Invitation Response',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'We will connect this to Supabase next.',
                    textAlign: TextAlign.center,
                    style: textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.82),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GuestStepperButton extends StatelessWidget {
  const _GuestStepperButton({
    required this.icon,
    required this.onPressed,
    required this.colorScheme,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    final isEnabled = onPressed != null;

    return Material(
      color: Colors.transparent,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        child: Ink(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isEnabled
                ? colorScheme.primary.withValues(alpha: 0.20)
                : Colors.white.withValues(alpha: 0.06),
            border: Border.all(
              color: isEnabled
                  ? colorScheme.primary.withValues(alpha: 0.60)
                  : Colors.white.withValues(alpha: 0.10),
              width: 1.1,
            ),
          ),
          child: Icon(
            icon,
            color: isEnabled
                ? colorScheme.primary
                : Colors.white.withValues(alpha: 0.30),
            size: 24,
          ),
        ),
      ),
    );
  }
}
