import 'package:flutter/material.dart';

const int kGuestCountMax = 100;

Future<int?> showGuestCountMenu({
  required BuildContext context,
  required GlobalKey anchorKey,
  required int initialValue,
}) {
  final initialCount = initialValue.clamp(1, kGuestCountMax).toInt();

  return showModalBottomSheet<int>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.38),
    builder: (sheetContext) {
      return _GuestCountSheet(initialValue: initialCount);
    },
  );
}

class _GuestCountSheet extends StatefulWidget {
  const _GuestCountSheet({required this.initialValue});

  final int initialValue;

  @override
  State<_GuestCountSheet> createState() => _GuestCountSheetState();
}

class _GuestCountSheetState extends State<_GuestCountSheet> {
  late final FixedExtentScrollController _scrollController;
  late int _selectedValue;

  @override
  void initState() {
    super.initState();
    _selectedValue = widget.initialValue;
    _scrollController = FixedExtentScrollController(
      initialItem: widget.initialValue - 1,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final mediaSize = MediaQuery.sizeOf(context);
    final sheetHeight = mediaSize.height * 0.52;

    return Material(
      color: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          border: Border.all(
            color: colorScheme.primary.withValues(alpha: 0.12),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.18),
              blurRadius: 28,
              offset: const Offset(0, -10),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: sheetHeight,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 42,
                      height: 4,
                      decoration: BoxDecoration(
                        color: colorScheme.onSurface.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Guest count',
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: colorScheme.onSurface,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close_rounded),
                        tooltip: 'Close',
                      ),
                    ],
                  ),
                  Text(
                    'Scroll to choose a value from 1 to $kGuestCountMax.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.72),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(
                          child: ListWheelScrollView.useDelegate(
                            controller: _scrollController,
                            physics: const FixedExtentScrollPhysics(),
                            itemExtent: 52,
                            perspective: 0.006,
                            diameterRatio: 1.5,
                            useMagnifier: true,
                            magnification: 1.08,
                            squeeze: 1.05,
                            onSelectedItemChanged: (index) {
                              setState(() {
                                _selectedValue = index + 1;
                              });
                            },
                            childDelegate: ListWheelChildBuilderDelegate(
                              childCount: kGuestCountMax,
                              builder: (context, index) {
                                if (index < 0 || index >= kGuestCountMax) {
                                  return null;
                                }
                                final value = index + 1;
                                final selected = value == _selectedValue;
                                return Center(
                                  child: AnimatedDefaultTextStyle(
                                    duration: const Duration(milliseconds: 120),
                                    style: theme.textTheme.headlineMedium!.copyWith(
                                      color: selected
                                          ? colorScheme.primary
                                          : colorScheme.onSurface.withValues(
                                              alpha: 0.48,
                                            ),
                                      fontWeight: selected
                                          ? FontWeight.w800
                                          : FontWeight.w600,
                                    ),
                                    child: Text('$value'),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        const SizedBox(width: 20),
                        SizedBox(
                          width: 84,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: colorScheme.primary.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: colorScheme.primary.withValues(alpha: 0.16),
                              ),
                            ),
                            child: Center(
                              child: Text(
                                '$_selectedValue',
                                style: theme.textTheme.displaySmall?.copyWith(
                                  color: colorScheme.primary,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton(
                          onPressed: () => Navigator.of(context).pop(_selectedValue),
                          child: const Text('Done'),
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
    );
  }
}
