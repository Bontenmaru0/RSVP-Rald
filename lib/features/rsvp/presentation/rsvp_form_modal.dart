import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/errors/app_exceptions.dart';
import '../../../core/utils/app_snackbar.dart';
import '../data/rsvp_repository_factory.dart';
import '../domain/entities/rsvp_submission.dart';
import 'rsvp_status_modal.dart';
import 'widgets/guest_count_picker.dart';

Future<void> showRsvpFormModal(BuildContext context) {
  return showGeneralDialog(
    context: context,
    barrierDismissible: false,
    barrierLabel: 'RSVP Response',
    barrierColor: Colors.black.withValues(alpha: 0.34),
    transitionDuration: const Duration(milliseconds: 320),
    pageBuilder: (dialogContext, animation, secondaryAnimation) {
      return RsvpFormModal(hostContext: context);
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
  const RsvpFormModal({super.key, required this.hostContext});

  final BuildContext hostContext;

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
  int _guestCount = 1;
  bool _showPasscode = false;
  bool _showConfirmPasscode = false;
  bool _isSubmitting = false;
  final GlobalKey _guestCountTriggerKey = GlobalKey();

  @override
  void dispose() {
    _passcodeController.dispose();
    _confirmPasscodeController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _resetForm() {
    setState(() {
      _passcodeController.clear();
      _confirmPasscodeController.clear();
      _nameController.clear();
      _passcodeError = null;
      _confirmPasscodeError = null;
      _nameError = null;
      _guestCount = 1;
      _showPasscode = false;
      _showConfirmPasscode = false;
    });
  }

  Future<void> _showNoticeDialog(BuildContext dialogContext, String message) {
    return showDialog<void>(
      context: dialogContext,
      barrierDismissible: false,
      builder: (dialogContext) {
        final theme = Theme.of(dialogContext);
        final colorScheme = theme.colorScheme;
        return AlertDialog(
          backgroundColor: colorScheme.surface.withValues(alpha: 0.96),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: BorderSide(
              color: colorScheme.primary.withValues(alpha: 0.30),
            ),
          ),
          title: Text(
            'Invitation Response',
            style: theme.textTheme.titleLarge?.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
          content: Text(
            message,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.84),
            ),
          ),
          actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          actions: [
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              style: FilledButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
              ),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  String _buildSuccessMessage(String respondentName) {
    final displayName = respondentName.isEmpty ? 'there' : respondentName;
    return 'Hi, $displayName!\n\n'
        'We received your response and will review it as we prepare the guest list for Gerald and Mervielynn\'s wedding.\n\n'
        'You can check the church and reception locations using the location buttons, and return to the message icon anytime to review your invitation status with your passcode.\n\n'
        'Thank you for your patience and understanding.';
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

  // void _clearPasscodeErrorIfValid(String value) {
  //   if (_passcodeError != null && _validatePasscode(value) == null) {
  //     setState(() => _passcodeError = null);
  //   }
  //   if (_confirmPasscodeError != null &&
  //       _validateConfirmPasscode(_confirmPasscodeController.text) == null) {
  //     setState(() => _confirmPasscodeError = null);
  //   }
  // }

  // void _clearConfirmErrorIfValid(String value) {
  //   if (_confirmPasscodeError != null && _validateConfirmPasscode(value) == null) {
  //     setState(() => _confirmPasscodeError = null);
  //   }
  // }

  // void _clearNameErrorIfValid(String value) {
  //   if (_nameError != null && _validateName(value) == null) {
  //     setState(() => _nameError = null);
  //   }
  // }

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
          backgroundColor: colorScheme.surface.withValues(alpha: 0.96),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: BorderSide(
              color: colorScheme.primary.withValues(alpha: 0.30),
            ),
          ),
          title: Text(
            'Will you be attending our wedding?',
            style: theme.textTheme.titleLarge?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),
          content: Text(
            'Please choose Yes or No to confirm your attendance.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.84),
            ),
          ),
          actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          actions: [
            OutlinedButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              style: OutlinedButton.styleFrom(
                foregroundColor: colorScheme.onSurface,
                side: BorderSide(
                  color: colorScheme.primary.withValues(alpha: 0.22),
                ),
              ),
              child: const Text('No'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: FilledButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
              ),
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );

    if (value == null || !mounted) {
      return;
    }

    if (value == false) {
      Navigator.of(context, rootNavigator: true).pop();
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final navigator = Navigator.of(context, rootNavigator: true);
    final repository = createRsvpRepository();
    final submission = RsvpSubmission(
      passcode: _passcodeController.text.trim(),
      fullName: _nameController.text.trim(),
      guestCount: _guestCount,
      isAttending: value,
    );

    try {
      await repository.submitResponse(submission);
      if (!mounted) {
        return;
      }
      final respondentName = _nameController.text.trim();
      _resetForm();
      navigator.pop();
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!widget.hostContext.mounted) {
          return;
        }
        await _showNoticeDialog(
          widget.hostContext,
          _buildSuccessMessage(respondentName),
        );
        if (!widget.hostContext.mounted) {
          return;
        }
        AppSnackBar.show(
          widget.hostContext,
          'Thank you for sending your response',
        );
      });
    } on AppException catch (error) {
      if (!mounted) {
        return;
      }
      await _showNoticeDialog(context, error.message);
      return;
    } catch (_) {
      if (!mounted) {
        return;
      }
      await _showNoticeDialog(
        context,
        'We could not save your RSVP right now. Please try again.',
      );
      return;
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  InputDecoration _fieldDecoration(String hintText, {Widget? suffixIcon}) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.46),
      ),
      filled: true,
      fillColor: Theme.of(context).colorScheme.surface.withValues(alpha: 0.30),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 16,
      ),
      suffixIcon: suffixIcon,
      suffixIconColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.70),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.14),
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
                  color: theme.colorScheme.onSurface,
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
            color: theme.colorScheme.onSurface.withValues(alpha: 0.70),
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
        _guestCount = (_guestCount + delta).clamp(1, kGuestCountMax);
      });
    }

    Future<void> openMenu() async {
      final selected = await showGuestCountMenu(
        context: context,
        anchorKey: _guestCountTriggerKey,
        initialValue: _guestCount,
      );
      if (!mounted || selected == null) {
        return;
      }
      setState(() {
        _guestCount = selected;
      });
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.30),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.14),
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
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                key: _guestCountTriggerKey,
                borderRadius: BorderRadius.circular(14),
                onTap: openMenu,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '$_guestCount guest${_guestCount == 1 ? '' : 's'}',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Tap number to choose from 1 to $kGuestCountMax',
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withValues(alpha: 0.70),
                            ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          _GuestStepperButton(
            icon: Icons.add_rounded,
            onPressed: _guestCount < kGuestCountMax ? () => changeGuests(1) : null,
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
            color: Colors.black.withValues(alpha: 0.62),
          ),
          SafeArea(
            child: Padding(
              padding: EdgeInsets.all(isCompact ? 16 : 20),
              child: Column(
                children: [
                  Row(
                    children: [
                      DecoratedBox(
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                            color: colorScheme.primary.withValues(alpha: 0.22),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Invitation Response',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: textTheme.headlineSmall?.copyWith(
                                color: colorScheme.onSurface,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Please complete the form below.',
                              style: textTheme.bodyMedium?.copyWith(
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
                  SizedBox(height: isCompact ? 12 : 16),
                  Expanded(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 860),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(28),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                            child: Container(
                              decoration: BoxDecoration(
                                color: colorScheme.surface.withValues(alpha: 0.26),
                                borderRadius: BorderRadius.circular(28),
                                border: Border.all(
                                  color: colorScheme.primary.withValues(alpha: 0.18),
                                  width: 1.1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.22),
                                    blurRadius: 24,
                                    offset: const Offset(0, 12),
                                  ),
                                ],
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
                                      style: TextStyle(
                                        color: colorScheme.onSurface,
                                      ),
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
                                      style: TextStyle(
                                        color: colorScheme.onSurface,
                                      ),
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
                                      style: TextStyle(
                                        color: colorScheme.onSurface,
                                      ),
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
                                    counterText: '$_guestCount / $kGuestCountMax',
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
                                        backgroundColor: colorScheme.primary,
                                        foregroundColor: colorScheme.onPrimary,
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
                                  const SizedBox(height: 12),
                                  SizedBox(
                                    width: double.infinity,
                                    child: OutlinedButton.icon(
                                      onPressed: _isSubmitting
                                          ? null
                                          : () => showInvitationStatusModal(
                                                widget.hostContext,
                                              ),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: colorScheme.onSurface,
                                        side: BorderSide(
                                          color: colorScheme.primary.withValues(alpha: 0.28),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 20,
                                          vertical: 16,
                                        ),
                                        textStyle: textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      icon: Icon(
                                        Icons.search_rounded,
                                        color: colorScheme.primary,
                                      ),
                                      label: const Text('Check Invitation Status'),
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
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Saved securely through the RSVP service.',
                    textAlign: TextAlign.center,
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.76),
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
                : colorScheme.surface.withValues(alpha: 0.50),
            border: Border.all(
              color: isEnabled
                  ? colorScheme.primary.withValues(alpha: 0.60)
                  : colorScheme.primary.withValues(alpha: 0.12),
              width: 1.1,
            ),
          ),
          child: Icon(
            icon,
            color: isEnabled
                ? colorScheme.primary
                : colorScheme.onSurface.withValues(alpha: 0.34),
            size: 24,
          ),
        ),
      ),
    );
  }
}
