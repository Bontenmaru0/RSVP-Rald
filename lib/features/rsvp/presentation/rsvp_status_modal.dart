import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/errors/app_exceptions.dart';
import '../data/rsvp_repository_factory.dart';
import '../domain/entities/rsvp_submission.dart';

Future<void> showInvitationStatusModal(BuildContext context) {
  return showGeneralDialog(
    context: context,
    barrierDismissible: false,
    barrierLabel: 'Invitation Status',
    barrierColor: Colors.black.withValues(alpha: 0.34),
    transitionDuration: const Duration(milliseconds: 320),
    pageBuilder: (dialogContext, animation, secondaryAnimation) {
      return InvitationStatusModal(hostContext: context);
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

class InvitationStatusModal extends StatefulWidget {
  const InvitationStatusModal({super.key, required this.hostContext});

  final BuildContext hostContext;

  @override
  State<InvitationStatusModal> createState() => _InvitationStatusModalState();
}

class _InvitationStatusModalState extends State<InvitationStatusModal> {
  final _passcodeController = TextEditingController();

  RsvpSubmission? _submission;
  String? _errorMessage;
  bool _isLoading = false;

  @override
  void dispose() {
    _passcodeController.dispose();
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

  String _normalizeStatus(String value) {
    return value.trim().toLowerCase();
  }

  String _buildPendingMessage(String name) {
    final displayName = name.isEmpty ? 'there' : name;
    return 'Hi, $displayName!\n\n'
        'Thank you for checking your invitation status.\n\n'
        'Your response is still awaiting confirmation. We will review it and update your status as soon as possible.\n\n'
        'Please check again later using your passcode.';
  }

  String _buildConfirmedMessage(String name) {
    final displayName = name.isEmpty ? 'there' : name;
    return 'Hi, $displayName!\n\n'
        'Thank you for waiting. Your response has been confirmed.\n\n'
        'Kindly wear formal or semi-formal attire in Emerald Green and the soft wedding palette shown below.\n\n'
        'We are excited to celebrate our wedding with you. See you there!';
  }

  String _buildDeclinedMessage(String name) {
    final displayName = name.isEmpty ? 'there' : name;
    return 'Hi, $displayName!\n\n'
        'Thank you for letting us know. Your response has been marked as declined.\n\n'
        'We understand and appreciate your reply. We will miss celebrating with you on the day, but we are grateful for your time and support.\n\n'
        'Thank you again, and we wish you all the best.';
  }

  Future<void> _checkStatus() async {
    final passcodeError = _validatePasscode(_passcodeController.text);
    if (passcodeError != null) {
      setState(() {
        _errorMessage = passcodeError;
      });
      return;
    }

    setState(() {
      _errorMessage = null;
      _isLoading = true;
      _submission = null;
    });

    try {
      final repository = createRsvpRepository();
      final submission = await repository.fetchResponseByPasscode(
        _passcodeController.text.trim(),
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _submission = submission;
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
        _errorMessage = 'We could not check the invitation status right now.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
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

  Widget _buildPaletteChip(Color color, String label) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: colorScheme.surface.withValues(alpha: 0.34),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.primary.withValues(alpha: 0.12),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.22),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmedPalette() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        _buildPaletteChip(const Color(0xFF1F6B3C), 'Emerald Green'),
        _buildPaletteChip(const Color(0xFF8AA58B), 'Sage'),
        _buildPaletteChip(const Color(0xFFA8D5BA), 'Mint'),
        _buildPaletteChip(const Color(0xFFF4EBDD), 'Ivory'),
        _buildPaletteChip(const Color(0xFFF2D7D5), 'Blush'),
      ],
    );
  }

  Widget _buildGuideCard(RsvpSubmission submission) {
    final colorScheme = Theme.of(context).colorScheme;
    final status = _normalizeStatus(submission.confirmationStatus);
    final isConfirmed = status == 'confirmed';
    final isDeclined = status == 'declined';
    final displayName = submission.fullName.isEmpty ? 'there' : submission.fullName;
    final icon = isConfirmed
        ? Icons.verified_rounded
        : isDeclined
            ? Icons.cancel_rounded
            : Icons.hourglass_top_rounded;
    final iconColor = isConfirmed
        ? colorScheme.primary
        : isDeclined
            ? colorScheme.error
            : colorScheme.secondary;
    final title = isConfirmed
        ? 'Confirmed'
        : isDeclined
            ? 'Declined'
            : 'Awaiting Confirmation';
    final body = isConfirmed
        ? _buildConfirmedMessage(displayName)
        : isDeclined
            ? _buildDeclinedMessage(displayName)
            : _buildPendingMessage(displayName);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface.withValues(alpha: 0.28),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDeclined
              ? colorScheme.error.withValues(alpha: 0.20)
              : colorScheme.primary.withValues(alpha: 0.16),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: iconColor,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
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
            body,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.82),
                ),
          ),
          if (isConfirmed) ...[
            const SizedBox(height: 16),
            Text(
              'Attire Guide',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 10),
            _buildConfirmedPalette(),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

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
                                    'Invitation Status',
                                    style: theme.textTheme.headlineSmall?.copyWith(
                                      color: colorScheme.onSurface,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _submission == null
                                        ? 'Enter your passcode to check your response.'
                                        : 'Your response status is loaded below.',
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
                        if (_submission == null) ...[
                          TextField(
                            controller: _passcodeController,
                            maxLength: 6,
                            maxLengthEnforcement: MaxLengthEnforcement.enforced,
                            obscureText: true,
                            obscuringCharacter: '\u2022',
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(6),
                            ],
                            style: TextStyle(color: colorScheme.onSurface),
                            decoration: _fieldDecoration('Passcode').copyWith(
                              counterText: '',
                              suffixIcon: const Icon(Icons.lock_outline_rounded),
                            ),
                            onChanged: (_) {
                              if (_errorMessage != null) {
                                setState(() => _errorMessage = null);
                              }
                            },
                          ),
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
                            onPressed: _isLoading ? null : _checkStatus,
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
                            child: Text(_isLoading ? 'Checking...' : 'Check'),
                          ),
                        ] else ...[
                          _buildGuideCard(_submission!),
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
                          const SizedBox(height: 4),
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
