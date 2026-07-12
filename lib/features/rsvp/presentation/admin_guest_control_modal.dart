import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/errors/app_exceptions.dart';
import '../../../core/utils/app_snackbar.dart';
import '../data/rsvp_repository_factory.dart';
import '../domain/entities/admin_guest_record.dart';
import '../domain/entities/rsvp_dashboard_summary.dart';
import 'widgets/guest_count_picker.dart';

Future<void> showAdminGuestControlModal(BuildContext context) {
  return showGeneralDialog(
    context: context,
    barrierDismissible: false,
    barrierLabel: 'Admin Guest Controls',
    barrierColor: Colors.black.withValues(alpha: 0.34),
    transitionDuration: const Duration(milliseconds: 320),
    pageBuilder: (dialogContext, animation, secondaryAnimation) {
      return AdminGuestControlModal(hostContext: context);
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

class AdminGuestControlModal extends StatefulWidget {
  const AdminGuestControlModal({super.key, required this.hostContext});

  final BuildContext hostContext;

  @override
  State<AdminGuestControlModal> createState() => _AdminGuestControlModalState();
}

class _AdminGuestControlModalState extends State<AdminGuestControlModal> {
  final _passcodeFilterController = TextEditingController();
  final _nameFilterController = TextEditingController();

  final List<String> _statusFilters = const [
    'Any',
    'ForConfirmation',
    'Confirmed',
    'Declined',
  ];

  final List<String> _sortDirectionFilters = const ['ASC', 'DESC'];

  final List<int> _guestCountFilters = List<int>.generate(
    kGuestCountMax,
    (index) => index + 1,
  );

  String _selectedStatusFilter = 'Any';
  String _selectedSortDirection = 'ASC';
  int? _selectedGuestCountFilter;
  bool _showFilters = false;
  bool _isLoading = false;
  String? _errorMessage;
  List<AdminGuestRecord> _guests = const [];
  final Map<String, bool> _editVisibility = <String, bool>{};
  RsvpDashboardSummary? _dashboardSummary;
  bool _isSummaryLoading = false;
  String? _summaryErrorMessage;
  bool _showDashboardDetails = false;

  @override
  void initState() {
    super.initState();
    _loadGuests();
    _loadDashboardSummary();
  }

  @override
  void dispose() {
    _passcodeFilterController.dispose();
    _nameFilterController.dispose();
    super.dispose();
  }

  Future<void> _loadGuests() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final repository = createRsvpRepository();
      final guests = await repository.fetchAdminGuests(
        passcode: _passcodeFilterController.text.trim().isEmpty
            ? null
            : _passcodeFilterController.text.trim(),
        name: _nameFilterController.text.trim().isEmpty
            ? null
            : _nameFilterController.text.trim(),
        guestCount: _selectedGuestCountFilter,
        confirmationStatus: _selectedStatusFilter == 'Any'
            ? null
            : _selectedStatusFilter,
        sortDirection: _selectedSortDirection,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _guests = guests;
        for (final guest in guests) {
          _editVisibility.putIfAbsent(guest.passcode, () => false);
        }
      });
    } on AppException catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _errorMessage = error.message;
        _guests = const [];
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _errorMessage = 'We could not load the admin checklist right now.';
        _guests = const [];
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadDashboardSummary() async {
    setState(() {
      _isSummaryLoading = true;
      _summaryErrorMessage = null;
    });

    try {
      final repository = createRsvpRepository();
      final summary = await repository.fetchAdminDashboardSummary();

      if (!mounted) {
        return;
      }

      setState(() {
        _dashboardSummary = summary;
      });
    } on AppException catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _summaryErrorMessage = error.message;
        _dashboardSummary = null;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _summaryErrorMessage =
            'We could not load the dashboard summary right now.';
        _dashboardSummary = null;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSummaryLoading = false;
        });
      }
    }
  }

  void _toggleEditControls(String passcode) {
    setState(() {
      _editVisibility[passcode] = !(_editVisibility[passcode] ?? false);
    });
  }

  String _normalizeStatus(String value) {
    return value.isEmpty ? 'ForConfirmation' : value;
  }

  bool _matchesCurrentFilters(AdminGuestRecord record) {
    final passcodeFilter = _passcodeFilterController.text.trim().toLowerCase();
    final nameFilter = _nameFilterController.text.trim().toLowerCase();
    final guestCountFilter = _selectedGuestCountFilter;
    final selectedStatusFilter = _selectedStatusFilter;

    if (passcodeFilter.isNotEmpty &&
        !record.passcode.toLowerCase().contains(passcodeFilter)) {
      return false;
    }

    if (nameFilter.isNotEmpty &&
        !record.fullName.toLowerCase().contains(nameFilter)) {
      return false;
    }

    if (guestCountFilter != null && record.guestCount != guestCountFilter) {
      return false;
    }

    if (selectedStatusFilter != 'Any' &&
        _normalizeStatus(record.confirmationStatus) != selectedStatusFilter) {
      return false;
    }

    return true;
  }

  void _replaceGuestRecord(AdminGuestRecord updatedRecord) {
    setState(() {
      final index = _guests.indexWhere(
        (guest) => guest.passcode == updatedRecord.passcode,
      );
      if (index == -1) {
        return;
      }

      if (_matchesCurrentFilters(updatedRecord)) {
        _guests[index] = updatedRecord;
      } else {
        _guests.removeAt(index);
      }

      _editVisibility.putIfAbsent(updatedRecord.passcode, () => false);
    });
    _loadDashboardSummary();
  }

  void _removeGuestRecord(String passcode) {
    setState(() {
      _guests.removeWhere((guest) => guest.passcode == passcode);
      _editVisibility.remove(passcode);
    });
    _loadDashboardSummary();
  }

  Future<bool> _confirmAction({
    required String title,
    required String message,
    required String confirmLabel,
  }) async {
    final result = await showGeneralDialog<bool>(
      context: context,
      barrierDismissible: false,
      barrierLabel: title,
      barrierColor: Colors.black.withValues(alpha: 0.34),
      transitionDuration: const Duration(milliseconds: 220),
      pageBuilder: (_, __, ___) {
        final theme = Theme.of(context);
        final colorScheme = theme.colorScheme;
        return Material(
          color: Colors.transparent,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(26),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                    child: Container(
                      decoration: BoxDecoration(
                        color: colorScheme.surface.withValues(alpha: 0.96),
                        borderRadius: BorderRadius.circular(26),
                        border: Border.all(
                          color: colorScheme.primary.withValues(alpha: 0.18),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              title,
                              style: theme.textTheme.titleLarge?.copyWith(
                                color: colorScheme.onSurface,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              message,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSurface.withValues(
                                  alpha: 0.82,
                                ),
                              ),
                            ),
                            const SizedBox(height: 18),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () => Navigator.of(
                                      context,
                                      rootNavigator: true,
                                    ).pop(false),
                                    child: const Text('No'),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: FilledButton(
                                    onPressed: () => Navigator.of(
                                      context,
                                      rootNavigator: true,
                                    ).pop(true),
                                    child: Text(confirmLabel),
                                  ),
                                ),
                              ],
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
        );
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
    return result ?? false;
  }

  String _formatDate(String value) {
    final parsed = DateTime.tryParse(value);
    if (parsed == null) {
      return value;
    }
    final local = parsed.toLocal();
    final hour = local.hour % 12 == 0 ? 12 : local.hour % 12;
    final amPm = local.hour >= 12 ? 'pm' : 'am';
    return '${local.year.toString().padLeft(4, '0')}-'
        '${local.month.toString().padLeft(2, '0')}-'
        '${local.day.toString().padLeft(2, '0')} | '
        '${hour.toString().padLeft(2, '0')}:'
        '${local.minute.toString().padLeft(2, '0')} $amPm';
  }

  Future<void> _updateGuestCount(AdminGuestRecord record, int newCount) async {
    if (newCount == record.guestCount) {
      return;
    }

    final confirmed = await _confirmAction(
      title: 'Update Guest Count',
      message:
          'Are you sure you want to update ${record.fullName.isEmpty ? 'this guest' : record.fullName} to $newCount guest(s)?',
      confirmLabel: 'Yes, update',
    );
    if (!confirmed) {
      return;
    }

    try {
      final repository = createRsvpRepository();
      final message = await repository.updateAdminGuestCount(
        passcode: record.passcode,
        guestCount: newCount,
      );
      if (!mounted) {
        return;
      }
      AppSnackBar.show(
        widget.hostContext,
        message.isEmpty
            ? '${record.fullName.isEmpty ? 'Guest' : record.fullName} guest count has been updated.'
            : message,
      );
      _replaceGuestRecord(
        AdminGuestRecord(
          id: record.id,
          passcode: record.passcode,
          fullName: record.fullName,
          guestCount: newCount,
          confirmationStatus: record.confirmationStatus,
          datetimeSentIso8601: record.datetimeSentIso8601,
          datetimeUpdatedByAdminIso8601: DateTime.now()
              .toUtc()
              .toIso8601String(),
        ),
      );
    } on AppException catch (error) {
      if (!mounted) {
        return;
      }
      AppSnackBar.show(widget.hostContext, error.message);
    } catch (_) {
      if (!mounted) {
        return;
      }
      AppSnackBar.show(
        widget.hostContext,
        'Something went wrong while updating the guest count.',
      );
    }
  }

  Future<void> _updateStatus(AdminGuestRecord record, String newStatus) async {
    if (newStatus == record.confirmationStatus) {
      return;
    }

    final confirmed = await _confirmAction(
      title: 'Update Status',
      message:
          'Are you sure you want to update ${record.fullName.isEmpty ? 'this guest' : record.fullName} to $newStatus?',
      confirmLabel: 'Yes, update',
    );
    if (!confirmed) {
      return;
    }

    try {
      final repository = createRsvpRepository();
      final message = await repository.updateAdminConfirmationStatus(
        passcode: record.passcode,
        confirmationStatus: newStatus,
      );
      if (!mounted) {
        return;
      }
      AppSnackBar.show(
        widget.hostContext,
        message.isEmpty
            ? '${record.fullName.isEmpty ? 'Guest' : record.fullName} status has been updated.'
            : message,
      );
      _replaceGuestRecord(
        AdminGuestRecord(
          id: record.id,
          passcode: record.passcode,
          fullName: record.fullName,
          guestCount: record.guestCount,
          confirmationStatus: newStatus,
          datetimeSentIso8601: record.datetimeSentIso8601,
          datetimeUpdatedByAdminIso8601: DateTime.now()
              .toUtc()
              .toIso8601String(),
        ),
      );
    } on AppException catch (error) {
      if (!mounted) {
        return;
      }
      AppSnackBar.show(widget.hostContext, error.message);
    } catch (_) {
      if (!mounted) {
        return;
      }
      AppSnackBar.show(
        widget.hostContext,
        'Something went wrong while updating the status.',
      );
    }
  }

  Future<void> _deleteGuest(AdminGuestRecord record) async {
    final confirmed = await _confirmAction(
      title: 'Delete Guest',
      message:
          'Are you sure you want to delete ${record.fullName.isEmpty ? 'this guest' : record.fullName}?',
      confirmLabel: 'Yes, delete',
    );
    if (!confirmed) {
      return;
    }

    try {
      final repository = createRsvpRepository();
      final message = await repository.deleteAdminGuests([record.passcode]);
      if (!mounted) {
        return;
      }
      AppSnackBar.show(
        widget.hostContext,
        message.isEmpty
            ? '${record.fullName.isEmpty ? 'Guest' : record.fullName} has been deleted.'
            : message,
      );
      _removeGuestRecord(record.passcode);
    } on AppException catch (error) {
      if (!mounted) {
        return;
      }
      AppSnackBar.show(widget.hostContext, error.message);
    } catch (_) {
      if (!mounted) {
        return;
      }
      AppSnackBar.show(
        widget.hostContext,
        'Something went wrong while deleting the guest.',
      );
    }
  }

  InputDecoration _filterDecoration(String hintText) {
    final colorScheme = Theme.of(context).colorScheme;
    return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(
        color: colorScheme.onSurface.withValues(alpha: 0.46),
      ),
      filled: true,
      fillColor: colorScheme.surface.withValues(alpha: 0.30),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: colorScheme.primary.withValues(alpha: 0.14),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: colorScheme.primary.withValues(alpha: 0.14),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: colorScheme.primary, width: 1.4),
      ),
    );
  }

  Color _dropdownSurfaceColor() {
    final colorScheme = Theme.of(context).colorScheme;
    return Color.alphaBlend(
      Colors.white.withValues(alpha: 0.04),
      colorScheme.surface,
    );
  }

  Color _dropdownMenuColor() {
    final colorScheme = Theme.of(context).colorScheme;
    return Color.alphaBlend(
      Colors.white.withValues(alpha: 0.08),
      colorScheme.surface,
    );
  }

  InputDecoration _dropdownDecoration(String hintText) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(
        color: colorScheme.onSurface.withValues(alpha: 0.62),
      ),
      filled: true,
      fillColor: _dropdownSurfaceColor(),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      isDense: true,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(
          color: colorScheme.primary.withValues(alpha: 0.18),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(
          color: colorScheme.primary.withValues(alpha: 0.18),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
      ),
    );
  }

  List<Widget> _selectedTextDropdownItems(Iterable<String> labels) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return labels
        .map(
          (label) => Align(
            alignment: Alignment.centerLeft,
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        )
        .toList(growable: false);
  }

  List<Widget> _selectedCountDropdownItems(int count) {
    return _selectedTextDropdownItems(
      List<String>.generate(count, (index) => '${index + 1}'),
    );
  }

  Widget _buildFilterField({
    required String label,
    required TextEditingController controller,
    required String hintText,
    TextInputType keyboardType = TextInputType.text,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: colorScheme.onSurface.withValues(alpha: 0.84),
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: keyboardType == TextInputType.number
              ? [FilteringTextInputFormatter.digitsOnly]
              : null,
          style: TextStyle(color: colorScheme.onSurface),
          decoration: _filterDecoration(hintText),
        ),
      ],
    );
  }

  Widget _buildDashboardSummarySection() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final summary = _dashboardSummary;
    final hasSummary = summary != null;
    final confirmedGuests = summary?.confirmedGuests;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.primary.withValues(alpha: 0.10),
            colorScheme.surface.withValues(alpha: 0.38),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: colorScheme.primary.withValues(alpha: 0.16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final isCompact = constraints.maxWidth < 640;
              final titleBlock = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Confirmed guests',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.78),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  if (_isSummaryLoading)
                    SizedBox(
                      height: 28,
                      width: 28,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.4,
                        color: colorScheme.primary,
                      ),
                    )
                  else if (confirmedGuests != null)
                    Text(
                      confirmedGuests.toString(),
                      style: theme.textTheme.displaySmall?.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.w800,
                      ),
                    )
                  else
                    Text(
                      '--',
                      style: theme.textTheme.displaySmall?.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.58),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  const SizedBox(height: 4),
                  Text(
                    _isSummaryLoading
                        ? 'Loading dashboard summary...'
                        : 'Tap see all data for the full dashboard breakdown.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.72),
                    ),
                  ),
                ],
              );

              final actionButton = TextButton.icon(
                onPressed: hasSummary && !_isSummaryLoading
                    ? () {
                        setState(() {
                          _showDashboardDetails = !_showDashboardDetails;
                        });
                      }
                    : null,
                icon: Icon(
                  _showDashboardDetails
                      ? Icons.expand_less_rounded
                      : Icons.visibility_rounded,
                ),
                label: Text(
                  _showDashboardDetails ? 'Show less' : 'See all data',
                ),
              );

              if (isCompact) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    titleBlock,
                    const SizedBox(height: 12),
                    Align(alignment: Alignment.centerLeft, child: actionButton),
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(child: titleBlock),
                  const SizedBox(width: 12),
                  actionButton,
                ],
              );
            },
          ),
          if (_summaryErrorMessage != null) ...[
            const SizedBox(height: 10),
            Text(
              _summaryErrorMessage!,
              style: theme.textTheme.labelMedium?.copyWith(
                color: colorScheme.error,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: summary == null
                ? const SizedBox.shrink()
                : Padding(
                    padding: const EdgeInsets.only(top: 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildDashboardGroupCard(
                          title: 'Invitations',
                          items: [
                            ('Total', summary.totalInvitations),
                            ('Confirmed', summary.confirmedInvitations),
                            ('Declined', summary.declinedInvitations),
                            ('Pending', summary.forConfirmationInvitations),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _buildDashboardGroupCard(
                          title: 'Guests',
                          items: [
                            ('Total', summary.totalGuests),
                            ('Confirmed', summary.confirmedGuests),
                            ('Declined', summary.declinedGuests),
                            ('Pending', summary.forConfirmationGuests),
                          ],
                        ),
                      ],
                    ),
                  ),
            crossFadeState: _showDashboardDetails && hasSummary
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 220),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardGroupCard({
    required String title,
    required List<(String, int)> items,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final groupCompact = MediaQuery.sizeOf(context).width < 640;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorScheme.surface.withValues(alpha: 0.30),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colorScheme.primary.withValues(alpha: 0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 10),
          if (groupCompact)
            Column(
              children: items
                  .map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _buildDashboardMetricRow(
                        label: item.$1,
                        value: item.$2,
                      ),
                    ),
                  )
                  .toList(growable: false),
            )
          else
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: items
                  .map(
                    (item) => _buildDashboardMetricPill(
                      label: item.$1,
                      value: item.$2,
                    ),
                  )
                  .toList(growable: false),
            ),
        ],
      ),
    );
  }

  Widget _buildDashboardMetricRow({required String label, required int value}) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: colorScheme.surface.withValues(alpha: 0.36),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.primary.withValues(alpha: 0.12)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelMedium?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.72),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            value.toString(),
            style: theme.textTheme.titleLarge?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardMetricPill({
    required String label,
    required int value,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Container(
      constraints: const BoxConstraints(minWidth: 96),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: colorScheme.surface.withValues(alpha: 0.36),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.primary.withValues(alpha: 0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.72),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value.toString(),
            style: theme.textTheme.titleLarge?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGuestCard(AdminGuestRecord record) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final mediaWidth = MediaQuery.sizeOf(context).width;
    final isCompact = mediaWidth < 760;
    final status = record.confirmationStatus.isEmpty
        ? 'ForConfirmation'
        : record.confirmationStatus;
    final showEditControls = _editVisibility[record.passcode] ?? false;

    Widget labeledDropdown({required String label, required Widget child}) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [_buildControlLabel(label), const SizedBox(height: 8), child],
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface.withValues(alpha: 0.26),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: colorScheme.primary.withValues(alpha: 0.16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      record.fullName.isEmpty ? 'Guest' : record.fullName,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      record.passcode,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.74),
                      ),
                    ),
                  ],
                ),
              ),
              Tooltip(
                message: 'Delete guest',
                child: IconButton(
                  onPressed: () => _deleteGuest(record),
                  icon: Icon(
                    Icons.delete_outline_rounded,
                    color: colorScheme.error,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _buildInfoChip('Guest Count', record.guestCount.toString()),
              _buildInfoChip('Status', status),
              if (record.datetimeSentIso8601.isNotEmpty)
                _buildInfoChip('Sent', _formatDate(record.datetimeSentIso8601)),
              if (record.datetimeUpdatedByAdminIso8601.isNotEmpty)
                _buildInfoChip(
                  'Updated',
                  _formatDate(record.datetimeUpdatedByAdminIso8601),
                ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              TextButton.icon(
                onPressed: () => _toggleEditControls(record.passcode),
                icon: Icon(
                  showEditControls
                      ? Icons.expand_less_rounded
                      : Icons.edit_rounded,
                ),
                label: Text(showEditControls ? 'Hide edit' : 'Edit'),
              ),
              const Spacer(),
              if (showEditControls)
                Text(
                  'Editing ${record.fullName.isEmpty ? 'guest' : record.fullName}',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.74),
                    fontWeight: FontWeight.w700,
                  ),
                ),
            ],
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: const EdgeInsets.only(top: 12),
              child: isCompact
                  ? Column(
                      children: [
                        labeledDropdown(
                          label: 'Guest Count',
                          child: DropdownButtonFormField<int>(
                            initialValue: record.guestCount.clamp(1, kGuestCountMax).toInt(),
                            decoration: _dropdownDecoration(
                              'Select guest count',
                            ),

                            dropdownColor: colorScheme.surface.withValues(
                              alpha: 0.98,
                            ),

                            borderRadius: BorderRadius.circular(18),

                            icon: Icon(
                              Icons.keyboard_arrow_down_rounded,

                              color: colorScheme.primary,
                            ),

                            iconEnabledColor: colorScheme.primary,

                            iconDisabledColor: colorScheme.onSurface.withValues(
                              alpha: 0.38,
                            ),

                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurface,

                              fontWeight: FontWeight.w700,
                            ),

                            menuMaxHeight: 280,
                            selectedItemBuilder: (context) =>
                                _selectedCountDropdownItems(kGuestCountMax),
                            items: List<DropdownMenuItem<int>>.generate(
                              kGuestCountMax,
                              (index) => DropdownMenuItem<int>(
                                value: index + 1,
                                child: Text('${index + 1}'),
                              ),
                            ),
                            onChanged: (value) {
                              if (value == null) {
                                return;
                              }
                              _updateGuestCount(record, value);
                            },
                          ),
                        ),
                        const SizedBox(height: 12),
                        labeledDropdown(
                          label: 'Confirmation Status',
                          child: DropdownButtonFormField<String>(
                            initialValue: status,
                            decoration: _dropdownDecoration(
                              'Select confirmation status',
                            ),

                            dropdownColor: colorScheme.surface.withValues(
                              alpha: 0.98,
                            ),

                            borderRadius: BorderRadius.circular(18),

                            icon: Icon(
                              Icons.keyboard_arrow_down_rounded,

                              color: colorScheme.primary,
                            ),

                            iconEnabledColor: colorScheme.primary,

                            iconDisabledColor: colorScheme.onSurface.withValues(
                              alpha: 0.38,
                            ),

                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurface,

                              fontWeight: FontWeight.w700,
                            ),

                            menuMaxHeight: 280,
                            selectedItemBuilder: (context) =>
                                _selectedTextDropdownItems(const [
                                  'ForConfirmation',
                                  'Confirmed',
                                  'Declined',
                                ]),
                            items: const [
                              DropdownMenuItem(
                                value: 'ForConfirmation',
                                child: Text('ForConfirmation'),
                              ),
                              DropdownMenuItem(
                                value: 'Confirmed',
                                child: Text('Confirmed'),
                              ),
                              DropdownMenuItem(
                                value: 'Declined',
                                child: Text('Declined'),
                              ),
                            ],
                            onChanged: (value) {
                              if (value == null) {
                                return;
                              }
                              _updateStatus(record, value);
                            },
                          ),
                        ),
                      ],
                    )
                  : Row(
                      children: [
                        Expanded(
                          child: labeledDropdown(
                            label: 'Guest Count',
                            child: DropdownButtonFormField<int>(
                              initialValue: record.guestCount
                                  .clamp(1, kGuestCountMax)
                                  .toInt(),
                              decoration: _dropdownDecoration(
                                'Select guest count',
                              ),

                              dropdownColor: colorScheme.surface.withValues(
                                alpha: 0.98,
                              ),

                              borderRadius: BorderRadius.circular(18),

                              icon: Icon(
                                Icons.keyboard_arrow_down_rounded,

                                color: colorScheme.primary,
                              ),

                              iconEnabledColor: colorScheme.primary,

                              iconDisabledColor: colorScheme.onSurface
                                  .withValues(alpha: 0.38),

                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSurface,

                                fontWeight: FontWeight.w700,
                              ),

                              menuMaxHeight: 280,
                              selectedItemBuilder: (context) =>
                                  _selectedCountDropdownItems(kGuestCountMax),
                              items: List<DropdownMenuItem<int>>.generate(
                                kGuestCountMax,
                                (index) => DropdownMenuItem<int>(
                                  value: index + 1,
                                  child: Text('${index + 1}'),
                                ),
                              ),
                              onChanged: (value) {
                                if (value == null) {
                                  return;
                                }
                                _updateGuestCount(record, value);
                              },
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: labeledDropdown(
                            label: 'Confirmation Status',
                            child: DropdownButtonFormField<String>(
                              initialValue: status,
                              decoration: _dropdownDecoration(
                                'Select confirmation status',
                              ),

                              dropdownColor: colorScheme.surface.withValues(
                                alpha: 0.98,
                              ),

                              borderRadius: BorderRadius.circular(18),

                              icon: Icon(
                                Icons.keyboard_arrow_down_rounded,

                                color: colorScheme.primary,
                              ),

                              iconEnabledColor: colorScheme.primary,

                              iconDisabledColor: colorScheme.onSurface
                                  .withValues(alpha: 0.38),

                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSurface,

                                fontWeight: FontWeight.w700,
                              ),

                              menuMaxHeight: 280,
                              selectedItemBuilder: (context) =>
                                  _selectedTextDropdownItems(const [
                                    'ForConfirmation',
                                    'Confirmed',
                                    'Declined',
                                  ]),
                              items: const [
                                DropdownMenuItem(
                                  value: 'ForConfirmation',
                                  child: Text('ForConfirmation'),
                                ),
                                DropdownMenuItem(
                                  value: 'Confirmed',
                                  child: Text('Confirmed'),
                                ),
                                DropdownMenuItem(
                                  value: 'Declined',
                                  child: Text('Declined'),
                                ),
                              ],
                              onChanged: (value) {
                                if (value == null) {
                                  return;
                                }
                                _updateStatus(record, value);
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
            crossFadeState: showEditControls
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 220),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(String label, String value) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: colorScheme.surface.withValues(alpha: 0.34),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colorScheme.primary.withValues(alpha: 0.12)),
      ),
      child: Text(
        '$label: $value',
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: colorScheme.onSurface,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildControlLabel(String label) {
    final colorScheme = Theme.of(context).colorScheme;
    return Text(
      label,
      style: Theme.of(context).textTheme.labelLarge?.copyWith(
        color: colorScheme.onSurface.withValues(alpha: 0.84),
        fontWeight: FontWeight.w700,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final mediaSize = MediaQuery.sizeOf(context);
    final isMobile = mediaSize.width < 700;
    final modalMaxWidth = mediaSize.width < 980
        ? mediaSize.width * 0.96
        : 980.0;
    final modalMaxHeight = mediaSize.height * 0.92;

    Widget buildHeader({required EdgeInsets padding}) {
      return Padding(
        padding: padding,
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Admin Guest Controls',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Search, update, or remove guests. Every action asks for confirmation first.',
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
      );
    }

    Widget buildScrollContent({required bool includeSummaryAtTop}) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (includeSummaryAtTop) ...[
            _buildDashboardSummarySection(),
            const SizedBox(height: 12),
          ],
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: () {
                setState(() {
                  _showFilters = !_showFilters;
                });
              },
              icon: Icon(
                _showFilters ? Icons.expand_less_rounded : Icons.tune_rounded,
              ),
              label: Text(_showFilters ? 'Hide filters' : 'Show filters'),
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: const EdgeInsets.only(top: 14),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildFilterField(
                    label: 'Passcode',
                    controller: _passcodeFilterController,
                    hintText: 'Filter passcode',
                  ),
                  const SizedBox(height: 12),
                  _buildFilterField(
                    label: 'Name',
                    controller: _nameFilterController,
                    hintText: 'Filter name',
                  ),
                  const SizedBox(height: 12),
                  _buildControlLabel('Guest Count'),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<int?>(
                    initialValue: _selectedGuestCountFilter,
                    decoration: _dropdownDecoration('Select guest count'),

                    dropdownColor: _dropdownMenuColor(),

                    borderRadius: BorderRadius.circular(18),

                    icon: Icon(
                      Icons.keyboard_arrow_down_rounded,

                      color: colorScheme.primary,
                    ),

                    iconEnabledColor: colorScheme.primary,

                    iconDisabledColor: colorScheme.onSurface.withValues(
                      alpha: 0.38,
                    ),

                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface,

                      fontWeight: FontWeight.w700,
                    ),

                    menuMaxHeight: 280,
                    selectedItemBuilder: (context) =>
                        _selectedTextDropdownItems([
                          'Any',
                          ..._guestCountFilters.map((count) => '$count'),
                        ]),
                    items: [
                      const DropdownMenuItem<int?>(
                        value: null,
                        child: Text('Any'),
                      ),
                      ..._guestCountFilters.map(
                        (count) => DropdownMenuItem<int?>(
                          value: count,
                          child: Text('$count'),
                        ),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedGuestCountFilter = value;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildControlLabel('Confirmation Status'),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedStatusFilter,
                    decoration: _dropdownDecoration(
                      'Select confirmation status',
                    ),

                    dropdownColor: _dropdownMenuColor(),

                    borderRadius: BorderRadius.circular(18),

                    icon: Icon(
                      Icons.keyboard_arrow_down_rounded,

                      color: colorScheme.primary,
                    ),

                    iconEnabledColor: colorScheme.primary,

                    iconDisabledColor: colorScheme.onSurface.withValues(
                      alpha: 0.38,
                    ),

                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface,

                      fontWeight: FontWeight.w700,
                    ),

                    menuMaxHeight: 280,
                    selectedItemBuilder: (context) =>
                        _selectedTextDropdownItems(_statusFilters),
                    items: _statusFilters
                        .map(
                          (status) => DropdownMenuItem<String>(
                            value: status,
                            child: Text(status),
                          ),
                        )
                        .toList(growable: false),
                    onChanged: (value) {
                      if (value == null) {
                        return;
                      }
                      setState(() {
                        _selectedStatusFilter = value;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildControlLabel('Sort Order'),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedSortDirection,
                    decoration: _dropdownDecoration('Select sort order'),

                    dropdownColor: _dropdownMenuColor(),

                    borderRadius: BorderRadius.circular(18),

                    icon: Icon(
                      Icons.keyboard_arrow_down_rounded,

                      color: colorScheme.primary,
                    ),

                    iconEnabledColor: colorScheme.primary,

                    iconDisabledColor: colorScheme.onSurface.withValues(
                      alpha: 0.38,
                    ),

                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface,

                      fontWeight: FontWeight.w700,
                    ),

                    menuMaxHeight: 280,
                    selectedItemBuilder: (context) =>
                        _selectedTextDropdownItems(_sortDirectionFilters),
                    items: _sortDirectionFilters
                        .map(
                          (direction) => DropdownMenuItem<String>(
                            value: direction,
                            child: Text(direction),
                          ),
                        )
                        .toList(growable: false),
                    onChanged: (value) {
                      if (value == null) {
                        return;
                      }
                      setState(() {
                        _selectedSortDirection = value;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: _isLoading ? null : _loadGuests,
                          icon: const Icon(Icons.search_rounded),
                          label: const Text('Apply Filters'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _isLoading
                              ? null
                              : () {
                                  setState(() {
                                    _passcodeFilterController.clear();
                                    _nameFilterController.clear();
                                    _selectedStatusFilter = 'Any';
                                    _selectedGuestCountFilter = null;
                                  });
                                  _loadGuests();
                                },
                          icon: const Icon(Icons.refresh_rounded),
                          label: const Text('Reset'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            crossFadeState: _showFilters
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 220),
          ),
          const SizedBox(height: 12),
          if (_showFilters)
            Divider(
              height: 1,
              thickness: 1,
              color: colorScheme.primary.withValues(alpha: 0.14),
            ),
          if (_showFilters) const SizedBox(height: 16),
          if (_errorMessage != null) ...[
            Text(
              _errorMessage!,
              style: theme.textTheme.labelLarge?.copyWith(
                color: colorScheme.error,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
          ],
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_guests.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Text(
                'No guest records found.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.72),
                ),
              ),
            )
          else
            ListView.separated(
              itemCount: _guests.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                return _buildGuestCard(_guests[index]);
              },
            ),
        ],
      );
    }

    if (isMobile) {
      return Material(
        color: Colors.transparent,
        child: SizedBox.expand(
          child: Container(
            decoration: BoxDecoration(
              color: colorScheme.surface.withValues(alpha: 0.98),
            ),
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  buildHeader(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                  ),
                  Divider(
                    height: 1,
                    thickness: 1,
                    color: colorScheme.primary.withValues(alpha: 0.14),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
                      child: buildScrollContent(includeSummaryAtTop: true),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Material(
      color: Colors.transparent,
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: modalMaxWidth,
            maxHeight: modalMaxHeight,
          ),
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      buildHeader(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 14),
                      ),
                      Divider(
                        height: 1,
                        thickness: 1,
                        color: colorScheme.primary.withValues(alpha: 0.14),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
                        child: _buildDashboardSummarySection(),
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(20),
                          child: buildScrollContent(includeSummaryAtTop: false),
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
    );
  }
}
